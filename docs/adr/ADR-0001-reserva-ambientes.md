# ADR-0001: Incorporar la reserva de ambientes

- **Estado:** Propuesto
- **Fecha:** 2026-11-04
- **Decisores:** Equipo del proyecto Gestal
- **Historias afectadas:** HU-21, HU-22, HU-23, HU-24, HU-25
- **Requisitos afectados:** RF-25, RF-26, RF-27, RF-28, RF-29, RF-30, RNF-16, RNF-17, RNF-18
- **Documento de datos:** [DISENIO-BD.md](../../DISENIO-BD.md)

## Contexto

`docs/ARCHITECTURE.md` declaraba la reserva de ambientes como una posible extensión, fuera del alcance inicial. El equipo decidió incorporarla al producto como la épica **EP-07**, sin reutilizar las solicitudes de servicio (`solicitudes`) porque su ciclo de vida, sus actores y sus datos son distintos.

El sistema ya cuenta con autenticación y autorización por roles como objetivo (EP-01, HU-01/HU-02), catálogos administrables (EP-05) y un patrón de historial más auditoría (EP-06). La reserva debe apoyarse en esas piezas, no duplicarlas.

## Decisión

1. **Módulo separado.** La reserva vive en su propio conjunto de tablas y su propio módulo lógico; no se modela como una categoría de `solicitudes`.
2. **Aprobación obligatoria.** Toda reserva nace en estado `PENDIENTE`. El supervisor del área del espacio o el administrador la pasa a `CONFIRMADA` o la rechaza con motivo (`RECHAZADA`). El solicitante puede cancelarla antes de la hora de inicio (`CANCELADA`).
3. **Franja por fecha y horas.** La reserva ocupa `fecha` + `hora_inicio` + `hora_fin`, con validación de solapamiento, duración, anticipación, horario del espacio y capacidad.
4. **Cualquier usuario autenticado puede reservar.** Cada usuario ve y cancela sus reservas; las bandejas de aprobación se limitan al área del espacio o al administrador.
5. **Control de concurrencia en servidor.** La validación de solapamiento se ejecuta en una transacción con bloqueo de la fila del espacio (`SELECT … FOR UPDATE`) y se refuerza con el índice único `uk_reservas_franja_exacta (espacio_id, fecha, hora_inicio, estado_id)`.
6. **Historial y auditoría.** Cada transición deja una fila en `historial_estados_reserva` y en `auditoria_eventos`.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
| --- | --- |
| Reutilizar `solicitudes` con una categoría «Reserva» | Mezcla dos ciclos de vida, dos modelos de aprobación y dos formas de asignación; complica reportes y permisos. |
| Reserva por día completo | No permite compartir un ambiente en varias franjas del mismo día. |
| Franjas fijas de una hora | Menos flexible y obliga a definir una malla horaria rígida. |
| Confirmación automática sin aprobación | El equipo decidió controlar el uso de los ambientes; la aprobación deja responsable y motivo. |
| Validar solapamiento solo en la aplicación, sin bloqueo | Dos solicitudes concurrentes podrían superponerse. |

## Consecuencias

- **Base de datos:** 8 tablas nuevas (`tipos_espacio`, `espacios`, `horarios_espacio`, `estados_reserva`, `politicas_reserva`, `reservas`, `historial_estados_reserva`, `secuencias_codigo_reserva`) y 2 vistas (`vw_reservas_detalle`, `vw_reservas_operativas`). El diseño completo está en `DISENIO-BD.md`.
- **Requisitos:** se añaden RF-25 a RF-30, RNF-16 a RNF-18 y las HU-21 a HU-25; `EPICS.md` incorpora EP-07.
- **Backend:** requiere un módulo `reservations` y migraciones Flyway. Depende de que exista el módulo de autenticación y RBAC, todavía no implementado.
- **Frontend:** requiere `features/reservations` (catálogo, disponibilidad, formulario, «mis reservas» y administración de espacios).
- **Infraestructura:** no cambia `compose.yaml`; el esquema se aplicará mediante migraciones del backend.
- **Riesgos:** doble reserva si se omite el bloqueo; horarios y feriados reales pendientes de validación con el negocio; la aprobación por área debe coordinarse con la matriz de permisos de `docs/SECURITY.md` cuando exista.
