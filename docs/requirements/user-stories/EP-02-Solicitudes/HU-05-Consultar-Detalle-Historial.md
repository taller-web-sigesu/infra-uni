# HU-05: Consultar detalle e historial de solicitud

## 1. Información general

- **ID:** HU-05
- **Épica:** EP-02 — Registro y seguimiento de solicitudes
- **Prioridad:** Alta
- **Actor:** solicitante (estudiante o docente), técnico o supervisor
- **Alcance de la historia (según RF):** AL-03
- **Alcance de la épica:** AL-02, AL-03
- **Requisitos funcionales asociados:** RF-07
- **Pantalla vinculada (Fase I):** 4. Detalle y seguimiento

## 2. Historia de usuario

Como solicitante (estudiante o docente), técnico o supervisor, quiero consultar el detalle completo de una solicitud junto con su responsable asignado y su historial de estados, para conocer la trazabilidad de la atención.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-05 y HU-06 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-05.

- **CA-01:** La vista de detalle muestra todos los datos de la solicitud (código, solicitante, categoría, área, ubicación, descripción, prioridad, fecha, responsable asignado y estado actual).
- **CA-02:** Se muestra el historial cronológico de los estados por los que ha pasado la solicitud.

## 4. Escenarios BDD

### Escenario 5.1 – Visualización del detalle e historial de estados (Flujo correcto)

**Dado** que un usuario autorizado selecciona una solicitud desde el listado  
**Cuando** se abre la pantalla de «Detalle y seguimiento de solicitud»  
**Entonces** el sistema muestra la información completa de la solicitud, el técnico responsable (o «Sin asignar» si está en estado «Nuevo»)  
**Y** despliega la línea de tiempo con el historial de estados y los comentarios registrados.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
