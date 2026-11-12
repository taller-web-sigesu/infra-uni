# Auditoría de faltantes hasta la Fase III

- **Fecha:** 2026-11-11
- **Estado:** Revisión previa a la ejecución — pendiente de revisión del responsable técnico
- **Audiencia:** responsable técnico del proyecto (revisión antes de ejecutar el plan)
- **Alcance:** todo lo necesario para completar y presentar las **fases I, II y III** del curso.
- **Fuera de alcance de esta auditoría:** Fase IV y entregables finales; se listan aparte en la sección 8 porque no bloquean la presentación Fase I–III.
- **Fuentes:** propuesta del curso; [`ARCHITECTURE.md`](../../ARCHITECTURE.md); [`ALCANCE-POR-ROL.html`](../../ALCANCE-POR-ROL.html); [`DISENIO-BD.md`](../../../DISENIO-BD.md); [`user-stories`](../../requirements/user-stories/); [`plan de ingeniería`](../../superpowers/plans/2026-11-04-ingenieria-pendiente.md); [`ADR-0004`](../../adr/ADR-0004-despliegue-persistencia.md); [`ADR-0005`](../../adr/ADR-0005-ci-cd-calidad.md).

## Cómo usar este documento

| Etiqueta | Significado |
| --- | --- |
| `[HECHO]` | Existe y fue verificado. |
| `[PARCIAL]` | Hay diseño o configuración, pero falta implementación o verificación. |
| `[PLAN]` | El plan aprobado lo contempla, pero todavía no existe el artefacto. |
| `[FALTA]` | No existe y el plan tampoco lo cubre; hay que agregarlo. |
| `[DECISIÓN]` | Requiere respuesta del docente o del equipo antes de implementar. |
| `[EXTERNO]` | Existe fuera de estos repositorios; solo hay que enlazarlo como evidencia. |

El responsable técnico debe revisar la sección 10 y firmar antes de iniciar la ejecución.

## 1. Resumen ejecutivo

| Fase | Estado general | Qué falta principalmente | ¿Afecta la presentación Fase I–III? |
| --- | --- | --- | --- |
| Fase 0 — prerrequisitos | `[PARCIAL]` | Aprobar ADR, `openapi.yaml`, `SECURITY.md`, `DATABASE.md`, formato de errores y paginación | Sí |
| Fase I — análisis y prototipo | `[PARCIAL]` | Completar BDD faltantes, enlazar HTML/CSS/JS externo, API simulada y carpeta de evidencia | Sí |
| Fase II — full-stack | `[PLAN]` | Implementar backend, frontend, MySQL, MVP end-to-end y decidir evidencias/auto-registro/recuperación | Sí |
| Fase III — APIs, cloud, DevOps y seguridad | `[PARCIAL]` | Docker de producción, CI/CD, OpenAPI/Swagger, seguridad, pruebas, staging y RC | Sí |
| Transversales | `[PARCIAL]` | Registro de uso de IA, protección de `main`, enlaces rotos y planes de backend | Sí |
| Fase IV — calidad y entrega | `[FALTA]` | Carga/estrés, pruebas de usuario, observabilidad, backups, manuales e informe final | No (sección 8) |

## 2. Fase 0 — Prerrequisitos de la Fase III

| Requisito | Estado | Qué falta / acción |
| --- | --- | --- |
| Aprobar `ADR-0002` a `ADR-0005` | `[PARCIAL]` | Los cuatro ADR están redactados, pero todos siguen en estado **Propuesto**. Falta aprobación formal del equipo. |
| Validar compatibilidad de versiones | `[FALTA]` | Documentar la validación de Java 21, Spring Boot 4.1.2, MySQL 8.4.13, React 19.3.0, Vite 8.3.5 y Maven 3.9.16. |
| `backend-uni/docs/api/openapi.yaml` | `[FALTA]` | Crear el contrato OpenAPI con todos los endpoints, esquemas, filtros, errores y ejemplos. Validarlo con Spectral o Swagger CLI. |
| `backend-uni/docs/SECURITY.md` | `[FALTA]` | Crear la matriz RBAC: permisos por endpoint, rol y alcance por recurso. |
| `backend-uni/docs/DATABASE.md` | `[FALTA]` | Documentar convenciones, migraciones Flyway, diccionario de datos y estrategia de seeds. |
| Formato de errores, paginación, fechas UTC e IDs | `[FALTA]` | Definirlo en Fase 0 y aplicarlo en el módulo `shared`. |
| Herramienta de validación OpenAPI | `[FALTA]` | Elegir Spectral, Swagger CLI o equivalente e integrarla en CI. |

