<div class="portada">

# Manual técnico

**Gestal / UniService**  
Sistema Web para la Gestión Integral de Servicios Universitarios

Versión `v1.0.0` · 22/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

</div>

## 1. Propósito y alcance

Este manual explica cómo está construido Gestal y cómo instalarlo, configurarlo, desplegarlo, observarlo y respaldarlo. Está dirigido a desarrolladores y operadores. Las fuentes detalladas viven en los repositorios:

| Tema | Documento de referencia |
| :---- | :---- |
| Arquitectura global | `infra-uni/docs/ARCHITECTURE.md` |
| Arquitectura del backend y del frontend | `ARCHITECTURE.md` de cada repositorio |
| Base de datos | `infra-uni/DISENIO-BD.md`, `backend-uni/docs/DATABASE.md` |
| Seguridad | `backend-uni/docs/SECURITY.md`, `infra-uni/docs/fase-4/MATRIZ-AUTORIZACION-P2.md` |
| Observabilidad | `backend-uni/docs/OBSERVABILITY.md`, `backend-uni/observability/README.md` |
| Decisiones | `infra-uni/docs/adr/ADR-0001` a `ADR-0005` |
| Promoción y rollback | `infra-uni/docs/fase-3/PROMOCION-Y-ROLLBACK.md` |

## 2. Arquitectura

### 2.1 Vista general

Gestal es un **monolito modular**: una sola aplicación Spring Boot desplegable, consumida por una SPA React. No hay microservicios, mensajería, cachés distribuidas ni API Gateway.

```text
 Usuarios (estudiante, docente, técnico, supervisor, administrador)
        │ HTTPS
        ▼
 Frontend React + Vite ─── Vercel (staging: main · producción: production)
        │ HTTPS / JSON  /api/v1  (JWT en memoria + cookie HttpOnly de refresh)
        ▼
 Backend Spring Boot ───── Render (contenedor Docker)
        │ JPA / Flyway                 │ OTLP, /actuator/prometheus
        ▼                              ▼
 MySQL 8.4 ── Railway        Prometheus · Tempo · Grafana (observabilidad)
        │
 Evidencias: disco local (Compose: volumen; Render: /tmp) · Supabase Storage (evolución)
```

### 2.2 Repositorios

| Repositorio | Responsabilidad |
| :---- | :---- |
| `frontend-uni` | Interfaz React, rutas por rol, cliente HTTP, pruebas Vitest y Playwright. |
| `backend-uni` | API REST, reglas de negocio, autorización, esquema MySQL (Flyway), OpenAPI y observabilidad. |
| `infra-uni` | Docker Compose local, documentación global, ADR, requisitos, evidencias y pruebas de rendimiento k6. |

### 2.3 Módulos del backend

Paquete raíz: `pe.edu.universidad.servicios`.

| Módulo | Responsabilidad |
| :---- | :---- |
| `auth` | Login, refresh, logout, cambio de contraseña, registro, sesión única, límites de intentos. |
| `users` | Cuentas, roles, áreas, aprobación de registros y restablecimiento de contraseñas. |
| `catalogs` | Áreas, categorías, prioridades y nombres de estados. |
| `requests` | Solicitudes, comentarios, historial y encuesta. |
| `management` | Asignación, prioridad y transiciones de estado por rol y área. |
| `attachments` | Evidencias: validación, almacenamiento local o Supabase y descarga firmada. |
| `sla` | Políticas SLA y cálculo de plazos de aviso y vencimiento. |
| `dashboard` | Indicadores y exportación CSV. |
| `reservations` | Espacios, horarios, política, reservas y aprobación. |
| `audit` | Registro de eventos de auditoría. |
| `status` | Estado público de la API. |
| `shared` | Seguridad, errores, correlación y utilidades comunes. |

### 2.4 Frontend

React 19 con React Router 7 y Vite 8. Código organizado por *features* (`auth`, `home`, `requests`, `management`, `dashboard`, `reservations`, `administration`). Las rutas y los menús por rol están en `src/app/routes.jsx` y `src/app/navigation.js`. El cliente HTTP (`src/services/http.js`) renueva el JWT con la cookie de refresh. MSW (`src/mocks/`) permite trabajar sin backend con `npm run dev:mock`.

