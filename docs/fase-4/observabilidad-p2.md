# Fase IV · Observabilidad de backend · Insumo para P2

Fecha de verificación local: 21 de noviembre de 2026, hora de Lima.

## Implementado

El commit de backend `b3a53da38b5fc7b0684d1276a14b8162b039ee23`, rama `feature/fase-4-p2-observabilidad-local`, parte de `main` `b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0`. La captura y la correlación utilizaron el backend instrumentado de A en `fc6bbbea54eab85b4a52fd76e389ec9b614e2edb`. Los repositorios auxiliares se crearon en clones independientes. Para consolidar, P2 puede aplicar el commit de observabilidad en la rama que integre a A y el commit de documentación en su rama de infra.

- `observability/compose.yaml`, `blackbox.yml`, `tempo.yml` y `prometheus/prometheus.yml`: recolección local por Basic Auth, sonda de salud y trazas por OTLP/HTTP. Prometheus y Grafana se publican en loopback.
- `observability/deploy_exporter.py`: lee el último resultado completado de `deploy-production.yml` en la rama `production`.
- `observability/prometheus/gestal.rules.yml` y `gestal.test.yml`: cuatro series calculadas, seis alertas y fixtures.
- `observability/grafana/dashboards/gestal.json`, `grafana/provisioning/dashboards/gestal.yml` y `grafana/provisioning/datasources/gestal.yml`: dashboard y fuentes versionadas. Indicadores de tasa HTTP, 5xx, p95, memoria, hilos, CPU, Hikari, altas de negocio, rechazos de login, disponibilidad y despliegue.
- `observability/README.md`: instalación, confirmación de cada alerta, diagnóstico, recuperación, correlación y retención.

## Verificado en local

Docker Compose v2.39.4 levantó cinco componentes de observabilidad, el JAR de A y MySQL 8.4.13 en una red aislada. Prometheus tuvo tres targets UP. El recolector autenticado recibió métricas; la sonda reportó `probe_success=1`. La API devolvió 201 para una solicitud ficticia y 401 para el login rechazado de una cuenta ficticia. En el instante guardado, Prometheus registró 0,0624 req/s, 0 % de 5xx, p95 de 7,83 ms, una solicitud confirmada y un rechazo de credenciales. La petición `GET /api/v1/status` devolvió 200. El log JSON y el span recuperado de Tempo por su API coinciden en `traceId` y `spanId`. El log y la respuesta coinciden en `X-Correlation-ID`.

| Alerta | Condición de prueba | Resultado sintético |
| --- | --- | --- |
| `GestalHealthUnavailable` | Sonda 0 durante 1 min y sonda ausente en un caso independiente | Disparó y se recuperó. La ausencia también disparó. |
| `GestalHttp5xxHigh` | 2 % de 5xx, umbral > 1 % durante 5 min | Disparó y se recuperó. Con cero tráfico quedó inactiva. |
| `GestalHttpP95High` | Histograma con p95 > 2 s durante 5 min | Disparó y se recuperó. |
| `GestalPoolSaturated` | 9/10 conexiones activas, umbral > 80 % durante 5 min | Disparó y se recuperó con 8/10 activas. |
| `GestalDeploymentFailed` | Workflow fallido y exportador UP durante 1 min | Disparó y se recuperó con éxito. Una lectura fallida quedó sin alerta de despliegue. |
| `GestalLoginRejectionsHigh` | 6 rechazos por minuto en fixtures, umbral ≥ 20 en 5 min durante 2 min | Disparó y se recuperó. |

El exportador recogió en vivo `run_id=43963809965` y valor `failed=0`. GitHub devolvió `completed/success` y confirmó el hook, la espera y el smoke exitosos. El evento efectivo de Render queda a cargo de operaciones. [Resultado de deploy-production](https://github.com/taller-web-sigesu/backend-uni/actions/runs/43963809965).

### Retención

Se verificó `storage.tsdb.retention.time=15d` en Prometheus y `compactor.compaction.block_retention=168h` en Tempo durante la ejecución. Coinciden con los 15 y 7 días del ADR-0003. La prueba corta verificó la configuración efectiva. La purga por antigüedad sigue pendiente. Los logs técnicos se consultaron desde la consola JSON de A y la retención de 30 días sigue pendiente de un almacenamiento o proveedor que la garantice. La retención de staging también sigue pendiente de evidencia.

## Verificado en CI

GitHub Actions no devolvió ejecuciones asociadas al SHA instrumentado de A. La prueba de las seis alertas se ejecutó localmente con el binario oficial de Prometheus y dentro de su contenedor. P2 debe ejecutar esa misma prueba en el commit consolidado y registrar la URL de la corrida.

## Verificado en staging

El último `staging-smoke` consultado reportó `success` el 16 de noviembre sobre el SHA base `b00e92b3500c1a85526372a9bb5c00a6f6ca4dc0`. Sirve como antecedente del entorno. La prueba de observabilidad corresponde al SHA instrumentado de A en local. El 21 de noviembre, una consulta pública a `/actuator/health` confirmó HTTP 200 y `status=UP` tras reintentar con un plazo mayor. [Smoke de staging](https://github.com/taller-web-sigesu/backend-uni/actions/runs/43970286002).

## Evidencias y comandos

- [Dashboard de Grafana](evidencias-observabilidad/dashboard-local.png)
- [Respuesta HTTP, log y span](evidencias-observabilidad/peticion-correlacionada.json)
- [Consultas y valores de Prometheus](evidencias-observabilidad/prometheus-local.json)
- [Comandos y resultados sanitizados](evidencias-observabilidad/verificaciones.txt)

## Pendientes por dependencia

- **P2:** aplicar ambos commits, consolidar con A y registrar el resultado de CI del commit integrado.
- **Operaciones y P2:** comprobar el SHA desplegado, la recolección autorizada de staging, la recepción de trazas y el destino de las alertas del equipo.
- **Proveedor de observabilidad:** demostrar 30 días para logs y aportar la política efectiva de retención de métricas y trazas en staging.
