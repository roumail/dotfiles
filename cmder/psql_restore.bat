@echo off
setlocal
set BACKUP_FILE=%1
set DB_BACKUP_FOLDER=/db-backup

if "%BACKUP_FILE%"=="" set BACKUP_FILE=backup.sql

docker compose exec app_postgres psql -d geco -f "%DB_BACKUP_FOLDER%/%BACKUP_FILE%" -U postgres
endlocal
