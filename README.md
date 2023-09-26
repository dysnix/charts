[![Lint and Test Charts](https://github.com/dysnix/charts/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/dysnix/charts/actions/workflows/lint-test.yaml)

# Dysnix Helm Charts

To add dysnix charts repository:

```bash
helm repo add dysnix https://dysnix.github.io/charts
```

## Enable client githooks

**It's strongly advised to enable client-side .git/hooks!**

```bash
cat <<EHD > .git/hooks/pre-push
#!/bin/bash
set -e
repo_path="$(git rev-parse --show-toplevel)"

${repo_path}/githooks/pre-push/chart-version
${repo_path}/githooks/pre-push/helm-lint
${repo_path}/githooks/pre-push/yaml-lint
${repo_path}/githooks/pre-push/kubeval
EHD

chmod +x .git/hooks/pre-push
```
