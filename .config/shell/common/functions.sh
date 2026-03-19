#!/usr/bin/env bash
chkpyt() {
    PYTEST_ADDOPTS='' pytest -q -r fE --tb=no --capture=fd "$@"
}


source_dir() {
  [ -d "$1" ] || return
  # Use process substitution instead of pipe to avoid subshell
  while read -r f; do
      source_if_exists "$f"
  done < <(find "$1" -maxdepth 1 -name '*.sh' -type f)
}

