# HU-08: Asignar o reasignar técnico y ajustar prioridad

## 1. Información general

- **ID:** HU-08
- **Épica:** EP-03 — Gestión del ciclo de vida de solicitudes
- **Prioridad:** Alta
- **Actor:** supervisor
- **Alcance de la historia (según RF):** AL-04
- **Alcance de la épica:** AL-04
- **Requisitos funcionales asociados:** RF-10, RF-11, RF-15
- **Pantalla vinculada (Fase I):** 5. Vista de gestión

## 2. Historia de usuario

Como supervisor, quiero asignar o reasignar una solicitud a un técnico de mi área y ajustar su nivel de prioridad, para asegurar que cada requerimiento tenga un responsable adecuado según su urgencia.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-07 y HU-08 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-08.

- **CA-02:** Al asignar un técnico del área a una solicitud en estado Nuevo, el estado cambia automáticamente a Asignado.
- **CA-03:** El supervisor puede reasignar la solicitud a otro técnico de su área o modificar su nivel de prioridad en cualquier momento mientras la solicitud no esté Cerrado ni Rechazado.

## 4. Escenarios BDD

### Escenario 8.1 – Asignación de técnico responsable y ajuste de prioridad (Flujo correcto)

**Dado** que el supervisor visualiza una solicitud en estado «Nuevo» dentro de la vista de gestión  
**Cuando** selecciona a un técnico perteneciente a su área, ajusta la prioridad a «Alta» y guarda los cambios  
**Entonces** el sistema registra al técnico como responsable de la solicitud y actualiza la prioridad  
**Y** cambia automáticamente el estado de la solicitud a «Asignado»  
**Y** añade el cambio al historial de estados.  

### Escenario 8.2 – Intento de asignar sin seleccionar un técnico (Validación)

**Dado** que el supervisor se encuentra en la vista de gestión de una solicitud en estado «Nuevo»  
**Cuando** presiona la acción «Asignar responsable» sin haber elegido un técnico del selector  
**Entonces** el sistema muestra un mensaje de validación solicitando seleccionar un técnico válido  
**Y** mantiene la solicitud en estado «Nuevo».  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
