# HU-28: Aprobar o rechazar cuentas registradas

## 1. Información general

- **ID:** HU-28
- **Épica:** EP-05 — Administración y configuración
- **Prioridad:** Media
- **Actor:** administrador
- **Alcance de la historia (según RF):** AL-06
- **Alcance de la épica:** AL-06
- **Requisitos funcionales asociados:** RF-33
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-06
- **Pantalla vinculada (Fase I):** — (Fase II–III, dentro de «Administración de usuarios»)

## 2. Historia de usuario

Como administrador, quiero revisar las cuentas creadas por auto-registro y aprobarlas o rechazarlas, para que solo accedan al sistema estudiantes legítimos.

## 3. Criterios de aceptación

- **CA-01:** El administrador ve una bandeja de cuentas pendientes con nombre, correo y fecha de registro, ordenada de la más antigua a la más reciente.
- **CA-02:** Al aprobar, la cuenta pasa a activa con el rol Estudiante y el usuario puede iniciar sesión.
- **CA-03:** Al rechazar, el motivo es obligatorio; la cuenta pasa a rechazada y el usuario no puede iniciar sesión.
- **CA-04:** El sistema registra quién aprobó o rechazó la cuenta, cuándo y el motivo, también en la auditoría.
- **CA-05:** Solo el administrador puede ver la bandeja y decidir sobre las cuentas.

## 4. Escenarios BDD

### Escenario 28.1 – Aprobar una cuenta pendiente (Flujo correcto)

**Dado** que existe una cuenta pendiente registrada por un estudiante  
**Cuando** el administrador la aprueba desde la bandeja de cuentas pendientes  
**Entonces** la cuenta pasa a activa  
**Y** el estudiante puede iniciar sesión con el correo y la contraseña que registró.  

### Escenario 28.2 – Rechazar una cuenta sin motivo (Validación)

**Dado** que existe una cuenta pendiente  
**Cuando** el administrador intenta rechazarla sin escribir el motivo  
**Entonces** el sistema no rechaza la cuenta  
**Y** indica que el motivo es obligatorio.  

### Escenario 28.3 – Rechazar una cuenta con motivo (Flujo correcto)

**Dado** que existe una cuenta pendiente con un correo que no corresponde a un estudiante  
**Cuando** el administrador la rechaza indicando el motivo  
**Entonces** la cuenta pasa a rechazada  
**Y** el usuario recibe un mensaje de cuenta rechazada si intenta iniciar sesión.  

### Escenario 28.4 – Acceso sin permiso (Seguridad)

**Dado** que un supervisor ha iniciado sesión  
**Cuando** intenta abrir la bandeja de cuentas pendientes  
**Entonces** el sistema rechaza el acceso.  

---

**Fuente:** [Decisiones 01](../../../decisiones/decisiones-01.md), D2. Criterios y escenarios definidos por el equipo.
