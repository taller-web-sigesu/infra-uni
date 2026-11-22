# Gestal · Matriz de autorización de Fase IV

Revisión del 21 de noviembre de 2026. La revisión cruza `docs/api/openapi.yaml`, `docs/SECURITY.md`, `docs/OBSERVABILITY.md`, los controladores bajo `src/main/java/pe/edu/universidad/servicios`, `SecurityConfiguration`, los servicios de cada dominio y las pruebas de `src/test/java`. `OpenApiContractIT` comprueba las 64 operaciones publicadas en el contrato generado. La matriz incluye Actuator y Swagger.

La referencia de verificación es `backend-uni@79c5cdd17e5ffb944b3c9057e892a5f140b190ce`, que incorpora las regresiones de seguridad sobre el candidato local de E. El [informe](INFORME-SEGURIDAD-P2.md) registra los resultados locales, de CI y de staging.

**E** estudiante, **D** docente, **T** técnico, **S** supervisor, **A** administrador. **JWT** indica una sesión vigente con cuenta activa. Para rutas privadas, se espera `401` sin sesión, `403` para rol sin permiso y `404` para un recurso de negocio fuera de alcance cuando la operación comprueba su visibilidad. Los listados filtran antes de contar. El primer ingreso solo habilita cambio de contraseña, refresh y logout entre las operaciones autenticadas. Se omite el prefijo `/api/v1` en las rutas de negocio.

**Evidencia** identifica regresiones que cubren una parte o la totalidad de cada fila. **Pendiente** indica una combinación específica que no se ha ejercitado de forma directa. Los códigos `2xx` se refieren a peticiones válidas.

## Sesión, Swagger y Actuator

| Método y ruta | Rol o credencial | Alcance y respuesta esperada | Evidencia |
| --- | --- | --- | --- |
| `POST /auth/login` | Público | Cuenta activa y origen admitido → `200`, JWT y cookie. Fallo indistinguible → `401`. Credencial correcta con cuenta pendiente o rechazada → `403`. Tras cinco fallos por correo e IP → `429`. Nuevo ingreso válido revoca JWT y refresh anteriores. | `AuthIT`, `RegistrationIT` |
| `POST /auth/register` | Público | Correo institucional exacto, rol E pendiente impuesto por servidor → `201`; origen ajeno `403`, duplicado `409`, tras diez registros por IP `429`. | `RegistrationIT`, `RegistrationRateLimitIT` |
| `POST /auth/refresh` | Cookie propia | Sesión vigente, origen admitido, rotación `200`, vigencia absoluta de siete días; reúso o revocación `401`. | `AuthIT` |
| `POST /auth/logout` | JWT o cookie propios | Revoca la sesión y limpia la cookie → `204`; modo cookie valida origen. | `AuthIT` |
| `PATCH /auth/password` | JWT, E/D/T/S/A | Cuenta propia, clave actual y política → `200` con sesión nueva. Revoca las anteriores. | `AuthIT` |
| `GET /status` | Público | Estado público `200`. | `AuthIT`, `TelemetryIT` |
| `GET /actuator/health`, `GET /actuator/health/**` | Público | Raíz `200` si está UP, sin `details` ni `components`. Subrutas autorizadas por el filtro, respuesta según grupo disponible. | `TelemetryIT` raíz; pendiente comprobar los grupos publicados si se configuran explícitamente. |
| `GET /actuator/prometheus`, `/actuator/info`, `/actuator/metrics`, `/actuator/metrics/{nombre}` | Basic, cuenta `prometheus` | `200` para credencial válida y métrica existente. Anónimo, clave inválida y JWT de negocio → `401`. | `TelemetryIT`, con JWT A y E. Sin hash configurado, exclusión por código, pendiente prueba directa con perfil específico. |
| Otros métodos y endpoints Actuator | Ninguno | Cadena separada deniega por defecto. Credencial recolectora válida → `403` para `POST`, `HEAD`, `OPTIONS` y rutas excluidas; al presentarla a negocio → `401`. | `TelemetryIT`, raíz Actuator y `/actuator/env` |
| `GET /swagger-ui.html`, `/swagger-ui/index.html`, `/v3/api-docs`, `/v3/api-docs.yaml`, `/v3/api-docs/swagger-config` | Público | UI `302` a HTML `200`, configuración `200` apunta a JSON `200`; YAML `200`. OpenAPI excluye Actuator. | `OpenApiContractIT` |

