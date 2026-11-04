# HU-21: Consultar espacios y disponibilidad

## 1. Información general

- **ID:** HU-21
- **Épica:** EP-07 — Reserva de ambientes
- **Prioridad:** Alta
- **Actor:** usuario autenticado
- **Alcance de la historia (según RF):** AL-08
- **Alcance de la épica:** AL-08
- **Requisitos funcionales asociados:** RF-25
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-09, RNF-18
- **Pantalla vinculada (Fase I):** 9. Reserva de ambientes

## 2. Historia de usuario

Como usuario autenticado, quiero consultar los espacios reservables y su disponibilidad por fecha y hora, para elegir un ambiente libre antes de solicitar la reserva.

## 3. Criterios de aceptación

- **CA-01:** El sistema muestra los espacios activos con nombre, tipo, pabellón, capacidad y horario de atención del día consultado.
- **CA-02:** El usuario puede filtrar por tipo de espacio, pabellón, capacidad mínima y fecha.
- **CA-03:** Al seleccionar un espacio y una fecha, el sistema muestra las franjas libres y ocupadas; solo cuentan como ocupadas las reservas en estado `PENDIENTE` o `CONFIRMADA`.
- **CA-04:** Si no hay espacios o no hay disponibilidad para la fecha, el sistema muestra un estado vacío claro con la opción de limpiar los filtros.

## 4. Escenarios BDD

### Escenario 21.1 – Consulta de disponibilidad con franjas libres (Flujo correcto)

**Dado** que el usuario está autenticado y se encuentra en la pantalla de reserva de ambientes  
**Cuando** selecciona el espacio «Laboratorio 204» y la fecha «2026-11-10»  
**Entonces** el sistema muestra el horario de atención de ese día  
**Y** marca como ocupadas únicamente las franjas con reservas en estado `PENDIENTE` o `CONFIRMADA`  
**Y** muestra el resto de franjas como disponibles.  

### Escenario 21.2 – Día sin franjas libres (Estado vacío)

**Dado** que el usuario consulta un espacio cuya fecha seleccionada tiene todas sus franjas ocupadas  
**Cuando** el sistema carga la disponibilidad  
**Entonces** no permite seleccionar ninguna franja  
**Y** muestra el mensaje «No hay disponibilidad para la fecha seleccionada».  

### Escenario 21.3 – Filtros sin resultados (Estado vacío)

**Dado** que el usuario se encuentra en el catálogo de espacios  
**Cuando** aplica el filtro tipo «Auditorio» y pabellón «B» y no existe coincidencia  
**Entonces** el sistema muestra un estado vacío  
**Y** ofrece la opción de limpiar los filtros.  

---

**Fuente:** Requisito aprobado por el equipo para la extensión EP-07 (RF-25); criterios y escenarios definidos para esta historia.
