# Guía paso a paso para que una IA genere el programa

- **Fecha:** 2026-11-11
- **Estado:** Guía de ejecución — usar después de revisar [`AUDITORIA-ALCANCE.md`](AUDITORIA-ALCANCE.md)
- **Ubicación:** `infra-uni/docs/auditorias/auditoria-01/`
- **Alcance:** fases 0 a 3 del [plan de ingeniería](../../superpowers/plans/2026-11-04-ingenieria-pendiente.md), que cubren las fases I a III del curso (lo necesario para la presentación). Las fases 4 y 5 del plan (observabilidad y despliegue) quedan al final como opcionales.
- **Objetivo:** decirle a una IA **qué hacer, en qué orden y con qué límites**, sin pedirle “haz todo el programa” en un solo mensaje.

> **Numeración.** En esta guía “Fase 0, 1, 2, 3, 4, 5” se refiere siempre a las fases del plan de ingeniería. Las fases del curso se escriben en romanos (Fase I–IV).

## Regla principal

**No le pidas todo el programa en un solo prompt.** La IA se pierde, inventa endpoints y consume contexto de más. Se trabaja **una fase o un módulo por sesión**, con un objetivo verificable y un commit al final.

## 1. Antes de abrir la IA

- [ ] Leer [`AUDITORIA-ALCANCE.md`](AUDITORIA-ALCANCE.md) y resolver las decisiones pendientes: evidencias, auto-registro, recuperación de contraseña, proveedor MySQL y rate limiting. Anotar la respuesta en la sección 7 de la auditoría: los prompts de las sesiones 1.2, 1.4, 2.2 y 2.3 dependen de ella.
- [ ] Tener los tres repositorios de la organización de GitHub `taller-web-sigesu` clonados en carpetas hermanas: `frontend-uni`, `backend-uni`, `infra-uni`. El nombre de la carpeta local que los contiene es libre (por ejemplo `universidad-sm`).
- [ ] Docker Desktop abierto y `infra-uni/iniciar.bat` funcionando (`http://localhost:3000`).
- [ ] **Rama base con la documentación.** Mientras `docs/ingenieria-pendiente` no esté fusionada en `main`, los planes, ADR y contratos que leen los prompts solo existen en esa rama. Usar como base:
  - `main`, si `docs/ingenieria-pendiente` ya se fusionó en los tres repos (lo normal);
  - `docs/ingenieria-pendiente`, si todavía no se fusionó.

  En `backend-uni`, los planes `docs/plan/00` a `04` están en la rama `docs/planes-backend` (creada desde `docs/ingenieria-pendiente`). Fusionarla antes de la Fase 0 o usarla como base en ese repo.
- [ ] Repositorios limpios y rama base actualizada (reemplazar `<base>` por `main` o `docs/ingenieria-pendiente`):
  ```powershell
  git -C backend-uni switch <base>;  git -C backend-uni pull
  git -C frontend-uni switch <base>; git -C frontend-uni pull
  git -C infra-uni switch <base>;    git -C infra-uni pull
  git -C backend-uni status; git -C frontend-uni status; git -C infra-uni status
  ```
  Si `git status` muestra archivos sin seguimiento (`??`), decidir antes de empezar si se versionan en una rama `docs/...` o se descartan. No arrancar una sesión con el árbol sucio.
- [ ] Confirmar que existe el registro de uso de IA [`infra-uni/docs/ai/AI_USAGE_LOG.md`](../../ai/AI_USAGE_LOG.md). Es **uno solo** para los tres repositorios.
- [ ] Elegir la herramienta de IA y confirmar que puede leer y escribir en el workspace multirrepo.
- [ ] Tener a mano la HU que se va a implementar y el contrato OpenAPI (existe a partir de la Fase 0).

## 2. Cómo preparar la sesión

Abre la IA **en la carpeta local que contiene los tres repositorios**, no dentro de un solo repo, para que pueda leer los tres. Si la herramienta solo permite un repo, indícale las rutas absolutas de los otros dos.

En el primer mensaje de cada sesión pega el **prompt maestro** y luego el prompt de la fase.

## 3. Prompt maestro (copiar y pegar)

