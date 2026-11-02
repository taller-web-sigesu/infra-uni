# HU-07: Filtrar solicitudes del área

## 1. Información general

- **ID:** HU-07
- **Épica:** EP-03 — Gestión del ciclo de vida de solicitudes
- **Prioridad:** Alta
- **Actor:** supervisor
- **Alcance de la historia (según RF):** AL-04
- **Alcance de la épica:** AL-04
- **Requisitos funcionales asociados:** RF-09
- **Pantalla vinculada (Fase I):** 2. Listado / 5. Vista de gestión

## 2. Historia de usuario

Como supervisor, quiero visualizar las solicitudes dirigidas a mi área filtrándolas por estado, categoría y prioridad, para organizar y supervisar la carga de trabajo pendiente.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-07 y HU-08 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-07.

- **CA-01:** El supervisor visualiza únicamente las solicitudes cuya categoría pertenece a su área responsable (S-02, S-03) y puede filtrarlas por estado, categoría y prioridad.

## 4. Escenarios BDD

### Escenario 7.1 – Filtrado de solicitudes del área (Flujo correcto)

**Dado** que el supervisor está autenticado en la vista de gestión de su área  
**Cuando** selecciona el filtro de estado «Nuevo» y la prioridad «Alta»  
**Entonces** el sistema actualiza el listado mostrando únicamente las solicitudes de su área que cumplen ambos criterios.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