## Solicitudes y adjuntos

| Método y ruta | Rol | Alcance y respuesta esperada | Evidencia |
| --- | --- | --- | --- |
| `POST /requests` | E, D | Crea solicitud propia con referencias activas `201`. Rol no autorizado `403`. | `RequestLifecycleIT` |
| `GET /requests` | E, D, T, S | E/D propias, T asignación vigente, S su área; `200` con total filtrado. A `403`. | `RequestLifecycleIT` |
| `GET /requests/{id}`, `GET /requests/{id}/history` | E, D, T, S | Propietario, T asignado o S del área → `200`. Ajeno → `404`. | `RequestLifecycleIT`, con historial propio y ajeno. |
| `GET /requests/{id}/comments`, `POST /requests/{id}/comments` | E, D, T, S | Mismo alcance del detalle; lectura `200`, alta `201`, ajeno `404` y sin escritura. | `RequestLifecycleIT` |
| `GET /requests/{id}/audit-events` | S | S del área `200`, otro S `404`, resto `403`. | `RequestLifecycleIT` |
| `GET /requests/{id}/eligible-technicians` | S | S de la misma área `200`; otro S `404`, resto `403`. | `RequestLifecycleIT` cubre consulta autorizada; pendiente denegación directa de esta ruta. |
| `POST /requests/{id}/assignments` | S | S del área, técnico activo de su área y solicitud abierta → `201`; otro S `404`, A `403`, técnico de otra área `400`, estado terminal `409`. | `RequestLifecycleIT` |
| `PATCH /requests/{id}` | S | S del área y solicitud abierta `200`; otro S `404`, resto `403`, terminal `409`. Mantiene SLA. | `RequestLifecycleIT` cubre actualización y SLA; pendiente denegación directa por rol y área para esta ruta. |
| `PATCH /requests/{id}/status` | T, S | T asignado: EN_PROCESO/RESUELTO. S del área: CERRADO/RECHAZADO. Válido `200`, fuera de alcance `404`, destino sin permiso `403`, transición inválida `409`. | `RequestLifecycleIT` |
| `POST /requests/{id}/survey` | E, D | Propietario, cerrada, una por solicitud → `201`; ajena `404`, prematura o duplicada `409`. | `RequestLifecycleIT` cubre alta y duplicado; pendiente denegación directa de encuesta ajena. |
| `GET /requests/{id}/attachments` | E, D, T, S | Mismo alcance del detalle; `200` o `404`. | `AttachmentIT` |
| `POST /requests/{id}/attachments` | E, D, T, S | Mismo alcance. Abierta, tipo por contenido, máximo cinco adjuntos vigentes y 5 MB → `201`; ajena `404`, cerrada/rechazada `409`. | `AttachmentIT`, `AttachmentFailureIT` |
| `GET /requests/{id}/attachments/{attachmentId}/content` | E, D, T, S | Adjunto de esa solicitud y alcance del detalle → binario `200` con `attachment` y `nosniff`, o URL firmada `302`; anónimo `401`; ajeno `404`, sin firma ni `Location`. | `AttachmentIT`, `SignedDownloadIT`; proveedor de firma simulado, sin acceso real a Supabase. |
| `DELETE /requests/{id}/attachments/{attachmentId}` | E, D, T, S | Solo autor, solicitud abierta → `204`; otro autor con acceso `403`, fuera del alcance `404`, terminal `409`. | `AttachmentIT` |

## Administración, catálogos y paneles