## 3. Fase I — Análisis, especificación y prototipo

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Documento del proyecto: problema, objetivos, actores, alcance y arquitectura | `[HECHO]` | `ARCHITECTURE.md`, `ALCANCE-POR-ROL.html`, `EPICS.md` y los documentos de requisitos. |
| Épicas, historias, tareas y criterios de aceptación | `[HECHO]` | 7 épicas y 25 HU con criterios. |
| Escenarios BDD | `[PARCIAL]` | Varias HU no tienen escenarios (por ejemplo, HU-13, HU-14, HU-17, HU-19 y HU-20). Completarlos o justificar su ausencia. |
| Especificaciones y contratos | `[PARCIAL]` | Hay diseño REST en Markdown, diseño de BD y `DESIGN.md`; falta el OpenAPI formal de la Fase 0. |
| Wireframes, mockups y prototipo | `[HECHO]` | Figma y 28 capturas en `frontend-uni/docs/superpowers/plans/capturas-figma/`. |
| HTML, CSS, JavaScript y manipulación del DOM | `[EXTERNO]` | El equipo ya lo tiene en otro espacio. Ver sección 3.1. |
| Primera interacción con API simulada | `[PLAN]` | El plan 01 de frontend incluye MSW; falta implementarlo. |
| Evidencia del primer desarrollo | `[PARCIAL]` | Existen la pantalla inicial y `GET /api/v1/status`, pero falta armar la carpeta de evidencia para la presentación. |
| Carpeta o índice de presentación Fase I | `[FALTA]` | Reunir enlaces, capturas, prototipo HTML/CSS/JS y evidencias en un solo lugar. |

### 3.1. Evidencia externa de HTML, CSS y JavaScript

El prototipo HTML/CSS/JS no se reimplementa en estos repositorios. Solo hay que enlazarlo y adjuntarlo como evidencia.

| Evidencia | Qué debe incluir | Ubicación o enlace | Responsable | Estado |
| --- | --- | --- | --- | --- |
| Prototipo HTML/CSS/JS | HTML semántico, CSS responsive, JavaScript moderno, manipulación del DOM, formularios, validaciones y `fetch` a una API simulada | Completar | Completar | `[EXTERNO]` |
| Capturas responsive | Vistas a 360, 768 y 1440 px | Completar | Completar | `[EXTERNO]` |
| README del prototipo | Cómo ejecutarlo y qué flujo demuestra | Completar | Completar | `[EXTERNO]` |
| Evidencia de commits | Fecha, autor y enlace al repositorio o tag | Completar | Completar | `[EXTERNO]` |

**Acción:** si el docente exige que la evidencia esté dentro del proyecto, copiar el prototipo a `frontend-uni/docs/fase-1/` o agregar un enlace permanente en el informe. No duplicar código en la aplicación React.