```text
Actúa como ingeniero de software senior en este workspace multirrepo:

- frontend-uni: React + Vite.
- backend-uni: Spring Boot + Maven + MySQL.
- infra-uni: Docker Compose, documentación, CI/CD y operación.

Reglas obligatorias:

1. Antes de escribir código, lee el AGENTS.md y el ARCHITECTURE.md del repo que vas a modificar, infra-uni/docs/ARCHITECTURE.md, el plan de la fase y la historia de usuario exacta.
2. No inventes endpoints, campos, estados, roles ni requisitos. La fuente de verdad es backend-uni/docs/api/openapi.yaml, las HU en infra-uni/docs/requirements/user-stories/ e infra-uni/DISENIO-BD.md.
3. No edites ni hagas commit directamente en main. Crea una rama desde la rama base indicada con uno de los prefijos permitidos por AGENTS.md: feature/..., fix/... o docs/... No uses otros prefijos.
4. Un cambio pequeño por rama y por PR. No mezcles fases ni módulos.
5. Ejecuta las pruebas, el build y las validaciones que correspondan. Muestra la salida. No afirmes que algo pasa sin ejecutarlo.
6. Los comandos docker compose se ejecutan desde infra-uni/ (ahí está compose.yaml) o con `docker compose -f infra-uni/compose.yaml`.
7. No incluyas secretos, contraseñas, tokens ni archivos .env en commits, logs o capturas.
8. Si falta una decisión, hay una contradicción o el alcance no está claro, detente y pregunta antes de implementar.
9. Al terminar, actualiza la documentación afectada y registra el uso de IA en infra-uni/docs/ai/AI_USAGE_LOG.md (un único registro para los tres repos).
10. Explica qué archivos cambiaste, qué pruebas ejecutaste y cómo verificarlo.
11. No ejecutes comandos destructivos: nada de `docker compose down -v`, borrar volúmenes, `git push --force` ni eliminar ramas ajenas.
```

## 4. Fase 0 — Contratos y decisiones

**Objetivo:** dejar el contrato y las reglas antes de programar. No se implementa negocio todavía.

**Prompt:**

```text
Trabaja solo en la Fase 0 del plan de ingeniería.

Lee:
- infra-uni/docs/superpowers/plans/2026-11-04-ingenieria-pendiente.md
- infra-uni/docs/ARCHITECTURE.md
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md (sección 7: decisiones tomadas)
- infra-uni/docs/adr/ADR-0001 a ADR-0005
- backend-uni/docs/API-DISENIO.md
- backend-uni/docs/api/*.md
- backend-uni/docs/plan/00-contratos-y-decisiones.md
- infra-uni/DISENIO-BD.md

Tarea:
1. Crear backend-uni/docs/api/openapi.yaml con todos los endpoints, esquemas, filtros, errores y ejemplos. Incluir los endpoints condicionales (evidencias, auto-registro, recuperación) solo si la decisión de la auditoría fue afirmativa.
2. Crear backend-uni/docs/SECURITY.md con la matriz RBAC por endpoint, rol y recurso.
3. Crear backend-uni/docs/DATABASE.md con convenciones, migraciones Flyway y diccionario de datos.
4. Definir el formato de errores, paginación, fechas UTC e identificadores.
5. Validar el OpenAPI con Spectral o Swagger CLI.

No implementes código de negocio ni modifiques src/.
Criterio de cierre: los tres documentos existen, el OpenAPI valida sin errores y no hay contradicciones con las HU.

Rama: docs/fase-0-contratos.
Al terminar: muestra `git diff --stat`, el resultado de la validación y actualiza el registro de IA.
```

**Verificación:**

```powershell
git -C backend-uni status
git -C backend-uni diff --stat
# Validar OpenAPI (ejemplo con Spectral, si está instalado)
npx @stoplight/spectral-cli lint backend-uni/docs/api/openapi.yaml
```

## 5. Fase 1 — Backend

Trabaja **un módulo por sesión**. No pidas “todo el backend” de una vez.

### 5.1. Fundaciones

**Prompt:**

