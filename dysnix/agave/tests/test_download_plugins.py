import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.request import Request

spec = importlib.util.spec_from_file_location('download', Path(__file__).parents[1] / 'files/download-plugins.py')
download = importlib.util.module_from_spec(spec)
spec.loader.exec_module(download)
DATA = b'plugin binary'
DIGEST = hashlib.sha256(DATA).hexdigest()


class Downloads(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.target = self.root / 'yellowstone-grpc/lib' / download.PLUGIN
        self.config = self.root / 'source.json'
        self.config.write_text('{"address": "LISTEN_IP:10000"}')
        self.env = {'PLUGINS_DIR': str(self.root), 'YELLOWSTONE_GRPC__CONFIG_PATH': str(self.config),
                    'YELLOWSTONE_GRPC__LISTEN_IP': '127.0.0.1'}

    def test_atomic_failure_preserves_existing_and_cleans_temporary(self):
        self.target.parent.mkdir(parents=True)
        self.target.write_bytes(b'old')
        for data, digest, size in [(DATA, '0' * 64, None), (DATA, DIGEST, 99), (DATA, DIGEST, 1), (b'', '', None)]:
            with self.subTest(size=size), self.assertRaises(download.DownloadError):
                download.install(io.BytesIO(data), self.target, digest, size)
            self.assertEqual(self.target.read_bytes(), b'old')
            self.assertEqual(list(self.target.parent.glob('.plugin-*')), [])

    def test_local_copy_cache_and_config_refresh(self):
        source = self.root / 'local.so'
        source.write_bytes(DATA)
        self.env['YELLOWSTONE_GRPC__LOCAL_FILE'] = str(source)
        self.env['YELLOWSTONE_GRPC__GITHUB_REPOSITORY'] = 'dysnix/private'
        with patch.object(download, 'build_opener', side_effect=AssertionError('network')):
            download.bootstrap('unused', self.env)
            with patch.object(download, 'install', side_effect=AssertionError('copy')):
                self.env['YELLOWSTONE_GRPC__LISTEN_IP'] = '10.0.0.2'
                download.bootstrap('unused', self.env)
            source.write_bytes(b'new')
            download.bootstrap('unused', self.env)
        self.assertEqual(self.target.read_bytes(), b'new')
        self.assertEqual(json.loads((self.root / 'yellowstone-grpc/config.json').read_text())['address'], '10.0.0.2:10000')

    def test_public_download_and_pinned_cache(self):
        self.env['YELLOWSTONE_GRPC__SHA256'] = DIGEST
        with patch.object(download, 'build_opener') as opener:
            opener.return_value.open.return_value = io.BytesIO(DATA)
            download.bootstrap('https://example.com/plugin.so', self.env)
            opener.return_value.open.assert_called_once()
        with patch.object(download, 'build_opener', side_effect=AssertionError('network')):
            download.bootstrap('https://example.com/plugin.so', self.env)

    def test_github_assets_and_cache(self):
        tag = 'v1+solana/2'
        release = {'draft': False, 'tag_name': tag, 'assets': [
            {'name': download.PLUGIN, 'id': 11, 'size': len(DATA)},
            {'name': 'SHA256SUMS', 'id': 12}]}
        manifest = (DIGEST + '  ' + download.PLUGIN + '\n').encode()
        for cached in (False, True):
            with patch.object(download, 'build_opener') as opener:
                responses = [io.BytesIO(json.dumps(release).encode()), io.BytesIO(manifest)]
                if not cached:
                    responses.append(io.BytesIO(DATA))
                opener.return_value.open.side_effect = responses
                download.download_github('dysnix/private', tag, 'test-secret', self.target)
                requests = [call.args[0] for call in opener.return_value.open.call_args_list]
                self.assertTrue(requests[0].full_url.endswith('/tags/v1%2Bsolana%2F2'))
                self.assertEqual(len(requests), 2 if cached else 3)
                for request in requests:
                    self.assertEqual(request.get_header('Authorization'), 'Bearer test-secret')
                    self.assertNotIn('Authorization', request.headers)
        self.assertEqual(self.target.read_bytes(), DATA)

    def test_redirect_drops_credentials_and_rejects_downgrade(self):
        request = Request('https://api.github.com/asset')
        request.add_unredirected_header('Authorization', 'Bearer secret')
        handler = download.SafeRedirectHandler()
        redirected = handler.redirect_request(request, None, 302, '', {}, 'https://assets.example/file')
        self.assertIsNone(redirected.get_header('Authorization'))
        for url in ['http://assets.example/file', 'file:///tmp/file']:
            with self.assertRaises(download.DownloadError):
                handler.redirect_request(request, None, 302, '', {}, url)

    def test_manifest_requires_unique_valid_digest(self):
        line = DIGEST + '  ' + download.PLUGIN + '\n'
        for body in ['', line + line, 'bad  ' + download.PLUGIN]:
            with self.assertRaises(download.DownloadError):
                download.checksum_for_plugin(body.encode())
        self.assertEqual(download.checksum_for_plugin(line.encode()), DIGEST)

    def test_errors_do_not_leak_transport_details(self):
        env = {'YELLOWSTONE_GRPC__ENABLED': '1', 'YELLOWSTONE_GRPC__DOWNLOAD_URL': 'https://example.com',
               'YELLOWSTONE_GRPC__VERSION': 'v1', **self.env}
        stderr = io.StringIO()
        with patch.dict(download.os.environ, env, clear=True), patch.object(download, 'build_opener', side_effect=RuntimeError('secret-signed-url')), contextlib.redirect_stderr(stderr):
            self.assertEqual(download.main(), 1)
        self.assertNotIn('secret', stderr.getvalue())


if __name__ == '__main__':
    unittest.main()
