# HU-29: Restablecer la contraseña de un usuario

## 1. Información general

- **ID:** HU-29
- **Épica:** EP-05 — Administración y configuración
- **Prioridad:** Media
- **Actor:** administrador
- **Alcance de la historia (según RF):** AL-06
- **Alcance de la épica:** AL-06
- **Requisitos funcionales asociados:** RF-34
- **Requisitos no funcionales relacionados (sección 11):** RNF-05, RNF-06
- **Pantalla vinculada (Fase I):** — (Fase II–III, dentro de «Administración de usuarios»)

## 2. Historia de usuario

Como administrador, quiero restablecer la contraseña de un usuario que la olvidó, para que pueda volver a ingresar sin que el sistema dependa del envío de correos.

## 3. Criterios de aceptación

- **CA-01:** El administrador puede restablecer la contraseña de cualquier usuario activo desde «Administración de usuarios».
- **CA-02:** El sistema genera una contraseña temporal aleatoria que cumple la política, la muestra una sola vez al administrador y guarda solo su hash.
- **CA-03:** Al restablecer, el sistema revoca todas las sesiones activas del usuario y lo obliga a cambiar la contraseña en su próximo ingreso.
- **CA-04:** El restablecimiento queda registrado en la auditoría con el administrador y la fecha, sin guardar la contraseña temporal.
- **CA-05:** Cualquier usuario autenticado puede cambiar su propia contraseña desde su perfil indicando la contraseña actual y la nueva.

## 4. Escenarios BDD

### Escenario 29.1 – Restablecer la contraseña (Flujo correcto)

**Dado** que un estudiante activo olvidó su contraseña y lo informó a soporte  
**Cuando** el administrador elige «Restablecer contraseña» en su cuenta y confirma  
**Entonces** el sistema muestra una contraseña temporal una sola vez  
**Y** revoca las sesiones activas del estudiante  
**Y** le exige cambiar la contraseña en su próximo ingreso.  

### Escenario 29.2 – Primer ingreso con contraseña temporal (Flujo correcto)

**Dado** que el administrador restableció la contraseña del estudiante  
**Cuando** el estudiante inicia sesión con la contraseña temporal  
**Entonces** el sistema lo lleva a la pantalla de cambio obligatorio de contraseña  
**Y** no le permite usar otras opciones hasta cambiarla.  

### Escenario 29.3 – Cambio de contraseña desde el perfil con contraseña actual incorrecta (Validación)

**Dado** que el usuario ha iniciado sesión y está en su perfil  
**Cuando** intenta cambiar la contraseña escribiendo mal la contraseña actual  
**Entonces** el sistema no cambia la contraseña  
**Y** indica que la contraseña actual no es correcta.  

### Escenario 29.4 – Acceso sin permiso (Seguridad)

**Dado** que un técnico ha iniciado sesión  
**Cuando** intenta restablecer la contraseña de otro usuario  
**Entonces** el sistema rechaza la operación.  

---

**Fuente:** [Decisiones 01](../../../decisiones/decisiones-01.md), D3 (propuesta del curso, Módulo 1, «Recuperación o cambio de contraseña»). Criterios y escenarios definidos por el equipo.