```text
Implementa solo las fundaciones del backend de la Fase 1.

Lee:
- backend-uni/AGENTS.md
- backend-uni/ARCHITECTURE.md
- backend-uni/docs/BACKEND-DISENIO.md
- backend-uni/docs/plan/01-fundaciones-y-sesion.md
- backend-uni/docs/SECURITY.md
- backend-uni/docs/DATABASE.md
- infra-uni/DISENIO-BD.md
- infra-uni/docs/adr/ADR-0003-observabilidad-retencion.md
- infra-uni/compose.yaml (healthcheck del backend)

Tarea:
1. Agregar dependencias: Spring Security, Bean Validation, Flyway, springdoc OpenAPI, Testcontainers, JUnit 5 y Mockito. Micrometer Tracing solo para propagar el traceId a los logs, sin exportación (ADR-0003); la observabilidad completa es Fase 4.
2. Configurar Flyway y mantener spring.jpa.hibernate.ddl-auto=none.
3. Crear el módulo shared: errores globales, DTO de error, validación, CORS, password encoder, configuración de seguridad y OpenAPI.
4. Proteger Actuator dejando públicos solo health (liveness/readiness). El healthcheck de infra-uni/compose.yaml usa /actuator/health: debe seguir respondiendo sin autenticación.
5. Crear las migraciones V1 (esquema), V2 (catálogos semilla, incluidas las áreas y los roles) y V3 (datos demo opcional).
6. Crear backend-uni/.github/workflows/backend.yml mínimo: checkout, JDK 21 y `mvn verify`. La Fase 3.1 lo amplía.

No implementes todavía auth, users, requests ni el resto de módulos.
Criterio de cierre: `mvn verify` compila, Flyway corre desde una base vacía, el contexto de Spring levanta y `docker compose ps` muestra el backend healthy.

Nota: Testcontainers necesita acceso a Docker. Dentro del contenedor backend no lo tiene; ejecuta las pruebas de integración en el host o en CI y dilo explícitamente si no pudiste correrlas.

Rama: feature/backend-fundaciones.
Al terminar: muestra la salida de `mvn verify` y actualiza el registro de IA.
```

### 5.2. Auth y usuarios

**Prompt:**

```text
Implementa el módulo auth y el módulo users del backend.

Lee:
- HU-01 y HU-02 en infra-uni/docs/requirements/user-stories/EP-01-Autenticacion/
- HU-15 en infra-uni/docs/requirements/user-stories/EP-05-Administracion/
- infra-uni/docs/adr/ADR-0002-autenticacion-sesion.md
- backend-uni/docs/api/autenticacion.md y usuarios.md
- backend-uni/docs/api/openapi.yaml
- backend-uni/docs/SECURITY.md
- backend-uni/docs/BACKEND-DISENIO.md secciones auth y users
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md, secciones 7.2 y 7.3

Alcance:
- Sesión según ADR-0002: access token JWT de 15 minutos, refresh token opaco en cookie HttpOnly con rotación, hash en sesiones_usuario, logout y revocación.
- Cambio obligatorio de contraseña en el primer ingreso.
- RBAC por rol y área.
- CRUD de usuarios y asignación de rol y área según HU-15. Las áreas se leen del catálogo (semilla V2); su CRUD es de la sesión 5.3.
- Auto-registro y recuperación de contraseña solo si la decisión de la auditoría fue afirmativa.
- Pruebas de autenticación, autorización, rotación de refresh y escalada de privilegios.

No implementes catálogos, solicitudes ni dashboard.
Criterio de cierre: los endpoints del OpenAPI responden, las pruebas de autorización pasan y no se puede acceder a datos de otro rol.

Rama: feature/backend-auth-users.
Al terminar: muestra `mvn test`, los endpoints probados y actualiza el registro de IA.
```

### 5.3. Catálogos

**Prompt:**

```text
Implementa el módulo catalogs del backend.

Lee:
- HU-16, HU-17 y HU-18.
- backend-uni/docs/api/catalogos.md y calidad-servicio.md.
- backend-uni/docs/api/openapi.yaml.
- infra-uni/DISENIO-BD.md, tablas de catálogos y SLA.

Alcance:
- CRUD administrativo de áreas, categorías, prioridades, estados visibles y políticas SLA.
- Validaciones y reglas de vigencia (no borrar un área con usuarios o solicitudes activas).
- Pruebas de permisos y conflictos.

No modifiques auth ni users salvo para leer áreas.
Criterio de cierre: los endpoints del OpenAPI funcionan y las pruebas pasan.

Rama: feature/backend-catalogos.
```

### 5.4. Solicitudes

**Prompt:**

