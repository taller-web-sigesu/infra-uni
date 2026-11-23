<div class="portada">

# Guía del repositorio

**Gestal / UniService**

Versión `v1.0.0` · 22/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

</div>

## 1. Organización

El código vive en la organización de GitHub [taller-web-sigesu](https://github.com/taller-web-sigesu), en **tres repositorios independientes** separados por responsabilidad. Se clonan como carpetas hermanas dentro de una carpeta de trabajo, por ejemplo `universidad-sm/`, que no es un repositorio.

| Repositorio | URL | Contenido |
| :---- | :---- | :---- |
| `frontend-uni` | <https://github.com/taller-web-sigesu/frontend-uni> | SPA React + Vite |
| `backend-uni` | <https://github.com/taller-web-sigesu/backend-uni> | API Spring Boot, esquema MySQL y observabilidad |
| `infra-uni` | <https://github.com/taller-web-sigesu/infra-uni> | Docker Compose, documentación global, evidencias y pruebas k6 |

Los repositorios no comparten código. Se comunican por HTTP/JSON y el contrato OpenAPI del backend.

## 2. Estructura

### 2.1 `frontend-uni`

```text
frontend-uni/
├── src/
│   ├── app/            # router, rutas por rol, navegación, páginas 403/404
│   ├── components/     # layout y componentes UI reutilizables
│   ├── features/       # auth, home, requests, management, dashboard,
│   │                   # reservations, administration
│   ├── services/       # cliente HTTP, errores, descargas, hooks de datos
│   ├── mocks/          # MSW: API simulada para desarrollo y pruebas
│   ├── styles/         # tokens, base y layout CSS
│   └── test/           # utilidades de Vitest
├── e2e/                # Playwright: sesión, solicitudes, reservas, admin, a11y
├── docs/               # prototipo de Fase I, Figma y verificaciones
├── ARCHITECTURE.md · DESIGN.md · AGENTS.md
├── Dockerfile.dev · vite.config.js · playwright.config.js · vercel.json
└── .github/workflows/ci.yml
```

### 2.2 `backend-uni`

```text
backend-uni/
├── src/main/java/pe/edu/universidad/servicios/
│   ├── auth · users · catalogs · requests · management · attachments
│   ├── sla · dashboard · reservations · audit · status · shared
├── src/main/resources/
│   ├── application.yml
│   └── db/
│       ├── migration/  # V1, V2, R__consolidar_sesiones_vigentes (producción)
│       └── demo/       # V1000, V1001 (solo local y staging)
├── src/test/java/      # unitarias y de integración (*IT, Testcontainers)
├── observability/      # Prometheus, Tempo, Grafana, alertas y runbook
├── docs/               # API (openapi.yaml), DATABASE, SECURITY, OBSERVABILITY
├── scripts/            # smoke de imagen
├── Dockerfile · Dockerfile.dev · pom.xml
└── .github/workflows/  # backend-ci, staging-smoke, deploy-production
```

### 2.3 `infra-uni`

```text
infra-uni/
├── compose.yaml · .env.example · iniciar.bat · detener.bat
├── DISENIO-BD.md · README.md · AGENTS.md
├── docs/
│   ├── ARCHITECTURE.md · DOCKER.md · EPICS.md · ALCANCE-POR-ROL.md
│   ├── requirements/   # requisitos funcionales, no funcionales e historias HU-01…HU-29
│   ├── adr/            # ADR-0001 … ADR-0005
│   ├── decisiones/     # decisiones de producto
│   ├── fase-3/         # informe, evidencias, OWASP, API, promoción y rollback
│   ├── fase-4/         # observabilidad, seguridad, matriz, rendimiento y evidencias
│   ├── entregables/    # informes, manuales, versión y release notes (fuentes de los PDF)
│   ├── testing/ · ai/ · auditorias/ · superpowers/
├── tests/performance/  # k6: carga, estrés y smoke de staging
└── .github/workflows/infra-ci.yml
```

## 3. Ramas

| Rama | Propósito | Protección |
| :---- | :---- | :---- |
| `main` | Versión estable. Despliega a **staging**. | Protegida en los tres repositorios: PR, revisión y checks obligatorios. |
| `production` | Versión de **producción**. Se promueve desde `main` por PR. | Protegida en backend. Despliegue con aprobación. |
| `feature/*` | Funcionalidad nueva. | Se crea desde `main` y vuelve por PR. |
| `fix/*` | Corrección. | Igual que `feature/*`. |
| `docs/*` | Documentación. | Igual que `feature/*`. |

Ejemplos: `feature/fase-4-ui-ux`, `fix/fase-4-seguridad`, `docs/fase-4-release`.

**Reglas**

- Nadie confirma directamente en `main` ni en `production`.
- Una rama por cambio, creada desde `main` actualizado.
- Todo entra por PR, con CI en verde y la revisión de otro integrante.

## 4. Commits y pull requests

- Commits en español, en modo imperativo y con prefijo convencional: `feat(...)`, `fix(...)`, `test(...)`, `docs(...)` o `chore(...)`.
- Título del PR con el repositorio entre corchetes: `[backend] …`, `[frontend] …` o `[infra] …`.
- La descripción del PR incluye un resumen, cómo se validó (comandos y resultados) y la historia de usuario o la decisión relacionada.
- No se versionan `.env`, credenciales, tokens ni datos personales reales.

## 5. CI/CD

| Repositorio | Workflow | Disparador | Qué valida o hace |
| :---- | :---- | :---- | :---- |
| `frontend-uni` | `ci.yml` | Todo push y PR | Lint, Vitest, build y Playwright. |
| `backend-uni` | `backend-ci.yml` | PR y push a `main` | Lint OpenAPI, `mvn verify` con Testcontainers, contrato publicado, imagen y smoke, CodeQL y dependencias. |
| `backend-uni` | `staging-smoke.yml` | Tras desplegar staging | Health y estado de staging. |
| `backend-uni` | `deploy-production.yml` | Push a `production` | Aprobación, Deploy Hook de Render, espera de health y smoke. |
| `infra-uni` | `infra-ci.yml` | Todo push y PR | Compose, variables, scripts, secretos y enlaces. |

**Despliegues continuos:** Vercel publica el frontend desde `main` (staging) y `production` (producción). Render publica el backend de staging desde `main`. Producción se despliega solo con `deploy-production.yml`.

## 6. Cómo levantar el proyecto

```sh
git clone https://github.com/taller-web-sigesu/frontend-uni.git
git clone https://github.com/taller-web-sigesu/backend-uni.git
git clone https://github.com/taller-web-sigesu/infra-uni.git
cd infra-uni
# Windows: doble clic en iniciar.bat
docker compose up -d --build --wait
```

| Servicio | URL |
| :---- | :---- |
| Aplicación | <http://localhost:3000> |
| API | <http://localhost:8080/api/v1> |
| Swagger | <http://localhost:8080/swagger-ui.html> |
| Health | <http://localhost:8080/actuator/health> |

Cuentas demo: `*.demo@universidad.example`, contraseña `Demo2026!`. Para detener: `detener.bat` o `docker compose stop`.

**Sin Docker:**

| Parte | Comandos |
| :---- | :---- |
| Frontend con API simulada | `cd frontend-uni && npm ci && npm run dev:mock` |
| Pruebas frontend | `npm test` · `npm run lint` · `npm run test:e2e` |
| Pruebas backend | `cd backend-uni && mvn verify` (requiere Docker para Testcontainers) |

## 7. Cómo desplegar

1. **Staging:** integra el PR en `main`. Vercel y Render despliegan solos. Revisa `staging-smoke`.
2. **Producción:**
   1. Confirma que existe un respaldo reciente de la base de producción.
   2. Abre un PR `main` → `production` en el repositorio correspondiente, con CI en verde.
   3. Intégralo. En `backend-uni`, aprueba el environment `production` en la ejecución de `deploy-production.yml`.
   4. Verifica el smoke y `https://uniservice-backend-prod.onrender.com/actuator/health`.
3. **Rollback:** vuelve al deploy anterior en Render o Vercel. Consulta `infra-uni/docs/fase-3/PROMOCION-Y-ROLLBACK.md`.

## 8. Versiones y tags

| Tag | Estado |
| :---- | :---- |
| `v1.0.0-rc.1` | Histórico, Release Candidate 1. |
| `v1.0.0-rc.2` | Histórico, Release Candidate 2 (Fase III). No se elimina. |
| `v1.0.0` | Release final. Se crea después de la verificación final, sobre el `main` final de cada repositorio. |

**Crear el tag final** (en cada repositorio):

```sh
git switch main
git pull --ff-only
git tag -a v1.0.0 -m "Release final Fase IV - Gestal/UniService"
git push origin v1.0.0
gh release create v1.0.0 --title "v1.0.0 — Release final Fase IV" --notes-file RELEASE-NOTES.md
```

**Verificar:**

```sh
git rev-parse 'v1.0.0^{commit}'     # debe ser igual a:
git rev-parse main
git ls-remote --tags origin v1.0.0
gh release view v1.0.0 --json tagName,isPrerelease,targetCommitish,url
```

**Inmutabilidad:** un tag publicado no se mueve. Un cambio posterior se publica como `v1.0.1`.

## 9. Documentación clave

| Documento | Ubicación |
| :---- | :---- |
| Arquitectura global | `infra-uni/docs/ARCHITECTURE.md` |
| Requisitos e historias de usuario | `infra-uni/docs/requirements/` |
| Decisiones de arquitectura | `infra-uni/docs/adr/` |
| Decisiones de Fase IV | `infra-uni/docs/entregables/DECISIONES-FASE-IV.md` |
| Exclusiones | `infra-uni/docs/entregables/DELIBERADAMENTE-NO-HECHO.md` |
| Contrato API | `backend-uni/docs/api/openapi.yaml` |
| Diseño de UI | `frontend-uni/DESIGN.md` |
| Registro de uso de IA | `infra-uni/docs/ai/` |
| Fuentes de los PDF finales | `infra-uni/docs/entregables/` (`tools/build-pdf.sh` los regenera) |
