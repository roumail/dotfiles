@echo off
setlocal
set JQ=%1
docker run -i --rm ghcr.io/jqlang/jq "%JQ%"
endlocal
