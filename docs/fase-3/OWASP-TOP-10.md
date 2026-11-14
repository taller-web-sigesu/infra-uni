# OWASP Top 10 — Controles y evidencia

- **Fecha:** 14/11/2026
- **Alcance:** API REST de UniService, sesión, autorización, datos y despliegue local/staging.
- **Referencia:** OWASP Top 10 (2021).
- **Estado:** revisión inicial de los controles implementados. Los puntos marcados como pendientes no bloquean la operación actual, pero deben cerrarse antes de producción.

## Resumen

| Riesgo | Estado | Control implementado | Evidencia |
| --- | --- | --- | --- |
| A01 Broken Access Control | ✅ | RBAC por rol y por recurso; 404 fuera de alcance; 403 por operación; sin confiar en el rol del cliente | `SECURITY.md`, `AuthIT`, `RequestLifecycleIT`, `ReservationIT` |
| A02 Cryptographic Failures | ✅ | BCrypt costo 10; JWT HS256 de 15 min; refresh opaco de 256 bits; cookies `HttpOnly` y `Secure`; HTTPS en staging | `SECURITY.md`, `AuthIT`, `PasswordPolicy` |
| A03 Injection | ✅ | SQL parametrizado con `JdbcClient`; Bean Validation; tipo de archivo por contenido; sin SQL dinámico | Repositorios, DTO y pruebas de adjuntos |
| A04 Insecure Design | ⚠️ | Reglas de negocio, SLA, transiciones y alcance por recurso; falta un threat model formal | `SECURITY.md`, `ARCHITECTURE.md` |
| A05 Security Misconfiguration | ⚠️ | Variables de entorno, CORS explícito, health sin detalles, cabeceras en Vercel; Swagger/Actuator deben restringirse en producción | `application.yml`, `vercel.json`, `SecurityConfiguration` |
| A06 Vulnerable Components | ✅ | Versiones fijadas; CodeQL y revisión de dependencias en CI | `backend-ci.yml`, `pom.xml` |
| A07 Identification and Authentication Failures | ✅ | Límite de intentos, errores genéricos, revocación, rotación y detección de reúso de refresh | `LoginAttemptLimiter`, `SessionService`, `AuthIT` |
| A08 Software and Data Integrity Failures | ✅ | Flyway versionado, control de versión en solicitudes, auditoría y transacciones | Migraciones, `RequestWorkflowService`, `audit` |
| A09 Security Logging and Monitoring Failures | ⚠️ | `correlationId`, logs sin cuerpos ni credenciales; faltan alertas y retención centralizada | `CorrelationIdFilter`, `ADR-0003` |
| A10 Server-Side Request Forgery | ✅ | No se aceptan URLs de usuario; las claves de archivos las genera el servidor; Supabase usa URL fija | `AttachmentService`, `SECURITY.md` |

## Detalle

### A01 — Control de acceso

- El rol y el área se leen de la base en cada petición, no del JWT.
- Los recursos fuera del alcance responden `404` para no revelar su existencia.
- Un rol sin permiso recibe `403`.
- Pruebas: acceso de otro estudiante, técnico no asignado, supervisor de otra área y rutas administrativas.

**Pendiente:** revisar que todo endpoint nuevo tenga prueba de alcance antes de integrarse.

### A02 — Criptografía

- Contraseñas con BCrypt; nunca se devuelven hashes.
- Access token JWT corto y refresh token opaco; en base solo se guarda el SHA-256 del refresh.
- Cookie `HttpOnly`, `Secure` en staging/producción y `SameSite=Lax`.
- HTTPS obligatorio en Vercel/Render.

**Pendiente:** rotación documentada de `APP_JWT_SECRET` y de la clave de servicio de Supabase.

### A03 — Inyección

- Consultas parametrizadas con `JdbcClient`.
- Validación de entrada con Bean Validation y límites de tamaño.
- Los adjuntos se validan por contenido, no solo por extensión.
- La descarga agrega `nosniff` y `Content-Disposition: attachment`.

### A04 — Diseño inseguro

- Reglas explícitas de transición, SLA, autoaprobación y alcance por área.
- Auditoría de cambios y encuesta única por solicitud.

**Pendiente:** threat model formal con actores, activos, abusos y mitigaciones.

### A05 — Configuración

- CORS con orígenes explícitos y credenciales.
- `APP_COOKIE_SECURE=true` fuera de local.
- Actuator solo expone `health`; Swagger está habilitado para la demo.
- Vercel agrega `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy` y HSTS.

**Pendiente:** restringir Swagger/Actuator a la red interna o a usuarios autorizados en producción. Evaluar CSP después de probar la app con la política aplicada.

### A06 — Componentes

- Dependencias fijadas en `pom.xml` y `package-lock.json`.
- CodeQL para Java y `dependency-review-action` en PRs.
- Pruebas de integración con MySQL 8.4.13.

**Pendiente:** revisar alertas de dependencias antes de cada release.

### A07 — Autenticación

- Límite de 5 fallos por correo e IP en 15 minutos.
- Mensajes 401 genéricos.
- Revocación de sesiones al desactivar una cuenta, cambiar contraseña o detectar reúso de refresh.
- Primer ingreso obliga a cambiar contraseña.

### A08 — Integridad

- Migraciones Flyway no destructivas.
- `version_fila` para control de concurrencia.
- Auditoría de cambios con actor, campo y valores.
- Transacciones en las operaciones de estado y asignación.

### A09 — Logs y monitoreo

- `X-Correlation-ID` en las respuestas.
- Los logs no registran cuerpos de petición ni credenciales.
- Healthcheck en `/actuator/health`.

**Pendiente:** centralizar logs, definir alertas de 5xx, latencia y disponibilidad, y aplicar la retención de `ADR-0003`.

### A10 — SSRF

- No hay endpoints que reciban URLs para descargar.
- Las claves de archivos las genera el servidor.
- El proveedor de almacenamiento se configura por entorno, no por usuario.

## Pruebas recomendadas antes de producción

- [ ] Repetir las pruebas de autorización por recurso contra staging.
- [ ] Ejecutar OWASP ZAP baseline contra staging.
- [ ] Verificar que Swagger y Actuator no queden públicos sin decisión.
- [ ] Revisar logs de staging en busca de tokens, contraseñas o datos personales.
- [ ] Probar expiración y revocación de sesión con dos pestañas.
- [ ] Revisar dependencias y alertas de CodeQL.
