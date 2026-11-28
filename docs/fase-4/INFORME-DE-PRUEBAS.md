<div class="portada">

# Informe de pruebas

**Gestal / UniService**

Sistema Web para la Gestión Integral de Servicios Universitarios

Fase IV · Entrega final (`v1.0.0`) · 27/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

Responsable: Persona 5 (QA Lead)

</div>

## 1. Alcance y objetivos

Este informe consolida la estrategia, ejecución y resultados de las pruebas realizadas para el cierre de la Fase IV de Gestal / UniService. Abarca pruebas unitarias, de integración, funcionales y de regresión, seguridad de caja negra, análisis estático y dinámico (SAST/DAST), accesibilidad, compatibilidad cross-browser y responsive, rendimiento, respaldo/restauración, así como los instrumentos de aceptación (UAT) y usabilidad.

Se complementa con `06-Evidencias/EVIDENCIAS-TECNICAS.pdf` (P2), `02-Documentacion/ANEXO-MEJORAS-UI-UX.pdf` (P3), `06-Evidencias/INDICE-DE-EVIDENCIAS.pdf` (P5) y `06-Evidencias/VERIFICACION-FINAL.pdf` (P5/P1).

## 2. Entornos y versiones evaluadas

| Entorno | Componente | Revisión / Dirección | Uso en QA |
| --- | --- | --- | --- |
| Staging | Frontend (Vercel) | `frontend-uni@0d950e3` · <https://frontend-uni-tdk7.vercel.app> | Pruebas funcionales, cabeceras, CSP, demo |
| Staging | Backend (Render) | `backend-uni@8136b68` · <https://uniservice-backend-staging.onrender.com> | Pruebas funcionales, seguridad caja negra, DAST, smoke k6 |
| CI (GitHub Actions) | Backend, Frontend e Infra | `backend-uni@8136b68`, `frontend-uni@0d950e3`, `infra-uni@942adc6` | Unitarias, integración, E2E cross-browser, axe, CodeQL |
| Local (Windows 11 / Docker) | Frontend y pila de observabilidad | `frontend-uni@0d950e3`, Docker Compose + MySQL 8.4.13 | Lint, Vitest, build, k6 carga/estrés, Grafana/Tempo |

## 3. Resumen ejecutivo de pruebas automatizadas

| Suite / Herramienta | Repositorio / Entorno | Ejecutadas | Aprobadas | Omitidas | Fallidas | Evidencia |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| JUnit 5 (unitarias) | `backend-uni` CI (`8136b68`) | 13 | 13 | 0 | 0 | Run `46075021436` |
| Failsafe + Testcontainers MySQL 8.4 (integración) | `backend-uni` CI (`8136b68`) | 94 | 94 | 0 | 0 | Run `46075021436` |
| `staging-smoke` (API en vivo) | `backend-uni` CI (`8136b68`) | 1 flujo | 1 | 0 | 0 | Run `46078054975` |
| ESLint + compilación Vite | `frontend-uni` local y CI (`0d950e3`) | 2 checks | 2 | 0 | 0 | Verificado local y run `46083003177` |
| Vitest + Testing Library (unitarias/componentes) | `frontend-uni` local y CI (`0d950e3`) | 289 (46 archivos) | 289 | 0 | 0 | Verificado local (17,60 s) y run `46083003177` |
| Playwright E2E + axe-core (4 proyectos) | `frontend-uni` CI (`0d950e3`) | 112 | 108 | 4 | 0 | Run `46083003177` (3,1 min) |
| CodeQL SAST (Java y JS/TS) | `backend-uni` y `frontend-uni` CI | 2 análisis | 2 | 0 | 0 | Runs `46075021436` y `46083003163` |
| Infra CI (Compose, variables, scripts, secretos) | `infra-uni` CI (`942adc6`) | 2 jobs | 2 | 0 | 0 | Run `46084152235` |

> Nota sobre las 4 pruebas omitidas en Playwright: corresponden al mismo caso de revocación de sesión única (1 por cada proyecto de la matriz), que requiere API real y no MSW. Ese comportamiento se verificó directamente contra el backend real en `AuthIT` y en el caso `QA-07` sobre staging.

## 4. Pruebas funcionales y de seguridad de caja negra en staging (P5)