```text
Implementa el módulo requests del backend.

Lee:
- HU-03, HU-04, HU-05 y HU-06.
- backend-uni/docs/api/solicitudes.md.
- backend-uni/docs/api/openapi.yaml.
- infra-uni/DISENIO-BD.md, tablas solicitudes, historial_estados, comentarios y secuencias_codigo_solicitud.
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md, sección 7.1 (evidencias).

Alcance:
- Registrar solicitud con código automático, fecha, solicitante, prioridad inicial y estado Nuevo.
- Listar mis solicitudes, ver detalle e historial y agregar comentarios.
- Validaciones, paginación y autorización por recurso.
- Evidencias adjuntas solo si la decisión fue afirmativa: validar tipo y tamaño, almacenamiento privado y acceso autorizado.
- Pruebas de creación, listado, detalle, comentarios y accesos indebidos.

No implementes asignación ni cambios de estado; eso es management.
Criterio de cierre: el flujo crear → listar → detallar → comentar funciona contra MySQL.

Rama: feature/backend-solicitudes.
```

### 5.5. Gestión del ciclo de vida

**Prompt:**

```text
Implementa el módulo management del backend.

Lee:
- HU-07 a HU-11.
- backend-uni/docs/api/atencion.md.
- backend-uni/docs/api/openapi.yaml.
- infra-uni/DISENIO-BD.md, tablas asignaciones, transiciones_estado e historial_estados.

Alcance:
- Bandeja por área con filtros.
- Asignar y reasignar técnico, ajustar prioridad.
- Cambiar estado según la matriz de transiciones.
- Cerrar o rechazar con motivo.
- Auditoría de cada cambio.
- Pruebas de transiciones inválidas y permisos.

No inventes estados ni transiciones fuera de la matriz.
Criterio de cierre: las transiciones del ciclo de vida se cumplen y las inválidas se rechazan.

Rama: feature/backend-gestion.
```

### 5.6. Dashboard, SLA, auditoría y encuesta

**Prompt:**

```text
Implementa dashboard, SLA, auditoría y encuesta del backend.

Lee:
- HU-12, HU-13, HU-14, HU-19 y HU-20.
- backend-uni/docs/api/dashboard.md.
- backend-uni/docs/api/openapi.yaml.
- infra-uni/DISENIO-BD.md, vistas de indicadores y auditoria_eventos.

Alcance:
- Los 9 indicadores, filtros por fecha y área, y exportación CSV.
- Cálculo de vencidas y próximas a vencer según SLA.
- Consulta de auditoría.
- Encuesta de satisfacción al cerrar.
- Pruebas de cálculos, filtros y permisos.

No modifiques solicitudes ni management salvo lo necesario para leer datos.
Criterio de cierre: los indicadores coinciden con datos de prueba y el CSV se descarga.

Rama: feature/backend-dashboard.
```

### 5.7. Reservas

**Prompt:**

```text
Implementa el módulo reservations del backend.

Lee:
- HU-21 a HU-25.
- backend-uni/docs/api/reservas.md.
- backend-uni/docs/api/openapi.yaml.
- backend-uni/docs/plan/03-reservas-de-ambientes.md.
- infra-uni/docs/adr/ADR-0001-reserva-ambientes.md.
- infra-uni/DISENIO-BD.md, tablas de espacios, horarios, reservas y políticas.

Alcance:
- Catálogo de espacios y disponibilidad.
- Registrar reserva con validación de solapamiento, horario, duración y anticipación.
- Aprobar, rechazar y cancelar con motivo.
- Administrar espacios, tipos, horarios y política.
- Pruebas de concurrencia y conflictos.

Criterio de cierre: no se pueden crear reservas solapadas y las reglas de la política se respetan.

Rama: feature/backend-reservas.
```

### 5.8. Pruebas y calidad del backend

**Prompt:**

```text
Completa las pruebas y la calidad del backend.

Lee:
- backend-uni/AGENTS.md
- infra-uni/docs/ARCHITECTURE.md, tabla de pruebas por capa.
- Las HU y el OpenAPI.

Tarea:
1. Unitarias de servicios y reglas con JUnit 5 + Mockito.
2. Integración de endpoints y migraciones con Testcontainers MySQL.
3. Pruebas de autorización por recurso y transiciones inválidas.
4. Configurar JaCoCo y el umbral de cobertura acordado.
5. Ejecutar `mvn verify` y corregir lo que falle.

No agregues funcionalidad nueva.
Criterio de cierre: `mvn verify` verde y reporte de cobertura generado.

Rama: feature/backend-calidad.
```

