# HU-11: Cerrar o rechazar una solicitud

## 1. Información general

- **ID:** HU-11
- **Épica:** EP-03 — Gestión del ciclo de vida de solicitudes
- **Prioridad:** Alta
- **Actor:** supervisor
- **Alcance de la historia (según RF):** AL-04
- **Alcance de la épica:** AL-04
- **Requisitos funcionales asociados:** RF-14, RF-15
- **Pantalla vinculada (Fase I):** 5. Vista de gestión

## 2. Historia de usuario

Como supervisor, quiero cambiar a *Cerrado* una solicitud resuelta tras verificar su conformidad, o a *Rechazado* registrando el motivo correspondiente, para concluir formalmente el ciclo de vida de la solicitud.

## 3. Criterios de aceptación

- **CA-01:** El supervisor puede cambiar una solicitud en estado Resuelto al estado final Cerrado.
- **CA-02:** El supervisor puede cambiar una solicitud al estado Rechazado únicamente si ingresa el motivo del rechazo.
- **CA-03:** Una vez en estado Cerrado o Rechazado, la solicitud no admite nuevos cambios de estado ni reasignaciones.

## 4. Escenarios BDD

### Escenario 11.1 – Cierre de una solicitud resuelta (Flujo correcto)

**Dado** que el supervisor revisa una solicitud de su área que se encuentra en estado «Resuelto»  
**Cuando** selecciona la acción «Cerrar solicitud» y confirma la operación  
**Entonces** el sistema actualiza el estado de la solicitud a «Cerrado»  
**Y** registra el cierre en el historial de estados bloqueando futuras ediciones.  

### Escenario 11.2 – Rechazo de una solicitud indicando el motivo (Flujo correcto)

**Dado** que el supervisor evalúa una solicitud improcedente o duplicada en su área  
**Cuando** selecciona la acción «Rechazar solicitud», escribe el motivo del rechazo y confirma  
**Entonces** el sistema actualiza el estado a «Rechazado»  
**Y** registra el motivo como parte del historial y detalle visible para el solicitante.  

### Escenario 11.3 – Intento de rechazar una solicitud sin indicar motivo (Validación)

**Dado** que el supervisor selecciona la opción «Rechazar solicitud»  
**Cuando** intenta confirmar el rechazo dejando el campo de motivo vacío  
**Entonces** el sistema impide el cambio de estado  
**Y** muestra un mensaje de validación indicando que el motivo de rechazo es obligatorio.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