El 27/11/2026 se ejecutó una batería directa de 19 casos de prueba de caja negra contra staging (`backend-uni@8136b68` y `frontend-uni@0d950e3`), cubriendo salud, cabeceras, los 7 roles demo, sesión única, datos de Fase IV (`LAB-10` y `CANCHA-01`), ciclo completo de solicitudes (`SOL-2026-000019`), autorización por rol y área, IDOR, carga de archivos maliciosos, administración, indicadores y límite de intentos de login.

| ID | Categoría | Caso de prueba | Resultado | Evidencia observada |
| --- | --- | --- | --- | --- |
| QA-01 | Salud | `GET /actuator/health` público sin detalles internos | Aprobado | HTTP 200; JSON contiene únicamente `status: UP` y `groups`. |
| QA-02 | Salud | `GET /api/v1/status` público operativo | Aprobado | HTTP 200; `{"service":"backend","status":"UP"}`. |
| QA-03 | Seguridad | `GET /actuator/prometheus` anónimo rechazado | Aprobado | HTTP 401. |
| QA-04 | Seguridad | `GET /actuator/info` anónimo rechazado | Aprobado | HTTP 401. |
| QA-05 | Seguridad | Cabeceras HTTP en frontend staging (`/login`) | Aprobado | HTTP 200; presentes `Content-Security-Policy`, `Strict-Transport-Security`, `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy` y `Permissions-Policy`. |
| QA-06 | Funcional | Inicio de sesión con las 7 cuentas demo por rol | Aprobado | HTTP 200 y rol correcto para `ana.demo` (ESTUDIANTE), `pedro.demo` (DOCENTE), `tecnico.ti.demo` (TECNICO), `tecnico.sg.demo` (TECNICO), `supervisor.ti.demo` (SUPERVISOR), `supervisor.sg.demo` (SUPERVISOR) y `admin.demo` (ADMINISTRADOR). |
| QA-07 | Seguridad / Sesión | Sesión única revoca token anterior y fallo de login conserva sesión vigente | Aprobado | Segundo login HTTP 200; token previo recibe HTTP 401 en `/api/v1/requests`; intento con clave inválida recibe HTTP 401 y el token vigente continúa respondiendo HTTP 200. |
| QA-08 | Funcional / Demo | Datos demo Fase IV visibles en `/api/v1/spaces` | Aprobado | HTTP 200; 18 espacios activos, incluidos `LAB-10` (capacidad 30) y `CANCHA-01` (capacidad 40). |
| QA-09 | Funcional / Reservas | Consulta de disponibilidad de `LAB-10` y `CANCHA-01` | Aprobado | HTTP 200 para ambos espacios en fecha hábil (`2026-12-01`). |
| QA-10 | Funcional / Catálogos | Listado de categorías activas para estudiante | Aprobado | HTTP 200; categoría `Soporte informático` (`id=1`, `areaId=1`) disponible. |
| QA-11 | Funcional / Solicitudes | Registro de nueva solicitud por estudiante | Aprobado | HTTP 201; solicitud creada con código `SOL-2026-000019` (`id=19`). |
| QA-12 | Seguridad / IDOR | Aislamiento entre estudiantes (detalle, historial y comentarios ajenos) | Aprobado | `pedro.demo` recibe HTTP 404 en detalle, historial y comentarios de `SOL-2026-000019`. |
| QA-13 | Seguridad / Autorización | Restricción de asignación por rol y área | Aprobado | `admin.demo` recibe HTTP 403 y `supervisor.sg.demo` (otra área) recibe HTTP 404 al intentar asignar `SOL-2026-000019`. |
| QA-14 | Funcional / Ciclo de vida | Asignación de técnico elegible y cambio de prioridad por supervisor TI | Aprobado | `POST /assignments` HTTP 201 y `PATCH /requests/19` (prioridad) HTTP 200. |
| QA-15 | Seguridad / Uploads | Rechazo de archivo ejecutable `.exe` en adjuntos | Aprobado | HTTP 400 al subir `malicioso.exe` (`application/octet-stream`). |
| QA-16 | Funcional / Ciclo de vida | Transiciones completas Técnico (`EN_PROCESO` -> `RESUELTO`) y Supervisor (`CERRADO`) | Aprobado | Técnico no asignado recibió HTTP 404 y cierre prematuro HTTP 409; tras asignar `tecnico.ti.demo` (`id=7`): `EN_PROCESO` HTTP 200, `RESUELTO` HTTP 200 y `CERRADO` HTTP 200. |
| QA-17 | Funcional / Admin | Gestión de usuarios y catálogos restringida a administrador | Aprobado | `admin.demo` obtiene HTTP 200 en `/admin/users`, `/admin/catalogs/areas` y `/admin/catalogs/request-statuses`; `ana.demo` recibe HTTP 403 en `/admin/users`. |
| QA-18 | Seguridad / Indicadores | Dashboard global para admin y aislamiento de área para supervisor | Aprobado | Con `fechaDesde`/`fechaHasta`: `admin.demo` HTTP 200, `supervisor.ti.demo` en área 1 HTTP 200 y en área 3 (ajena) HTTP 403. |
| QA-19 | Seguridad / Rate limit | Límite de intentos fallidos en `POST /api/v1/auth/login` en staging | Observado (`DEF-01`) | 8 intentos consecutivos con correo inexistente devolvieron HTTP 401 sin HTTP 429 en Render staging; en `AuthIT` (CI/local) sí retorna HTTP 429. Ver sección 6. |

