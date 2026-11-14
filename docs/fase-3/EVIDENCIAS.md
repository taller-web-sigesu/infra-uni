# Evidencias de Fase III — Staging y producción

- **Fecha:** 14/11/2026
- **Entornos:** staging y producción
- **Estado:** dos despliegues separados, con frontend, backend y base de datos conectados.
- **Informe completo:** [INFORME-FASE-III.md](INFORME-FASE-III.md)

## Dos despliegues

| Entorno | Frontend | Backend | Rama frontend | Rama backend | Base de datos |
| --- | --- | --- | --- | --- | --- |
| Staging | https://frontend-uni-tdk7.vercel.app | https://uniservice-backend-staging.onrender.com | `main` | `main` | Railway staging |
| Producción | https://frontend-uni-wx9m.vercel.app | https://uniservice-backend-prod.onrender.com | `production` | `production` | Railway producción |

Staging se actualiza al integrar en `main`. Producción se promueve con `main` → `production` y exige aprobación del environment `production`; Render producción tiene `Auto-Deploy: Off`.

## URLs de staging

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
- **Render:** servicio `uniservice-backend-prod`, repo `taller-web-sigesu/backend-uni`, branch `production`, `Auto-Deploy: Off`.
- **Despliegue:** workflow `deploy-production`, environment `production` con aprobación y smoke automático.
- **MySQL:** instancia de producción en Railway, separada de staging.
- **Admin inicial:** `admin@uniservice.app`; la contraseña se entrega por separado y el sistema obliga a cambiarla en el primer ingreso.
- **Datos demo:** no se cargan en producción (`APP_FLYWAY_LOCATIONS=classpath:db/migration`).
- **Evidencias:** almacenamiento local temporal en Render; persistencia pendiente.

## Infraestructura

| Componente | Staging | Producción |
| --- | --- | --- |
| Frontend | Vercel `frontend-uni-tdk7`, rama `main` | Vercel `frontend-uni-wx9m`, rama `production` |
| Backend | Render `uniservice-backend-staging`, rama `main`, auto-deploy | Render `uniservice-backend-prod`, rama `production`, sin auto-deploy |
| Base de datos | MySQL en Railway | MySQL en Railway, instancia distinta |
| Almacenamiento | Local temporal en Render (`/tmp/evidencias`) | Local temporal en Render (`/tmp/evidencias`) |

## Repositorios y referencias

| Repo | Staging (commit verificado) | Producción (commit verificado) |
| --- | --- | --- |
| `frontend-uni` | `a03afde` — restauración de sesión sin bloqueo | `3971af6` — merge de `main` con proxy a producción |
| `backend-uni` | `544e3d7` — smoke real de staging | `50caa78` — workflow de deploy de producción |
| `infra-uni` | `main` — documentación de Fase III | No aplica |

La referencia estable de la entrega es el tag **`v1.0.0-rc.1`** en los tres repos.

## Flujo verificado en staging

- [x] Frontend responde en `/` y `/login`.
- [x] Proxy `/api/v1/status` devuelve `{"status":"UP","service":"backend"}`.
- [x] Login con `ana.demo@universidad.example`.
- [x] Sesión persiste al recargar mediante cookie de refresh.
- [x] Creación de solicitud desde Vercel y lectura desde MySQL.
- [x] Render sirve el backend y aplica Flyway.
- [x] Railway responde con MySQL.
- [x] Cabeceras de seguridad: HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`.

## Cuentas de demostración (staging)

Todas usan la contraseña `Demo2026!`:

| Correo | Rol |
| --- | --- |
| `admin.demo@universidad.example` | Administrador |
| `supervisor.ti.demo@universidad.example` | Supervisor TI |
| `supervisor.mant.demo@universidad.example` | Supervisor Mantenimiento |
| `supervisor.bib.demo@universidad.example` | Supervisor Biblioteca |
| `tecnico.ti.demo@universidad.example` | Técnico TI |
| `tecnica.ti.demo@universidad.example` | Técnica TI |
| `tecnico.mant.demo@universidad.example` | Técnico Mantenimiento |
| `ana.demo@universidad.example` | Estudiante |
| `pedro.demo@universidad.example` | Docente |

Producción no carga cuentas demo. Su administrador inicial es `admin@uniservice.app`; la contraseña se entrega por el canal privado.

## Automatización

| Suite | Resultado |
| --- | --- |
| Frontend unitarias | 274 en verde |
| Frontend E2E simulado | 46 en verde, 2 omitidas por diseño |
| Frontend E2E real | 24 de 24 en verde |
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
- **Frontend CI validado:** https://github.com/taller-web-sigesu/frontend-uni/actions/runs/43587160904
- **Infra CI validado:** https://github.com/taller-web-sigesu/infra-uni/actions/runs/43583112971

## Releases

- Tag `v1.0.0` en los tres repos.
- **Release Candidate `v1.0.0-rc.1`:**
  - https://github.com/taller-web-sigesu/frontend-uni/releases/tag/v1.0.0-rc.1
  - https://github.com/taller-web-sigesu/backend-uni/releases/tag/v1.0.0-rc.1
  - https://github.com/taller-web-sigesu/infra-uni/releases/tag/v1.0.0-rc.1

## Pendiente

- Configurar almacenamiento persistente de evidencias (Supabase o disco).
- Ejecutar OWASP ZAP baseline / DAST y revisar logs de staging.
- Completar la revisión independiente de las PRs (en la recta final se usó bypass de administrador).
- Definir el dominio definitivo, si se solicita.
- Documentar y probar la rotación de secretos y los backups.
