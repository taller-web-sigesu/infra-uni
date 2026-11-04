# Plan de ingeniería pendiente — Gestal

- **Fecha:** 2026-11-04
- **Estado:** Aprobado; implementación pendiente
- **Alcance:** ingeniería pendiente (backend, frontend, migraciones, seguridad, pruebas, CI/CD, observabilidad, despliegue y backups)
- **Fuera de alcance:** pagos, chatbot con LLM, mensajería externa, API Gateway, microservicios y extensiones de producto (notificaciones, recuperación de contraseña, tiempo real, adjuntos y reservas recurrentes)
- **Decisiones:** [ADR-0002](../../adr/ADR-0002-autenticacion-sesion.md), [ADR-0003](../../adr/ADR-0003-observabilidad-retencion.md), [ADR-0004](../../adr/ADR-0004-despliegue-persistencia.md), [ADR-0005](../../adr/ADR-0005-ci-cd-calidad.md)
- **Diseño de datos:** [DISENIO-BD.md](../../../DISENIO-BD.md)

## 1. Contexto

El repositorio de infraestructura y los dos repositorios de aplicación existen, pero el producto está en estado de esqueleto:

- Backend: `GET /api/v1/status`, datasource, JPA y Actuator. Sin Spring Security, Bean Validation, Flyway, OpenAPI, pruebas ni módulos de negocio.
- Frontend: una pantalla de estado. Sin router, features, cliente HTTP, tests ni lint.
- Infraestructura: Compose local funcional. Sin CI/CD, Dockerfile de producción, observabilidad ni despliegue.

Este plan cierra esa brecha sin cambiar el alcance funcional aprobado.

## 2. Principios

1. **Contrato primero:** OpenAPI y `SECURITY.md` antes de implementar endpoints y pantallas.
2. **Migraciones versionadas:** el esquema implementado nace de Flyway, no de `ddl-auto`.
3. **Seguridad en el servidor:** ocultar botones no sustituye RBAC ni control por recurso.
4. **Evidencia reproducible:** cada fase deja pruebas, reportes y comandos ejecutados.
5. **Un solo desplegable:** monolito modular Spring Boot; sin microservicios ni API Gateway.
6. **Sin datos reales:** seeds y demos con datos ficticios.

## 3. Fase 0 — Contratos y decisiones

- [ ] Aprobar ADR-0002 a ADR-0005.
- [ ] Validar compatibilidad de versiones fijadas: Java 21, Spring Boot 4.1.2, MySQL 8.4.13, React 19.3.0, Vite 8.3.5.
- [ ] Crear `backend-uni/docs/api/openapi.yaml` con:
  - `GET /api/v1/status`.
  - `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh`, `POST /api/v1/auth/logout`.
  - Solicitudes: crear, listar, detallar, comentar.
  - Gestión: bandeja por área, asignar/reasignar, cambiar estado, cerrar/rechazar.
  - Dashboard y exportación.
  - Administración de usuarios y catálogos.
  - Reservas: espacios, disponibilidad, crear, aprobar, rechazar, cancelar.
- [ ] Crear `backend-uni/docs/SECURITY.md` con la matriz RBAC y permisos por recurso.
- [ ] Crear `backend-uni/docs/DATABASE.md` con convenciones, migraciones y diccionario resumido.
- [ ] Definir el formato de errores, paginación, fechas UTC e identificadores.
- **Aceptación:** OpenAPI validado, ADRs aprobados y documentos revisados por otro integrante.

## 4. Fase 1 — Backend

### 4.1. Fundaciones

- [ ] Añadir dependencias: Spring Security, Bean Validation, Flyway, springdoc OpenAPI, Micrometer Tracing, Testcontainers, JUnit 5 y Mockito.
- [ ] Configurar `spring.jpa.hibernate.ddl-auto=none` y Flyway.
- [ ] Migraciones:
  - `V1__esquema_inicial.sql`: tablas, FKs, índices, checks y vistas de `DISENIO-BD.md`.
  - `V2__catalogos_semilla.sql`: roles, áreas, prioridades, estados, categorías, SLA, tipos de espacio, estados de reserva, espacios, horarios y política de reservas.
  - `V3__datos_demostracion.sql` (opcional, solo demo): usuarios y solicitudes ficticias.
- [ ] Módulo `shared`: errores globales, DTO de error, validación, correlación, CORS, password encoder, configuración de seguridad y OpenAPI.
- [ ] Actuator protegido y health/readiness.

### 4.2. Módulos funcionales

- [ ] `auth`: login, refresh, logout, revocación y RBAC (HU-01, HU-02).
- [ ] `users`: perfil, usuarios, roles y áreas (HU-15).
- [ ] `catalogs`: áreas, categorías, prioridades, estados y SLA (HU-16, HU-17, HU-18).
- [ ] `requests`: registrar, listar, detallar y comentar (HU-03 a HU-06).
- [ ] `management`: bandeja del área, asignación, transiciones, cierre y rechazo (HU-07 a HU-11).
- [ ] `dashboard`: los 9 indicadores, filtros y exportación (HU-12 a HU-14).
- [ ] `reservations`: espacios, horarios, disponibilidad, reservas, aprobación y cancelación (HU-21 a HU-25).
- [ ] Auditoría y encuesta de satisfacción (HU-19, HU-20).

### 4.3. Pruebas y calidad