## 4. Fase II — Construcción full-stack

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Backend Spring Boot: controladores, servicios, DTO, validaciones y capas | `[PLAN]` | El diseño está en `BACKEND-DISENIO.md`; falta implementar `auth`, `users`, `catalogs`, `requests`, `management`, `dashboard`, SLA/auditoría/encuesta y `reservations`. |
| Migraciones Flyway y esquema MySQL | `[PLAN]` | El diseño está en `DISENIO-BD.md`; faltan `V1__esquema_inicial.sql`, `V2__catalogos_semilla.sql` y la semilla demo opcional. |
| Frontend React: componentes, props, estado, eventos, listas y renderizado condicional | `[PLAN]` | Los planes 01–06 existen; hoy solo hay una pantalla de bienvenida. |
| CRUD, relaciones, GET/POST/PUT/DELETE, `fetch` y manejo de estado | `[PLAN]` | Cubierto por los planes de backend y frontend; falta ejecutarlo. |
| Cookies, `localStorage` y `sessionStorage` | `[PARCIAL]` | El diseño usa cookie `HttpOnly` para el refresh token y prohíbe tokens en `localStorage`. Si el curso exige demostrar `localStorage`, usarlo solo para preferencias no sensibles y justificarlo. |
| MVP end-to-end: login → solicitud → MySQL → consulta → cambio de estado | `[PLAN]` | Es el objetivo de la Fase II; falta implementarlo y demostrarlo. |
| Datos de prueba y seeds | `[PLAN]` | La migración V3 es opcional; definir fixtures deterministas para pruebas y demo. |
| Informe parcial de la semana 10 | `[FALTA]` | Es un entregable académico de Fase II; no está en el plan técnico. |
| Decisión: evidencias en la solicitud | `[HECHO]` | Se implementa completo con almacenamiento en la nube (D1, [decisiones 01](../../decisiones/decisiones-01.md)). Faltan HU, tabla en BD y elegir el almacén. |
| Decisión: auto-registro de usuarios | `[HECHO]` | Auto-registro con aprobación del administrador, sin correo (D2, [decisiones 01](../../decisiones/decisiones-01.md)). Falta la HU. |
| Decisión: recuperación de contraseña | `[HECHO]` | Cambio de contraseña y restablecimiento por el administrador, sin correo (D3, [decisiones 01](../../decisiones/decisiones-01.md)). Falta la HU. |

## 5. Fase III — APIs, cloud, DevOps y seguridad

### 5.1. Cloud, Docker y entornos

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Selección de plataforma cloud | `[PARCIAL]` | `ADR-0004` propone Vercel (frontend), Render (backend) y MySQL gestionado, pero está en estado **Propuesto** y el proveedor MySQL (Aiven, Railway o Clever Cloud) no está elegido. |
| Docker de desarrollo | `[HECHO]` | `infra-uni/compose.yaml` + `iniciar.bat` verificados el 2026-11-11: frontend, backend y MySQL saludables. |
| Docker de producción (backend) | `[PLAN]` | Crear `backend-uni/Dockerfile` multi-stage: build con Maven, runtime JRE 21, usuario no root, healthcheck y opciones JVM. |
| Build de producción (frontend) | `[PLAN]` | Definir `npm run build`, salida `dist/`, configuración de Vercel y variables por entorno. |
| Entorno de prueba | `[FALTA]` | Definir matriz `local` / `test` / `staging` / `production`. `test` puede ser CI con Testcontainers. |
| Staging | `[PLAN]` | Crear servicios y base de datos separadas, dominio, variables y credenciales. |
| Producción | `[PLAN]` | Ídem, con accesos restringidos, TLS y backups. |
| Git y ramas | `[PARCIAL]` | La política existe en `AGENTS.md`, pero falta proteger `main` y exigir checks. |
| Secretos por entorno | `[PLAN]` | Hay `.env` local y `.env.example`; falta la matriz de secretos en GitHub, Vercel y Render. |
| Dominio, TLS, CORS y cookies | `[PLAN]` | `ADR-0004` lo exige; falta definir dominio, HTTPS, CORS por entorno y cookies `Secure`/`SameSite`. |
| Backups y rollback | `[PLAN]` | `ADR-0004` define la política; falta implementarla, probar la restauración y documentar el rollback. |
| Estimación de costos cloud | `[FALTA]` | Documentar costo mensual estimado de Render, Vercel y MySQL gestionado para elegir proveedor. |

