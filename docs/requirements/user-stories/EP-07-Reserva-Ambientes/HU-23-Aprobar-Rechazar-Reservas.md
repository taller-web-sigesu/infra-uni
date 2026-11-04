# HU-23: Aprobar o rechazar reservas

## 1. Información general

- **ID:** HU-23
- **Épica:** EP-07 — Reserva de ambientes
- **Prioridad:** Alta
- **Actor:** supervisor / administrador
- **Alcance de la historia (según RF):** AL-08
- **Alcance de la épica:** AL-08
- **Requisitos funcionales asociados:** RF-28
- **Requisitos no funcionales relacionados (sección 11):** RNF-06, RNF-17
- **Pantalla vinculada (Fase I):** 10. Gestión de reservas

## 2. Historia de usuario

Como supervisor del área del espacio o administrador, quiero aprobar o rechazar las reservas pendientes, para controlar el uso de los ambientes y dejar registro de la decisión.

## 3. Criterios de aceptación

- **CA-01:** El supervisor visualiza las reservas pendientes de los espacios de su área; el administrador visualiza todas.
- **CA-02:** Al aprobar, la reserva pasa a `CONFIRMADA`, se registran `aprobada_por_id` y `aprobada_en`, y se inserta el historial.
- **CA-03:** Al rechazar se exige un motivo; la reserva pasa a `RECHAZADA` y se registran el motivo y el historial.
- **CA-04:** Un aprobador no puede aprobar su propia reserva.
- **CA-05:** Al aprobar, el sistema revalida el solapamiento; si apareció un conflicto, no aprueba y lo informa.
- **CA-06:** No se puede aprobar ni rechazar una reserva que ya esté `RECHAZADA` o `CANCELADA`.

## 4. Escenarios BDD

### Escenario 23.1 – Aprobación de una reserva pendiente (Flujo correcto)

**Dado** que el supervisor del área del espacio accede a la bandeja de reservas pendientes  
**Cuando** selecciona una reserva y presiona «Aprobar»  
**Entonces** la reserva cambia a `CONFIRMADA`  
**Y** se registra el aprobador y la fecha de aprobación  
**Y** la reserva aparece en el historial del solicitante.  

### Escenario 23.2 – Rechazo con motivo (Flujo correcto)

**Dado** que el supervisor revisa una reserva pendiente  
**Cuando** ingresa el motivo «Espacio solicitado para mantenimiento» y presiona «Rechazar»  
**Entonces** la reserva cambia a `RECHAZADA`  
**Y** el motivo queda visible para el solicitante.  

### Escenario 23.3 – Rechazo sin motivo (Validación)

**Dado** que el supervisor revisa una reserva pendiente  
**Cuando** presiona «Rechazar» sin ingresar el motivo  
**Entonces** el sistema no cambia el estado  
**Y** muestra un mensaje de validación indicando que el motivo es obligatorio.  

### Escenario 23.4 – Conflicto detectado al aprobar (Validación)

**Dado** que apareció otra reserva confirmada que se solapa con una reserva pendiente  
**Cuando** el supervisor intenta aprobarla  
**Entonces** el sistema no la aprueba  
**Y** muestra un mensaje indicando el conflicto de franja.  

### Escenario 23.5 – Intento de aprobar la propia reserva (Autorización)

**Dado** que un supervisor registró una reserva para un espacio de su área  
**Cuando** intenta aprobarla  
**Entonces** el sistema bloquea la operación  
**Y** muestra un mensaje indicando que no puede aprobar su propia reserva.  

---

**Fuente:** Requisito aprobado por el equipo para la extensión EP-07 (RF-28); criterios y escenarios definidos para esta historia.
