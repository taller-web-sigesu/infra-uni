# Release notes — `v1.0.0`

**Gestal / UniService: release final de la Fase IV.**  
Versión anterior: `v1.0.0-rc.2` (16/11/2026). Documento preparado el 22/11/2026 por el Grupo 3.

`v1.0.0` cierra las cuatro fases del curso. Sobre el Release Candidate de la Fase III, esta versión incorpora las decisiones de alcance, la sesión única por cuenta, los datos de demostración, la observabilidad, las pruebas de seguridad y de rendimiento y la documentación de cierre.

## 1. Novedades

### 1.1 Reglas de negocio (`backend-uni`)

- **Sesión única por cuenta** ([backend-uni#16](https://github.com/taller-web-sigesu/backend-uni/pull/16)). Un inicio de sesión válido revoca el JWT y el refresh token anteriores. Bloquea la cuenta, revalida las credenciales y emite la nueva sesión dentro de la misma transacción. Un intento inválido conserva la sesión vigente. La migración repetible `R__consolidar_sesiones_vigentes.sql` conserva solo la sesión más reciente de las cuentas que ya tenían varias.
- **Decisiones de alcance verificadas** ([backend-uni#17](https://github.com/taller-web-sigesu/backend-uni/pull/17), [infra-uni#25](https://github.com/taller-web-sigesu/infra-uni/pull/25)). Pruebas de integración para el rechazo motivado de duplicados, la asignación dentro del área y el rechazo con reingreso de reportes mal dirigidos.

### 1.2 Datos de demostración

- Migración `db/demo/V1001__ambientes_y_cuentas_fase_iv.sql`. No modifica las migraciones de producción.
- **Laboratorio 10** (`LAB-10`), a cargo de Soporte Informático, y **Cancha deportiva** (`CANCHA-01`), a cargo de Servicios Generales. Ambos abren de lunes a viernes de 07:00 a 22:00.
- Cuentas `supervisor.sg.demo@universidad.example` y `tecnico.sg.demo@universidad.example` de Servicios Generales.

### 1.3 Observabilidad ([backend-uni#18](https://github.com/taller-web-sigesu/backend-uni/pull/18))

- Métricas HTTP, JVM, Hikari y de negocio con Micrometer/Prometheus.
- Trazas con OpenTelemetry (OTLP/HTTP) hacia Tempo.
- Logs JSON con `correlationId`, `traceId` y `spanId`.
- Dashboard de Grafana versionado con tasa de requests, 5xx, p95, memoria, hilos, CPU, pool de conexiones, altas de negocio, rechazos de login, disponibilidad y despliegue.
- Seis alertas: `GestalHealthUnavailable`, `GestalHttp5xxHigh`, `GestalHttpP95High`, `GestalPoolSaturated`, `GestalDeploymentFailed` y `GestalLoginRejectionsHigh`.
- Runbook de incidentes en `backend-uni/observability/README.md`.
- Los endpoints de Actuator, salvo `health`, se protegen con una cuenta de recolección dedicada.

### 1.4 Seguridad

- Matriz de autorización por rol, método, ruta y recurso para las 64 operaciones de la API, Swagger y Actuator.
- Regresiones nuevas de autorización por recurso, adjuntos, descargas firmadas, Swagger y Actuator. Resultado: 13 pruebas unitarias y 94 de integración, sin fallos.
- Análisis pasivo con OWASP ZAP 2.16.1 sobre staging y escaneo de secretos con Gitleaks 8.28.0.
- Procedimiento de rotación de secretos documentado.

### 1.5 Rendimiento ([infra-uni#26](https://github.com/taller-web-sigesu/infra-uni/pull/26))

- Scripts k6 de carga, estrés y smoke de staging en `infra-uni/tests/performance/`.
- Carga local: unas 11 req/s, 0 % de errores, p95 total de 21,89 ms en el candidato.
- Estrés local: hasta 40 req/s durante 45 s, 0 % de errores, p95 total de 15,49 ms.

### 1.6 Interfaz (`frontend-uni`)

Los diez cambios de UI/UX acordados se documentan en `ANEXO-MEJORAS-UI-UX.pdf`, con el estado final de cada uno.

### 1.7 Documentación

Versión, release notes, informe final de las Fases I–IV, manual de usuario, manual técnico, guía del repositorio y presentación. Las fuentes Markdown están en `infra-uni/docs/entregables/` y los PDF en el Drive del curso.

## 2. Correcciones

- Se eliminaron los tags `v1.0.0` antiguos (`c8fe871`, `9d88468` y `67475d8`) para que `v1.0.0` apunte únicamente al `main` final.
- Se sanitizaron los resúmenes k6. Las evidencias no contienen JWT ni datos privados del setup.
- E2E de categorías: la prueba espera la recarga de la tabla ([frontend-uni#22](https://github.com/taller-web-sigesu/frontend-uni/pull/22)).

## 3. Decisiones de alcance de la Fase IV

| Tema | Decisión |
| :---- | :---- |
| Solicitudes duplicadas | Se aceptan los reportes. El supervisor revisa los posibles duplicados y rechaza el duplicado con un motivo (HU-11). |
| Sesión única | El último inicio de sesión válido reemplaza a los anteriores. |
| Asignación | El supervisor asigna dentro de su área. El administrador gestiona cuentas y catálogos. |
| Transferencia entre áreas | Excluida de `v1.0.0`. Se usa el rechazo motivado y el reingreso con la categoría correcta. |

## 4. Limitaciones conocidas

| Limitación | Detalle |
| :---- | :---- |
| CSP | El frontend en Vercel aún no envía `Content-Security-Policy` (hallazgo SEG-01, severidad media). |
| Evidencias en Render | Staging y producción guardan los adjuntos en almacenamiento temporal (`/tmp/evidencias`). Supabase Storage queda como evolución (ADR-0004). |
| Observabilidad en staging | La pila se verificó en local. La recolección, la recepción de trazas y el destino de las alertas en staging dependen de identificar el SHA desplegado. |
| Retención | Prometheus retiene 15 días y Tempo 7. La retención de 30 días para logs requiere un proveedor que la garantice. |
| Respaldos | La política es un respaldo diario de Railway con retención de 7 días. La prueba de restauración está pendiente de evidencia. |
| Sin notificaciones | No hay notificaciones in-app ni por correo, recuperación de contraseña por correo ni reservas recurrentes. |
| Cuentas demo | Staging tiene cuentas ficticias con una contraseña compartida. Se deshabilitan al terminar la demostración. |

La lista completa está en `DELIBERADAMENTE-NO-HECHO.md` de `infra-uni`.

## 5. Actualización

- **Local:** `git pull` en los tres repositorios y `iniciar.bat`. Flyway aplica `R__consolidar_sesiones_vigentes.sql` y, si `db/demo` está habilitado, `V1001`.
- **Staging:** despliegue automático desde `main`.
- **Producción:** PR `main` → `production` y workflow `deploy-production.yml` con aprobación.
- **Efecto visible:** al actualizar, las cuentas con varias sesiones conservan solo la más reciente. Las otras sesiones deben iniciar sesión de nuevo.