### 5.2. CI/CD

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Workflow backend | `[PLAN]` | `.github/workflows/backend.yml`: `mvn verify`, unitarias, Testcontainers con Docker, análisis estático, escaneo de dependencias, build y publicación de imagen, smoke test. |
| Workflow frontend | `[PLAN]` | `.github/workflows/frontend.yml`: `npm ci`, lint, Vitest, build y Playwright. |
| Workflow infraestructura | `[PLAN]` | `.github/workflows/infra.yml`: `docker compose config`, validación de scripts `.bat`, escaneo de secretos y verificación de enlaces. |
| Protección de `main` | `[PLAN]` | PR obligatoria, al menos una revisión, checks obligatorios, sin force push. |
| SAST | `[PLAN]` | Elegir herramienta (CodeQL, Semgrep o Sonar) y configurarla en backend y frontend. |
| Escaneo de dependencias | `[PLAN]` | OWASP Dependency-Check, Dependabot o `npm audit`, según la herramienta elegida. |
| Escaneo de secretos | `[PLAN]` | Gitleaks o TruffleHog en CI. |
| DAST | `[PLAN]` | OWASP ZAP baseline contra staging autorizado; archivar el reporte. |
| k6 | `[PLAN]` | Script de humo y latencia; integrarlo en CI o en una ejecución programada. |
| CD a staging/producción | `[PLAN]` | Deploy a Render/Vercel, migraciones Flyway y aprobación manual para producción. |
| Evidencia de CI | `[PLAN]` | Archivar reportes, artefactos, imágenes y resultados de pruebas. |

### 5.3. API REST

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Diseño de recursos, rutas, parámetros y códigos HTTP | `[HECHO]` | 9 documentos en `backend-uni/docs/api/`, `API-DISENIO.md` y colección Postman con entorno. |
| OpenAPI formal | `[FALTA]` | Crear `backend-uni/docs/api/openapi.yaml` (Fase 0) y validarlo con Spectral o Swagger CLI. |
| Swagger UI | `[FALTA]` | Agregar `springdoc-openapi` al `pom.xml` y publicar `/swagger-ui`. |
| Formato de errores, paginación, fechas UTC e IDs | `[FALTA]` | Definirlo en Fase 0 y aplicarlo en el módulo `shared`. |
| Pruebas de API | `[PARCIAL]` | La colección Postman existe como diseño; falta ejecutarla con Newman en CI y contra staging. |
| Contract tests | `[FALTA]` | Validar las respuestas contra OpenAPI (Schemathesis o similar). |
| GraphQL / gRPC / webhooks | `[FALTA]` | Documento o sección teórica; no se implementan. |
| API Gateway | `[FALTA]` | Documento de justificación: monolito modular sin gateway y panorama de alternativas. |
| Versionado y deprecación | `[PARCIAL]` | `/api/v1` existe; falta la política escrita. |

### 5.4. Seguridad

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Autenticación JWT o sesión | `[PLAN]` | Implementar Spring Security, login, refresh, logout y revocación (Fase 1). |
| Autorización y roles | `[PLAN]` | RBAC por rol y por recurso, con pruebas de acceso. |
| Matriz RBAC (`SECURITY.md`) | `[FALTA]` | Crear el documento con permisos por endpoint y rol (Fase 0). |
| Validación de entradas | `[PLAN]` | Agregar Bean Validation y manejo global de errores. |
| Hash de contraseñas | `[PARCIAL]` | `BACKEND-DISENIO.md` menciona `PasswordEncoder`; falta definir BCrypt o Argon2 y la política de contraseñas. |
| Claves JWT y secretos | `[FALTA]` | Generar claves por entorno, nunca en el repositorio, con rotación documentada. |
| CSRF, CORS y cookies | `[PLAN]` | Configurar `HttpOnly`, `Secure`, `SameSite` y CORS por entorno. |
| Cabeceras de seguridad | `[FALTA]` | CSP, HSTS, `X-Content-Type-Options`, `X-Frame-Options` y `Referrer-Policy`. |
| Rate limiting / fuerza bruta | `[DECISIÓN]` | El Figma muestra límite de intentos, pero no está en las HU ni en el plan. Decidir si se implementa. |
| Principios OWASP | `[FALTA]` | Mapeo OWASP Top 10 y pruebas correspondientes. |
| SAST, DAST y escaneo de dependencias | `[PLAN]` | Ver sección 5.2. |
| Auditoría | `[PLAN]` | Implementar HU-19 y el registro de eventos. |
| Logs sin datos sensibles | `[PLAN]` | `ADR-0003` define la política; falta implementarla y revisarla. |
| Seguridad de archivos | `[DECISIÓN]` | Solo si se aprueban evidencias: validar tipo/tamaño, acceso autorizado y almacenamiento privado. |

