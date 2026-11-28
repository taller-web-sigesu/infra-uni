<div class="portada">

# Índice de evidencias

**Gestal / UniService**

Sistema Web para la Gestión Integral de Servicios Universitarios

Fase IV · Entrega final (`v1.0.0`) · 27/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

Responsable: Persona 5 (QA y verificación)

</div>

## 1. Propósito

Este documento centraliza los enlaces y referencias a todas las evidencias técnicas, funcionales, de seguridad, rendimiento, observabilidad, calidad de interfaz y cierre de entrega del proyecto Gestal / UniService. Permite a P1 y al docente verificar cada requisito sin buscar archivos dispersos entre repositorios y carpetas del Drive.

## 2. Repositorios y pipelines CI/CD

Estado verificado al 27/11/2026 sobre la rama `main` de los tres repositorios de la organización [taller-web-sigesu](https://github.com/taller-web-sigesu).

| Repositorio | Commit `main` | Workflow | Estado | Enlace de evidencia |
| --- | --- | --- | --- | --- |
| `backend-uni` | `8136b68` | `backend-ci` (CodeQL, contrato OpenAPI, migraciones, 13 unitarias, 94 integración, imagen y smoke) | Verde | <https://github.com/taller-web-sigesu/backend-uni/actions/runs/46075021436> |
| `backend-uni` | `8136b68` | `staging-smoke` (verificación contra Render staging) | Verde | <https://github.com/taller-web-sigesu/backend-uni/actions/runs/46078054975> |
| `frontend-uni` | `0d950e3` | `ci` (ESLint, 289 Vitest, build, 108 Playwright cross-browser + axe) | Verde | <https://github.com/taller-web-sigesu/frontend-uni/actions/runs/46083003177> |
| `frontend-uni` | `0d950e3` | `codeql` (SAST JavaScript/TypeScript) | Verde | <https://github.com/taller-web-sigesu/frontend-uni/actions/runs/46083003163> |
| `infra-uni` | `942adc6` | `infra-ci` (Compose, variables, scripts, secretos, enlaces Markdown) | Verde | <https://github.com/taller-web-sigesu/infra-uni/actions/runs/46084152235> |

### Pull Requests clave de Fase IV

- `backend-uni`: [PR #16 Sesión única](https://github.com/taller-web-sigesu/backend-uni/pull/16), [PR #17 Datos demo y reglas](https://github.com/taller-web-sigesu/backend-uni/pull/17), [PR #18 Observabilidad y seguridad](https://github.com/taller-web-sigesu/backend-uni/pull/18), [PR #19 Migración demo idempotente](https://github.com/taller-web-sigesu/backend-uni/pull/19).
- `frontend-uni`: [PR #23 Mejoras UI/UX Fase IV](https://github.com/taller-web-sigesu/frontend-uni/pull/23), [PR #24 Content-Security-Policy](https://github.com/taller-web-sigesu/frontend-uni/pull/24), [PR #25 SAST CodeQL](https://github.com/taller-web-sigesu/frontend-uni/pull/25).
- `infra-uni`: [PR #25 Decisiones Fase IV](https://github.com/taller-web-sigesu/infra-uni/pull/25), [PR #26 Consolidación de reportes](https://github.com/taller-web-sigesu/infra-uni/pull/26), [PR #27 Fuentes documentos P4](https://github.com/taller-web-sigesu/infra-uni/pull/27), [PR #28 Cierre staging P2](https://github.com/taller-web-sigesu/infra-uni/pull/28), [PR #29 Cierre SAST, DAST y restore P2](https://github.com/taller-web-sigesu/infra-uni/pull/29).

## 3. Evidencias de seguridad (SAST, DAST, secretos y autorización)

| Evidencia | Descripción | Ubicación / Enlace |
| --- | --- | --- |
| Informe de seguridad Fase IV | Hallazgos SEG-01 a SEG-07, escaneo Gitleaks 8.28.0 y rotación de secretos | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/INFORME-SEGURIDAD-P2.md> |
| Matriz de autorización | Contrato por rol, método, ruta y recurso (64 operaciones + Actuator + Swagger) | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/MATRIZ-AUTORIZACION-P2.md> |
| Resumen DAST activo | OWASP ZAP 2.17.0 sobre login staging, Swagger UI y `/api/v1/status` (0 altos) | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/RESUMEN-DAST.md> |
| Reportes HTML ZAP | Reportes generados para frontend, Swagger y status | <https://github.com/taller-web-sigesu/infra-uni/tree/main/docs/fase-4/evidencias-dast> |
| SAST Backend (CodeQL) | Job `Análisis estático (CodeQL)` en verde | <https://github.com/taller-web-sigesu/backend-uni/actions/runs/46075021436/job/140760617222> |
| SAST Frontend (CodeQL) | Workflow `codeql.yml` en verde | <https://github.com/taller-web-sigesu/frontend-uni/actions/runs/46083003163> |
| PDF consolidado de P2 | Evidencias técnicas de observabilidad, seguridad y carga | Drive: `06-Evidencias/EVIDENCIAS-TECNICAS.pdf` |
| Complementos de cierre P2 | Cierre de staging y cierre SAST/DAST/restauración (27/11/2026) | Drive: `06-Evidencias/CIERRE-P2.pdf` y `06-Evidencias/CIERRE-P2-SEGURIDAD.pdf` |

## 4. Evidencias de rendimiento (k6)

| Escenario | Resultado resumido | Ubicación / Enlace |
| --- | --- | --- |
| Informe de rendimiento | Comparativa base local, candidato local y smoke staging | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/performance-p2.md> |
| Scripts k6 | `load.js`, `stress.js`, `staging-smoke.js` y ejecutores PowerShell | <https://github.com/taller-web-sigesu/infra-uni/tree/main/tests/performance> |
| Carga local candidato | 1480 peticiones, ~11,01 req/s, 0 % error, p95 21,89 ms | <https://github.com/taller-web-sigesu/infra-uni/tree/main/docs/fase-4/evidencias-performance/local-candidato> |
| Estrés local candidato | 4659 peticiones, hasta 40 req/s (45 s), 0 % error, p95 15,49 ms | <https://github.com/taller-web-sigesu/infra-uni/tree/main/docs/fase-4/evidencias-performance/local-candidato> |
| Smoke staging final (`8136b68`) | 6 peticiones, 12/12 checks, 0 % error, p95 441,89 ms | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/evidencias-performance/staging-final/smoke-k6.json> |

## 5. Evidencias de observabilidad y respaldo/restauración

| Evidencia | Descripción | Ubicación / Enlace |
| --- | --- | --- |
| Informe de observabilidad | Micrometer, Prometheus, Tempo, Grafana, 6 alertas y correlación | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/observabilidad-p2.md> |
| Dashboard Grafana local | Capturas de dashboard general, carga y estrés | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/evidencias-observabilidad/dashboard-local.png> |
| Correlación petición/log/span | Coincidencia de `X-Correlation-ID`, `traceId` y `spanId` | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/evidencias-observabilidad/peticion-correlacionada.json> |
| Verificación staging final | Salud, datos demo, sesión única y CSP en staging (`8136b68`) | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/VERIFICACION-STAGING-FINAL.md> |
| Respaldo y restauración MySQL | Volcado y restauración en base temporal: 27 tablas, 460 filas, 0 diferencias | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/VERIFICACION-BACKUP-RESTORE.md> |
| Resultado JSON de restore | Conteos por tabla y SHA-256 del volcado | <https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-4/evidencias-backup/restore-result.json> |

## 6. Evidencias de UI/UX, accesibilidad, cross-browser y pruebas funcionales

| Evidencia | Descripción | Ubicación / Enlace |
| --- | --- | --- |
| Anexo de mejoras UI/UX (P3) | Estado de los 10 puntos, 5 hallazgos adicionales y contraste con Figma | Drive: `02-Documentacion/ANEXO-MEJORAS-UI-UX.pdf` |
| Informe de pruebas (P5) | Pruebas funcionales, regresión, seguridad caja negra, accesibilidad, cross-browser, UAT y usabilidad | Drive: `02-Documentacion/INFORME-DE-PRUEBAS.pdf` |
| Verificación final (P5/P1) | Checklist de repositorios, Drive, PDFs, enlaces, tags y aprobación | Drive: `06-Evidencias/VERIFICACION-FINAL.pdf` |
| Suites E2E y accesibilidad | `a11y.spec.js`, `administracion.spec.js`, `reservas.spec.js`, `sesion.spec.js`, `solicitudes.spec.js` | <https://github.com/taller-web-sigesu/frontend-uni/tree/main/e2e> |
| Capturas funcionales de pantallas | 20 capturas por rol incluidas en el manual de usuario | <https://github.com/taller-web-sigesu/infra-uni/tree/main/docs/entregables/assets/manual> |
| Prototipo de referencia Figma | Vistas P00, P11, P12 y P13 en GESTAL V2 | <https://www.figma.com/design/9qJJaiyMwZ1ZON36LkmbyR/GESTAL-V2?node-id=0-1> |

## 7. Entornos en vivo y documentación de entrega

| Recurso | URL o ruta |
| --- | --- |
| Frontend Staging | <https://frontend-uni-tdk7.vercel.app> |
| Backend Staging (Salud) | <https://uniservice-backend-staging.onrender.com/actuator/health> |
| Backend Staging (Swagger UI) | <https://uniservice-backend-staging.onrender.com/swagger-ui/index.html> |
| Frontend Producción | <https://frontend-uni-wx9m.vercel.app> |
| Backend Producción (Salud) | <https://uniservice-backend-prod.onrender.com/actuator/health> |
| Guion de demostración | Drive: `08-Demostracion/GUION-DE-DEMOSTRACION.pdf` |
| Acta UAT y protocolo de usabilidad | Incluidos en `02-Documentacion/INFORME-DE-PRUEBAS.pdf` (secciones 7 y 8) |
| Video de respaldo de la demo | Reservado en `08-Demostracion/` tras el ensayo general (Plan B2) |

## 8. Matriz de entregables PDF en el Drive

| N.º | Carpeta | Archivo PDF | Responsable | Estado |
| --- | --- | --- | --- | --- |
| 1 | `01-Version-definitiva/` | `VERSION.pdf` | P4 | Disponible |
| 2 | `01-Version-definitiva/` | `RELEASE-NOTES.pdf` | P4 | Disponible |
| 3 | `02-Documentacion/` | `INFORME-FINAL-FASES-I-IV.pdf` | P4 | Disponible |
| 4 | `02-Documentacion/` | `INFORME-DE-PRUEBAS.pdf` | P5 | Generado |
| 5 | `02-Documentacion/` | `ANEXO-MEJORAS-UI-UX.pdf` | P3 | Disponible |
| 6 | `03-Manual-de-usuario/` | `MANUAL-DE-USUARIO.pdf` | P4 | Disponible |
| 7 | `04-Manual-tecnico/` | `MANUAL-TECNICO.pdf` | P4 | Disponible |
| 8 | `05-Repositorio/` | `GUIA-DEL-REPOSITORIO.pdf` | P4 | Disponible |
| 9 | `06-Evidencias/` | `INDICE-DE-EVIDENCIAS.pdf` | P5 | Generado |
| 10 | `06-Evidencias/` | `EVIDENCIAS-TECNICAS.pdf` | P2 | Disponible |
| 11 | `06-Evidencias/` | `VERIFICACION-FINAL.pdf` | P5 | Generado |
| 12 | `07-Presentacion/` | `PRESENTACION.pdf` | P4 | Disponible |
| 13 | `08-Demostracion/` | `GUION-DE-DEMOSTRACION.pdf` | P5 | Generado |
