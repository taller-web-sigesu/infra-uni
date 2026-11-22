param(
    [Parameter(Mandatory)][string]$RunMetadata,
    [Parameter(Mandatory)][string]$Output
)

$ErrorActionPreference = 'Stop'
if (Test-Path $Output) { throw 'La captura ya existe. Selecciona otro archivo.' }
$run = Get-Content -Raw $RunMetadata | ConvertFrom-Json -DateKind String
$start = [datetimeoffset]::Parse($run.start_utc).ToUnixTimeMilliseconds() / 1000
$end = [datetimeoffset]::Parse($run.end_utc).ToUnixTimeMilliseconds() / 1000
$range = 'start={0}&end={1}&step=10s' -f $start.ToString([cultureinfo]::InvariantCulture),
    $end.ToString([cultureinfo]::InvariantCulture)
$http = 'job="gestal-backend",uri=~"/api/v1(/.*)?"'
$traffic = 'sum(rate(http_server_requests_seconds_count{' + $http + '}[30s]))'
$serverErrors = 'sum(rate(http_server_requests_seconds_count{' + $http + ',status=~"5.."}[30s]))'
$queries = [ordered]@{
    scrape_up = 'max(up{job="gestal-backend"})'
    http_per_second = $traffic
    http_5xx_ratio = "($serverErrors or 0 * $traffic) / ($traffic > 0)"
    http_p95_seconds = 'histogram_quantile(0.95, sum by(le)(rate(http_server_requests_seconds_bucket{' + $http + '}[30s])))'
    jvm_heap_bytes = 'sum(jvm_memory_used_bytes{job="gestal-backend",area="heap"})'
    jvm_threads = 'sum(jvm_threads_live_threads{job="gestal-backend"})'
    process_cpu = 'max(process_cpu_usage{job="gestal-backend"})'
    hikari_active = 'sum(hikaricp_connections_active{job="gestal-backend"})'
    hikari_max = 'sum(hikaricp_connections_max{job="gestal-backend"})'
    hikari_pending = 'sum(hikaricp_connections_pending{job="gestal-backend"})'
    business_operations_30s = 'sum by(operation)(increase(gestal_business_operations_total{job="gestal-backend"}[30s]))'
    login_rejections_30s = 'sum by(reason)(increase(gestal_auth_login_rejections_total{job="gestal-backend"}[30s]))'
}
$series = [ordered]@{}
foreach ($key in $queries.Keys) {
    $query = [uri]::EscapeDataString($queries[$key])
    $result = Invoke-RestMethod "http://127.0.0.1:9090/api/v1/query_range?${range}&query=$query" -TimeoutSec 10 -MaximumRedirection 0
    if ($result.status -ne 'success') { throw "Falló la consulta PromQL $key." }
    $series[$key] = @($result.data.result)
}
[ordered]@{
    backend_sha = $run.backend_sha
    start_utc = $run.start_utc
    end_utc = $run.end_utc
    step_seconds = 10
    queries = $queries
    series = $series
} | ConvertTo-Json -Depth 12 | Set-Content $Output
