#!/usr/bin/env sh
set -e

lookup_latest_tag() {
    git fetch --tags > /dev/null 2>&1

    if ! git describe --tags --abbrev=0 2> /dev/null; then
        git rev-list --max-parents=0 --first-parent HEAD
    fi
}

lookup_changed_charts() {
    commit="$1"
    changed_files=$(git diff --find-renames --name-only "$commit" -- "$charts_dir")

    depth=$(( $(echo "$charts_dir" | tr "/" "\n" | sed '/^\(\.\)*$/d' | wc -l) + 1 ))
    fields="1-${depth}"

    echo "$changed_files" | cut -d '/' -f "$fields" | uniq | filter_charts
}

filter_charts() {
    while read chart; do
        [ ! -d "$chart" ] && continue
        file="$chart/Chart.yaml"
        if [ -f "$file" ]; then
            echo "$chart"
        else
            echo "WARNING: $file is missing, assuming that '$chart' is not a Helm chart. Skipping." 1>&2
        fi
    done
}

update_helm_repos() {
    yq '.chart-repos[]' .github/ct.yaml | sed 's/=/ /' | xargs -n2 helm repo add
}

export charts_dir="${1:-charts/}"

echo 'Fetching tools'
apk add --no-cache git yq
git config --global --add safe.directory /github/workspace

echo 'Looking up latest tag...'
latest_tag=$(lookup_latest_tag)

changed_charts=$(lookup_changed_charts "$latest_tag")

if [ -n "$changed_charts" ]; then
    update_helm_repos
    for chart in $changed_charts; do
        if (ls -1 "$chart"/tests/*_test.yaml 1>/dev/null 2>/dev/null); then
            helm dependency update "$chart" 
            helm unittest --color --helm3 "$chart"
        fi
    done
fi