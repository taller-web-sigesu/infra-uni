@echo off
setlocal
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "PROJECT_ROOT=%%~fI"
set "COMPOSE_FILE=%SCRIPT_DIR%\compose.yaml"
set "ENV_FILE=%SCRIPT_DIR%\.env"
set "EXIT_CODE=0"

echo ============================================================
echo  Universidad Actua - inicio del entorno local
echo ============================================================

where docker >nul 2>&1
if errorlevel 1 goto :docker_missing

docker compose version >nul 2>&1
if errorlevel 1 goto :compose_missing

docker info >nul 2>&1
if errorlevel 1 goto :engine_unavailable

set "REPO_ERROR=0"
if not exist "%PROJECT_ROOT%\frontend-uni\package.json" (
    echo [ERROR] No se encontro frontend-uni como repositorio hermano.
    set "REPO_ERROR=1"
)
if not exist "%PROJECT_ROOT%\frontend-uni\Dockerfile.dev" (
    echo [ERROR] Falta frontend-uni\Dockerfile.dev.
    set "REPO_ERROR=1"
)
if not exist "%PROJECT_ROOT%\backend-uni\pom.xml" (
    echo [ERROR] No se encontro backend-uni como repositorio hermano.
    set "REPO_ERROR=1"
)
if not exist "%PROJECT_ROOT%\backend-uni\Dockerfile.dev" (
    echo [ERROR] Falta backend-uni\Dockerfile.dev.
    set "REPO_ERROR=1"
)
if not exist "%COMPOSE_FILE%" (
    echo [ERROR] No se encontro infra-uni\compose.yaml.
    set "REPO_ERROR=1"
)
if "%REPO_ERROR%"=="1" goto :repositories_missing

if not exist "%ENV_FILE%" (
    if not exist "%SCRIPT_DIR%\.env.example" goto :env_example_missing
    echo [INFO] Creando infra-uni\.env desde .env.example.
    copy /Y "%SCRIPT_DIR%\.env.example" "%ENV_FILE%" >nul
    if errorlevel 1 goto :env_create_failed
)

echo [INFO] Construyendo e iniciando frontend, backend y mysql...
docker compose --project-name universidad-sm --project-directory "%SCRIPT_DIR%" --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" up -d --build
set "START_CODE=%ERRORLEVEL%"

echo.
echo [INFO] Estado actual de los servicios:
docker compose --project-name universidad-sm --project-directory "%SCRIPT_DIR%" --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" ps --all
set "STATUS_CODE=%ERRORLEVEL%"
if not "%STATUS_CODE%"=="0" (
    echo [ERROR] No se pudo consultar el estado de los contenedores.
    set "EXIT_CODE=1"
)

if not "%START_CODE%"=="0" (
    echo.
    echo [ERROR] Docker Compose no pudo iniciar todos los servicios. Ultimos logs:
    docker compose --project-name universidad-sm --project-directory "%SCRIPT_DIR%" --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" logs --tail 40
    set "EXIT_CODE=%START_CODE%"
) else (
    echo.
    if "%STATUS_CODE%"=="0" (
        echo [OK] Docker Compose termino el inicio. Revisa arriba el estado de salud.
        echo Abre http://localhost:3000 para ver la aplicacion.
        echo Puedes iniciar, detener y reiniciar los contenedores desde Docker Desktop.
    )
)
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

:repositories_missing
set "EXIT_CODE=1"
goto :finish

:env_example_missing
echo [ERROR] Falta infra-uni\.env.example; no se puede crear la configuracion local.
set "EXIT_CODE=1"
goto :finish

:env_create_failed
echo [ERROR] No se pudo crear infra-uni\.env. Revisa permisos de escritura en esta carpeta.
set "EXIT_CODE=1"

:finish
echo.
echo Pulsa una tecla para cerrar esta ventana.
pause >nul
exit /b %EXIT_CODE%
