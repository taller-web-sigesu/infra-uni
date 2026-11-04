# HU-22: Registrar reserva de ambiente

## 1. Información general

- **ID:** HU-22
- **Épica:** EP-07 — Reserva de ambientes
- **Prioridad:** Alta
- **Actor:** usuario autenticado
- **Alcance de la historia (según RF):** AL-08
- **Alcance de la épica:** AL-08
- **Requisitos funcionales asociados:** RF-26, RF-27
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-16
- **Pantalla vinculada (Fase I):** 9. Reserva de ambientes

## 2. Historia de usuario

Como usuario autenticado, quiero registrar una reserva indicando espacio, fecha, hora de inicio, hora de fin y motivo, para solicitar el uso de un ambiente universitario en una franja determinada.

## 3. Criterios de aceptación

- **CA-01:** El formulario exige espacio, fecha, hora de inicio, hora de fin y motivo.
- **CA-02:** El sistema valida que la fecha no sea pasada ni exceda la anticipación máxima, que `hora_fin` sea posterior a `hora_inicio`, que la duración esté entre el mínimo y el máximo, que la franja esté dentro del horario del espacio, que no exista solapamiento con reservas activas, que los asistentes no superen la capacidad y que no se exceda el límite de reservas activas por usuario y día.
- **CA-03:** Al guardar, el sistema genera un código único `RES-AAAA-NNNNNN`, asigna el estado `PENDIENTE`, registra al solicitante y la fecha de creación, e inserta el historial inicial.
- **CA-04:** El sistema confirma la operación con el mensaje «Reserva registrada, pendiente de aprobación».
- **CA-05:** Si existe un conflicto o una validación falla, el sistema no guarda la reserva y explica el motivo con un mensaje comprensible.

## 4. Escenarios BDD

### Escenario 22.1 – Registro correcto de una reserva (Flujo correcto)

**Dado** que el usuario está autenticado y consultó la disponibilidad de un espacio  
**Cuando** selecciona una fecha futura, la franja de 10:00 a 12:00, escribe el motivo, indica asistentes dentro de la capacidad y presiona «Registrar reserva»  
**Entonces** el sistema guarda la reserva en estado `PENDIENTE`  
**Y** genera un código único con el formato `RES-AAAA-NNNNNN`  
**Y** muestra el mensaje «Reserva registrada, pendiente de aprobación».  

### Escenario 22.2 – Solapamiento con una reserva existente (Validación)

**Dado** que existe una reserva confirmada para el mismo espacio y fecha de 10:00 a 12:00  
**Cuando** el usuario intenta reservar de 11:00 a 13:00  
**Entonces** el sistema no guarda la reserva  
**Y** muestra un mensaje indicando que la franja ya está ocupada.  

### Escenario 22.3 – Franja fuera del horario del espacio (Validación)

**Dado** que el espacio atiende de 07:00 a 22:00  
**Cuando** el usuario intenta reservar de 21:00 a 23:00  
**Entonces** el sistema no guarda la reserva  
**Y** muestra un mensaje indicando que la franja excede el horario de atención.  

### Escenario 22.4 – Duración fuera de la política (Validación)

**Dado** que la política vigente exige una duración mínima de 30 minutos y máxima de 240 minutos  
**Cuando** el usuario intenta reservar de 10:00 a 10:15  
**Entonces** el sistema no guarda la reserva  
**Y** muestra un mensaje con la duración permitida.  

---

**Fuente:** Requisito aprobado por el equipo para la extensión EP-07 (RF-26, RF-27); criterios y escenarios definidos para esta historia.
