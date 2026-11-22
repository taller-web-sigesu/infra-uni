# Pruebas k6 de Fase IV

Usar k6 2.4.0 y PowerShell 7.5. Ejecutar desde la raíz de infra-uni. El checkout hermano `../backend-uni` debe estar limpio y en el SHA a medir.

## Carga y estrés en Compose local

Usar un nombre nuevo que comience por `gestal-perf-`. Compose crea una base y volúmenes propios. El override publica en loopback, y el backend carga los datos demo. El archivo de variables se guarda fuera de infra-uni.

```powershell
$compose = @('--env-file', '../runtime/local.env', '-p', 'gestal-perf-main',
             '-f', 'compose.yaml', '-f', 'tests/performance/compose.local.yaml')
# Crear ../runtime/local.env con las variables de .env.example y valores locales.
docker compose @compose config --quiet
docker compose @compose up -d --build --wait --wait-timeout 420 backend mysql
docker compose @compose ps

$env:PERF_BASE_URL = 'http://127.0.0.1:18080'
$env:PERF_AVAILABILITY_DATE = '2026-11-23'
$env:PERF_READER_EMAIL = Read-Host 'Cuenta supervisora demo'
$env:PERF_READER_PASSWORD = Read-Host -MaskInput 'Contraseña demo de lectura'
$env:PERF_WRITER_EMAIL = Read-Host 'Cuenta solicitante demo'
$env:PERF_WRITER_PASSWORD = Read-Host -MaskInput 'Contraseña demo de escritura'
$k6 = (Get-Command k6.exe).Source
$evidence = 'docs/fase-4/evidencias-performance/local-base'
./tests/performance/run-local.ps1 -Scenario load -K6 $k6 -Project gestal-perf-main -Evidence $evidence
./tests/performance/run-local.ps1 -Scenario stress -K6 $k6 -Project gestal-perf-main -Evidence $evidence
Remove-Item Env:PERF_READER_EMAIL, Env:PERF_READER_PASSWORD, Env:PERF_WRITER_EMAIL, Env:PERF_WRITER_PASSWORD
docker compose @compose stop backend mysql
```

Para comparar con el candidato, usar el checkout limpio del SHA de E, un proyecto nuevo y el directorio `local-candidato`. El segundo proyecto puede usar `PERF_COMPOSE_PORT=18081` y `PERF_BASE_URL=http://127.0.0.1:18081`. Ejecutar carga y estrés de forma consecutiva. Registrar el estado inicial de la base. Elegir un lunes con horario en el ambiente demo y fijar esa fecha para ambas revisiones.

El setup autentica una vez al supervisor demo y reutiliza su sesión de lectura. Usa otro usuario ficticio y una sesión para las altas, con un único VU de escritura. Si el supervisor carece de solicitudes, el setup crea una solicitud de referencia en su área. Estrés solo lee durante la ventana medida. Evitar otras sesiones con esas cuentas durante la prueba. Las solicitudes creadas quedan en la base aislada.

| Escenario | Perfil |
| --- | --- |
| Carga | 30 s a 5 lecturas/s, luego 120 s a 10 lecturas/s y 1 alta/s. 30 VU de lectura y 1 de escritura durante la medición. |
| Estrés | Mismo calentamiento y cuatro peldaños de 45 s a 10, 20, 30 y 40 lecturas/s, con 30, 60, 90 y 100 VU respectivamente. |

Entre escenarios consecutivos hay un margen de hasta 6 s para terminar las peticiones. Cada iteración medida hace una petición. La mezcla de lecturas es 40 % `GET /api/v1/requests?page=0&size=20`, 30 % `GET /api/v1/requests/{id}`, 20 % `GET /api/v1/spaces/{id}/availability?fecha=YYYY-MM-DD` y 10 % `GET /api/v1/catalogs/categories`. El alta `POST /api/v1/requests` añade alrededor del 9 % del tráfico total de carga. Los checks verifican el estado HTTP exacto y el contrato JSON.

### Criterios

