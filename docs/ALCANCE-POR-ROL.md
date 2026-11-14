# Alcance por rol — Gestal

> **Propósito:** resumen no técnico de qué se implementará, qué queda fuera y qué está pendiente, agrupado por rol.
> **Fuentes:** `docs/ARCHITECTURE.md`, `docs/EPICS.md`, `docs/requirements/`, `docs/adr/`, `DISENIO-BD.md` y `docs/superpowers/plans/2026-11-04-ingenieria-pendiente.md`.
> **Última actualización:** 2026-11-14 (Fase III cerrada y desplegada).
>
> **Estado:** implementado y desplegado en staging y producción. El detalle de la entrega está en [`docs/fase-3/INFORME-FASE-III.md`](fase-3/INFORME-FASE-III.md).

## 1. Punto de partida

El producto ya no es un esqueleto: las HU-01 a HU-29 están implementadas, con API REST documentada, base MySQL versionada con Flyway, autenticación, autorización, pruebas automatizadas y dos despliegues (staging y producción). Lo que sigue abajo describe el alcance por rol y lo que quedó fuera o pendiente.

## 2. Alcance por rol

### 2.1 Todos los usuarios (transversal)

| Se implementará | No se implementará / pendiente |
| --- | --- |
| Iniciar y cerrar sesión con correo y contraseña. | Recuperación de contraseña por correo (la cubre el restablecimiento por el administrador). |
| Registrarse con correo institucional `@unmsm.edu.pe` (solo estudiantes); la cuenta queda pendiente hasta que el administrador la aprueba. | Verificación de la cuenta por correo. |
| Cambiar la propia contraseña desde el perfil. | — |
| Ver solo las opciones y datos permitidos por su rol. | Notificaciones por correo o internas. |
| Consultar espacios reservables y su disponibilidad. | Varios roles por usuario (se asume uno por cuenta). |
| Registrar reservas y consultar o cancelar las propias. | Tiempo real (actualizaciones en vivo). |

### 2.2 Estudiante y docente

El docente tiene los mismos permisos que el estudiante. Su cuenta la crea el administrador; no se auto-registra.

| Se implementará | No se implementará / pendiente |
| --- | --- |
| Registrar solicitud con categoría, descripción y ubicación, con validación de campos. | Evidencias de otros formatos (video, audio) o de más de 5 MB. |
| Adjuntar, ver y eliminar evidencias (JPG, PNG o PDF) en sus solicitudes abiertas. | — |
| Ver el listado de sus solicitudes con código, categoría, estado, prioridad y fecha. | Recibir avisos de cambio de estado. |
| Ver el detalle con responsable, estado e historial, y comentar. | — |
| Responder la encuesta de satisfacción al cierre de su solicitud. | Política de reservas o prioridad propias para docentes. |

### 2.3 Técnico

| Se implementará | No se implementará / pendiente |
| --- | --- |
| Ver sus solicitudes asignadas, ordenadas por prioridad y fecha. | Asignar, reasignar o cerrar solicitudes. |
| Cambiar el estado de sus asignadas a «En proceso» y «Resuelto». | Cambiar la prioridad de una solicitud. |
| Ver detalle e historial y comentar. | Aprobar o rechazar reservas, salvo que además sea supervisor. |

### 2.4 Supervisor

| Se implementará | No se implementará / pendiente |
| --- | --- |
| Ver la bandeja de su área con filtros por estado, categoría y prioridad. | Reabrir solicitudes cerradas o rechazadas (sin decisión). |
| Asignar y reasignar solicitudes a técnicos de su área y ajustar la prioridad. | Exportar reportes (prioridad baja, no se descarta). |
| Cerrar solicitudes resueltas y rechazar con motivo obligatorio. | Reasignación múltiple o por lotes. |
| Aprobar o rechazar reservas de los espacios de su área. | Gestionar espacios o políticas de reserva. |
| Ver el dashboard con los indicadores, filtros por fecha y área. | — |

### 2.5 Administrador

| Se implementará | No se implementará / pendiente |
| --- | --- |
| Crear, editar y desactivar usuarios; asignar rol y área. Es la única vía para crear docentes. | Catálogos reales de la universidad (áreas, categorías, espacios). |
| Gestionar áreas, categorías, prioridades y nombres de estados. | Valores definitivos de SLA y de la política de reservas. |
| Definir políticas de SLA y marcar vencidas o por vencer. | Feriados y días no laborables. |
| Administrar espacios, tipos de espacio, horarios y política de reservas. | Multi-rol por usuario. |
| Aprobar cualquier reserva y ver el dashboard y la auditoría. | Retención definitiva de la auditoría. |
| Aprobar o rechazar con motivo las cuentas auto-registradas y restablecer contraseñas con una temporal. | — |