## 6. Fase 2 — Frontend

Trabaja **un plan por sesión**. Cada plan ya trae tareas y capturas de Figma. La sesión 2.1 puede hacerse en paralelo al backend porque usa API simulada (MSW).

### 6.1. Base visual, herramientas de prueba y API simulada

**Prompt:**

```text
Implementa la Fase 01 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/01-base-visual-y-api-simulada.md
- frontend-uni/AGENTS.md
- frontend-uni/DESIGN.md
- frontend-uni/ARCHITECTURE.md
- Las capturas de Figma de la fase 01.

Alcance:
- React Router con layouts público y autenticado.
- Sidebar, topbar y menú móvil.
- Tokens de tema claro, componentes comunes y estilos responsive.
- Cliente HTTP centralizado con prefijo /api/v1.
- MSW para API simulada.
- Estados de carga, vacío, error y reintento.
- Herramientas de prueba: Vitest, Testing Library y ESLint, con los scripts `lint` y `test` en package.json, para que las sesiones 2.2 a 2.5 puedan escribir y ejecutar pruebas.
- frontend-uni/.github/workflows/frontend.yml mínimo: `npm ci`, `npm run lint`, `npm test` y `npm run build`. La Fase 3.1 lo amplía.

No implementes los flujos de negocio todavía.
Criterio de cierre: navegación, diálogos y estados funcionan a 360, 768 y 1440 px; `npm run lint`, `npm test` y `npm run build` pasan.

Rama: feature/frontend-base.
```

### 6.2. Acceso, sesión y perfil

**Prompt:**

```text
Implementa la Fase 02 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/02-acceso-sesion-y-perfil.md
- HU-01 y HU-02.
- infra-uni/docs/adr/ADR-0002-autenticacion-sesion.md
- backend-uni/docs/api/openapi.yaml.
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md, secciones 7.2 y 7.3.
- Capturas p01, p02 y p16.

Alcance:
- Login, logout, sesión, refresh y primer ingreso. El access token vive solo en memoria; el refresh va en cookie HttpOnly (ADR-0002).
- Pantalla de perfil y cambio de contraseña.
- Pantallas de auto-registro o recuperación solo si la decisión fue afirmativa.
- Manejo de 401 con un único reintento tras refresh, errores y reintento.
- Pruebas de sesión y permisos.

No inventes endpoints. Usa solo el OpenAPI.
Criterio de cierre: login por rol, recarga, refresh y revocación funcionan con API simulada y real.

Rama: feature/frontend-auth.
```

### 6.3. Solicitudes y atención

**Prompt:**

```text
Implementa la Fase 03 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/03-solicitudes-y-atencion.md
- HU-03 a HU-11.
- backend-uni/docs/api/openapi.yaml.
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md, sección 7.1 (evidencias).
- Capturas p03, p04, p05, p06 y p07.

Alcance:
- Registro, listado, detalle, historial y comentarios.
- Adjuntar evidencias solo si la decisión fue afirmativa.
- Bandeja del técnico, asignación, prioridad, estados, cierre y rechazo.
- Formularios con validación y confirmaciones.
- Pruebas de flujo y permisos.

Criterio de cierre: los recorridos de estudiante, técnico y supervisor funcionan contra la API real.

Rama: feature/frontend-solicitudes.
```

### 6.4. Indicadores y administración

**Prompt:**

```text
Implementa la Fase 04 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/04-indicadores-y-administracion.md
- HU-12 a HU-20.
- backend-uni/docs/api/openapi.yaml.
- Capturas p08 y p12 a p15.

Alcance:
- Dashboard con los 9 indicadores, filtros y exportación CSV.
- Administración de usuarios, catálogos, SLA y configuración.
- Estados de carga, vacío y error.
- Pruebas de filtros, exportación y permisos.

Criterio de cierre: los filtros y el CSV son coherentes con la API; `npm run build` pasa.

Rama: feature/frontend-dashboard-admin.
```

### 6.5. Reservas y ambientes

**Prompt:**

```text
Implementa la Fase 05 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/05-reservas-y-ambientes.md
- HU-21 a HU-25.
- backend-uni/docs/api/openapi.yaml.
- Capturas p09, p10, p11 y p15.

Alcance:
- Catálogo de espacios, disponibilidad y reserva.
- Mis reservas, aprobación, rechazo y cancelación.
- Administración de espacios, horarios y política.
- Manejo de conflictos y errores 409.

Criterio de cierre: los recorridos de reserva y aprobación funcionan contra la API real.

Rama: feature/frontend-reservas.
```

