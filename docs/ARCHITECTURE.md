# ARCHITECTURE.md — Sistema Web Inteligente para la Gestión Integral de Servicios Universitarios

> **Estado:** Sistema implementado y desplegado en staging y producción; Release Candidate `v1.0.0-rc.1`.  
> **Ubicación canónica:** `infra-uni/docs/ARCHITECTURE.md`.  
> **Última actualización:** 2026-11-14.  
> **Propósito:** Dar al equipo y a los agentes de IA una referencia compartida sobre límites, componentes, datos, seguridad y despliegue. **Actualizar cuando cambie una decisión aprobada o el código real.**

**Origen de requisitos:** documento académico «Sistema Web Inteligente para la Gestión Integral de Servicios Universitarios» (11 páginas). Las tecnologías React, Spring Boot y MySQL, los cinco módulos mínimos y el ciclo de 16 semanas proceden de esa propuesta. La separación en tres repositorios, arquitectura modular y plataformas de despliegue son **decisiones/propuestas del equipo**, no obligaciones del PDF.

**Regla para agentes:** este archivo explica *cómo se organiza el sistema*, no sustituye las historias de usuario ni el contrato de API. No dar por implementado ningún componente descrito aquí hasta comprobarlo en el repositorio. Si surge un conflicto entre documentos, detener la modificación, señalar la contradicción y solicitar una decisión registrada en un ADR.

## 1. Documentación y límites de propiedad

Los tres repositorios Git son independientes y se clonan como carpetas hermanas. La arquitectura se distribuye por responsabilidad:

