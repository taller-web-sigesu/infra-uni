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

## Producción

| Servicio | URL |
| --- | --- |
| Frontend | https://frontend-uni-wx9m.vercel.app |
| Backend | https://uniservice-backend-prod.onrender.com |
| Salud del backend | https://uniservice-backend-prod.onrender.com/actuator/health |
| API a través del frontend | https://frontend-uni-wx9m.vercel.app/api/v1/status |
| Swagger | https://uniservice-backend-prod.onrender.com/swagger-ui.html |
| OpenAPI | https://uniservice-backend-prod.onrender.com/v3/api-docs |

- **Vercel:** proyecto `frontend-uni-wx9m`, repo `taller-web-sigesu/frontend-uni`, rama de producción `production`.
- **Render:** servicio `uniservice-backend-prod`, repo `taller-web-sigesu/backend-uni`, branch `main`.
- **MySQL:** instancia de producción en Railway.
- **Admin inicial:** `admin@uniservice.app`; la contraseña se entrega por separado y el sistema obliga a cambiarla en el primer ingreso.
- **Datos demo:** no se cargan en producción (`APP_FLYWAY_LOCATIONS=classpath:db/migration`).
- **Evidencias:** almacenamiento local temporal en Render; persistencia pendiente.

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
| Smoke de API staging | Health, login, estado y flujo real de solicitud en verde (`staging-smoke`) |
| Deploy de producción | Hook de Render, espera de health y smoke en verde (`deploy-production`) |

## CI/CD

- **Frontend staging:** GitHub Actions `ci` + deploy automático de Vercel al pushear a `main`.
- **Frontend producción:** deploy automático al pushear a la rama `production`; la promoción se hace mergeando `main` → `production`.
- **Backend staging:** GitHub Actions `backend-ci` + auto-deploy de Render al pushear a `main`.
- **Backend producción:** rama `production` protegida, Render con `Auto-Deploy: Off` y workflow `deploy-production` con environment `production` (aprobación de revisores), Deploy Hook de Render y smoke automático.
- **Infraestructura:** workflow `infra-ci` con validación de compose, variables y scripts.
- **Ramas protegidas:** `main` en los tres repos y `production` en el backend, con PR y checks requeridos.
- **Aprobación de producción:** environment `production` con revisores `kuki236` y `LuisibrosGD`.
- **Deploy de producción validado:** https://github.com/taller-web-sigesu/backend-uni/actions/runs/43582054889
- **Smoke de staging validado:** https://github.com/taller-web-sigesu/backend-uni/actions/runs/43582997332

## Releases

- Tag `v1.0.0` en los tres repos.
- **Release Candidate `v1.0.0-rc.1`:**
  - https://github.com/taller-web-sigesu/frontend-uni/releases/tag/v1.0.0-rc.1
  - https://github.com/taller-web-sigesu/backend-uni/releases/tag/v1.0.0-rc.1
  - https://github.com/taller-web-sigesu/infra-uni/releases/tag/v1.0.0-rc.1

## Pendiente

- Configurar almacenamiento persistente de evidencias (Supabase o disco).
- Ejecutar ZAP baseline y revisar logs de staging.
- Definir el dominio definitivo, si se solicita.
- Documentar la rotación de secretos y backups.
