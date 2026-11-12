# HU-26: Adjuntar evidencias a una solicitud

## 1. Información general

- **ID:** HU-26
- **Épica:** EP-02 — Registro y seguimiento de solicitudes
- **Prioridad:** Media
- **Actor:** estudiante (solicitante); técnico asignado y supervisor del área
- **Alcance de la historia (según RF):** AL-02
- **Alcance de la épica:** AL-02, AL-03
- **Requisitos funcionales asociados:** RF-31
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-07, RNF-19
- **Pantalla vinculada (Fase I):** 3. Formulario de registro y 5. Detalle de solicitud

## 2. Historia de usuario

Como solicitante, quiero adjuntar fotos o documentos como evidencia a mi solicitud, para que el área responsable entienda mejor el problema y pueda atenderlo.

## 3. Criterios de aceptación

- **CA-01:** El solicitante puede adjuntar evidencias al registrar la solicitud y después, desde el detalle, mientras la solicitud no esté en estado Cerrado o Rechazado. El técnico asignado y el supervisor del área también pueden adjuntar evidencias de la atención en esos mismos estados.
- **CA-02:** Solo se aceptan archivos JPG, PNG o PDF, de hasta 5 MB cada uno y un máximo de 5 evidencias activas por solicitud. El sistema valida el tipo por el contenido del archivo, no solo por la extensión.
- **CA-03:** Las evidencias se muestran en el detalle de la solicitud con nombre, tamaño, autor y fecha. Solo las puede ver o descargar quien tiene permiso para ver la solicitud.
- **CA-04:** El autor de una evidencia puede eliminarla mientras la solicitud no esté en estado Cerrado o Rechazado. La eliminación queda registrada en la auditoría.
- **CA-05:** Si el archivo no cumple las reglas, el sistema no lo guarda y explica el motivo con un mensaje comprensible.

## 4. Escenarios BDD

### Escenario 26.1 – Adjuntar una foto al registrar la solicitud (Flujo correcto)

**Dado** que el estudiante está completando el formulario de registro de solicitud  
**Cuando** adjunta una foto JPG de 2 MB y presiona «Registrar solicitud»  
**Entonces** el sistema registra la solicitud con la evidencia asociada  
**Y** la evidencia aparece en el detalle con su nombre, tamaño, autor y fecha.  

### Escenario 26.2 – Archivo con formato no permitido (Validación)

**Dado** que el estudiante está en el detalle de su solicitud en estado Nuevo  
**Cuando** intenta adjuntar un archivo `.exe`  
**Entonces** el sistema no guarda el archivo  
**Y** muestra un mensaje indicando que solo se aceptan JPG, PNG o PDF.  

### Escenario 26.3 – Archivo demasiado grande (Validación)

**Dado** que el estudiante está en el detalle de su solicitud en estado Nuevo  
**Cuando** intenta adjuntar un PDF de 8 MB  
**Entonces** el sistema no guarda el archivo  
**Y** muestra un mensaje indicando que el tamaño máximo es 5 MB.  

### Escenario 26.4 – Acceso indebido a una evidencia (Seguridad)

**Dado** que una evidencia pertenece a la solicitud de otro estudiante  
**Cuando** un estudiante intenta descargarla  
**Entonces** el sistema rechaza el acceso  
**Y** no revela si la evidencia existe.  

### Escenario 26.5 – Eliminar una evidencia propia (Flujo correcto)

**Dado** que el estudiante adjuntó una evidencia a su solicitud en estado Asignado  
**Cuando** elige «Eliminar» y confirma  
**Entonces** la evidencia deja de mostrarse en el detalle  
**Y** la auditoría registra quién la eliminó y cuándo.  

---

**Fuente:** [Decisiones 01](../../../decisiones/decisiones-01.md), D1 (propuesta del curso, Módulo 2, campo «Evidencias»). Criterios y escenarios definidos por el equipo.
