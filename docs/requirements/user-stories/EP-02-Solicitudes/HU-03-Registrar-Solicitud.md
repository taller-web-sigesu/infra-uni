# HU-03: Registrar solicitud de servicio

## 1. Información general

- **ID:** HU-03
- **Épica:** EP-02 — Registro y seguimiento de solicitudes
- **Prioridad:** Alta
- **Actor:** solicitante (estudiante o docente)
- **Alcance de la historia (según RF):** AL-02
- **Alcance de la épica:** AL-02, AL-03
- **Requisitos funcionales asociados:** RF-03, RF-04, RF-05
- **Requisitos no funcionales relacionados (sección 11):** RNF-02, RNF-03
- **Pantalla vinculada (Fase I):** 3. Formulario de registro

## 2. Historia de usuario

Como estudiante o docente, quiero registrar una solicitud de servicio indicando su categoría, descripción y ubicación, para reportar un problema o requerimiento en la universidad y que sea atendido.

## 3. Criterios de aceptación

- **CA-01:** El formulario exige completar tres datos obligatorios: categoría, ubicación y descripción del problema o requerimiento.
- **CA-02:** El registro se completa en un máximo de 3 pasos desde el inicio de sesión.
- **CA-03:** Al registrar la solicitud, el sistema asigna automáticamente un código único, la fecha y hora de registro, los datos del solicitante, la prioridad inicial por defecto según la categoría (S-04) y el estado inicial Nuevo.
- **CA-04:** Si se omite cualquiera de los campos obligatorios, el sistema impide el registro y resalta los campos pendientes con mensajes de validación claros.

## 4. Escenarios BDD

### Escenario 3.1 – Registro correcto de una solicitud (Flujo correcto)

**Dado** que el estudiante está autenticado y se encuentra en el formulario de registro de solicitud  
**Cuando** selecciona una categoría válida (por ejemplo, «Soporte informático»), ingresa la ubicación («Laboratorio 204 - Pabellón nuevo») y redacta la descripción del problema, y presiona «Registrar solicitud»  
**Entonces** el sistema guarda la solicitud  
**Y** genera automáticamente un código único de seguimiento y la fecha de registro  
**Y** asigna la prioridad inicial asociada a la categoría y el estado «Nuevo»  
**Y** muestra un mensaje de confirmación con el código generado.  

### Escenario 3.2 – Registro con datos obligatorios incompletos (Validación de formulario)

**Dado** que el estudiante se encuentra en el formulario de registro de solicitud  
**Cuando** intenta enviar el formulario dejando vacía la categoría, la ubicación o la descripción  
**Entonces** el sistema no registra la solicitud  
**Y** muestra un mensaje de validación junto a cada campo omitido indicando la información requerida.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
