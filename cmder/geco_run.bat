@echo off
setlocal
set OPERATION=%*

docker compose run --rm -it b2e2 "%OPERATION%"
endlocal
