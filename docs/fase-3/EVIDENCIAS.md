# Evidencias de Fase III — Staging

- **Fecha:** 14/11/2026
- **Entorno:** staging
- **Estado:** frontend, backend y base de datos desplegados y conectados.

## URLs

| Servicio | URL |
| --- | --- |
| Frontend | https://frontend-uni-tdk7.vercel.app |
| Backend | https://uniservice-backend-staging.onrender.com |
| Salud del backend | https://uniservice-backend-staging.onrender.com/actuator/health |
| API a través del frontend | https://frontend-uni-tdk7.vercel.app/api/v1/status |
| Swagger | https://uniservice-backend-staging.onrender.com/swagger-ui.html |
| OpenAPI | https://uniservice-backend-staging.onrender.com/v3/api-docs |

## Infraestructura

| Componente | Proveedor | Detalle |
| --- | --- | --- |
| Frontend | Vercel | Proyecto `frontend-uni-tdk7`, repo `taller-web-sigesu/frontend-uni`, branch `main` |
| Backend | Render | Servicio `uniservice-backend-staging`, repo `taller-web-sigesu/backend-uni`, auto-deploy on commit |
| Base de datos | Railway | MySQL gestionado, conectado al backend |
| Almacenamiento | Local en Render | Evidencias en `/tmp/evidencias`; para persistencia definitiva usar Supabase Storage |

## Repositorios y commits

| Repo | `main` |
| --- | --- |
| `frontend-uni` | `ee2884f` — fallback SPA y proxy `/api` |
| `backend-uni` | `c8fe871` — correcciones de QA |
| `infra-uni` | `67475d8` — compose y documentación sincronizada |

## Flujo verificado en staging

- [x] Frontend responde en `/` y `/login`.
- [x] Proxy `/api/v1/status` devuelve `{"status":"UP","service":"backend"}`.
- [x] Login con `ana.demo@universidad.example`.
- [x] Sesión persiste al recargar mediante cookie de refresh.
- [x] Creación de solicitud desde Vercel y lectura desde MySQL.
- [x] Render sirve el backend y aplica Flyway.
- [x] Railway responde con MySQL.
- [x] Cabeceras de seguridad: HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`.

## Cuentas de demostración

Todas usan la contraseña `Demo2026!`:

- `admin.demo@universidad.example`
- `supervisor.ti.demo@universidad.example`
- `tecnico.ti.demo@universidad.example`
- `ana.demo@universidad.example`
- `pedro.demo@universidad.example`

## Automatización

| Suite | Resultado |
| --- | --- |
| Frontend unitarias | 274 en verde |
| Frontend E2E | 48 en verde, 2 omitidas |
| Backend unitarias | 13 en verde |
| Backend integración | 79 en verde |
| Contrato OpenAPI | Validado y comparado en CI |
| CodeQL | En verde |
| Dependencias | Revisión en PR |

## CI/CD

- **Frontend:** GitHub Actions `ci` + deploy automático de Vercel al pushear a `main`.
- **Backend:** GitHub Actions `backend-ci` + auto-deploy de Render al pushear a `main`.
- **Infraestructura:** workflow `infra-ci` con validación de compose, variables y scripts.
- **Rama `main`:** protegida en frontend y backend con PR y checks requeridos.

## Releases

- Tag `v1.0.0` en los tres repos.

## Pendiente para producción

- Crear base, backend y frontend de producción separados.
- Configurar promoción manual staging → producción.
- Configurar almacenamiento persistente de evidencias.
- Ejecutar ZAP baseline y revisar logs de staging.
- Crear el tag/release del Release Candidate.