| Referencia | Propiedad |
| --- | --- |
| [Frontend](https://github.com/taller-web-sigesu/frontend-uni/blob/main/ARCHITECTURE.md) | Estructura React, componentes, sesión, consumo de API y pruebas UI |
| [Backend](https://github.com/taller-web-sigesu/backend-uni/blob/main/ARCHITECTURE.md) | Módulos Spring Boot, API, reglas de negocio, seguridad y persistencia |
| Este documento | Visión global, integración, infraestructura, despliegue y decisiones compartidas |

```text
universidad-sm/                  # Agrupación local, no otro repositorio
├── frontend-uni/
│   ├── AGENTS.md
│   ├── ARCHITECTURE.md          # Arquitectura interna del frontend
│   ├── DESIGN.md
│   ├── Dockerfile.dev
│   └── src/
├── backend-uni/
│   ├── AGENTS.md
│   ├── ARCHITECTURE.md          # Arquitectura interna del backend
│   ├── Dockerfile.dev
│   └── src/
└── infra-uni/
    ├── AGENTS.md
    ├── compose.yaml
    ├── .env.example
    ├── iniciar.bat
    ├── detener.bat
    ├── DISENIO-BD.md
    └── docs/
        ├── ARCHITECTURE.md      # Visión global y arquitectura de infraestructura
        ├── DOCKER.md
        ├── EPICS.md
        ├── requirements/
        │   ├── Gestal_Requisitos_Funcionales.md
        │   ├── Gestal_Requisitos_No_Funcionales.md
        │   └── user-stories/
        └── superpowers/plans/
```

**Estado observado:** los módulos de negocio, el esquema MySQL y el contrato OpenAPI están implementados; el frontend cubre HU-01 a HU-29. Staging y producción están desplegados con URLs públicas, bases MySQL separadas y CI/CD con smoke. La verificación detallada está en [EVIDENCIAS.md](fase-3/EVIDENCIAS.md) y [INFORME-FASE-III.md](fase-3/INFORME-FASE-III.md).

**Límites de propiedad:** frontend posee interfaz y pruebas UI; backend posee reglas de negocio, autorización, esquema MySQL y OpenAPI; infraestructura posee documentación global, Compose, operación y evidencias. No crear `common/` entre repositorios ni copiar entidades Java al frontend. El intercambio es HTTP/JSON y contrato OpenAPI, todavía pendiente. Cada repositorio tendrá su propio CI, historial y control de acceso.

Las estructuras internas futuras se documentan en los archivos locales. `docs/adr/`, `docs/superpowers/specs/`, `docs/testing/`, `docs/ai/AI_USAGE_LOG.md`, `docs/deliverables/`, `monitoring/`, `scripts/` y `.github/workflows/` son ubicaciones previstas; crearlas al incorporar su contenido. Las decisiones compartidas se mantienen aquí y las internas en el documento del repositorio propietario.

## 2. High-Level System Diagram

```mermaid
flowchart TD
    U[Estudiante / Docente / Técnico / Supervisor / Administrador]
    F[Frontend React - Vercel]
    B[API REST Spring Boot - Render]
    DB[(MySQL - Railway)]
    E[(Evidencias - local temporal; Supabase futuro)]
    O[Logs / Métricas / Trazas]
    CI[GitHub Actions]
    I[Docker Compose local - infra-uni]

    U -->|HTTPS| F
    F -->|HTTPS / JSON /api/v1| B
    B -->|JPA / transacciones| DB
    B -.->|Archivos| E
    B --> O
    CI -->|Tests y deploy| F
    CI -->|Tests y deploy| B
    I -.->|Orquestación local| F
    I -.->|Orquestación local| B
    I -.->|Orquestación local| DB
```

**Flujo crítico de negocio:** el solicitante inicia sesión → registra solicitud → la API valida permisos y campos → MySQL guarda solicitud con código único y estado `Nuevo` → supervisor evalúa/prioriza/asigna → técnico atiende y resuelve → supervisor cierra → frontend consulta seguimiento y dashboard. Cada transición autorizada deja historial persistente.

**Flujo de reserva de ambientes:** el usuario consulta espacios y disponibilidad → registra la reserva en estado `Pendiente` → el supervisor del área del espacio o el administrador la aprueba o rechaza → el solicitante puede cancelarla antes de la hora de inicio. Cada transición deja historial y auditoría.

**Regla arquitectónica:** una sola aplicación Spring Boot desplegable (**monolito modular**), no microservicios. Los módulos internos no se comunican a través de HTTP entre sí. No introducir mensajerías, cachés distribuidas, GraphQL o API Gateway sin necesidad demostrada y ADR aprobado.

## 3. Componentes y persistencia

### 3.1. Aplicaciones

El [frontend](https://github.com/taller-web-sigesu/frontend-uni/blob/main/ARCHITECTURE.md) posee la presentación y el [backend](https://github.com/taller-web-sigesu/backend-uni/blob/main/ARCHITECTURE.md) implementará el monolito modular. Sus estructuras, dependencias, responsabilidades internas y pruebas se mantienen en sus respectivos documentos.

### 3.2. Infraestructura y documentación transversal

- **Nombre:** `infra-uni`.
- **Responsabilidad:** ejecutar el conjunto en local; mantener scripts de operación y documentación global; recopilar evidencias de Docker, CI/CD, seguridad, testing y observabilidad.
- **Tecnologías previstas:** Docker Compose, GitHub Actions y herramientas de observabilidad escogidas según viabilidad.
- **Límite:** `infra-uni` no implementa lógica de negocio ni almacena contraseñas. `compose.yaml` puede usar rutas relativas a `../frontend-uni` y `../backend-uni` cuando los tres repositorios están clonados como hermanos.

## 4. Almacenamiento y límites de confianza

MySQL es el motor exigido por la propuesta académica. Infraestructura provisiona el servicio y su persistencia; backend posee esquema, migraciones y acceso a los datos. React no consulta MySQL directamente. Consultar [persistencia del backend](https://github.com/taller-web-sigesu/backend-uni/blob/main/ARCHITECTURE.md) y el [diseño relacional](../DISENIO-BD.md).

La carga de adjuntos y su proveedor siguen pendientes: si se aprueban, los archivos requieren almacenamiento persistente y privado, con metadatos en MySQL y autorización de descarga en backend. No usar disco efímero para evidencias críticas.

No se requieren Redis, Elasticsearch, RabbitMQ ni una segunda base de datos para el MVP; cualquier adición exige necesidad demostrada y ADR.

## 5. External Integrations / APIs

| Integración | Finalidad | Método / estado |
| --- | --- | --- |
| Frontend ↔ backend | Operaciones del sistema | REST/JSON sobre HTTPS, contrato OpenAPI; **interna al proyecto** |
| Vercel | Publicar frontend | Activo en staging (`frontend-uni-tdk7`) y producción (`frontend-uni-wx9m`) |
| Render | Publicar contenedor backend | Activo en staging (`uniservice-backend-staging`) y producción (`uniservice-backend-prod`) |
| Railway MySQL | Persistencia | Activo, una instancia por entorno |
| Almacenamiento de archivos | Evidencias | Local temporal en Render; Supabase Storage queda como evolución (ADR-0004) |
| Servicio de alertas | Avisos técnicos sobre salud | Pendiente de Fase IV |

**Fuera de alcance inicial:** pagos, chatbots con LLM, servicios externos de mensajería, API Gateway y microservicios. Las notificaciones internas siguen como extensión. La reserva de ambientes fue aprobada como EP-07 (ver `docs/adr/ADR-0001-reserva-ambientes.md`) y se implementa como módulo separado. El alcance aprobado el 2026-11-04 es de **ingeniería** (ver plan en `docs/superpowers/plans/2026-11-04-ingenieria-pendiente.md`); las extensiones de producto (notificaciones, recuperación de contraseña por correo, tiempo real y reservas recurrentes) siguen fuera. Evidencias, auto-registro con aprobación y restablecimiento de contraseña por el administrador se incorporaron en `docs/decisiones/decisiones-01.md`; el rol Docente, en `docs/decisiones/decisiones-02.md`. El uso de IA durante el desarrollo **sí exige** su registro documental, pero no exige integrar un chatbot en el producto.

## 6. Deployment & Infrastructure

**Entornos:** `local` (desarrollo), `staging` (pruebas integradas) y `producción` (sustentación). Cada uno tiene configuración, rama y base de datos separadas. Nunca usar información personal real para pruebas o demos.

| Entorno | Frontend | Backend | Rama frontend | Rama backend |
| --- | --- | --- | --- | --- |
| Staging | https://frontend-uni-tdk7.vercel.app | https://uniservice-backend-staging.onrender.com | `main` | `main` |
| Producción | https://frontend-uni-wx9m.vercel.app | https://uniservice-backend-prod.onrender.com | `production` | `production` |

**Configuración local existente:** `compose.yaml` define `frontend`, `backend` y `mysql`, con arranque condicionado por salud: MySQL → backend → frontend. Vite publica `127.0.0.1:3000` y reenvía `/api` al backend; este publica `127.0.0.1:8080`. MySQL no publica puerto al host. `app_net` conecta frontend/backend y `db_internal` es interna, solo para backend/MySQL.

`mysql_data` persiste datos; `backend_target`, `maven_cache` y `frontend_node_modules` conservan artefactos y dependencias de desarrollo. MySQL tiene límite de 1 CPU y 1 GiB. Los Dockerfiles de desarrollo pertenecen a cada aplicación. No eliminar volúmenes persistentes sin autorización explícita.

Para iniciar, clonar los tres repositorios hermanos, abrir Docker Desktop y ejecutar `iniciar.bat`; crea `.env` desde `.env.example` si falta y ejecuta Compose. `detener.bat` detiene sin borrar datos. Procedimiento, configuración y límites de verificación: [README](../README.md) y [DOCKER.md](DOCKER.md).

**CI/CD implementado:**

- Frontend: dependencias → lint → Vitest → build → Playwright; Vercel despliega staging desde `main` y producción desde `production`.
- Backend: lint OpenAPI → `mvn verify` con Testcontainers → imagen Docker y smoke → CodeQL y revisión de dependencias; Render despliega staging desde `main`.
- Infra: validación de Compose, variables, scripts, secretos y enlaces.
- `main` protegida en los tres repos; `production` protegida en backend. PR con revisión y checks requeridos.
- Secretos solo en GitHub Secrets y variables de Render; nunca en el repositorio.

**Promoción a producción:** `main` → `production` con PR y checks. El push a `production` dispara `deploy-production.yml`, que exige aprobación del environment `production`, llama al Deploy Hook de Render, espera `health = UP` y ejecuta el smoke. Render producción tiene `Auto-Deploy: Off`. Procedimiento y rollback: [PROMOCION-Y-ROLLBACK.md](fase-3/PROMOCION-Y-ROLLBACK.md).

**Observabilidad mínima:** Spring Actuator/Micrometer para salud y métricas, logs estructurados, identificador de correlación y trazas (OpenTelemetry es una opción expresamente mencionada por la propuesta). Alertas por indisponibilidad y errores anómalos; proteger endpoints de administración/actuator. Ver [ADR-0003](adr/ADR-0003-observabilidad-retencion.md).

## 7. Seguridad transversal

Backend es responsable de autenticación, RBAC y controles por recurso, validación, auditoría y protección de datos. Frontend aplica la experiencia de sesión y permisos sin sustituir controles del servidor. Los detalles están en las arquitecturas locales.

Infraestructura gestiona aislamiento de redes, configuración por entorno, secretos y persistencia. Nunca versionar `.env` ni credenciales reales. La configuración local usa HTTP y conexión MySQL sin TLS dentro de Docker; no extrapolarla a producción, donde se requiere HTTPS/TLS y revisión de credenciales y acceso.

La sesión implementada usa un JWT de acceso de corta duración en memoria y un refresh token en cookie `HttpOnly` (ver [ADR-0002](adr/ADR-0002-autenticacion-sesion.md), estado Propuesto). La cookie se coordina con CORS, `Secure`, SameSite y el proxy same-origin del frontend. Los adjuntos y endpoints operativos requieren autorización. No registrar tokens, contraseñas ni información sensible innecesaria.

## 8. Development & Testing Environment

**Configuración local:** los tres repositorios se ejecutan con Docker Desktop y Compose según `infra-uni/README.md`; el host solo requiere Git y Docker Desktop, no Java, Maven, Node.js ni MySQL. La configuración actual fija React 19.3.0, Vite 8.3.5, Java 21, Spring Boot 4.1.2, Maven 3.9.16 y MySQL 8.4.13. Vite aplica HMR en cambios del frontend; para código Java, Maven compila dentro del contenedor y Spring Boot DevTools reinicia al detectar las clases compiladas.

**Pruebas por capa:**

| Capa / propósito | Herramientas propuestas | Evidencia esperada |
| --- | --- | --- |
| Reglas de negocio | JUnit 5 + Mockito | Transiciones, permisos, validaciones |
| Persistencia/API | Spring Boot Test + Testcontainers MySQL | Migraciones, transacciones, códigos HTTP |
| UI React | Vitest + Testing Library | Formularios, carga, error y estados vacíos |
| Flujo integral | Playwright | Login → crear → asignar → resolver → cerrar |
| Calidad estática | ESLint, análisis Java y dependencias | Reportes CI reproducibles |
| Seguridad | SAST y OWASP ZAP sobre entorno autorizado | Informe de hallazgos y correcciones |
| Rendimiento | k6 | Carga, estrés, latencia, tasa de error |
| Aceptación | Historias HU + escenarios BDD | Matriz HU → PR → test → evidencia |

**Definition of Done por historia:** especificación aprobada, test relevante creado y ejecutado, cambio de código revisado, endpoint/documentación actualizada si aplica, evidencia guardada y registro de uso de IA cuando corresponda. **No afirmar que las pruebas pasan sin ver su salida.**

**Trabajo con agentes IA:** `AGENTS.md` define reglas de trabajo, `.agents/skills/` define procedimientos, `DESIGN.md` define UI y las HU individuales definen comportamiento funcional. Un agente debe localizar y leer la HU exacta antes de modificar código. Acceso a otro repositorio **no es automático**: proporcionar workspace multirrepositorio, rutas montadas o una copia explícita del contexto autorizado. No permitir que el agente invente endpoints, requisitos o dependencias no aprobadas.

## 9. Future Considerations / Roadmap

**Semanas 1–4 (Fase I):** definición y aprobación de requisitos, épicas, HU individuales, BDD, arquitectura, modelo ER y `DESIGN.md`; primer frontend con mocks.

**Semanas 5–10 (Fase II):** Spring Boot, MySQL, login, solicitudes, asignación, gestión de estados, administración y dashboard; en semana 10 debe existir un **MVP end-to-end** y el informe parcial.

**Semanas 11–13 (Fase III):** documentación OpenAPI, Docker, cloud, entornos, CI/CD, controles OWASP, automatización y release candidate.

**Semanas 14–16 (Fase IV):** pruebas de aceptación/usuario/seguridad/carga/estrés, logs/métricas/trazas, correcciones, manuales y **sustentación con demostración real** en semana 16.

**EP-07 (reserva de ambientes):** aprobada; su diseño relacional vive en `DISENIO-BD.md` y su implementación se planifica después del núcleo de autenticación y solicitudes.

**Posibles extensiones, nunca automáticas:** notificaciones internas, recuperación de contraseña y mejoras de tiempo real. Un chatbot con IA no es un módulo obligatorio del PDF. No migrar a microservicios sin restricciones técnicas verificadas.

**Estado de los ADR:** ADR-0004 (despliegue y persistencia) y ADR-0005 (CI/CD) están **Aceptados**. ADR-0001 (reserva de ambientes), ADR-0002 (autenticación) y ADR-0003 (observabilidad) siguen **Propuestos**, aunque sus mecanismos están implementados. **Siguen pendientes de decisión de producto:** regla exacta de fechas límite y KPI de vencidas, política de cierre/reapertura y retención de auditoría.

### 9.1. Plan de ingeniería aprobado (2026-11-04)

El equipo aprobó cerrar la brecha de ingeniería sin ampliar el alcance funcional. El plan detallado vive en [`docs/superpowers/plans/2026-11-04-ingenieria-pendiente.md`](superpowers/plans/2026-11-04-ingenieria-pendiente.md).

- **Fase 0:** ADR-0002 a ADR-0005, OpenAPI, `SECURITY.md`, `DATABASE.md` y validación de versiones.
- **Fase 1:** Flyway, `shared`, `auth`, `users`, `catalogs`, `requests`, `management`, `dashboard`, SLA/auditoría/encuesta y `reservations`.
- **Fase 2:** router, cliente HTTP, features por rol, accesibilidad, Vitest y Playwright.
- **Fase 3:** CI/CD, SAST y puertas de calidad implementados; DAST y k6 quedan pendientes.
- **Fase 4:** logs JSON, métricas, trazas, alertas, retención, backups y runbooks.
- **Fase 5:** Docker de producción, Vercel/Render/MySQL gestionado, staging, producción, rollback y smoke tests. **Completado.**

**Decisiones:** [ADR-0002 autenticación](adr/ADR-0002-autenticacion-sesion.md), [ADR-0003 observabilidad](adr/ADR-0003-observabilidad-retencion.md), [ADR-0004 despliegue](adr/ADR-0004-despliegue-persistencia.md) y [ADR-0005 CI/CD](adr/ADR-0005-ci-cd-calidad.md).

**Sigue fuera de alcance:** pagos, chatbot con LLM, mensajería externa, API Gateway, microservicios, notificaciones, recuperación de contraseña por correo, tiempo real y reservas recurrentes.

## 10. Project Identification

| Campo | Valor |
| --- | --- |
| Nombre | Sistema Web Inteligente para la Gestión Integral de Servicios Universitarios |
| Organización GitHub | taller-web-sigesu (verificada) |
| Repositorio frontend | `frontend-uni` — https://github.com/taller-web-sigesu/frontend-uni |
| Repositorio backend | `backend-uni` — https://github.com/taller-web-sigesu/backend-uni |
| Repositorio infraestructura | `infra-uni` — https://github.com/taller-web-sigesu/infra-uni |
| Equipo | Grupo académico de cinco integrantes |
| Responsable técnico/contacto | Por asignar por el equipo |
| Fuente del alcance | PDF de propuesta del curso, 11 páginas |
| Estado de implementación | Implementado y desplegado; Release Candidate `v1.0.0-rc.1` |
| Última actualización | 2026-11-14 |

**Gobernanza de cambios:** toda decisión arquitectónica relevante se registra en `infra-uni/docs/adr/ADR-XXXX-descripcion.md`, enlaza las historias afectadas y se revisa por al menos otro integrante. Al implementar un módulo, corregir este documento para diferenciar intención de realidad. Revisarlo en cada entrega parcial y final.

## 11. Glossary / Acronyms

| Término | Significado |
| --- | --- |
| **API REST** | Interfaz HTTP basada en recursos utilizada para conectar frontend y backend. |
| **BDD** | Behavior-Driven Development: criterios de comportamiento en escenarios Dado/Cuando/Entonces. |
| **HU** | Historia de usuario; archivo de requisito funcional identificable, con criterios de aceptación. |
| **MVP** | Producto mínimo viable demostrable de extremo a extremo. |
| **RBAC** | Role-Based Access Control; autorización por roles, complementada por permisos sobre recursos. |
| **JWT** | JSON Web Token; posible mecanismo de autenticación, no obligatorio frente a sesiones. |
| **DTO** | Data Transfer Object; estructura de entrada/salida de la API. |
| **JPA** | Jakarta Persistence API; interfaz de persistencia relacional usada con Spring Data. |
| **CI/CD** | Integración continua y entrega/despliegue continuo. |
| **SAST / DAST** | Análisis de seguridad estático / dinámico. |
| **OpenAPI** | Especificación formal y versionada del contrato HTTP. |
| **ADR** | Architectural Decision Record; documento breve que registra una decisión técnica, alternativas y consecuencias. |
| **Registro de IA** | Evidencia de prompts, resultados, validaciones, modificaciones y responsables del desarrollo asistido por IA. |

---

### Reglas de lectura para agentes (resumen)

1. Leer `AGENTS.md`, el `ARCHITECTURE.md` del repositorio activo y esta arquitectura global.
2. Leer la HU individual, requisitos y criterios BDD de la tarea; para UI, leer también `frontend-uni/DESIGN.md`.
3. Para contratos REST y datos, consultar la arquitectura del backend y `infra-uni/DISENIO-BD.md`; OpenAPI, `docs/DATABASE.md` y migraciones son referencias previstas hasta que se implementen.
4. No considerar como existente ninguna carpeta o endpoint de la arquitectura objetivo sin verificar el código.
5. Si un cambio atraviesa repositorios, coordinar contratos, revisiones y pruebas de integración antes de darlo por cerrado.
6. Mantener este documento y el registro de uso de IA actualizados; no añadir funcionalidades fuera de alcance sin aprobación.
