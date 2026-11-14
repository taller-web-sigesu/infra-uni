# Informe de Fase III — APIs, nube, DevOps y seguridad

- **Proyecto:** UniService / Universidad Actúa
- **Fecha:** 14/11/2026
- **Producto entregado:** Release Candidate `v1.0.0-rc.1`
- **Repositorios:**
  - [frontend-uni](https://github.com/taller-web-sigesu/frontend-uni)
  - [backend-uni](https://github.com/taller-web-sigesu/backend-uni)
  - [infra-uni](https://github.com/taller-web-sigesu/infra-uni)
- **Documentos relacionados:** [EVIDENCIAS.md](EVIDENCIAS.md), [PROMOCION-Y-ROLLBACK.md](PROMOCION-Y-ROLLBACK.md), [OWASP-TOP-10.md](OWASP-TOP-10.md), [API-PANORAMA.md](API-PANORAMA.md), [PRUEBAS-IA.md](PRUEBAS-IA.md)

## 1. Resumen ejecutivo

UniService es una mesa de ayuda universitaria con frontend React, API REST Spring Boot y MySQL gestionado. La Fase III se cerró con **dos despliegues reales y separados**:

| Entorno | Frontend | Backend | Base de datos | Rama del frontend | Rama del backend |
| --- | --- | --- | --- | --- | --- |
| **Staging** | https://frontend-uni-tdk7.vercel.app | https://uniservice-backend-staging.onrender.com | MySQL en Railway | `main` | `main` |
| **Producción** | https://frontend-uni-wx9m.vercel.app | https://uniservice-backend-prod.onrender.com | MySQL en Railway (instancia distinta) | `production` | `production` |

Los dos entornos tienen bases de datos separadas, variables de entorno propias y ciclos de despliegue distintos. Staging se actualiza al integrar cambios en `main`; producción solo recibe un cambio después de una aprobación manual en GitHub y del smoke automático.

El Release Candidate está publicado como **pre-release** en los tres repositorios:

- https://github.com/taller-web-sigesu/frontend-uni/releases/tag/v1.0.0-rc.1
- https://github.com/taller-web-sigesu/backend-uni/releases/tag/v1.0.0-rc.1
- https://github.com/taller-web-sigesu/infra-uni/releases/tag/v1.0.0-rc.1

## 2. Los dos despliegues

### 2.1 Staging

- **Frontend:** Vercel, proyecto `frontend-uni-tdk7`, rama `main`.
- **Backend:** Render, servicio `uniservice-backend-staging`, rama `main`, auto-deploy al hacer push.
- **Base de datos:** MySQL en Railway, independiente de producción.
- **Datos:** migraciones Flyway y cuentas de demostración (`classpath:db/demo`).
- **Swagger:** https://uniservice-backend-staging.onrender.com/swagger-ui.html
- **OpenAPI:** https://uniservice-backend-staging.onrender.com/v3/api-docs

Staging es el entorno de integración y de pruebas. Es el entorno recomendado para que el docente pruebe la aplicación con las cuentas demo.

### 2.2 Producción

- **Frontend:** Vercel, proyecto `frontend-uni-wx9m`, rama `production`.
- **Backend:** Render, servicio `uniservice-backend-prod`, rama `production`.
- **Base de datos:** MySQL en Railway, instancia separada de staging.
- **Datos:** solo migraciones (`classpath:db/migration`), sin cuentas ni datos demo.
- **Swagger:** https://uniservice-backend-prod.onrender.com/swagger-ui.html
- **OpenAPI:** https://uniservice-backend-prod.onrender.com/v3/api-docs
- **Administrador inicial:** `admin@uniservice.app`. La contraseña se entrega por el canal privado del equipo y el sistema obliga a cambiarla en el primer ingreso.

Producción **no tiene auto-deploy en Render**. El flujo es:

1. Se integra el cambio en `main` y se valida en staging.
2. Se promueve `main` → `production` con PR y checks.
3. El push a `production` dispara `deploy-production.yml`.
4. El job queda esperando la aprobación del environment `production`.
5. Al aprobar, el workflow llama al Deploy Hook de Render, espera `health = UP` y ejecuta el smoke.
6. Si el smoke falla, el workflow falla y se hace rollback al deploy anterior.

### 2.3 Por qué hay dos despliegues

- **Aislamiento:** un error en staging no afecta a producción.
- **Datos separados:** las pruebas no contaminan la base real.
- **Promoción controlada:** producción exige aprobación y smoke.
- **Configuración por entorno:** CORS, cookies, base de datos y almacenamiento se definen por variables.
- **Rollback independiente:** se puede volver atrás en Vercel o Render sin tocar el otro entorno.

## 3. Cumplimiento de la rúbrica

### 3.1 Cloud + CI/CD

| Punto | Estado | Evidencia |
| --- | --- | --- |
| Selección de plataforma cloud | Cumplido | ADR-0004 aceptado: Vercel + Render + Railway MySQL |
| Docker | Cumplido | `backend-uni/Dockerfile` de producción, `Dockerfile.dev` en frontend y backend, `infra-uni/compose.yaml` |
| Ambientes de desarrollo/prueba/producción | Cumplido | Local, CI, staging y producción, con bases separadas |
| Git | Cumplido | Tres repositorios con historial y PRs |
| Ramas | Cumplido | `main` protegida en los tres repos; `production` protegida en backend y usada para el frontend de producción |
| Integración continua | Cumplido | `backend-ci.yml`, `ci.yml` del frontend e `infra-ci.yml` |
| Despliegue | Cumplido | Staging y producción con URLs públicas |
| Pipeline CI/CD | Cumplido | `deploy-production.yml` con environment, Deploy Hook, health y smoke; `staging-smoke.yml` con flujo real |

### 3.2 API REST

| Punto | Estado | Evidencia |
| --- | --- | --- |
| Diseño de recursos | Cumplido | Solicitudes, reservas, usuarios, catálogos, SLA, auditoría, dashboard y adjuntos |
| Rutas | Cumplido | Prefijo versionado `/api/v1` |
| Parámetros | Cumplido | Filtros, paginación, fechas, estado y búsqueda |
| Códigos HTTP | Cumplido | 200, 201, 204, 400, 401, 403, 404, 409 y 429; errores `application/problem+json` |
| Documentación | Cumplido | `backend-uni/docs/api/openapi.yaml`, Swagger y `/v3/api-docs` |
| Pruebas de API | Cumplido | Contrato OpenAPI, integración con Testcontainers y smoke real contra staging |
| Panorama de GraphQL/gRPC/webhooks | Cumplido | `API-PANORAMA.md` con análisis y decisión |
| API Gateway | Cumplido | `API-PANORAMA.md`: comparación y decisión de no usar gateway propio |

El smoke real de staging verifica: login de estudiante, login de supervisor, selección de una categoría del área del supervisor, creación de una solicitud, lectura de la solicitud y visibilidad en la bandeja del supervisor.

### 3.3 Seguridad

| Punto | Estado | Evidencia |
| --- | --- | --- |
| Autenticación | Cumplido | Login, logout, bloqueo por intentos y errores genéricos |
| Autorización | Cumplido | RBAC por rol y alcance por recurso; 403/404 según corresponda |
| Roles | Cumplido | Estudiante, docente, técnico, supervisor y administrador |
| JWT o sesión | Cumplido | JWT de 15 minutos y refresh opaco en cookie `HttpOnly` |
| Validación de entradas | Cumplido | Bean Validation, validación de archivos y errores globales |
| Protección de secretos | Cumplido | Variables de entorno, GitHub Secrets y secretos de Render |
| Variables de entorno | Cumplido | Configuración separada por entorno |
| Prevención de hardcode | Cumplido | Sin credenciales reales en el código; las cuentas demo viven en `db/demo` y producción solo aplica `db/migration` |
| Principios OWASP | Cumplido | `OWASP-TOP-10.md` con controles, pruebas y riesgos residuales |

### 3.4 Testing

| Punto | Estado | Evidencia |
| --- | --- | --- |
| Pruebas unitarias | Cumplido | 274 pruebas de frontend y 13 de backend |
| Pruebas de integración | Cumplido | 79 pruebas de backend con Testcontainers y MySQL |
| Automatización | Cumplido | CI, Playwright y smoke programado/manual |
| Criterios de aceptación | Cumplido | `frontend-uni/docs/verificacion/matriz-hu.md`: HU-01 a HU-29 con unitarias y E2E |
| Pruebas de API | Cumplido | Contrato, integración y smoke real de negocio |
| Generación asistida por IA | Cumplido | `docs/ai/AI_USAGE_LOG.md` |
| Revisión de pruebas generadas por IA | Cumplido | `PRUEBAS-IA.md` y registro de revisión/validación |

### 3.5 Demostración y producto

| Punto | Estado | Evidencia |
| --- | --- | --- |
| Aplicación desplegada | Cumplido | Staging y producción |
| API documentada | Cumplido | Swagger y OpenAPI públicos |
| CI/CD | Cumplido | Runs en verde, environment y smoke |
| Autenticación | Cumplido | Verificada en staging y producción |
| Autorización | Cumplido | Pruebas por rol y por recurso |
| Seguridad | Cumplido | Auth, roles, validación, secretos, OWASP y cabeceras |
| Pruebas | Cumplido | Unitarias, integración, E2E y smoke |
| Evidencias de automatización | Cumplido | `EVIDENCIAS.md`, runs de GitHub Actions y reportes |
| Release Candidate | Cumplido | `v1.0.0-rc.1` publicado y desplegado |

## 4. Pipeline CI/CD y ramas

### 4.1 Ramas

| Repo | Rama | Entorno | Protección |
| --- | --- | --- | --- |
| `frontend-uni` | `main` | Staging | PR + revisión + check `frontend` |
| `frontend-uni` | `production` | Producción | Rama de despliegue; `vercel.json` apunta al backend de producción |
| `backend-uni` | `main` | Staging | PR + revisión + 3 checks |
| `backend-uni` | `production` | Producción | PR + revisión + 3 checks; Render sin auto-deploy |
| `infra-uni` | `main` | Documentación y CI | PR + revisión + check de infraestructura |

### 4.2 Workflows

- **Frontend `ci.yml`:** instalación, lint, Vitest, build y Playwright. Vercel despliega staging desde `main` y producción desde `production`.
- **Backend `backend-ci.yml`:** lint de OpenAPI, `mvn verify` con Testcontainers, imagen Docker y smoke, CodeQL y revisión de dependencias.
- **Infra `infra-ci.yml`:** `docker compose config`, variables, scripts, secretos y enlaces de documentación.
- **`staging-smoke.yml`:** health, login y flujo real de solicitud contra staging; manual y semanal.
- **`deploy-production.yml`:** push a `production` o ejecución manual; environment `production` con revisores; Deploy Hook de Render; health; smoke de backend y frontend.

### 4.3 Evidencia de ejecución

- **Deploy de producción en verde:** https://github.com/taller-web-sigesu/backend-uni/actions/runs/43582054889
- **Smoke real de staging en verde:** https://github.com/taller-web-sigesu/backend-uni/actions/runs/43582997332
- **CI del frontend:** workflow `ci` en https://github.com/taller-web-sigesu/frontend-uni/actions
- **CI de infraestructura:** workflow `infra-ci` en https://github.com/taller-web-sigesu/infra-uni/actions

## 5. Usuarios de prueba

### 5.1 Staging

Todas las cuentas usan la contraseña **`Demo2026!`** y están activas sin cambio obligatorio.

| Correo | Rol | Área |
| --- | --- | --- |
| `admin.demo@universidad.example` | Administrador | — |
| `supervisor.ti.demo@universidad.example` | Supervisor | TI (1) |
| `supervisor.mant.demo@universidad.example` | Supervisor | Mantenimiento (2) |
| `supervisor.bib.demo@universidad.example` | Supervisor | Biblioteca (4) |
| `tecnico.ti.demo@universidad.example` | Técnico | TI (1) |
| `tecnica.ti.demo@universidad.example` | Técnica | TI (1) |
| `tecnico.mant.demo@universidad.example` | Técnico | Mantenimiento (2) |
| `ana.demo@universidad.example` | Estudiante | — |
| `pedro.demo@universidad.example` | Docente | — |

### 5.2 Producción

- **Administrador:** `admin@uniservice.app`.
- La contraseña inicial se entrega por el canal privado del equipo y **no se publica en el repositorio**.
- El sistema obliga a cambiarla en el primer ingreso.
- Producción no carga cuentas demo.

### 5.3 Recorrido sugerido para la demostración

1. Abrir staging y esperar el primer arranque de Render si el servicio estaba inactivo.
2. Ingresar como `ana.demo@universidad.example` y crear una solicitud.
3. Ingresar como `supervisor.ti.demo@universidad.example`, revisar la bandeja y asignar la solicitud a un técnico de TI.
4. Ingresar como `tecnico.ti.demo@universidad.example` y cambiar el estado de la solicitud.
5. Volver al supervisor para cerrarla.
6. Ingresar como `admin.demo@universidad.example` para mostrar usuarios, catálogos, SLA y el dashboard.

## 6. Evidencias y documentación

- [EVIDENCIAS.md](EVIDENCIAS.md): URLs, runs, pruebas y estado de los dos entornos.
- [PROMOCION-Y-ROLLBACK.md](PROMOCION-Y-ROLLBACK.md): promoción, aprobación, smoke y rollback.
- [OWASP-TOP-10.md](OWASP-TOP-10.md): controles y riesgos residuales.
- [API-PANORAMA.md](API-PANORAMA.md): REST, GraphQL, gRPC, webhooks y API Gateway.
- [PRUEBAS-IA.md](PRUEBAS-IA.md): proceso de generación y revisión de pruebas con IA.
- `frontend-uni/docs/verificacion/matriz-hu.md`: trazabilidad HU → pruebas.
- `backend-uni/docs/api/openapi.yaml`: contrato OpenAPI.
- `infra-uni/docs/adr/ADR-0004-despliegue-persistencia.md` y `ADR-0005-ci-cd-calidad.md`: decisiones aceptadas.

## 7. Limitaciones y trabajo futuro

1. **Evidencias persistentes:** staging y producción usan almacenamiento local temporal en Render (`/tmp/evidencias`). La integración con Supabase Storage queda como evolución acordada; no bloquea la entrega.
2. **DAST:** no se ejecutó OWASP ZAP. CodeQL, revisión de dependencias, pruebas de autorización y smoke sí están en verde.
3. **OWASP:** el mapeo está completo; quedan mejoras opcionales (threat model formal, restricción de Swagger/Actuator en producción y alertas centralizadas).
4. **Arranque en frío:** Render free puede tardar 30–60 segundos en despertar. El frontend ya muestra el login a los 8 segundos aunque la restauración de sesión siga esperando.
5. **Revisión independiente:** la protección de ramas exige revisión, pero en la recta final se usó el bypass de administrador para integraciones del equipo. La revisión independiente de las PRs queda como tarea de gobierno del equipo.
6. **Docker del frontend de producción:** el frontend productivo se construye en Vercel. Docker está cubierto para desarrollo (frontend y backend) y para el backend de producción.

## 8. Conclusión

La Fase III queda cumplida: hay dos despliegues reales y separados, API REST documentada y probada, seguridad implementada, CI/CD con aprobación y smoke, pruebas automatizadas y un Release Candidate publicado. Las limitaciones restantes son de evolución (almacenamiento persistente de evidencias, DAST y endurecimiento OWASP), no bloqueantes para la demostración.
