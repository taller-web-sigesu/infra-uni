# HU-27: Registrarse en el sistema

## 1. Información general

- **ID:** HU-27
- **Épica:** EP-01 — Autenticación y control de acceso
- **Prioridad:** Media
- **Actor:** visitante (estudiante sin cuenta)
- **Alcance de la historia (según RF):** AL-01
- **Alcance de la épica:** AL-01
- **Requisitos funcionales asociados:** RF-32
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-05, RNF-07
- **Pantalla vinculada (Fase I):** — (Fase II–III, pantalla nueva de registro)

## 2. Historia de usuario

Como estudiante sin cuenta, quiero registrarme con mi correo institucional, para solicitar acceso a la plataforma sin depender de que el administrador me cree la cuenta.

## 3. Criterios de aceptación

- **CA-01:** El formulario exige nombre completo, correo institucional, contraseña y confirmación de contraseña.
- **CA-02:** El sistema acepta solo correos del dominio institucional `@unmsm.edu.pe` y rechaza correos ya registrados sin revelar a quién pertenecen.
- **CA-03:** La contraseña debe cumplir la política de contraseñas definida en `SECURITY.md` y se guarda con hash seguro.
- **CA-04:** La cuenta se crea con el rol Estudiante, sin área, en estado pendiente de aprobación. El usuario no puede elegir otro rol.
- **CA-05:** El sistema muestra el mensaje «Registro enviado. Podrás ingresar cuando un administrador apruebe tu cuenta». No se envía correo.
- **CA-06:** Mientras la cuenta está pendiente o rechazada, el inicio de sesión no se permite y el sistema informa el estado de la cuenta con un mensaje claro.

## 4. Escenarios BDD

### Escenario 27.1 – Registro correcto (Flujo correcto)

**Dado** que el visitante está en la pantalla «Crear cuenta»  
**Cuando** ingresa su nombre, un correo institucional válido, una contraseña que cumple la política y su confirmación, y presiona «Registrarme»  
**Entonces** el sistema crea la cuenta con el rol Estudiante en estado pendiente de aprobación  
**Y** muestra el mensaje «Registro enviado. Podrás ingresar cuando un administrador apruebe tu cuenta».  

### Escenario 27.2 – Correo fuera del dominio institucional (Validación)

**Dado** que el visitante está en la pantalla «Crear cuenta»  
**Cuando** ingresa un correo `@gmail.com` u otro dominio distinto de `@unmsm.edu.pe`  
**Entonces** el sistema no crea la cuenta  
**Y** indica que se debe usar el correo institucional `@unmsm.edu.pe`.  

### Escenario 27.3 – Intento de ingreso con cuenta pendiente (Validación)

**Dado** que el estudiante se registró y su cuenta sigue pendiente de aprobación  
**Cuando** intenta iniciar sesión con su correo y contraseña  
**Entonces** el sistema no inicia la sesión  
**Y** informa que la cuenta está pendiente de aprobación.  

### Escenario 27.4 – Intento de escalar privilegios (Seguridad)

**Dado** que el visitante envía el formulario de registro modificado para pedir el rol Administrador  
**Cuando** el sistema procesa el registro  
**Entonces** ignora el rol enviado y crea la cuenta solo con el rol Estudiante en estado pendiente.  

---

**Fuente:** [Decisiones 01](../../../decisiones/decisiones-01.md), D2 (propuesta del curso, Módulo 1, «Registro de usuarios»). Criterios y escenarios definidos por el equipo.
