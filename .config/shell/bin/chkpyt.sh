#!/usr/bin/env bash
set -euo pipefail

if ! command -v pytest >/dev/null 2>&1; then
    echo "Error: pytest not found in PATH" >&2
    exit 127
fi
PYTEST_ADDOPTS='' pytest -q -r fE --tb=no --capture=fd "$@"