### 6.6. Integración, E2E y entrega local

**Prompt:**

```text
Implementa la Fase 06 del frontend.

Lee:
- frontend-uni/docs/superpowers/plans/06-integracion-y-entrega-local.md
- frontend-uni/AGENTS.md
- backend-uni/docs/plan/04-integracion-local-y-ci.md
- infra-uni/docs/DOCKER.md

Alcance:
- Configurar Playwright y el script `test:e2e` (Vitest, Testing Library y ESLint ya existen desde la 2.1).
- Ejecutar `npm ci`, lint, tests, build y E2E.
- Repetir los recorridos de las fases 02 a 05 contra la API real en Docker.
- Registrar evidencia por HU y marcar lo que quede pendiente.

Criterio de cierre: los cuatro roles completan sus recorridos y las comprobaciones de CI pasan.

Rama: feature/frontend-integracion.
```

## 7. Fase 3 — CI/CD, seguridad y pruebas

### 7.1. Workflows de CI

Los workflows mínimos de backend y frontend ya existen desde las sesiones 1.1 y 2.1. Esta sesión los completa y crea el de infra.

**Prompt:**

```text
Completa los workflows de CI de los tres repositorios.

Lee:
- infra-uni/docs/adr/ADR-0005-ci-cd-calidad.md
- infra-uni/docs/superpowers/plans/2026-11-04-ingenieria-pendiente.md, Fase 3.
- AGENTS.md de cada repo.
- Los workflows existentes en backend-uni/.github/workflows/ y frontend-uni/.github/workflows/.

Tarea:
1. Ampliar backend-uni/.github/workflows/backend.yml: unitarias, Testcontainers, análisis, dependencias, build de imagen y smoke.
2. Ampliar frontend-uni/.github/workflows/frontend.yml: Playwright.
3. Crear infra-uni/.github/workflows/infra.yml: `docker compose config`, validación de scripts, secret scan y link check.
4. Archivar reportes y artefactos.
5. Documentar cómo proteger main y exigir checks.

No configures CD a producción todavía.
Criterio de cierre: los workflows son válidos y un PR de prueba ejecuta los checks.

Rama: feature/ci-workflows (una por repo).
```

### 7.2. Endurecimiento de seguridad

La sesión 1.2 ya implementó la sesión según ADR-0002. Esta sesión **endurece y prueba**, no rediseña.

**Prompt:**

```text
Endurece la seguridad del backend y frontend.

Lee:
- backend-uni/docs/SECURITY.md
- infra-uni/docs/adr/ADR-0002-autenticacion-sesion.md
- infra-uni/docs/adr/ADR-0003-observabilidad-retencion.md
- infra-uni/docs/auditorias/auditoria-01/AUDITORIA-ALCANCE.md, decisión de rate limiting.

Tarea:
1. Revisar que la implementación de la sesión cumple ADR-0002 (vigencias, rotación, revocación, cookie).
2. Configurar CSRF, CORS, SameSite y Secure por entorno.
3. Agregar cabeceras de seguridad.
4. Revisar la validación de entradas con Bean Validation.
5. Revisar la política de contraseñas y hashing.
6. Implementar rate limiting si la decisión fue afirmativa.
7. Pruebas de autenticación, autorización, IDOR, XSS e inyección.

No debilites el diseño para “que funcione”.
Criterio de cierre: la matriz RBAC se cumple y las pruebas de seguridad pasan.

Rama: feature/security-hardening.
```

### 7.3. API documentada y pruebas de API

**Prompt:**

```text
Publica y prueba la API.

Lee:
- backend-uni/docs/api/openapi.yaml
- backend-uni/docs/postman-disenio/postman-api-design.md
- backend-uni/docs/postman-disenio/gestal.postman_collection.json

Tarea:
1. Verificar que Swagger UI (springdoc, agregado en la 1.1) está publicado y coincide con openapi.yaml.
2. Ejecutar la colección Postman con Newman en CI.
3. Agregar contract tests contra OpenAPI.
4. Cubrir 200, 400, 401, 403, 404, 409, 429 y 503.
5. Archivar reportes.

Criterio de cierre: Swagger disponible, Newman verde y contract tests pasan.

Rama: feature/api-contract.
```