## 3. Requisitos del entorno

| Para | Necesitas |
| :---- | :---- |
| Ejecutar en local | Git y Docker Desktop. No hace falta instalar Java, Node.js, Maven ni MySQL. |
| Desarrollar backend fuera de Docker | Java 21, Maven 3.9 y Docker para Testcontainers. |
| Desarrollar frontend fuera de Docker | Node.js 24 (la versión de `Dockerfile.dev`). |
| Pruebas de rendimiento | k6 2.x. |

## 4. Instalación local

1. Clona los tres repositorios como carpetas hermanas:

   ```sh
   mkdir universidad-sm && cd universidad-sm
   git clone https://github.com/taller-web-sigesu/frontend-uni.git
   git clone https://github.com/taller-web-sigesu/backend-uni.git
   git clone https://github.com/taller-web-sigesu/infra-uni.git
   ```

2. Abre Docker Desktop.
3. Ejecuta `infra-uni/iniciar.bat` (en Linux o macOS, `docker compose up -d --build` desde `infra-uni`). El script crea `.env` desde `.env.example` si falta.
4. Abre <http://localhost:3000>. La API queda en <http://localhost:8080> y Swagger en <http://localhost:8080/swagger-ui.html>.
5. Para detener sin borrar datos: `detener.bat` o `docker compose stop`.

**Servicios de Compose** (proyecto `universidad-sm`):

| Servicio | Imagen | Puerto host | Notas |
| :---- | :---- | :---- | :---- |
| `mysql` | `mysql:8.4.13` | No se publica | Red interna `db_internal`; 1 CPU y 1 GiB. |
| `backend` | `backend-uni/Dockerfile.dev` | `127.0.0.1:8080` | Maven + DevTools. Carga `db/demo`. |
| `frontend` | `frontend-uni/Dockerfile.dev` | `127.0.0.1:3000` | Vite con HMR y proxy de `/api` al backend. |

Volúmenes: `mysql_data`, `evidencias_data`, `maven_cache`, `backend_target` y `frontend_node_modules`. **No borres** volúmenes (`docker compose down -v`) sin autorización: se pierden los datos.

**Cambios en caliente.** El frontend se recarga solo (HMR). Para el backend, ejecuta `mvn compile` en la pestaña **Exec** del contenedor `backend` y DevTools reinicia la aplicación.

**Problema conocido.** Si el backend reinicia en bucle con `AccessDeniedException` en `/home/app/.m2`, hay archivos del volumen `maven_cache` creados por root. Corrige el propietario sin borrar el volumen:

```sh
docker compose stop backend
docker run --rm -v universidad-sm_maven_cache:/m alpine chown -R 1001:1001 /m
docker compose up -d --wait
```

## 5. Configuración

### 5.1 Variables del backend

