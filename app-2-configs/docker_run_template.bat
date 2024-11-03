
@echo off
setlocal

REM Configuration Parameters
set TEMPLATE_PATH=%~1

REM Validate input parameters
if "%TEMPLATE_PATH%"=="" (
    echo Template path is not provided. Usage: run_docker.bat [Template Path]
    exit /b 1
)

REM Automatically infer the APP_DIR_NAME from the current directory
for %%i in ("%cd%") do set APP_DIR_NAME=%%~nxi

REM Define APP_PATH as one directory up from the current directory
set APP_PATH=..\%APP_DIR_NAME%

REM Set Environment Variables
set CONTAINER_NAME=win-gres-7445
set B2E2_HOST_PORT=6000
set VOLUME_MOUNT_ROOT=b2e2-1
@REM set CELERY_FLOWER_HOST_PORT=6555
@REM set LOCALSTACK_HOST_GATEWAY_PORT=5566
@REM set LOCALSTACK_HOST_EXTERNAL_PORTS=4610-4659
@REM set TOURBILLON_HOST_POSTGRES_PORT=5542
@REM set APP_HOST_POSTGRES_PORT=16432
@REM set TOURBILLON_HOST_REDIS_PORT=7379

REM Dynamically construct CELERY_BROKER_URL using TOURBILLON_HOST_REDIS_PORT
@REM set CELERY_BROKER_URL=redis://redis:%TOURBILLON_HOST_REDIS_PORT%/1

REM Generate a unique network name
set CUSTOM_NETWORK=%CONTAINER_NAME%_network

REM Run Python to check installed site packages
echo Python version used...
python -c "import sys; print('Python executable used:', sys.executable)"

REM Create a new docker-compose file without ports declarations
set BASE_COMPOSE_FILE=docker-compose.no-ports.yml
set PATH2PYTHON=%TEMPLATE_PATH%\rewrite_docker_compose.py
python "%PATH2PYTHON%" "docker-compose.yml" "%BASE_COMPOSE_FILE%"

echo Python script done updating docker-compose file
echo Press any key to continue, or CTRL+C to cancel...
pause > nul

REM Specify the template file name
set TEMPLATE_FILE=%TEMPLATE_PATH%\docker-compose.override.template.yml

REM Create a unique override file name based on the container name
set OVERRIDE_FILE=docker-compose.override.%CONTAINER_NAME%.yml

REM Copy the template and replace placeholders with actual values
copy "%TEMPLATE_FILE%" %OVERRIDE_FILE%


powershell -Command ^
  "(Get-Content '%OVERRIDE_FILE%') " ^
  "-replace '\$\{CONTAINER_NAME\}', '%CONTAINER_NAME%' " ^
  "-replace '\$\{APP_PATH\}', '%APP_PATH%' " ^
  "-replace '\$\{B2E2_HOST_PORT\}', '%B2E2_HOST_PORT%' " ^
  "-replace '\$\{VOLUME_MOUNT_ROOT\}', '%VOLUME_MOUNT_ROOT%' " ^
  "-replace '\$\{APP_DIR_NAME\}', '%APP_DIR_NAME%' " ^
  "-replace '\$\{CUSTOM_NETWORK\}', '%CUSTOM_NETWORK%' " ^
  @REM "-replace '\$\{CELERY_FLOWER_HOST_PORT\}', '%CELERY_FLOWER_HOST_PORT%' " ^
  @REM "-replace '\$\{LOCALSTACK_HOST_GATEWAY_PORT\}', '%LOCALSTACK_HOST_GATEWAY_PORT%' " ^
  @REM "-replace '\$\{LOCALSTACK_HOST_EXTERNAL_PORTS\}', '%LOCALSTACK_HOST_EXTERNAL_PORTS%' " ^
  @REM "-replace '\$\{TOURBILLON_HOST_POSTGRES_PORT\}', '%TOURBILLON_HOST_POSTGRES_PORT%' " ^
  @REM "-replace '\$\{APP_HOST_POSTGRES_PORT\}', '%APP_HOST_POSTGRES_PORT%' " ^
  @REM "-replace '\$\{TOURBILLON_HOST_REDIS_PORT\}', '%TOURBILLON_HOST_REDIS_PORT%' " ^
  @REM "-replace '\$\{CELERY_BROKER_URL\}', '%CELERY_BROKER_URL%' " ^
  "| Set-Content '%OVERRIDE_FILE%'"

REM Dry Run Information
echo Launching Docker container named "%CONTAINER_NAME%" in directory "%cd%" using override file "%OVERRIDE_FILE%"
echo Press any key to continue, or CTRL+C to cancel...
pause > nul

REM Run docker-compose with the modified base file and specific override file
docker-compose -f %BASE_COMPOSE_FILE% -f %OVERRIDE_FILE% up -d

endlocal
