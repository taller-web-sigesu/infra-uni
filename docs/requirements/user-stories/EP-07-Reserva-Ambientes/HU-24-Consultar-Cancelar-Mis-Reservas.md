# HU-24: Consultar y cancelar mis reservas

## 1. Información general

- **ID:** HU-24
- **Épica:** EP-07 — Reserva de ambientes
- **Prioridad:** Alta
- **Actor:** usuario autenticado
- **Alcance de la historia (según RF):** AL-08
- **Alcance de la épica:** AL-08
- **Requisitos funcionales asociados:** RF-29
- **Requisitos no funcionales relacionados (sección 11):** RNF-10, RNF-17
- **Pantalla vinculada (Fase I):** 11. Mis reservas

## 2. Historia de usuario

Como usuario autenticado, quiero consultar y cancelar mis reservas, para hacer seguimiento de mis solicitudes y liberar un ambiente cuando ya no lo necesite.

## 3. Criterios de aceptación

- **CA-01:** El sistema lista las reservas propias con código, espacio, fecha, horario y estado.
- **CA-02:** El listado permite filtrar por estado y rango de fechas, y se presenta paginado.
- **CA-03:** El detalle muestra el historial de estados y, si aplica, el motivo de rechazo.
- **CA-04:** El usuario puede cancelar una reserva solo si está `PENDIENTE` o `CONFIRMADA` y antes de `fecha + hora_inicio`; se registran `cancelada_por_id`, `cancelada_en` e historial.
- **CA-05:** Un usuario no puede ver ni cancelar reservas de otro usuario; el sistema responde con acceso denegado o recurso no encontrado.

## 4. Escenarios BDD

### Escenario 24.1 – Cancelación de una reserva confirmada futura (Flujo correcto)

**Dado** que el usuario tiene una reserva `CONFIRMADA` cuya fecha y hora de inicio aún no llegan  
**Cuando** presiona «Cancelar reserva» y confirma la acción  
**Entonces** la reserva cambia a `CANCELADA`  
**Y** se registra el usuario y la fecha de cancelación  
**Y** la franja vuelve a estar disponible para otros usuarios.  

### Escenario 24.2 – Intento de cancelar una reserva ya iniciada (Validación)

**Dado** que el usuario tiene una reserva confirmada cuya hora de inicio ya pasó  
**Cuando** intenta cancelarla  
**Entonces** el sistema bloquea la operación  
**Y** muestra un mensaje indicando que solo se puede cancelar antes del inicio.  

### Escenario 24.3 – Acceso a una reserva ajena (Autorización)

**Dado** que el usuario está autenticado  
**Cuando** intenta abrir o cancelar una reserva de otro usuario por su identificador  
**Entonces** el sistema deniega el acceso  
**Y** no muestra los datos de la reserva.  

---

**Fuente:** Requisito aprobado por el equipo para la extensión EP-07 (RF-29); criterios y escenarios definidos para esta historia.