Resultado de la batería en staging: **18 aprobadas y 1 hallazgo documentado (`DEF-01`)** de 19 casos ejecutados.

## 5. Accesibilidad, cross-browser, seguridad DAST/SAST, rendimiento y respaldo

### 5.1 Accesibilidad y navegación por teclado

La suite `frontend-uni/e2e/a11y.spec.js` ejecuta `@axe-core/playwright` contra las reglas WCAG 2.0 A/AA, WCAG 2.1 A/AA y WCAG 2.2 AA (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `wcag22aa`) sobre 11 vistas autenticadas y públicas (`/login`, `/inicio` estudiante y administrador, `/solicitudes`, `/reservas/nueva`, detalle de solicitud, `/gestion`, `/indicadores`, `/reservas/aprobacion`, `/admin/usuarios`, `/admin/catalogos`).

- **Infracciones críticas o graves (`critical` / `serious`):** 0 en todas las pantallas y navegadores de la matriz.
- **Teclado y foco:** verificados el enlace «Saltar al contenido» (`Tab` + `Enter` hacia `<main>`), expandir/contraer menú lateral en escritorio con `aria-expanded`, diálogo móvil con retorno de foco al pulsar `Escape`, migas de navegación (`aria-current="page"`) y ausencia de desbordamiento horizontal (`scrollWidth <= innerWidth`).

### 5.2 Matriz cross-browser y responsive

Ejecutada en el CI de `frontend-uni` (run `46083003177`, 27/11/2026) con Playwright 1.65.1:

| Proyecto | Motor / Dispositivo | Viewport | Aprobadas | Omitidas | Fallidas |
| --- | --- | --- | ---: | ---: | ---: |
| `chromium` | Desktop Chrome | 1440 × 900 | 27 | 1 | 0 |
| `mobile` | Mobile Chrome (táctil) | 360 × 740 | 27 | 1 | 0 |
| `firefox` | Desktop Firefox | 1024 × 768 | 27 | 1 | 0 |
| `webkit` | Desktop Safari / WebKit | 1440 × 900 | 27 | 1 | 0 |
| **Total** | **4 proyectos** | — | **108** | **4** | **0** |

### 5.3 Seguridad (SAST, DAST, secretos), rendimiento y respaldo (insumos de P2)

Los reportes fuente están en `infra-uni/docs/fase-4/` y consolidados en `06-Evidencias/EVIDENCIAS-TECNICAS.pdf` (complementados por `CIERRE-P2.pdf` y `CIERRE-P2-SEGURIDAD.pdf`):

- **SAST:** CodeQL en verde en `backend-uni` (Java) y `frontend-uni` (JavaScript/TypeScript).
- **DAST activo (OWASP ZAP 2.17.0):** 0 hallazgos altos; 4 medios aceptados (CSP `style-src 'unsafe-inline'` en SPA, CORS `*` en estáticos públicos sin credenciales, CSP ausente en Swagger UI, `/actuator/health` mínimo), 1 bajo (falso positivo de timestamp en Swagger UI) y 9 informativos.
- **Secretos (Gitleaks 8.28.0):** 0 secretos reales en `backend-uni` e `infra-uni` (1 falso positivo en fixture de prueba de Supabase).
- **Rendimiento (k6 2.4.0):** carga local candidato ~11,01 req/s, 0 % errores, p95 21,89 ms; estrés local hasta 40 req/s (45 s), 0 % errores, p95 15,49 ms; smoke staging (`8136b68`) 6/6 peticiones, 12/12 checks, 0 % errores, p95 441,89 ms.
- **Respaldo y restauración:** volcado lógico MySQL de staging restaurado en base temporal aislada con 27 tablas y 460 filas, 0 diferencias (`VERIFICACION-BACKUP-RESTORE.md`).