- Gestal registra menos de 2 s con carga demo para las operaciones habituales y la disponibilidad de ambientes (RNF-09 y RNF-18). El ADR-0003 propuesto registra referencias operativas de más de 1 % de 5xx, p95 superior a 2 s y uso de Hikari por encima de 80 %. Las alertas de B usan una ventana de cinco minutos. [Requisitos de Gestal](../../docs/requirements/Gestal_Requisitos_No_Funcionales.md) · [ADR-0003](../../docs/adr/ADR-0003-observabilidad-retencion.md)
- La puerta de carga **propuesta** exige p95 < 2 s por escenario y flujo, < 1 % de error HTTP, todos los checks y cero iteraciones descartadas. Es una aplicación medible del objetivo de latencia a una mezcla acotada. El máximo se guarda para contrastar las peticiones individuales con el objetivo. k6 cuenta respuestas inesperadas y fallas de transporte en errores HTTP. `api_5xx` registra solo 5xx.
- El estrés **propuesto** aborta si un peldaño alcanza p95 ≥ 3 s, ≥ 5 % de error HTTP o ≥ 5 % de 5xx tras 15 s de muestras. También aborta ante descartes de iteraciones en un peldaño para limitar la influencia del generador. k6 evalúa periódicamente los umbrales. El operador puede interrumpir si el backend deja de estar saludable o visible. Llegar al último escalón solo demuestra el intervalo ensayado.

### Evidencia y captura de B

El ejecutor guarda el resumen JSON, metadatos UTC y estadísticas de CPU, memoria y procesos de los dos contenedores. El resumen registra etiquetas estáticas y métricas agregadas. Ejecutar sin `--http-debug` ni exportadores remotos. Conservar los secretos en variables de proceso o archivos locales fuera del clon.

Para el candidato, agregar `-f tests/performance/compose.metrics.yaml` al Compose de la aplicación. Definir `APP_TELEMETRY_PASSWORD_HASH` como un hash BCrypt local y seguir el runbook de B para su archivo de scrape. Iniciar `observability/compose.yaml` de B con la red `<proyecto>_app_net` y verificar `up{job="gestal-backend"}=1` antes de k6. Tras la corrida esperar al siguiente scrape y exportar su intervalo UTC. Si se quieren comparar dos revisiones con OTLP, registrar la misma política de muestreo en ambas.

```powershell
$dir = 'docs/fase-4/evidencias-performance/local-candidato'
./tests/performance/capture-prometheus.ps1 -RunMetadata "$dir/load-meta.json" -Output "$dir/load-prometheus.json"
./tests/performance/capture-prometheus.ps1 -RunMetadata "$dir/stress-meta.json" -Output "$dir/stress-prometheus.json"
```

Guardar el PNG del dashboard de B con el mismo rango absoluto. Registrar el SHA del stack y verificar que las capturas solo contengan datos de prueba. El exportador evalúa cada 10 s y calcula tasas sobre ventanas de 30 s para distinguir los escalones. Los primeros puntos pueden incluir el final de la ventana anterior al inicio. Verificar `scrape_up` y distinguir una serie ausente de una serie en cero. Los paneles de B suavizan con ventanas de 5 min. El p95 de Prometheus se estima a partir de histogramas.

## Smoke público de staging

Confirmar autorización y buscar el SHA en el historial de despliegues de Render. Si falta esa evidencia, registrar «SHA desplegado sin confirmar». Una revisión anterior se guarda como línea base. El workflow `staging-smoke` del backend ofrece un antecedente de disponibilidad.

```powershell
$env:PERF_STAGING = 'authorized'
$env:K6_HTTP_DEBUG = ''
$env:K6_OUT = ''
$env:PERF_SUMMARY = 'docs/fase-4/evidencias-performance/staging-base/smoke-k6.json'
k6 run --quiet --log-output=none --no-usage-report tests/performance/staging-smoke.js
Remove-Item Env:PERF_STAGING, Env:PERF_SUMMARY
```

El script fija el host de staging, desactiva redirecciones y hace tres pares de GET a `/actuator/health` y `/api/v1/status` con un VU. Pausa dos segundos por par y fija plazos de 5 s por petición y 40 s para el escenario. Exige seis HTTP 200 con `status=UP`, todos los checks y respuestas en menos de 5 s. Registrar inicio y fin UTC, versión de k6, código de salida y evidencia de revisión junto al JSON.