### 5.5. Pruebas y automatización

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Unitarias backend | `[PLAN]` | Agregar `spring-boot-starter-test`, JUnit 5 y Mockito; probar servicios y reglas. |
| Integración backend | `[PLAN]` | Testcontainers MySQL; migraciones y endpoints. |
| Unitarias frontend | `[PLAN]` | Vitest + Testing Library; agregar script `test`. |
| E2E | `[PLAN]` | Playwright con flujos por rol. |
| Lint | `[PLAN]` | ESLint y análisis Java (Checkstyle, SpotBugs o Sonar). |
| Pruebas de API | `[FALTA]` | Newman/Postman en CI; casos 200, 400, 401, 403, 404, 409, 429 y 503. |
| Aceptación HU/BDD | `[PARCIAL]` | Las HU y los BDD existen; falta la matriz HU → prueba → evidencia. |
| Pruebas generadas por IA y revisión | `[FALTA]` | Definir proceso, prompts, revisión y registro en el log de IA. |
| Cobertura mínima | `[PARCIAL]` | El plan dice «cobertura mínima acordada», pero no hay umbral. Acordar (por ejemplo, 70%) y configurar JaCoCo. |
| Datos de prueba | `[PARCIAL]` | La migración V3 es opcional; definir fixtures deterministas. |
| Evidencia de pruebas para Fase III | `[FALTA]` | Reporte de ejecución, capturas de CI y resultados por HU. El informe final es de Fase IV. |
| k6 carga/estrés | `[PLAN]` | Pertenece a Fase IV; en Fase III basta el humo y la latencia. |

### 5.6. Release Candidate

| Requisito del curso | Estado | Qué falta / acción |
| --- | --- | --- |
| Aplicación desplegada | `[PLAN]` | Staging en Vercel + Render + MySQL gestionado. |
| API documentada | `[FALTA]` | OpenAPI + Swagger UI publicados. |
| CI/CD | `[PLAN]` | Workflows, CD y protección de `main`. |
| Autenticación, autorización y seguridad | `[PLAN]` | Implementación y pruebas. |
| Pruebas y automatización | `[PLAN]` | Suite completa y evidencia archivada. |
| Smoke tests en staging | `[PLAN]` | Script y ejecución documentada. |
| Rollback probado | `[PLAN]` | Procedimiento y prueba real. |
| Tag y versión RC | `[FALTA]` | Por ejemplo, `v1.0.0-rc.1` con release notes. |
| Evidencia final | `[FALTA]` | Reportes, capturas, URLs y credenciales de demostración. |

## 6. Transversales hasta la Fase III