## 6. Registro de defectos y observaciones

| ID | Severidad | Componente | Descripción y evidencia | Estado / Responsable |
| --- | --- | --- | --- | --- |
| DEF-01 | Media | `backend-uni` / Staging Render | En `QA-19`, 8 intentos fallidos consecutivos en `POST /api/v1/auth/login` sobre Render staging devolvieron `401` sin activar `429`. La clave de `LoginAttemptLimiter` usa `correo + "|" + request.getRemoteAddr()`; detrás del proxy inverso de Render la IP interna puede variar entre nodos si no se resuelve la IP de cliente reenviada. En `AuthIT` (CI/local) el bloqueo `429` sí se activa tras 5 fallos. | Reportado por P5 a P2 para evaluar `server.forward-headers-strategy=framework` en versión `v1.0.1` o evolución. No bloquea la demo. |
| OBS-01 | Baja | Drive de entrega | Las carpetas locales `01` a `08` contenían archivos `.md` vacíos (0 bytes) que incumplen la regla de dejar solo PDFs en la entrega final. | P5 limpia los archivos propios y notifica a P4 para retirar los `.md` vacíos restantes antes del envío. |
| OBS-02 | Informativa | Drive `06-Evidencias/` | Existen dos PDFs complementarios de P2 (`CIERRE-P2.pdf` y `CIERRE-P2-SEGURIDAD.pdf`) adicionales a los 13 PDFs de la matriz. | Se documentan en `INDICE-DE-EVIDENCIAS.pdf` y `VERIFICACION-FINAL.pdf`; P1/P4 definen si se conservan o se fusionan en `EVIDENCIAS-TECNICAS.pdf`. |

## 7. Pruebas de aceptación (UAT)

### 7.1 Matriz de criterios de aceptación

| Código | Criterio de aceptación (HU / Fase IV) | Validación técnica previa (P5) | Validación usuario (UAT) |
| --- | --- | --- | --- |
| UAT-01 | Autenticación por rol y redirección al inicio correspondiente (HU-01, HU-02) | Aprobado (`QA-06`, E2E) | Pendiente de firma |
| UAT-02 | Sesión única revoca sesiones previas de la misma cuenta (Fase IV) | Aprobado (`QA-07`, `AuthIT`) | Pendiente de firma |
| UAT-03 | Registro de solicitud, detalle, historial, comentarios y adjuntos válidos (HU-03 a HU-06, HU-26) | Aprobado (`QA-11`, `QA-15`, E2E) | Pendiente de firma |
| UAT-04 | Asignación por supervisor de área, prioridad y ciclo de vida completo hasta cierre/rechazo (HU-07 a HU-11) | Aprobado (`QA-13`, `QA-14`, `QA-16`) | Pendiente de firma |
| UAT-05 | Consulta de disponibilidad, reserva y aprobación de `LAB-10` y `CANCHA-01` (HU-21 a HU-24, Fase IV) | Aprobado (`QA-08`, `QA-09`, `VERIFICACION-STAGING-FINAL`) | Pendiente de firma |
| UAT-06 | Panel administrativo con mejoras UI/UX: marca UNMSM, menú contraíble, breadcrumbs, usuarios y catálogos (HU-15 a HU-17, Anexo UI/UX) | Aprobado (`QA-17`, Vitest, Playwright) | Pendiente de firma |
| UAT-07 | Indicadores mensuales con aislamiento por área para supervisor y vista global para administrador (HU-12, HU-13) | Aprobado (`QA-18`, E2E) | Pendiente de firma |

### 7.2 Acta de aceptación de usuarios (UAT)

