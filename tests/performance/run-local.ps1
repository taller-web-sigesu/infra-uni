param(
    [Parameter(Mandatory)][ValidateSet('load', 'stress')][string]$Scenario,
    [Parameter(Mandatory)][string]$K6,
    [Parameter(Mandatory)][ValidatePattern('^gestal-perf-[a-z0-9-]+$')][string]$Project,
    [Parameter(Mandatory)][string]$Evidence
)

$ErrorActionPreference = 'Stop'
$api = $env:PERF_BASE_URL
if (-not $api) { $api = 'http://127.0.0.1:18080' }
if ($api -notmatch '^http://127\.0\.0\.1:(18080|18081)$') { throw 'Destino fuera de loopback.' }
$port = ([uri]$api).Port
$backend = "$Project-backend-1"
$mysql = "$Project-mysql-1"
if ((docker port $backend 8080/tcp) -ne "127.0.0.1:$port") {
    throw 'El backend del proyecto de prueba no publica el puerto seleccionado.'
}
$health = Invoke-RestMethod "$api/actuator/health" -TimeoutSec 5 -MaximumRedirection 0
if ($health.status -ne 'UP') { throw 'El backend de prueba aún no está disponible.' }

$infra = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path.Replace('\', '/')
$backendPath = (Resolve-Path (Join-Path $infra '../backend-uni')).Path.Replace('\', '/')
$infraSha = git -c "safe.directory=$infra" -C $infra rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'No se pudo verificar el SHA de infraestructura.' }
$backendSha = git -c "safe.directory=$backendPath" -C $backendPath rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'No se pudo verificar el SHA de backend.' }
if (git -c "safe.directory=$backendPath" -C $backendPath status --porcelain) {
    throw 'El checkout del backend contiene cambios locales.'
}

$out = (New-Item -ItemType Directory -Path $Evidence -Force).FullName
if (Test-Path (Join-Path $out "$Scenario-k6.json")) { throw 'El resumen ya existe. Usa otro directorio.' }
$details = [ordered]@{
    scenario = $Scenario
    project = $Project
    endpoint = $api
    availability_date = if ($env:PERF_AVAILABILITY_DATE) { $env:PERF_AVAILABILITY_DATE } else { '2026-11-23' }
    infra_sha = $infraSha
    backend_sha = $backendSha
    backend_image = docker inspect --format '{{.Image}}' $backend
    mysql_image = docker inspect --format '{{.Image}}' $mysql
    docker = docker version --format '{{.Client.Version}} / {{.Server.Version}}'
    compose = docker compose version --short
    docker_engine = docker info --format '{{.OperatingSystem}} / {{.Architecture}} / CPU={{.NCPU}} / RAM={{.MemTotal}}'
    k6 = & $K6 version
    start_utc = $null
    end_utc = $null
    exit_code = $null
}

$stamp = Join-Path $out "$Scenario-running"
$samples = Join-Path $out "$Scenario-docker.tsv"
$env:PERF_LOCAL = 'isolated-compose'
$env:PERF_SUMMARY = Join-Path $out "$Scenario-k6.json"
$env:K6_HTTP_DEBUG = ''
$env:K6_OUT = ''
$env:K6_CLOUD_TOKEN = ''
$env:NO_PROXY = '127.0.0.1'
New-Item -ItemType File -Path $stamp | Out-Null
$job = Start-Job -ArgumentList $backend, $mysql, $stamp, $samples -ScriptBlock {
    param($Backend, $Mysql, $Stamp, $Samples)
    "utc`tcontainer`tcpu`tmemory`tmemory_percent`tpids" | Set-Content $Samples
    while (Test-Path $Stamp) {
        $utc = [datetime]::UtcNow.ToString('o')
        docker stats --no-stream --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}|{{.PIDs}}' $Backend $Mysql |
            ForEach-Object { "$utc`t$($_.Replace('|', "`t"))" | Add-Content $Samples }
        Start-Sleep -Seconds 8
    }
}
try {
    $details.start_utc = [datetime]::UtcNow.ToString('o')
    & $K6 run --quiet --log-output=none --no-usage-report (Join-Path $PSScriptRoot "$Scenario.js") | Out-Null
    $details.exit_code = $LASTEXITCODE
} finally {
    $details.end_utc = [datetime]::UtcNow.ToString('o')
    $details | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $out "$Scenario-meta.json")
    Remove-Item -LiteralPath $stamp
    Wait-Job $job -Timeout 15 | Out-Null
    Remove-Job $job -Force
    Remove-Item Env:PERF_SUMMARY -ErrorAction SilentlyContinue
}
exit $details.exit_code
