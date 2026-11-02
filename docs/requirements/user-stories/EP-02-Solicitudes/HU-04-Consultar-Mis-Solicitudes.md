# HU-04: Consultar mis solicitudes

## 1. Información general

- **ID:** HU-04
- **Épica:** EP-02 — Registro y seguimiento de solicitudes
- **Prioridad:** Alta
- **Actor:** estudiante
- **Alcance de la historia (según RF):** AL-03
- **Alcance de la épica:** AL-02, AL-03
- **Requisitos funcionales asociados:** RF-06
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-10
- **Pantalla vinculada (Fase I):** 2. Listado de solicitudes

## 2. Historia de usuario

Como estudiante, quiero consultar el listado de mis solicitudes registradas viendo su código, categoría, estado, prioridad y fecha, para conocer rápidamente el estado general de mis trámites.

## 3. Criterios de aceptación

- **CA-01:** El listado muestra únicamente las solicitudes creadas por el estudiante autenticado.
- **CA-02:** Por cada solicitud se visualiza: código, categoría, estado actual, prioridad y fecha de registro.
- **CA-03:** Si el estudiante aún no ha registrado ninguna solicitud, se muestra un mensaje de estado vacío con un acceso directo para crear su primera solicitud.

## 4. Escenarios BDD

### Escenario 4.1 – Consulta del listado con solicitudes existentes (Flujo correcto)

**Dado** que el estudiante está autenticado y tiene solicitudes previamente registradas  
**Cuando** accede a la sección «Mis solicitudes»  
**Entonces** el sistema muestra el listado de sus solicitudes incluyendo código, categoría, estado, prioridad y fecha  
**Y** permite seleccionar cualquiera de ellas para ver su detalle.  

### Escenario 4.2 – Consulta del listado sin solicitudes registradas (Estado vacío)

**Dado** que el estudiante está autenticado y no ha registrado ninguna solicitud anteriormente  
**Cuando** accede a la sección «Mis solicitudes»  
**Entonces** el sistema muestra un estado vacío indicando «Aún no tienes solicitudes registradas»  
**Y** presenta un botón visible para «Registrar nueva solicitud».  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
