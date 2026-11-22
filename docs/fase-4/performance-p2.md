# Fase IV · Rendimiento de Gestal · Entrega para E

Mediciones del 21 de noviembre de 2026, hora de Lima (UTC−05:00). Se distinguieron la línea base local, el candidato local de E y la línea base de staging.

Esta entrega reprocesa los cuatro resúmenes locales originales. Se eliminó el campo de datos privados del setup y se conservaron todas las demás claves y valores. Los tiempos, resultados, metadatos y capturas corresponden a las corridas originales descritas aquí. El resumen del smoke de staging se conserva sin cambios.

## Revisiones y entorno local

| Componente | Identificación |
| --- | --- |
| infra-uni | `8672ed6aec899fb3c5a058fb1531d3484f0c8a23`, `main` remoto verificado. Se ejecutaron los scripts de esta entrega sobre ese checkout. |
| backend-uni | `b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0`, app 0.1.0-SNAPSHOT, Spring Boot 4.1.2, OpenJDK 21.0.12.1, Maven 3.9.16. |
| Docker | Docker Desktop, cliente y motor 29.9.3, Compose 5.7.0, Linux x86_64, 12 CPU lógicas y 7.65 GiB para el motor, host Windows 10.0.22621.0. |
| Generador | k6 2.4.0 (`dd9395906d`, Windows amd64), PowerShell 7.6.9, ejecutado en el mismo host. |
| Configuración | Proyecto `gestal-perf-main`, backend de desarrollo por bind mount, MySQL 8.4.13 con límite de 1 CPU y 1 GiB, volúmenes propios, Flyway con datos demo, puerto loopback 18080, disponibilidad del 23 de noviembre de 2026. |

Los metadatos por corrida conservan los identificadores de imagen y el intervalo UTC. El intento previo se detuvo en la preparación porque el endpoint de disponibilidad exige la fecha. Su única alta ficticia quedó como solicitud de referencia antes de la carga corregida. El estrés se ejecuta después de la carga sobre esa base aislada.

