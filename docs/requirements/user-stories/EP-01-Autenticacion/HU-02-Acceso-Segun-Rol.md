# HU-02: Acceso diferenciado según rol

## 1. Información general

- **ID:** HU-02
- **Épica:** EP-01 — Autenticación y control de acceso
- **Prioridad:** Alta
- **Actor:** usuario autenticado
- **Alcance de la historia (según RF):** AL-01
- **Alcance de la épica:** AL-01
- **Requisitos funcionales asociados:** RF-02
- **Requisitos no funcionales relacionados (sección 11):** RNF-06
- **Pantalla vinculada (Fase I):** Todas

## 2. Historia de usuario

Como usuario autenticado, quiero visualizar únicamente las opciones de navegación y los datos permitidos para mi rol, para operar sin confusiones y mantener la seguridad de la información.

## 3. Criterios de aceptación

- **CA-01:** El menú de navegación muestra únicamente los módulos autorizados para el rol del usuario autenticado (Estudiante, Técnico, Supervisor o Administrador).
- **CA-02:** Un usuario con rol Estudiante no puede visualizar ni ejecutar acciones de asignación de responsables, cambio de prioridad ni administración de catálogos.

## 4. Escenarios BDD

### Escenario 2.1 – Visualización de opciones según rol (Flujo correcto)

**Dado** que un usuario ha iniciado sesión con el rol «Estudiante»  
**Cuando** el sistema carga la interfaz principal  
**Entonces** el usuario visualiza las opciones para «Registrar solicitud» y «Mis solicitudes»  
**Y** no visualiza las opciones de «Gestión de área», «Dashboard» ni «Administración».  

### Escenario 2.2 – Intento de acceso no autorizado a vista de otro rol

**Dado** que un usuario autenticado con el rol «Estudiante» tiene una sesión activa  
**Cuando** intenta acceder directamente a una ruta o acción exclusiva del rol «Supervisor» o «Administrador»  
**Entonces** el sistema bloquea la operación  
**Y** muestra un mensaje de acceso restringido o redirige a su vista permitida.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
