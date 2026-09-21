#!/usr/bin/env python3
"""Bootstrap Geyser plugins from mounted files, URLs, or private GitHub releases."""

import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile
from urllib.error import HTTPError
from urllib.parse import quote, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener

PLUGIN = "libyellowstone_grpc_geyser.so"
MAX_METADATA_BYTES = 2 * 1024 * 1024


class DownloadError(Exception):
    pass


class SafeRedirectHandler(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if urlsplit(newurl).scheme not in ("http", "https") or (
            urlsplit(req.full_url).scheme == "https" and urlsplit(newurl).scheme != "https"
        ):
            raise DownloadError("Refusing an unsafe download redirect")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def read_small(response):
    body = response.read(MAX_METADATA_BYTES + 1)
    if len(body) > MAX_METADATA_BYTES:
        raise DownloadError("GitHub metadata exceeds the size limit")
    return body


def release_asset(release, name):
    matches = [asset for asset in release["assets"] if asset["name"] == name]
    if len(matches) != 1 or type(matches[0]["id"]) is not int or matches[0]["id"] <= 0:
        raise DownloadError("Required release asset is missing or ambiguous")
    return matches[0]


def checksum_for_plugin(body):
    hashes = []
    for line in body.decode("utf-8").splitlines():
        match = re.fullmatch(r"([a-fA-F0-9]{64}) [ *](.+)", line)
        if match and match[2] in (PLUGIN, "./" + PLUGIN):
            hashes.append(match[1].lower())
    if len(hashes) != 1:
        raise DownloadError("SHA256SUMS must contain exactly one plugin checksum")
    return hashes[0]


def sha256(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as source:
        while chunk := source.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def validate_checksum(value):
    if value and not re.fullmatch(r"[a-fA-F0-9]{64}", value):
        raise DownloadError("sha256 must be a 64-character hexadecimal digest")
    return value.lower()


def cached(destination, expected):
    return bool(expected and destination.is_file() and sha256(destination) == expected)


def install(source, destination, expected="", expected_size=None):
    """Validate a complete temporary file before replacing the installed library."""
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=destination.parent, prefix=".plugin-", delete=False) as output:
            temporary = Path(output.name)
            digest = hashlib.sha256()
            size = 0
            while chunk := source.read(1024 * 1024):
                size += len(chunk)
                if expected_size is not None and size > expected_size:
                    raise DownloadError("Plugin exceeds its release asset size")
                digest.update(chunk)
                output.write(chunk)
            if not size or (expected_size is not None and size != expected_size):
                raise DownloadError("Plugin is empty or truncated")
            if expected and digest.hexdigest() != expected:
                raise DownloadError("Plugin SHA256 verification failed")
        temporary.chmod(0o644)
        temporary.replace(destination)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def download_github(repository, tag, token, destination, pinned_checksum=""):
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise DownloadError("GitHub repository must be owner/repository")
    if not tag or not token:
        raise DownloadError("GitHub release tag and token are required")
    api = "https://api.github.com/repos/" + repository
    opener = build_opener(SafeRedirectHandler())

    def request(path, accept):
        req = Request(api + path, headers={
            "Accept": accept,
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "dysnix-agave-chart",
        })
        # urllib never copies unredirected headers to the signed asset URL.
        req.add_unredirected_header("Authorization", "Bearer " + token)
        return opener.open(req, timeout=60)

    with request("/releases/tags/" + quote(tag, safe=""), "application/vnd.github+json") as response:
        release = json.loads(read_small(response))
    if release.get("draft") is not False or release.get("tag_name") != tag:
        raise DownloadError("Expected a published release matching the pinned tag")
    plugin = release_asset(release, PLUGIN)
    checksums = release_asset(release, "SHA256SUMS")
    if type(plugin["size"]) is not int or plugin["size"] <= 0:
        raise DownloadError("Invalid plugin asset size")
    with request("/releases/assets/" + str(checksums["id"]), "application/octet-stream") as response:
        expected = checksum_for_plugin(read_small(response))
    if pinned_checksum and pinned_checksum != expected:
        raise DownloadError("Release checksum differs from the pinned sha256")
    if cached(destination, expected):
        return
    with request("/releases/assets/" + str(plugin["id"]), "application/octet-stream") as response:
        install(response, destination, expected, plugin["size"])


def bootstrap(url, environ):
    name, prefix, filename = "yellowstone-grpc", "YELLOWSTONE_GRPC__", PLUGIN
    plugin_dir = Path(environ["PLUGINS_DIR"]) / name
    destination = plugin_dir / "lib" / filename
    expected = validate_checksum(environ.get(prefix + "SHA256", ""))
    local_file = environ.get(prefix + "LOCAL_FILE", "")
    # Local sources have a content-derived checksum even without an explicit pin.
    if local_file and not expected:
        expected = sha256(local_file)
    if not cached(destination, expected):
        if local_file:
            with Path(local_file).open("rb") as source:
                install(source, destination, expected)
        elif environ.get(prefix + "GITHUB_REPOSITORY"):
            download_github(
                environ[prefix + "GITHUB_REPOSITORY"], environ[prefix + "VERSION"],
                environ[prefix + "GITHUB_TOKEN"], destination, expected,
            )
        else:
            parsed = urlsplit(url)
            if parsed.scheme not in ("http", "https") or not parsed.hostname or parsed.username or parsed.password:
                raise DownloadError("Plugin URL must be HTTP(S) without embedded credentials")
            with build_opener(SafeRedirectHandler()).open(url, timeout=60) as source:
                install(source, destination, expected)

    # Refresh configuration even when the library was already cached.
    config = Path(environ[prefix + "CONFIG_PATH"]).read_text().replace(
        "LISTEN_IP", environ[prefix + "LISTEN_IP"],
    )
    json.loads(config)
    config_path = plugin_dir / "config.json"
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=plugin_dir, prefix=".config-", mode="w", delete=False) as output:
            temporary = Path(output.name)
            output.write(config)
        temporary.chmod(0o644)
        temporary.replace(config_path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(name + ": plugin and configuration ready")


def main():
    try:
        env = os.environ
        if env.get("YELLOWSTONE_GRPC__ENABLED") == "1":
            url = env["YELLOWSTONE_GRPC__DOWNLOAD_URL"].rstrip("/") + "/" + quote(env["YELLOWSTONE_GRPC__VERSION"], safe="") + "/" + PLUGIN
            bootstrap(url, env)
    except HTTPError as error:
        print(f"Plugin download failed (HTTP {error.code})", file=sys.stderr)
        return 1
    except DownloadError as error:
        print(str(error), file=sys.stderr)
        return 1
    except Exception:
        # Transport exceptions may contain signed URLs. Never log their payloads.
        print("Plugin bootstrap failed: check configuration, source files and connectivity", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
