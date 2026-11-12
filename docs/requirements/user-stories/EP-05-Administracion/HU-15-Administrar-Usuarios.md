# HU-15: Administrar usuarios

## 1. Información general

- **ID:** HU-15
- **Épica:** EP-05 — Administración y configuración
- **Prioridad:** Alta
- **Actor:** administrador
- **Alcance de la historia (según RF):** AL-06
- **Alcance de la épica:** AL-06
- **Requisitos funcionales asociados:** RF-18
- **Pantalla vinculada (Fase I):** — (Fase II–III)

## 2. Historia de usuario

Como administrador, quiero crear, consultar, editar y desactivar usuarios asignándoles un rol y un área responsable, para controlar quiénes acceden y operan en el sistema.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-15 y HU-16 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-15.

- **CA-01:** El administrador puede registrar nuevos usuarios indicando nombre, correo, contraseña inicial, rol y área (cuando el rol sea Técnico o Supervisor), así como editarlos o desactivarlos.
- **CA-02:** El administrador es el único que puede crear cuentas con el rol Docente; estas cuentas no requieren área y tienen los mismos permisos que el rol Estudiante ([decisiones 02](../../../decisiones/decisiones-02.md)).

## 4. Escenarios BDD

### Escenario 15.1 – Creación de un usuario técnico asignado a un área (Flujo correcto)

**Dado** que el administrador se encuentra en el módulo de «Administración de usuarios»  
**Cuando** completa el formulario con nombre, correo institucional válido, contraseña, selecciona el rol «Técnico» y el área «Soporte informático», y guarda el registro  
**Entonces** el sistema crea el usuario en estado activo  
**Y** el técnico queda habilitado para recibir asignaciones de solicitudes de dicha área.  

### Escenario 15.2 – Creación de un usuario docente (Flujo correcto)

**Dado** que el administrador se encuentra en el módulo de «Administración de usuarios»  
**Cuando** completa el formulario con nombre, correo institucional válido y contraseña inicial, selecciona el rol «Docente» sin área y guarda el registro  
**Entonces** el sistema crea el usuario en estado activo con el rol Docente  
**Y** el docente debe cambiar la contraseña inicial en su primer ingreso.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