| Tema | Estado | Qué falta / acción |
| --- | --- | --- |
| Registro de uso de IA | `[HECHO]` | Creado en [`infra-uni/docs/ai/AI_USAGE_LOG.md`](../../ai/AI_USAGE_LOG.md): registro único para los tres repositorios con fecha, fase, repo, herramienta, prompt, resultado, validación, modificaciones y responsable. |
| Enlaces rotos | `[HECHO]` | `backend-uni/docs/plan/00` a `04` se versionaron en la rama `docs/planes-backend` de backend-uni. Los enlaces de los planes del frontend y de la guía resuelven en cuanto esa rama se fusione. |
| Planes de backend por fase | `[PARCIAL]` | Existen `backend-uni/docs/plan/00` a `04` (rama `docs/planes-backend`). Falta decidir si se agregan planes para las fases 05–06 o se corrigen las referencias. |
| Protección de `main` | `[PLAN]` | Incluida en CI/CD; falta configurarla en GitHub. |
| Carpeta de evidencia Fase I–III | `[FALTA]` | Reunir enlaces, capturas, reportes, URLs de staging y credenciales demo para la presentación. |
| Informe parcial de Fase II | `[FALTA]` | Entregable académico de la semana 10; no está en el plan técnico. |

## 7. Decisiones que bloquean la Fase I–III
> **Actualización 2026-11-11:** 7.1, 7.2 y 7.3 están resueltas en [decisiones 01](../../decisiones/decisiones-01.md). Siguen abiertas 7.4 y 7.5.

### 7.1. Evidencias en la solicitud

**Lo que pide la propuesta:** Módulo 2, campo «Evidencias» en cada solicitud.

**Lo que cubre el plan:** fuera de alcance; `adjuntos_solicitud` está documentada como opcional y no implementada.

**Pregunta para el docente:** ¿«Evidencias» es obligatorio o deseable?

| Respuesta | Acción |
| --- | --- |
| Es obligatorio | Agregar Fase 1.5: tabla `adjuntos_solicitud`, almacenamiento (volumen local en desarrollo; S3, Cloudinary o Supabase en producción), endpoints `POST/GET/DELETE` con `multipart/form-data`, validación de tipo y tamaño, autorización por solicitud y pruebas. Agregar la UI en Fase 2. |
| Es deseable | Documentar la exclusión justificada en el informe y en `ALCANCE-POR-ROL.html`; no ampliar el plan. |

### 7.2. Auto-registro de usuarios

**Lo que pide la propuesta:** Módulo 1, «Registro de usuarios».

**Lo que cubre el plan:** solo el administrador crea usuarios (HU-15); no hay auto-registro.

**Pregunta para el docente:** ¿«Registro de usuarios» exige que el estudiante se cree su cuenta, o basta con que el administrador cree los usuarios?

| Respuesta | Acción |
| --- | --- |
| Basta el administrador | El plan actual sirve; registrar la decisión en este documento y en `ALCANCE-POR-ROL.html`. |
| Se exige auto-registro | Agregar endpoint y pantalla de registro, rol por defecto `Estudiante`, restricción al dominio institucional, verificación por correo o aprobación del administrador, y pruebas de abuso y escalada de privilegios. Encaja en Fase 1 (backend) y Fase 2 (frontend). |

### 7.3. Recuperación de contraseña

**Lo que pide la propuesta:** Módulo 1, «Recuperación o cambio de contraseña, si el grupo tiene capacidad».

**Lo que cubre el plan:** cambio obligatorio de contraseña; recuperación fuera de alcance; no hay proveedor de correo.

**Pregunta para el docente:** ¿La recuperación cuenta si solo hay cambio obligatorio?

| Respuesta | Acción |
| --- | --- |
| Solo el cambio es suficiente | No cambiar el plan; registrar la interpretación. |
| Se exige recuperación | Agregar proveedor de correo, token temporal de un solo uso, endpoints de solicitud y confirmación, pantalla y pruebas. Encaja en Fase 1 y Fase 2. |

### 7.4. Proveedor de MySQL gestionado

**Pregunta:** ¿Aiven, Railway o Clever Cloud?

**Acción:** elegir por costo, backup y latencia; documentarlo en `ADR-0004` y actualizar la estimación de costos.

### 7.5. Rate limiting y fuerza bruta

**Pregunta:** ¿Se implementa límite de intentos de login?