- [ ] Unitarias de servicios y reglas (JUnit 5 + Mockito).
- [ ] Integración de endpoints y migraciones con Testcontainers MySQL.
- [ ] Pruebas de autorización por recurso y transiciones inválidas.
- [ ] Cobertura mínima acordada por el equipo.
- **Aceptación:** `mvn verify` verde, endpoints conformes a OpenAPI y migraciones reproducibles desde una base vacía.

## 5. Fase 2 — Frontend

- [ ] Incorporar React Router y la organización `app/`, `components/`, `features/`, `services/`, `styles/`.
- [ ] App shell, navegación por rol, modo claro/oscuro, responsive y accesibilidad.
- [ ] Cliente HTTP centralizado con access token en memoria, refresh y reintento único ante 401.
- [ ] Features:
  - `auth` (login, logout, sesión).
  - `requests` (registro, listado, detalle, comentarios).
  - `management` (bandeja, asignación, estados).
  - `dashboard` (indicadores, filtros, exportación).
  - `administration` (usuarios, catálogos, espacios, horarios, política).
  - `reservations` (catálogo, disponibilidad, reserva, aprobación, cancelación).
- [ ] Estados de carga, vacío, error y confirmación en cada pantalla.
- [ ] Vitest + Testing Library, ESLint y Playwright.
- **Aceptación:** `npm run build`, lint y tests verdes; recorridos E2E de los flujos principales.

## 6. Fase 3 — CI/CD, seguridad y rendimiento

- [ ] Backend: workflow con compilación, unitarias, integración con Testcontainers, SAST, escaneo de dependencias, build de imagen y smoke.
- [ ] Frontend: workflow con `npm ci`, lint, tests, build y smoke/E2E.
- [ ] Infra: workflow con `docker compose config`, validación de scripts, escaneo de secretos y enlaces.
- [ ] Proteger `main`, exigir PR revisada y checks obligatorios.
- [ ] OWASP ZAP baseline sobre staging autorizado.
- [ ] k6 con un escenario de humo y latencia.
- [ ] Archivar reportes y artefactos como evidencia.
- **Aceptación:** un PR con tests fallidos no se integra; reportes disponibles.

## 7. Fase 4 — Observabilidad y operación

- [ ] Logs JSON con `correlationId`, `traceId` y `spanId`, sin datos sensibles.
- [ ] Métricas Micrometer y trazas con Micrometer Tracing/OpenTelemetry.
- [ ] Alertas de disponibilidad, 5xx, latencia p95 y conexiones MySQL.
- [ ] Retención según ADR-0003: logs 30 días, métricas 15 días, trazas 7 días.
- [ ] Backups automáticos, prueba de restauración y runbook.
- [ ] Runbooks de incidentes, despliegue y rollback.
- **Aceptación:** métricas y trazas visibles, alerta de prueba disparada y restauración verificada.

## 8. Fase 5 — Despliegue

- [ ] `Dockerfile` de producción del backend y build del frontend.
- [ ] Vercel, Render y MySQL gestionado según ADR-0004.
- [ ] Entornos `staging` y `production` separados.
- [ ] Secretos, HTTPS/TLS, CORS, cookies y dominios.
- [ ] Migraciones Flyway en el despliegue.
- [ ] Smoke tests, rollback y checklist de producción.
- **Aceptación:** staging desplegado, smoke tests aprobados, rollback probado y backups activos.

## 9. Trazabilidad de historias

| Fase | Historias / requisitos |
| --- | --- |
| Fase 0 | RNF-06, RNF-07, RNF-08, RNF-13, RNF-14 |
| Fase 1 | HU-01 a HU-25; RF-01 a RF-30; RNF-05 a RNF-17 |
| Fase 2 | HU-01 a HU-25; RNF-01 a RNF-04, RNF-10 |
| Fase 3 | RNF-07, RNF-14, RNF-18 |
| Fase 4 | RNF-12, RNF-15 |
| Fase 5 | RNF-11 |

## 10. Dependencias y orden

1. ADRs y OpenAPI antes de implementar.
2. Migraciones y `shared` antes de los módulos.
3. `auth` antes de cualquier endpoint protegido.
4. `requests` antes de `management`, `dashboard` y `reservations`.
5. CI después de la primera suite de pruebas.
6. Observabilidad antes del despliegue a producción.
7. Staging antes de producción.

## 11. Definition of Done

- Especificación aprobada y trazable a una HU.
- Endpoint documentado en OpenAPI y probado.
- Pruebas unitarias y de integración ejecutadas con salida verificable.
- Autorización por rol y recurso cubierta.
- Migración Flyway reproducible.
- Logs y métricas sin datos sensibles.
- Documentación y registro de uso de IA actualizados.
- PR revisada por otro integrante.

## 12. Riesgos

- Compatibilidad de Spring Boot 4.1.2 con Spring Security, springdoc y Micrometer Tracing.
- Proveedor MySQL gestionado: costo, backups y latencia.
- Deriva entre OpenAPI y frontend si no se valida el contrato.
- Testcontainers requiere Docker en CI.
- Decisiones de producto pendientes: SLA, cierre/reapertura, catálogos reales, retención de auditoría, feriados y límites de reservas.
- Ramas apiladas sobre la documentación de reservas; si se quieren PRs independientes, integrar primero la de reservas.
