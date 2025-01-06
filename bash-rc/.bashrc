# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -al'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias psql_geco='docker compose exec app_postgres psql -U postgres geco'
alias psql_restore='docker compose exec app_postgres psql -d geco -f /db-backup/backup.sql -U postgres'
alias drop_connections='docker compose exec app_postgres psql -U postgres geco -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();"'
alias drop_geco='docker compose exec app_postgres dropdb -U postgres geco'
alias create_geco='docker compose exec app_postgres createdb -U postgres geco'
alias db_upgrade='docker compose exec b2e2 python -m flask db upgrade'
# To check that heads match
alias db_current='docker compose exec b2e2 python -m flask db current'
alias db_heads='docker compose exec b2e2 python -m flask db heads'
alias flask_shell='docker compose exec b2e2 python -m flask shell'
alias db_downgrade='docker compose exec b2e2 python -m flask db downgrade'
function db_migrate { docker compose exec b2e2 python -m flask db migrate -m "$1" ; }


export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi
eval "$(pyenv virtualenv-init -)"
eval "$(gh copilot alias -- bash)"
eval "$(starship init bash)"