| Método y ruta | Rol | Alcance y respuesta esperada | Evidencia |
| --- | --- | --- | --- |
| `GET /admin/users`, `/admin/users/{id}`, `/admin/users/pending`, `/admin/roles` | A | Acceso administrativo global `200`; otros roles `403`. | `AccountAdminIT`, `RegistrationIT`; pendiente prueba negativa directa por cada ruta. |
| `POST /admin/users`, `PATCH /admin/users/{id}` | A | Alta `201` o edición `200`. No se permite cambiar el propio rol ni desactivarse `403`; T/S requieren área activa; desactivar revoca sesiones. | `AccountAdminIT`, `AuthIT` |
| `PATCH /admin/users/{id}/account-status`, `POST /admin/users/{id}/password-reset` | A | Decisión de cuenta `200`; reset de otra cuenta activa `200` con `no-store`, temporal de primer ingreso y revocación. Rol ajeno `403`. | `RegistrationIT`, `AccountAdminIT` |
| `GET /catalogs/categories`, `GET /admin/catalogs/priorities` | E, D, T, S, A | Catálogo de categorías habilitadas y lectura de prioridades `200`. | `AdminCatalogIT`, `RequestLifecycleIT` |
| `GET`, `POST /admin/catalogs/areas`, `/admin/catalogs/categories`; `PATCH /admin/catalogs/areas/{id}`, `/admin/catalogs/categories/{id}` | A | Gestión global `200`/`201`, resto `403`; baja con dependencias `409`. | `AdminCatalogIT`; cobertura negativa representativa. |
| `POST /admin/catalogs/priorities`, `PATCH /admin/catalogs/priorities/{id}`; `GET /admin/catalogs/request-statuses`, `PATCH /admin/catalogs/request-statuses/{id}` | A | Gestión global `200`/`201`; edición de código `400`, rol ajeno `403`. | `AdminCatalogIT`; cobertura negativa representativa. |
| `GET`, `POST /admin/sla-policies`; `PATCH /admin/sla-policies/{id}` | A | Gestión global `200`/`201`; rol ajeno `403`. | `SlaAndDashboardIT` |
| `GET /dashboard/summary`, `GET /dashboard/reports` | S, A | S de su área `200`, consulta de otra área `403`; A global o por área `200`. | `SlaAndDashboardIT` |

## Espacios y reservas

| Método y ruta | Rol | Alcance y respuesta esperada | Evidencia |
| --- | --- | --- | --- |
| `GET /spaces`, `GET /spaces/{id}/availability` | E, D, T, S, A | Espacios y tipos activos → `200`; inactivo o ausente en consulta puntual → `404`. | `ReservationIT`, `DemoDataIT` |
| `POST /reservations` | E, D, T, S, A | Alta propia `201` para espacio activo y franja válida; conflicto de reglas `409`. | `ReservationIT` |
| `GET /reservations` | E, D, T, S, A | `vista=propias` para todos, `vista=gestion` solo S de área o A y solo pendientes; otros roles → `403`. | `ReservationIT`; pendiente prueba directa de aislamiento para ambas vistas y de espacio sin área. |
| `GET /reservations/{id}`, `GET /reservations/{id}/history` | Propietario, S del área, A | Alcance propio, área o global → `200`, fuera → `404`; espacio sin área solo gestionable por A. | `ReservationIT` cubre detalle y flujo de historial. Pendiente cruce de historial ajeno por rol. |
| `PATCH /reservations/{id}/status` | Propietario, S del área, A según destino | S o A decide sobre pendiente ajena; autoaprobación `403`. Solo titular puede cancelar antes de inicio. Fuera de área para S `404`, transición inválida `409`. | `ReservationIT` |
| `GET`, `POST /admin/spaces`, `/admin/space-types`; `PATCH /admin/spaces/{id}`, `/admin/space-types/{id}` | A | Gestión global `200`/`201`; rol ajeno `403`. | `ReservationIT`, denegación representativa. |
| `GET`, `PUT /admin/spaces/{id}/schedule`, `/admin/reservation-policy` | A | Gestión global `200`; rol ajeno `403`. Aprobación obligatoria. | `ReservationIT` |