> Nota de trazabilidad: las verificaciones técnicas automáticas y en staging fueron ejecutadas por P5 el 27/11/2026. El siguiente registro formal debe completarse con las firmas de los participantes y la aprobación de P1 antes del lunes 30/11/2026 a las 8:00 am.

- **Proyecto:** Gestal / UniService (`v1.0.0`)
- **Entorno UAT:** Staging (<https://frontend-uni-tdk7.vercel.app>)
- **Fecha de sesión UAT:** ____ / 11 / 2026
- **Resultado global:** [ ] Aceptado sin observaciones  [ ] Aceptado con observaciones menores  [ ] Rechazado

| Rol representado | Nombre del evaluador | Resultado | Firma / Conformidad |
| --- | --- | --- | --- |
| Estudiante / Solicitante | | | |
| Supervisor de área | | | |
| Técnico de atención | | | |
| Administrador | | | |
| QA Lead (Persona 5) | Gianpierre Rodrigo Dulanto Romero | Validación técnica completada | |
| Aprobación final (Persona 1) | Sebastian Andree Tejeda Alata | | |

## 8. Pruebas de usabilidad (protocolo para 5–8 usuarios)

Para cumplir el requisito de pruebas de usabilidad con entre 5 y 8 usuarios representativos, se define el protocolo estandarizado y las métricas objetivo. La ejecución presencial con participantes queda programada para el cierre del Bloque 2 (antes del 30/11/2026, 8:00 am) sin fabricar resultados sintéticos.

### 8.1 Tareas representativas y métricas objetivo

| Tarea | Rol | Descripción | Meta de éxito | Tiempo objetivo |
| --- | --- | --- | ---: | ---: |
| T1 | Estudiante | Iniciar sesión, registrar una incidencia en `Laboratorio 10` y ubicar su código. | ≥ 90 % | ≤ 90 s |
| T2 | Estudiante | Consultar disponibilidad de `Cancha deportiva` (`CANCHA-01`) y crear una reserva. | ≥ 90 % | ≤ 90 s |
| T3 | Supervisor | Encontrar la solicitud en gestión, asignar técnico y cambiar prioridad. | ≥ 90 % | ≤ 60 s |
| T4 | Supervisor | Abrir el detalle de una reserva pendiente desde el ícono del ojo y aprobarla. | ≥ 90 % | ≤ 45 s |
| T5 | Técnico | Actualizar una solicitud asignada de `En proceso` a `Resuelto` con comentario. | ≥ 90 % | ≤ 60 s |
| T6 | Administrador | Desde Inicio, abrir Usuarios mediante acceso rápido, usar breadcrumbs y contraer el menú. | ≥ 90 % | ≤ 45 s |

### 8.2 Hoja de registro de sesiones (5 a 8 participantes)

| Participante | Perfil | T1 (s / OK) | T2 (s / OK) | T3 (s / OK) | T4 (s / OK) | T5 (s / OK) | T6 (s / OK) | Puntaje SUS (0–100) | Hallazgo principal |
| --- | --- | --- | --- | --- | --- | --- | --- | ---: | --- |
| P-01 | | | | | | | | | |
| P-02 | | | | | | | | | |
| P-03 | | | | | | | | | |
| P-04 | | | | | | | | | |
| P-05 | | | | | | | | | |
| P-06 (opc.) | | | | | | | | | |

## 9. Conclusiones

1. **Calidad técnica verificada:** los tres repositorios mantienen CI en verde sobre `main` (`backend-uni@8136b68`, `frontend-uni@0d950e3`, `infra-uni@942adc6`), con 107 pruebas backend (13 unitarias + 94 integración), 289 pruebas unitarias frontend, 108 pruebas E2E cross-browser con 0 infracciones graves de accesibilidad y SAST/DAST sin vulnerabilidades altas.
2. **Validación en staging:** 18 de 19 pruebas de caja negra ejecutadas por P5 pasaron en vivo sobre staging, confirmando el funcionamiento de los 7 roles, sesión única, `LAB-10`, `CANCHA-01`, ciclo completo de solicitudes, aislamiento por rol/área, uploads y cabeceras CSP.
3. **Pendientes transparentes antes del envío final:** cerrar la observación `DEF-01` (rate limit tras proxy de Render, no bloqueante para la demo), completar el registro presencial de UAT y usabilidad (secciones 7 y 8) con las firmas correspondientes y coordinar con P4/P1 el etiquetado `v1.0.0`.