| Variable | Uso | Ejemplo o valor por defecto |
| :---- | :---- | :---- |
| `SERVER_PORT` | Puerto HTTP | `8080` |
| `SPRING_DATASOURCE_URL` | JDBC de MySQL | `jdbc:mysql://mysql:3306/uni_services` |
| `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` | Credenciales de MySQL | Secreto por entorno |
| `APP_JWT_SECRET` | Firma de JWT (≥ 32 bytes) | Secreto por entorno |
| `APP_ALLOWED_ORIGINS` | Orígenes CORS admitidos | URL del frontend |
| `APP_COOKIE_SECURE` | Cookie de refresh solo por HTTPS | `true` fuera de local |
| `APP_FLYWAY_LOCATIONS` | Migraciones a aplicar | `classpath:db/migration` (añadir `,classpath:db/demo` solo en local y staging) |
| `APP_BOOTSTRAP_ADMIN_EMAIL`, `_NAME`, `_PASSWORD` | Administrador inicial | Solo en el primer arranque de producción |
| `APP_LOGIN_MAX_ATTEMPTS`, `APP_LOGIN_WINDOW` | Límite de intentos de login | `5` en `15m` |
| `APP_REGISTRATION_EMAIL_DOMAIN` | Dominio institucional para el registro | `unmsm.edu.pe` |
| `APP_REGISTRATION_MAX_PER_IP_PER_HOUR` | Límite de registros por IP | `10` |
| `APP_STORAGE_PROVIDER` | `local` o `supabase` | `local` |
| `APP_STORAGE_LOCAL_DIR` | Carpeta de evidencias | `/data/evidencias` (Compose), `/tmp/evidencias` (Render) |
| `APP_STORAGE_SUPABASE_URL`, `_BUCKET`, `_SERVICE_KEY` | Supabase Storage | Solo si `provider=supabase` |
| `APP_TELEMETRY_PASSWORD_HASH` | BCrypt de la cuenta `prometheus` de Actuator | Secreto por entorno |
| `APP_OTLP_ENABLED`, `APP_OTLP_TRACES_ENDPOINT` | Exportación de trazas | `false` / `http://tempo:4318/v1/traces` |
| `APP_TRACING_SAMPLE_RATE` | Muestreo de trazas | `1.0` en local |

Duración de la sesión: JWT de acceso de **15 minutos** y refresh de **7 días**, con rotación.

### 5.2 Variables de Compose (`infra-uni/.env`)

`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` y `MYSQL_ROOT_PASSWORD`. Los valores de `.env.example` son solo para desarrollo local. `.env` nunca se versiona.

### 5.3 Secretos

Los secretos viven en **GitHub Secrets** y en las variables de **Render** y **Vercel**, nunca en el repositorio. El procedimiento de rotación de `APP_JWT_SECRET`, las credenciales de MySQL, la cuenta de telemetría, la clave de Supabase y el Deploy Hook está en `infra-uni/docs/fase-4/INFORME-SEGURIDAD-P2.md`.

## 6. Base de datos y migraciones

- Motor: **MySQL 8.4**. Esquema administrado por **Flyway**, que se ejecuta al arrancar el backend.
- `db/migration/`: migraciones de producción. `V1__esquema_inicial.sql`, `V2__catalogos_semilla.sql` y la repetible `R__consolidar_sesiones_vigentes.sql` (sesión única).
- `db/demo/`: datos ficticios. `V1000__datos_demostracion.sql` y `V1001__ambientes_y_cuentas_fase_iv.sql` (Laboratorio 10, Cancha deportiva y cuentas de Servicios Generales). **Nunca** se habilitan en producción.
- Las migraciones son **forward-only**. Un cambio se corrige con una versión nueva. No se editan migraciones ya aplicadas.
- El diseño relacional está en `infra-uni/DISENIO-BD.md`.

## 7. API REST

- Base: `/api/v1`. JSON sobre HTTPS.
- Contrato **OpenAPI 3** versionado en `backend-uni/docs/api/openapi.yaml`, con **64 operaciones**. El CI comprueba que el contrato publicado coincide con el versionado.
- Documentación interactiva: `/swagger-ui.html`. Contrato: `/v3/api-docs` y `/v3/api-docs.yaml`.
- Recursos principales: `auth`, `admin` (usuarios, catálogos, SLA y ambientes), `catalogs`, `requests` (comentarios, historial, adjuntos, asignaciones, estado, encuesta y auditoría), `dashboard`, `spaces`, `reservations` y `status`.
- Códigos: `401` sin sesión, `403` sin permiso de rol, `404` para un recurso fuera del alcance del usuario, `409` para una transición inválida y `429` al superar un límite.
- Autorización: matriz por rol, método, ruta y recurso en `infra-uni/docs/fase-4/MATRIZ-AUTORIZACION-P2.md`.
- Correlación: cada respuesta devuelve `X-Correlation-ID`. Si el cliente envía uno, se reutiliza.

## 8. Seguridad

