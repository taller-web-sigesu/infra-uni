# HU-01: Iniciar y cerrar sesión

## 1. Información general

- **ID:** HU-01
- **Épica:** EP-01 — Autenticación y control de acceso
- **Prioridad:** Alta
- **Actor:** usuario registrado
- **Alcance de la historia (según RF):** AL-01
- **Alcance de la épica:** AL-01
- **Requisitos funcionales asociados:** RF-01
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-06
- **Pantalla vinculada (Fase I):** 1. Inicio de sesión

## 2. Historia de usuario

Como usuario registrado, quiero iniciar y cerrar sesión con mi correo institucional y contraseña, para acceder de forma segura a la plataforma.

## 3. Criterios de aceptación

- **CA-01:** El formulario de inicio de sesión solicita obligatoriamente el correo electrónico y la contraseña.
- **CA-02:** Si las credenciales son válidas y el usuario está activo, el sistema inicia la sesión y redirige a la vista principal correspondiente a su rol.
- **CA-03:** Si algún campo está vacío o las credenciales son incorrectas, el sistema impide el acceso y muestra un mensaje claro sin exponer detalles técnicos.
- **CA-04:** Al cerrar sesión, el sistema invalida la sesión activa y redirige a la pantalla de inicio de sesión.

## 4. Escenarios BDD

### Escenario 1.1 – Inicio de sesión exitoso (Flujo correcto)

**Dado** que el usuario se encuentra en la pantalla de inicio de sesión y posee una cuenta activa  
**Cuando** ingresa su correo institucional y su contraseña válidos y presiona el botón «Iniciar sesión»  
**Entonces** el sistema autentica al usuario  
**Y** lo redirige a la pantalla principal correspondiente a su rol.  

### Escenario 1.2 – Intento de inicio de sesión con campos vacíos (Validación de datos incompletos)

**Dado** que el usuario se encuentra en la pantalla de inicio de sesión  
**Cuando** intenta enviar el formulario omitiendo el correo electrónico o la contraseña  
**Entonces** el sistema no envía la petición de autenticación  
**Y** muestra un mensaje de validación junto al campo faltante indicando que es obligatorio.  

### Escenario 1.3 – Credenciales inválidas

**Dado** que el usuario se encuentra en la pantalla de inicio de sesión  
**Cuando** ingresa un correo o una contraseña que no coinciden con un usuario activo  
**Entonces** el sistema rechaza el acceso  
**Y** muestra el mensaje «Correo o contraseña incorrectos».  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
