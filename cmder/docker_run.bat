@echo off
setlocal

REM Configuration Parameters
set PROJECT_DIR=%1
set TEMPLATE_PATH=%2

REM Validate input parameters
if "%PROJECT_DIR%"=="" (
    echo Project directory is not provided. Usage: run_docker.bat [Project Directory]
    exit /b 1
)

if "%TEMPLATE_PATH%"=="" (
    echo Template path is not provided. Usage: run_docker.bat [Project Directory] [Template Path]
    exit /b 1
)

REM Set Environment Variables
set CONTAINER_NAME=my-container
set APP_PATH=%PROJECT_DIR%
set B2E2_HOST_PORT=5000
set CELERY_FLOWER_HOST_PORT=5555
set LOCALSTACK_HOST_GATEWAY_PORT=4566
set LOCALSTACK_HOST_EXTERNAL_PORTS=4510-4559
set TOURBILLON_HOST_POSTGRES_PORT=5432
set APP_HOST_POSTGRES_PORT=15432
set TOURBILLON_HOST_REDIS_PORT=6379
set VOLUME_MOUNT_ROOT=b2e2-1

REM Create a unique override file name based on the container name
set OVERRIDE_FILE=docker-compose.override.%CONTAINER_NAME%.yml

REM Copy the template from the specified path and replace placeholders with actual values
copy "%TEMPLATE_PATH%\docker-compose.override.template.yml" %OVERRIDE_FILE%

powershell -Command "(Get-Content %OVERRIDE_FILE%) -replace '\$\{CONTAINER_NAME\}', '%CONTAINER_NAME%' -replace '\$\{APP_PATH\}', '%APP_PATH%' -replace '\$\{B2E2_HOST_PORT\}', '%B2E2_HOST_PORT%' -replace '\$\{CELERY_FLOWER_HOST_PORT\}', '%CELERY_FLOWER_HOST_PORT%' -replace '\$\{LOCALSTACK_HOST_GATEWAY_PORT\}', '%LOCALSTACK_HOST_GATEWAY_PORT%' -replace '\$\{LOCALSTACK_HOST_EXTERNAL_PORTS\}', '%LOCALSTACK_HOST_EXTERNAL_PORTS%' -replace '\$\{TOURBILLON_HOST_POSTGRES_PORT\}', '%TOURBILLON_HOST_POSTGRES_PORT%' -replace '\$\{APP_HOST_POSTGRES_PORT\}', '%APP_HOST_POSTGRES_PORT%' -replace '\$\{TOURBILLON_HOST_REDIS_PORT\}', '%TOURBILLON_HOST_REDIS_PORT%' -replace '\$\{VOLUME_MOUNT_ROOT\}', '%VOLUME_MOUNT_ROOT%' | Set-Content %OVERRIDE_FILE%"

REM Run docker-compose with the specific override file
docker-compose -f docker-compose.yml -f %OVERRIDE_FILE% up -d

REM Clean up the override file after use if needed
REM del %OVERRIDE_FILE%

endlocal