Para el candidato se clonaron los bundles de E. El backend está en `3fd0c0dfd84d6bc4c73130044a3f6ab221a1fa53` y la revisión de infra es `979090d912505ded349e3ac7bf029bf168a0b450` (PR #25). Ambas revisiones de infra tienen el mismo `compose.yaml`. Se compiló el candidato con el Dockerfile de desarrollo del commit, en el proyecto `gestal-perf-candidate` sobre una base demo propia. El puerto fue 18081.

## Comandos ejecutados

Los comandos se ejecutaron desde el clon de infra-uni. La contraseña ficticia se leyó de la migración demo a variables de proceso. La guía describe las cuatro variables de autenticación y los preparativos. El ejecutor llama internamente a `k6 run --quiet --log-output=none --no-usage-report` con el escenario correspondiente.

```powershell
git -C ../backend-uni switch --detach b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0
$compose = @('--env-file', '../runtime/local.env', '-p', 'gestal-perf-main',
             '-f', 'compose.yaml', '-f', 'tests/performance/compose.local.yaml')
docker compose @compose config --quiet
docker compose @compose up -d --build --wait --wait-timeout 420 backend mysql
docker compose @compose ps
$env:PERF_BASE_URL = 'http://127.0.0.1:18080'
$env:PERF_AVAILABILITY_DATE = '2026-11-23'
$k6 = (Get-ChildItem ../runtime -Recurse -Filter k6.exe | Select-Object -First 1).FullName
$out = 'docs/fase-4/evidencias-performance/local-base'
./tests/performance/run-local.ps1 -Scenario load -K6 $k6 -Project gestal-perf-main -Evidence $out
./tests/performance/run-local.ps1 -Scenario stress -K6 $k6 -Project gestal-perf-main -Evidence $out
```

[Guía de ejecución, mezcla, umbrales y captura](../../tests/performance/README.md)

Para el candidato, desde su clon de infra, con la credencial local de B preparada y las mismas variables de autenticación y fecha:

```powershell
$env:PERF_BASE_URL = 'http://127.0.0.1:18081'
$env:GESTAL_OBSERVABILITY_NETWORK = 'gestal-perf-candidate_app_net'
$app = @('--env-file', '../../runtime/candidate.env', '-p', 'gestal-perf-candidate',
          '-f', 'compose.yaml', '-f', 'tests/performance/compose.local.yaml',
          '-f', 'tests/performance/compose.metrics.yaml')
$obs = @('-p', 'gestal-perf-candidate-obs', '-f', '../backend-uni/observability/compose.yaml')
# candidate.env incluye PERF_COMPOSE_PORT=18081 y variables locales de backend/MySQL.
# GESTAL_SCRAPE_PASSWORD_FILE apunta al archivo privado de la contraseña de scrape.
docker compose @app config --quiet
docker compose @obs config --quiet
docker compose @app up -d --build --wait --wait-timeout 420 backend mysql
docker compose @obs up -d prometheus blackbox tempo grafana
$out = '../../infra-uni/docs/fase-4/evidencias-performance/local-candidato'
$k6 = (Get-ChildItem ../../runtime -Recurse -Filter k6.exe | Select-Object -First 1).FullName
foreach ($scenario in 'load', 'stress') {
    ./tests/performance/run-local.ps1 -Scenario $scenario -K6 $k6 -Project gestal-perf-candidate -Evidence $out
    Start-Sleep -Seconds 16
    ./tests/performance/capture-prometheus.ps1 -RunMetadata "$out/$scenario-meta.json" -Output "$out/$scenario-prometheus.json"
}
```

## Carga local

La línea base se midió de 20:16:45.584 a 20:19:22.354 (Lima). Cero errores HTTP (0 %) y 0 5xx en todas las filas. La tasa de cada fase usa sus segundos programados, mientras que el total de k6 incluye setup, calentamiento y separación. Cero iteraciones descartadas y salida 0.

| Fase o flujo base | Solicitudes | req/s | p50 ms | p95 ms | p99 ms | Checks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Calentamiento | 150 | 5.00 | 11.13 | 18.29 | 22.70 | 300/300 |
| Lecturas combinadas | 1201 | 10.01 | 7.79 | 11.46 | 15.30 | 2402/2402 |
| Listado de solicitudes | 481 | 4.01 | 8.88 | 12.32 | 18.61 | 962/962 |
| Detalle de solicitud | 360 | 3.00 | 7.06 | 10.36 | 12.84 | 720/720 |
| Disponibilidad | 240 | 2.00 | 7.31 | 10.85 | 12.46 | 480/480 |
| Categorías | 120 | 1.00 | 6.51 | 10.88 | 13.50 | 240/240 |
| Alta de solicitud | 121 | 1.01 | 18.47 | 28.37 | 115.34 | 242/242 |
| Total de k6 | 1479 | 9.45 | 8.27 | 18.71 | 25.75 | 2958/2958 |

Se completaron 1322 solicitudes en las dos fases medidas concurrentes, aproximadamente 11.02 req/s. El alta tuvo el mayor p95 entre los flujos. Todas las peticiones quedaron por debajo de 2 s y se cumplieron las puertas propuestas. [Resumen k6](evidencias-performance/local-base/load-k6.json) · [Metadatos](evidencias-performance/local-base/load-meta.json) · [Métricas Docker](evidencias-performance/local-base/load-docker.tsv)

El candidato se midió de 20:23:24.017 a 20:26:01.758 (Lima). Cero errores HTTP (0 %) y 0 5xx en todas las filas, cero iteraciones descartadas y salida k6 0.

| Fase o flujo candidato | Solicitudes | req/s | p50 ms | p95 ms | p99 ms | Checks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Calentamiento | 151 | 5.03 | 12.93 | 18.99 | 23.56 | 302/302 |
| Lecturas combinadas | 1200 | 10.00 | 9.54 | 17.77 | 23.48 | 2400/2400 |
| Listado de solicitudes | 480 | 4.00 | 10.62 | 19.47 | 26.15 | 960/960 |
| Detalle de solicitud | 360 | 3.00 | 8.68 | 16.46 | 20.50 | 720/720 |
| Disponibilidad | 240 | 2.00 | 9.20 | 17.55 | 23.54 | 480/480 |
| Categorías | 120 | 1.00 | 8.79 | 15.95 | 16.92 | 240/240 |
| Alta de solicitud | 121 | 1.01 | 20.17 | 38.24 | 114.16 | 242/242 |
| Total de k6 | 1480 | 9.43 | 10.59 | 21.89 | 35.40 | 2960/2960 |

El candidato completó 1321 peticiones medidas, aproximadamente 11.01 req/s. Pasó las puertas propuestas y su máximo de toda la corrida fue 335.43 ms. El p95 aumentó 6.31 ms para lecturas combinadas y 9.87 ms para altas frente a la base. Una corrida por revisión muestra la diferencia observada bajo estas condiciones y no permite atribuirla a un cambio individual. [Resumen k6](evidencias-performance/local-candidato/load-k6.json) · [Metadatos](evidencias-performance/local-candidato/load-meta.json) · [Métricas Docker](evidencias-performance/local-candidato/load-docker.tsv)

## Estrés local

La repetición de línea base se midió de 20:30:47.907 a 20:34:42.360 (Lima). Se ejecutó el mismo comando de estrés con `-Evidence ../runtime/base-stress-repeticion` y se publicaron esos archivos en `local-base`. La primera corrida había coincidido con la compilación del candidato. En la repetición se detuvieron previamente sus contenedores de aplicación y MySQL. Cero errores HTTP (0 %) y 0 5xx en todas las filas, cero iteraciones descartadas y salida k6 0.

| Fase base | Solicitudes | req/s | p50 ms | p95 ms | p99 ms | Checks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Calentamiento | 151 | 5.03 | 8.33 | 13.19 | 17.45 | 302/302 |
| 10 ofrecidas/s | 451 | 10.02 | 8.08 | 13.55 | 16.47 | 902/902 |
| 20 ofrecidas/s | 901 | 20.02 | 7.85 | 13.73 | 18.43 | 1802/1802 |
| 30 ofrecidas/s | 1351 | 30.02 | 7.88 | 11.34 | 14.88 | 2702/2702 |
| 40 ofrecidas/s | 1801 | 40.02 | 7.61 | 12.05 | 17.23 | 3602/3602 |
| Total de k6 | 4660 | 19.89 | 7.79 | 12.66 | 17.27 | 9320/9320 |

La línea base completó todos los peldaños. En el último procesó 1801 solicitudes verificadas durante 45 s con p95 de 12.05 ms. [Resumen k6](evidencias-performance/local-base/stress-k6.json) · [Metadatos](evidencias-performance/local-base/stress-meta.json) · [Métricas Docker](evidencias-performance/local-base/stress-docker.tsv)

El candidato se midió de 20:26:22.846 a 20:30:17.298 (Lima). Cero errores HTTP (0 %) y 0 5xx en todas las filas. Cero iteraciones descartadas y salida k6 0.

| Fase del candidato | Solicitudes | req/s | p50 ms | p95 ms | p99 ms | Checks |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Calentamiento | 151 | 5.03 | 8.87 | 15.26 | 21.32 | 302/302 |
| 10 ofrecidas/s | 451 | 10.02 | 8.97 | 14.75 | 18.41 | 902/902 |
| 20 ofrecidas/s | 900 | 20.00 | 8.23 | 15.91 | 19.80 | 1800/1800 |
| 30 ofrecidas/s | 1351 | 30.02 | 9.13 | 17.20 | 22.03 | 2702/2702 |
| 40 ofrecidas/s | 1801 | 40.02 | 8.33 | 13.80 | 17.45 | 3602/3602 |
| Total de k6 | 4659 | 19.89 | 8.55 | 15.49 | 20.24 | 9318/9318 |

El candidato completó el último peldaño sin activar condiciones de parada. La capacidad comprobada fue de aproximadamente 40 lecturas/s durante 45 s en este equipo y con esta mezcla. La saturación queda fuera del intervalo ensayado. El resumen conserva percentiles, errores y checks por ruta dentro de cada peldaño. [Resumen k6](evidencias-performance/local-candidato/stress-k6.json) · [Metadatos](evidencias-performance/local-candidato/stress-meta.json) · [Métricas Docker](evidencias-performance/local-candidato/stress-docker.tsv)

## Smoke k6 de staging

Inicio 20:14:04.663 y fin 20:14:12.725 (Lima). **SHA desplegado sin confirmar**. La consulta de deployments de GitHub no devolvió registros de staging. El último workflow `staging-smoke` consultado terminó con éxito para el head `b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0` el 16 de noviembre. Su head identifica el workflow y no acredita el despliegue de Render el día de la medición. [Workflow de referencia](https://github.com/taller-web-sigesu/backend-uni/actions/runs/43970286002)

```powershell
$env:PERF_STAGING = 'authorized'
$env:PERF_SUMMARY = 'docs/fase-4/evidencias-performance/staging-base/smoke-k6.json'
& $k6 run --quiet --log-output=none --no-usage-report tests/performance/staging-smoke.js
```

Las seis peticiones públicas devolvieron HTTP 200 con `status=UP`. Resultado global de disponibilidad con seis muestras, 12/12 checks, 0 errores (0 %), 0 5xx, 0.75 req/s incluida la pausa y salida k6 0. El p50 fue 225.13 ms, el p95 553.21 ms y el p99 575.20 ms. Esta muestra sirve para comprobar disponibilidad. [Resumen k6](evidencias-performance/staging-base/smoke-k6.json) · [Metadatos](evidencias-performance/staging-base/smoke-meta.json)

| Ruta | Solicitudes | p50 ms | p95 ms | p99 ms | Checks |
| --- | ---: | ---: | ---: | ---: | ---: |
| `GET /actuator/health` | 3 | 470.77 | 569.70 | 578.50 | 6/6 |
| `GET /api/v1/status` | 3 | 192.05 | 199.16 | 199.79 | 6/6 |

## Observabilidad y medición del candidato

Actuator en la línea base solo expone salud por configuración. Para esa revisión quedan los resúmenes HTTP de k6 y las muestras de contenedor. El candidato integra la instrumentación de A (`fc6bbbea54eab85b4a52fd76e389ec9b614e2edb`) y el stack de B (`b3a53da38b5fc7b0684d1276a14b8162b039ee23`, runbook corregido en `02144df719be36bdaf1752f2eb7cdfcbfe404b3a`). Se usó scrape cada 15 s con autenticación y el dashboard de B, sin el exportador de despliegue ni la exportación OTLP. La comparación corresponde a revisiones completas y datos demo, con la instrumentación activa en el candidato.

En carga, el scrape estuvo disponible en 16/16 puntos de evaluación. El backend alcanzó 11 req/s y 0 % de 5xx. El p95 de Prometheus llegó a 20.55 ms en las ventanas completas de 30 s del tramo sostenido. El máximo de toda la captura fue 345.08 ms, con una ventana inicial que incluye autenticación y preparación. El heap alcanzó 63.66 MiB y se observaron 28 hilos JVM. Hikari registró 0 conexiones activas y pendientes en los instantes de muestreo, con un máximo configurado de 10. Se observaron hasta 30 altas confirmadas por ventana de 30 s y cero rechazos de login. Los gauges de Hikari a este intervalo pueden omitir ocupaciones breves. [Series de Prometheus para carga](evidencias-performance/local-candidato/load-prometheus.json)

En estrés, el scrape estuvo disponible en 24/24 puntos, con un máximo de 40.07 req/s y 0 % de 5xx. Después de los primeros 30 s, el mayor p95 de Prometheus fue 14.37 ms. El heap alcanzó 79.86 MiB y se observaron 28 hilos JVM. Hikari llegó a 1/10 conexiones activas y 0 pendientes en las muestras. El flujo medido fue de lectura, con cero altas o reservas nuevas en las ventanas de 30 s completas de esta ejecución y cero rechazos de login. El primer punto de negocio conserva parte de la ventana anterior, en la que todavía había altas de carga. [Series de Prometheus para estrés](evidencias-performance/local-candidato/stress-prometheus.json)

Grafana muestra el mismo intervalo UTC de cada corrida en hora de Lima. Los paneles con ventanas de 5 min suavizan los peldaños de 45 s y conservan parte de la carga anterior al comienzo de estrés. Para ver los peldaños, usar la serie JSON con ventanas de 30 s y los resúmenes k6. [Dashboard de carga](evidencias-performance/local-candidato/load-grafana.png) · [Dashboard de estrés](evidencias-performance/local-candidato/stress-grafana.png)

Para cerrar la evidencia de staging del quinto PR, ejecutar el smoke cuando operaciones confirme el despliegue del candidato. El smoke actual se conserva en `staging-base`.

## Verificaciones de los scripts

`docker compose config --quiet` pasó en ambos proyectos locales. `k6 inspect` aceptó los tres escenarios con su destino habilitado y rechazó una URL ajena en cada caso. También rechazó el smoke sin habilitación explícita. Las pruebas locales y el smoke incluyeron verificaciones de estado HTTP y contrato JSON.

Una prueba adicional de sanitización ejecutó `prepare(false)` con inicio de sesión real de una cuenta ficticia y diez lecturas autenticadas con un VU. Se ejecutó sobre la línea base aislada `b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0` con k6 2.4.0. Pasaron los 20 checks medidos. El JSON guardado coincidió con el resumen emitido en stdout. Un escaneo redactado confirmó que ambas salidas carecen de JWT y de la clave de datos del setup. [Metadatos y huellas SHA-256 de la prueba](evidencias-performance/verificacion-sanitizacion.json)
