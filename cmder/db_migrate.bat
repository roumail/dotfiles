@echo off
setlocal

set MIGRATION_MESSAGE=%*

:: Remove surrounding quotes if present
set MIGRATION_MESSAGE=%MIGRATION_MESSAGE:"=%

docker compose run b2e2 python -m flask db migrate -m "%MIGRATION_MESSAGE%"
endlocal