### 2.6 Sistema e ingeniería (comportamiento automático)

| Se implementará | Pendiente de verificación o decisión |
| --- | --- |
| Código único y estado inicial por solicitud y por reserva. | Verificado en local y en los despliegues. |
| Máquina de estados; bloqueo de transiciones no permitidas. | Verificado con pruebas de integración. |
| Cálculo de SLA, solicitudes vencidas y próximas a vencer. | Implementado; falta definir la regla exacta de vencimiento con producto. |
| Auditoría con campo, valor anterior, valor nuevo y actor; historial visible. | Implementado; retención definitiva pendiente de decisión. |
| Prevención de reservas solapadas incluso con peticiones concurrentes. | Implementado y probado con Testcontainers. |
| Migraciones versionadas y pruebas unitarias e integración. | Implementado; CI en verde. |
| CI/CD, staging, producción y rollback. | Implementado; backups automáticos quedan para Fase IV. |
| Aprobación formal de ADR. | ADR-0004 y ADR-0005 aceptados; ADR-0001 a ADR-0003 siguen propuestos. |

## 3. Fuera de alcance del producto (no se implementará)

- Pagos y facturación.
- Chatbot con IA o LLM dentro del producto (sí se registra el uso de IA en el desarrollo).
- Mensajería externa: correo, SMS o chat.
- API Gateway y microservicios.
- Notificaciones internas y recuperación de contraseña por correo.
- Reservas recurrentes o periódicas.
- Varios roles por usuario.
- Datos personales reales: los datos de demostración son ficticios.
- Persistencia de reportes exportados (se generan al vuelo).

## 4. Pendiente de decisión (producto y administración)

No son funcionalidades faltantes: el mecanismo está diseñado y se implementa igual; lo que falta es el valor o la regla final. La columna **Responsable** es una propuesta tomada de `DISENIO-BD.md` §17.

| Tema | Qué falta decidir | Mientras tanto | Responsable |
| --- | --- | --- | --- |
| Catálogo real de áreas, categorías, espacios, pabellones y horarios. | Confirmar los valores reales de la universidad. | Los seeds traen 4 áreas, 4 categorías y 5 ambientes ficticios. | Producto / administrador |
| Nombres visibles de los estados. | Acordar la redacción final que verá el usuario. | El código es inmutable; el nombre es editable por el administrador (HU-17). | Administrador |
| Valores definitivos de SLA por prioridad y categoría. | Fijar las horas objetivo y de aviso. | Los seeds usan 72/48/24/8 h y 24 h para Soporte informático como ejemplo. | Administrador |
| Límites definitivos de la política de reservas. | Definir duraciones, anticipación y cupo diario. | Los seeds usan 30–240 min, 30 días de anticipación y 2 reservas por día como ejemplo. | Administrador |
| Aprobación de reservas por área frente a aprobación centralizada. | Decidir si aprueba el supervisor del área o solo el administrador. | El diseño adopta «supervisor del área o administrador»; sin área, solo el administrador. | Producto |
| Feriados y días no laborables. | Decidir si se agrega un calendario de feriados. | Hoy solo se valida el horario semanal: se podría reservar un día feriado. | Administrador / backend |
| Política de cierre y reapertura de solicitudes. | Decidir si una solicitud cerrada o rechazada puede reabrirse. | Hoy `CERRADO` y `RECHAZADO` son estados terminales. | Producto |
| Definición exacta del indicador de solicitudes vencidas. | Precisar qué cuenta y con qué filtro de fechas. | Sin esa definición el dashboard no se puede dar por aceptado. | Producto |
| Retención de `auditoria_eventos`. | Definir cuánto se conserva y si se particiona o archiva. | ADR-0003 fija la retención de logs, métricas y trazas, pero deja la auditoría a producto. | Infraestructura / backend |

## 5. Notas de estado

- ADR-0004 (despliegue y persistencia) y ADR-0005 (CI/CD) están aceptados. ADR-0001, ADR-0002 y ADR-0003 siguen propuestos, aunque sus mecanismos están implementados.
- La reserva de ambientes (EP-07) está implementada y probada.
- El entorno local se ejecutó con Docker Compose; staging y producción están desplegados y verificados. Ver [`docs/fase-3/EVIDENCIAS.md`](fase-3/EVIDENCIAS.md).
- Quedan pendientes de Fase IV: backups automáticos, restauración, alertas, retención centralizada de logs y pruebas de carga/DAST.
