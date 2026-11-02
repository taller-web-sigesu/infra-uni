# HU-06: Añadir comentarios a una solicitud

## 1. Información general

- **ID:** HU-06
- **Épica:** EP-02 — Registro y seguimiento de solicitudes
- **Prioridad:** Alta
- **Actor:** estudiante, técnico o supervisor
- **Alcance de la historia (según RF):** AL-03
- **Alcance de la épica:** AL-02, AL-03
- **Requisitos funcionales asociados:** RF-08
- **Pantalla vinculada (Fase I):** 4. Detalle y seguimiento

## 2. Historia de usuario

Como estudiante, técnico o supervisor, quiero añadir comentarios en una solicitud dejando constancia de mi usuario y la fecha, para comunicar avances, consultas o precisiones durante la atención.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-05 y HU-06 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-06.

- **CA-03:** El estudiante, el técnico asignado y el supervisor del área pueden añadir comentarios de seguimiento, registrándose automáticamente el autor y la fecha.
- **CA-04:** No se permite publicar un comentario en blanco.

## 4. Escenarios BDD

### Escenario 6.1 – Registro exitoso de un comentario (Flujo correcto)

**Dado** que el usuario autorizado se encuentra en el detalle de una solicitud activa  
**Cuando** escribe un texto en el campo de nuevo comentario y presiona «Publicar comentario»  
**Entonces** el sistema añade el comentario a la lista de seguimiento  
**Y** muestra el nombre del autor, su rol y la fecha y hora del registro.  

### Escenario 6.2 – Intento de publicar un comentario vacío (Validación)

**Dado** que el usuario se encuentra en el detalle de una solicitud  
**Cuando** presiona «Publicar comentario» dejando el campo de texto vacío o solo con espacios en blanco  
**Entonces** el sistema no registra el comentario  
**Y** muestra un mensaje de validación indicando que debe escribir un contenido antes de enviar.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