**Acción:** el Figma lo muestra, pero no está en las HU. Si se aprueba, agregarlo a `SECURITY.md`, al backend y a las pruebas.

## 8. Pendientes que NO afectan la Fase III

Estos puntos no bloquean la presentación de Fase I–III, pero sí la entrega final del curso.

| Tema | Estado | Qué falta |
| --- | --- | --- |
| Fase IV — pruebas de carga y estrés | `[FALTA]` | Escenarios completos con k6, latencia p95, tasa de error y informe. |
| Fase IV — pruebas de usuario y aceptación | `[FALTA]` | Guion de pruebas con usuarios, criterios de aceptación y resultados. |
| Fase IV — observabilidad | `[FALTA]` | Logs JSON, métricas, trazas, dashboards, alertas y retención. |
| Fase IV — backups y runbooks | `[FALTA]` | Backup automático, prueba de restauración, runbooks de incidentes y rollback. |
| Fase IV — revisión final | `[FALTA]` | Revisión de arquitectura, código, patrones, secretos, errores y documentación. |
| Informe final de pruebas | `[FALTA]` | Documento consolidado de Fase IV. |
| Manual de usuario | `[FALTA]` | Recorridos por rol y capturas. |
| Manual técnico | `[FALTA]` | Arquitectura, despliegue, operación y solución de problemas. |
| Informe final y presentación | `[FALTA]` | Documento final, guion de sustentación y credenciales demo. |
| Extensiones opcionales | `[DECISIÓN]` | Notificaciones, tiempo real, reservas recurrentes, recuperación de contraseña (si no se aprueba antes) y chatbot. No son obligatorias. |

## 9. Bloqueantes antes de ejecutar

1. Aprobar formalmente `ADR-0004` y `ADR-0005` (hoy están en estado Propuesto).
2. Crear `openapi.yaml`, `SECURITY.md` y `DATABASE.md` de la Fase 0.
3. Elegir el proveedor de MySQL gestionado y definir dominio, TLS, CORS y cookies.
4. Decidir si el docente exige evidencias, auto-registro y recuperación de contraseña.
5. Corregir los enlaces rotos a los planes de backend.
6. Crear `infra-uni/docs/ai/AI_USAGE_LOG.md` (hecho).
7. Agregar al plan las tareas de Fase III que hoy no están detalladas: Swagger UI, Postman en CI, contract tests, cabeceras de seguridad, rate limiting, cobertura mínima y evidencia de pruebas.
8. Armar la carpeta de evidencia Fase I–III.
9. Revisar y firmar este documento antes de iniciar la Fase 0.

## 10. Revisión del responsable técnico

| Campo | Respuesta |
| --- | --- |
| Revisado por |  |
| Fecha |  |
| Observaciones |  |
| Decisión | [ ] Aprobado para ejecutar · [ ] Aprobado con cambios · [ ] Rechazado |

## 11. Matriz de decisión

| Tema | Pregunta | Respuesta | Decisión | Fecha | Responsable |
| --- | --- | --- | --- | --- | --- |
| Registro de usuarios | ¿Auto-registro o administrador? |  |  |  |  |
| Evidencias | ¿Obligatorio o deseable? |  |  |  |  |
| Recuperación de contraseña | ¿Basta el cambio obligatorio? |  |  |  |  |
| Proveedor MySQL | ¿Aiven, Railway o Clever Cloud? |  |  |  |  |
| Rate limiting | ¿Se implementa? |  |  |  |  |

## 12. Historial

| Fecha | Cambio | Autor |
| --- | --- | --- |
| 2026-11-11 | Creación de la auditoría con las tres decisiones pendientes. | Equipo |
| 2026-11-11 | Se agrega el checklist completo de Fase III, la evidencia externa de HTML/CSS/JS y la revisión del responsable técnico. | Equipo |
| 2026-11-11 | Se reestructura en «faltantes hasta Fase III» y «pendientes que no afectan Fase III»; los documentos de Fase 0 pasan al bloque principal. | Equipo |