- Contraseñas con BCrypt. JWT de acceso en memoria del navegador y refresh en cookie `HttpOnly`, `Secure` y `SameSite`.
- **Sesión única:** un login válido revoca las sesiones anteriores en la misma transacción.
- RBAC más control por recurso: propietario, técnico asignado o supervisor del área.
- Límites: cinco intentos de login por correo e IP en 15 minutos, diez registros por IP y hora.
- Adjuntos: validación de tipo y tamaño (JPG, PNG o PDF de hasta 5 MB, máximo cinco) y descarga autorizada con firma.
- Actuator: solo `health` es público y no muestra detalles. Las métricas exigen la cuenta `prometheus` por Basic Auth.
- CI: CodeQL, revisión de dependencias y Gitleaks (Fase IV). DAST: OWASP ZAP pasivo sobre staging.
- Pendiente conocido: CSP en el frontend (SEG-01).

## 9. Pruebas

| Capa | Herramienta | Ubicación | Comando |
| :---- | :---- | :---- | :---- |
| Unitarias backend | JUnit 5 + Mockito | `backend-uni/src/test` | `mvn test` |
| Integración backend | Spring Boot Test + Testcontainers MySQL | `backend-uni/src/test` (`*IT`) | `mvn verify` |
| Unitarias frontend | Vitest + Testing Library | `frontend-uni/src/**/*.test.*` | `npm test` |
| E2E | Playwright | `frontend-uni/e2e/` | `npm run test:e2e` (`E2E_API=real` contra Compose) |
| Accesibilidad | axe + Playwright | `frontend-uni/e2e/a11y.spec.js` | `npm run test:e2e` |
| Carga, estrés y smoke | k6 | `infra-uni/tests/performance/` | `run-local.ps1 -Scenario load|stress` |

Resultado de referencia de la Fase IV: **13 unitarias y 94 de integración** en el backend, sin fallos. Las mediciones k6 están en `infra-uni/docs/fase-4/performance-p2.md`.

## 10. CI/CD y despliegue

### 10.1 Pipelines

| Repositorio | Workflow | Pasos |
| :---- | :---- | :---- |
| `backend-uni` | `backend-ci.yml` | Lint de OpenAPI → `mvn verify` → contrato publicado igual al versionado → imagen Docker y smoke → CodeQL → revisión de dependencias. |
| `backend-uni` | `staging-smoke.yml` | Smoke contra staging. |
| `backend-uni` | `deploy-production.yml` | Aprobación del environment `production` → Deploy Hook de Render → espera de `health = UP` → smoke. |
| `frontend-uni` | `ci.yml` | Dependencias → lint → Vitest → build → Playwright. |
| `infra-uni` | `infra-ci.yml` | Compose, variables, scripts, secretos y enlaces. |

### 10.2 Entornos

| Entorno | Frontend (Vercel) | Backend (Render) | Base | Despliegue |
| :---- | :---- | :---- | :---- | :---- |
| Staging | `frontend-uni-tdk7.vercel.app` | `uniservice-backend-staging.onrender.com` | Railway MySQL (staging) | Automático desde `main`. |
| Producción | `frontend-uni-wx9m.vercel.app` | `uniservice-backend-prod.onrender.com` | Railway MySQL (producción) | PR `main` → `production` + `deploy-production.yml` con aprobación. Render tiene Auto-Deploy desactivado. |

### 10.3 Promoción y rollback

1. Integra el cambio en `main` por PR con CI en verde. Staging se actualiza solo.
2. Valida en staging.
3. Abre un PR `main` → `production`. Al integrarlo, aprueba el environment `production` en GitHub Actions.
4. El workflow despliega, espera `health = UP` y ejecuta el smoke.
5. **Rollback:** en Render, vuelve al deploy anterior. En Vercel, promueve el deployment anterior. Si una migración es incompatible, restaura el respaldo, revierte la aplicación y corrige con una migración nueva.

Detalle: `infra-uni/docs/fase-3/PROMOCION-Y-ROLLBACK.md`.

## 11. Observabilidad

### 11.1 Señales