### 7.4. SAST, DAST y k6

**Prompt:**

```text
Configura SAST, DAST y k6.

Lee:
- infra-uni/docs/adr/ADR-0005-ci-cd-calidad.md
- infra-uni/docs/ARCHITECTURE.md, tabla de pruebas.

Tarea:
1. Elegir y configurar SAST para backend y frontend.
2. Configurar escaneo de dependencias y secretos.
3. Configurar OWASP ZAP baseline contra staging autorizado.
4. Crear un script k6 de humo y latencia.
5. Archivar reportes y documentar hallazgos.

No ejecutes DAST contra producción.
Criterio de cierre: los reportes se generan y los hallazgos críticos están corregidos o justificados.

Rama: feature/ci-security-performance.
```

## 8. Fases 4 y 5 — Opcionales para la presentación

Solo después de cerrar la Fase 3:

- Fase 4 — Observabilidad: logs JSON, métricas, exportación de trazas, alertas y retención (`ADR-0003`).
- Fase 4 — Backups, restauración y runbooks.
- Fase 5 — Dockerfile de producción, staging, producción, smoke tests y rollback (`ADR-0004`).

Puedes usar el mismo patrón: un prompt por tema, con lectura previa de `ADR-0003` y `ADR-0004`, y ramas `feature/...`.

## 9. Cómo pedir correcciones y revisiones

### Revisión sin modificar código

```text
No modifiques nada todavía. Revisa el diff actual contra la HU y el OpenAPI.
Devuelve:
1. Requisitos no cubiertos.
2. Endpoints, campos o estados inventados.
3. Riesgos de seguridad.
4. Pruebas faltantes.
5. Archivos que no deberían haber cambiado.
```

### Corrección de un error

```text
El comando `...` falla con este error:
[pegar salida]

1. Diagnostica la causa raíz.
2. Propón el cambio mínimo.
3. Aplícalo.
4. Vuelve a ejecutar el comando y muestra la salida.
No cambies archivos no relacionados.
```

### Cierre de una sesión

```text
Resume en 5 líneas qué cambiaste, qué pruebas ejecutaste y qué queda pendiente.
Luego:
1. Revisa `git status`.
2. Agrupa los cambios en un commit coherente.
3. Usa un mensaje conventional commit.
4. No incluyas .env, target, node_modules ni secretos.
5. Muestra el diff resumido.
6. Agrega la fila de la sesión en infra-uni/docs/ai/AI_USAGE_LOG.md.
```

## 10. Verificación después de cada sesión

Los comandos `docker compose` se ejecutan desde `infra-uni/`.

| Verificación | Comando | Disponible desde |
| --- | --- | --- |
| Estado del repo | `git status` y `git diff --stat` | Siempre |
| Backend compila y prueba | `docker compose exec backend mvn test` o `mvn verify` en el host | Sesión 1.1 |
| Integración backend | `mvn verify` en el host o en CI (Testcontainers necesita Docker) | Sesión 1.1 |
| Frontend compila | `docker compose exec frontend npm run build` | Siempre |
| Frontend lint y tests | `npm run lint`, `npm test` | Sesión 2.1 |
| E2E | `npm run test:e2e` | Sesión 2.6 |
| Docker sano | `docker compose ps` | Siempre |
| API responde | `curl http://localhost:8080/api/v1/status` | Siempre |
| Frontend responde | abrir `http://localhost:3000` | Siempre |

**No aceptes “está listo” sin ver la salida del comando.**

## 11. Reglas de oro para la IA

1. Una fase o un módulo por sesión.
2. Leer la HU y el OpenAPI antes de escribir código.
3. No inventar endpoints, campos, estados ni roles.
4. No editar `main`; una rama `feature/`, `fix/` o `docs/` por tarea.
5. Cambios pequeños y commits claros.
6. Ejecutar pruebas y mostrar salida.
7. No commitear secretos ni `.env`.
8. Si hay ambigüedad, preguntar antes de implementar.
9. Actualizar documentación y el registro único de IA.
10. Si se acaba el contexto: resumir, commitear y abrir una sesión nueva con solo los archivos del siguiente módulo.

## 12. Registro de uso de IA

