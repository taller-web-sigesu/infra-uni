@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "COMPOSE_FILE=%SCRIPT_DIR%\compose.yaml"
set "ENV_FILE=%SCRIPT_DIR%\.env"
set "EXIT_CODE=0"

echo ============================================================
echo  Universidad Actua - detener el entorno local
echo ============================================================

where docker >nul 2>&1
if errorlevel 1 goto :docker_missing

docker compose version >nul 2>&1
if errorlevel 1 goto :compose_missing

docker info >nul 2>&1
if errorlevel 1 goto :engine_unavailable

if not exist "%COMPOSE_FILE%" goto :compose_file_missing
if not exist "%ENV_FILE%" goto :env_missing

docker compose --project-name universidad-sm --project-directory "%SCRIPT_DIR%" --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" stop
set "STOP_CODE=%ERRORLEVEL%"
echo.
echo [INFO] Estado actual de los servicios:
docker compose --project-name universidad-sm --project-directory "%SCRIPT_DIR%" --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" ps --all
set "STATUS_CODE=%ERRORLEVEL%"

if not "%STOP_CODE%"=="0" goto :stop_failed
if not "%STATUS_CODE%"=="0" goto :status_failed
echo.
echo [OK] Servicios detenidos. El volumen mysql_data se conserva.
echo Puedes volver a iniciarlos desde Docker Desktop.
goto :finish

:docker_missing
echo [ERROR] No se encontro Docker CLI. Instala Docker Desktop y vuelve a intentarlo.
set "EXIT_CODE=1"
goto :finish

:compose_missing
echo [ERROR] Docker Compose no esta disponible. Actualiza o repara Docker Desktop.
set "EXIT_CODE=1"
goto :finish

:engine_unavailable
echo [ERROR] El motor de Docker Desktop no responde. Abre Docker Desktop y espera a que indique que esta en ejecucion.
docker info
set "EXIT_CODE=1"
goto :finish

:compose_file_missing
echo [ERROR] No se encontro infra-uni\compose.yaml.
set "EXIT_CODE=1"
goto :finish

:env_missing
echo [ERROR] Falta infra-uni\.env. Ejecuta iniciar.bat para preparar el proyecto.
set "EXIT_CODE=1"
goto :finish

:stop_failed
echo [ERROR] No se pudieron detener todos los servicios.
set "EXIT_CODE=%STOP_CODE%"
goto :finish

:status_failed
echo [ERROR] No se pudo consultar el estado de los contenedores.
set "EXIT_CODE=1"

:finish
echo.
echo Pulsa una tecla para cerrar esta ventana.
pause >nul
exit /b %EXIT_CODE%