| Señal | Implementación |
| :---- | :---- |
| Métricas | Micrometer → `/actuator/prometheus`: HTTP, JVM, CPU, Hikari y negocio (altas de solicitudes y reservas, rechazos de login). |
| Trazas | OpenTelemetry → OTLP/HTTP → Tempo. |
| Logs | JSON en consola con `correlationId`, `traceId` y `spanId`. |
| Salud | `/actuator/health` público y sonda Blackbox. |
| Despliegue | `deploy_exporter.py` lee el último resultado de `deploy-production.yml`. |

### 11.2 Pila local

`backend-uni/observability/compose.yaml` levanta Prometheus (`127.0.0.1:9090`), Blackbox, Tempo y Grafana (`127.0.0.1:3001`, dashboard `gestal-backend`). El README de esa carpeta explica la configuración del hash de telemetría y del endpoint OTLP.

### 11.3 Alertas y runbook

| Alerta | Condición |
| :---- | :---- |
| `GestalHealthUnavailable` | Sonda de salud caída durante 1 min. |
| `GestalHttp5xxHigh` | Más de 1 % de 5xx durante 5 min. |
| `GestalHttpP95High` | p95 mayor de 2 s durante 5 min. |
| `GestalPoolSaturated` | Más de 80 % del pool Hikari ocupado durante 5 min. |
| `GestalDeploymentFailed` | Último despliegue a producción fallido. |
| `GestalLoginRejectionsHigh` | 20 o más rechazos de login en 5 min (posible fuerza bruta). |

Cada alerta tiene en `backend-uni/observability/README.md` los pasos para confirmar, diagnosticar, recuperar y comprobar, y un procedimiento para correlacionar una petición con su log y su traza.

### 11.4 Retención

Según ADR-0003: métricas 15 días (Prometheus), trazas 7 días (Tempo) y logs 30 días. La retención de logs requiere un proveedor que la garantice.

## 12. Respaldos y restauración

| Elemento | Política |
| :---- | :---- |
| MySQL de producción y staging | Respaldo automático diario de Railway, con retención mínima de 7 días (ADR-0004). |
| Antes de promover a producción | Confirmar que existe un respaldo o snapshot reciente. |
| MySQL local | Volumen `mysql_data`. Exportación manual con `mysqldump`. |
| Evidencias | No forman parte del respaldo de MySQL. En Render son temporales. Supabase Storage queda como evolución. |

**Respaldo manual local:**

```sh
docker compose exec mysql sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction "$MYSQL_DATABASE"' > respaldo.sql
```

**Restauración local:**

```sh
docker compose exec -T mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < respaldo.sql
```

**Restauración en Railway:** desde el panel del servicio MySQL, elegir el respaldo y restaurarlo. Después, reiniciar el backend en Render y verificar `health = UP`, el login y una consulta de solicitudes.

> La prueba de restauración documentada que exige ADR-0004 aún no tiene evidencia. Se debe registrar en `VERIFICACION-FINAL.pdf`.

## 13. Operación diaria

| Tarea | Cómo |
| :---- | :---- |
| Ver estado | `GET /actuator/health` y `GET /api/v1/status`. |
| Ver logs | `docker compose logs backend` en local o la pestaña Logs de Render. Filtra por `correlationId`. |
| Crear el primer administrador en producción | Variables `APP_BOOTSTRAP_ADMIN_*` en el primer arranque. Luego, cambiar la contraseña. |
| Deshabilitar las cuentas demo tras la sustentación | Desde **Usuarios**, desactivar las cuentas `*.demo@universidad.example` en staging. |
| Rotar un secreto | Procedimiento de `INFORME-SEGURIDAD-P2.md`. |

## 14. Limitaciones técnicas conocidas

- Sin CSP en el frontend (SEG-01).
- Evidencias en disco temporal en Render.
- La observabilidad en staging (recolección, trazas y destino de alertas) depende de confirmar el SHA desplegado.
- Prueba de restauración de respaldos pendiente de evidencia.
- Render gratuito suspende el servicio sin tráfico: la primera petición tarda.
