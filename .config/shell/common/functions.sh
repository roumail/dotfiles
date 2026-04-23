#!/usr/bin/env bash
chkpyt() {
    PYTEST_ADDOPTS='' pytest -q -r fE --tb=no --capture=fd "$@"
}

_wezterm_osc7_hook() {
    printf "\033]7;file://%s%s\a" "$HOSTNAME" "$PWD"
}


