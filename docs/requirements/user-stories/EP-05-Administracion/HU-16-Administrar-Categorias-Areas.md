# HU-16: Administrar categorías y áreas

## 1. Información general

- **ID:** HU-16
- **Épica:** EP-05 — Administración y configuración
- **Prioridad:** Alta
- **Actor:** administrador
- **Alcance de la historia (según RF):** AL-06
- **Alcance de la épica:** AL-06
- **Requisitos funcionales asociados:** RF-19
- **Pantalla vinculada (Fase I):** — (Fase II–III)

## 2. Historia de usuario

Como administrador, quiero gestionar el catálogo de categorías y áreas responsables asociando cada categoría a un área, para que las solicitudes nuevas se deriven automáticamente al área correcta.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-15 y HU-16 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-16.

- **CA-02:** El administrador puede crear y editar categorías de solicitud asociando obligatoriamente cada categoría a un área responsable.

## 4. Escenarios BDD

### Escenario 16.1 – Intento de crear una categoría sin área responsable asociada (Validación)

**Dado** que el administrador se encuentra en la gestión de categorías  
**Cuando** ingresa el nombre de una nueva categoría pero omite seleccionar el área responsable asociada  
**Entonces** el sistema no guarda la categoría  
**Y** muestra un mensaje de validación indicando que toda categoría debe estar vinculada a un área responsable.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