El registro es único y vive en [`infra-uni/docs/ai/AI_USAGE_LOG.md`](../../ai/AI_USAGE_LOG.md). Cada sesión agrega una fila con este formato:

| Fecha | Fase | Repo | Herramienta | Prompt | Resultado | ¿Se usó? | Validación | Modificaciones | Responsable |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-11-11 | Fase 0 | backend-uni | Claude Code | Crear OpenAPI | `openapi.yaml` | Parcial | Spectral + revisión manual | 3 | Integrante 2 |

## 13. Problemas comunes

| Problema | Qué hacer |
| --- | --- |
| Docker no responde | Abrir Docker Desktop y esperar a que el motor esté activo. |
| La IA inventa endpoints | Detenerla y pedirle que compare con `openapi.yaml` y la HU. |
| La IA quiere hacer todo de golpe | Recordarle la regla: una fase/módulo por sesión. |
| La IA no encuentra un plan, ADR o contrato | Comprobar que la rama base contiene `docs/ingenieria-pendiente` (sección 1). |
| La IA propone una rama `test/`, `ci/` o `security/` | Rechazarla: AGENTS.md solo permite `feature/`, `fix/` y `docs/`. |
| Se acaba el contexto | Pedir resumen, commitear y abrir sesión nueva con el siguiente módulo. |
| `mvn` o `npm` no existen en el host | Ejecutar dentro de Docker desde `infra-uni/` (`docker compose exec ...`). |
| `docker compose` no encuentra el proyecto | Ejecutarlo desde `infra-uni/` o con `-f infra-uni/compose.yaml`. |
| El backend queda *unhealthy* tras proteger Actuator | Dejar `/actuator/health` público (sesión 1.1). |
| Testcontainers falla en local | Ejecutar integración en el host o en CI; no afirmar que pasa. |
| Un test falla | Pedir diagnóstico, cambio mínimo y nueva ejecución. |
| Se modificó `main` | Revertir, crear rama y repetir el cambio. |
| Hay un secreto en el diff | Quitarlo, rotar la credencial y registrar el incidente. |

## 14. Orden recomendado de sesiones

| Sesión | Fase | Entregable |
| --- | --- | --- |
| 1 | Fase 0 | OpenAPI, SECURITY.md, DATABASE.md |
| 2 | Fase 1.1 | Fundaciones del backend y CI mínima del backend |
| 3 | Fase 1.2 | Auth (ADR-0002) y usuarios |
| 4 | Fase 1.3 | Catálogos (incluye CRUD de áreas) |
| 5 | Fase 1.4 | Solicitudes |
| 6 | Fase 1.5 | Gestión del ciclo de vida |
| 7 | Fase 1.6 | Dashboard, SLA, auditoría y encuesta |
| 8 | Fase 1.7 | Reservas |
| 9 | Fase 1.8 | Pruebas y calidad del backend |
| 10 | Fase 2.1 | Base visual, MSW, Vitest/ESLint y CI mínima del frontend (puede ir en paralelo desde la sesión 2) |
| 11 | Fase 2.2 | Acceso, sesión y perfil |
| 12 | Fase 2.3 | Solicitudes y atención |
| 13 | Fase 2.4 | Indicadores y administración |
| 14 | Fase 2.5 | Reservas y ambientes |
| 15 | Fase 2.6 | Integración y E2E |
| 16 | Fase 3.1 | Workflows de CI completos |
| 17 | Fase 3.2 | Endurecimiento de seguridad |
| 18 | Fase 3.3 | API documentada y pruebas |
| 19 | Fase 3.4 | SAST, DAST y k6 |
| 20 | Fases 4 y 5 | Observabilidad y despliegue (opcional) |

## 15. Historial

| Fecha | Cambio | Autor |
| --- | --- | --- |
| 2026-11-11 | Creación de la guía de ejecución con prompts por fase y reglas para la IA. | Equipo |
| 2026-11-11 | Auditoría 01: se mueve a `infra-uni/docs/auditorias/auditoria-01/`; ramas solo `feature/`, `fix/` y `docs/`; rama base condicionada a `docs/ingenieria-pendiente`; registro de IA único en infra-uni; JWT en la sesión 1.2; CRUD de áreas solo en catálogos; Vitest/ESLint y CI mínima adelantados; decisiones condicionales en los prompts; healthcheck de Actuator; numeración unificada. | Equipo |
