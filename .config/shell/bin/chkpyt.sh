#!/usr/bin/env bash
# chkpyt.sh: unified pytest runner for Vim Dispatch + Start
#
# Modes
# 1) Default mode (uses baseline addopts, plus optional extras)
#    - Call: chkpyt.sh <pytest-args...>
#    - Baseline addopts: -q -r fE --tb=no --capture=fd
#    - Extras source: CHKPYT_PYTEST_ADDOPTS (typically from .env)
#
# 2) No-default mode (does not include baseline addopts)
#    - Call: chkpyt.sh --no-default-addopts <pytest-args...>
#    - Uses only CHKPYT_PYTEST_ADDOPTS if set; otherwise empty.
#
# .env behavior
# - If .env exists in the current working directory, it is sourced first.
# - This allows both modes to receive CHKPYT_PYTEST_ADDOPTS from .env.
#
# Example .env
#   CHKPYT_PYTEST_ADDOPTS=--maxfail=1
set -euo pipefail

if ! command -v pytest >/dev/null 2>&1; then
    echo "Error: pytest not found in PATH" >&2
    exit 127
fi

# 1) import from .env if present
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

# --tb=no
default_addopts='-q -r fE --tb=line --capture=fd'
use_defaults=1

# Mode switch for Start/trace flows
if [ "${1:-}" = "--no-default-addopts" ]; then
  use_defaults=0
  shift
fi

extra_addopts="${CHKPYT_PYTEST_ADDOPTS:-}"

# 2) build final PYTEST_ADDOPTS
if [ "$use_defaults" -eq 1 ]; then
  if [ -n "$extra_addopts" ]; then
    run_addopts="$default_addopts $extra_addopts"
  else
    run_addopts="$default_addopts"
  fi
else
  run_addopts="$extra_addopts"
fi

PYTEST_ADDOPTS="$run_addopts" pytest "$@"
