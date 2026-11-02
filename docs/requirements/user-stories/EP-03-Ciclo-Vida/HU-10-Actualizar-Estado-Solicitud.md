# HU-10: Actualizar estado de una solicitud

## 1. Información general

- **ID:** HU-10
- **Épica:** EP-03 — Gestión del ciclo de vida de solicitudes
- **Prioridad:** Alta
- **Actor:** técnico
- **Alcance de la historia (según RF):** AL-04
- **Alcance de la épica:** AL-04
- **Requisitos funcionales asociados:** RF-13, RF-15
- **Pantalla vinculada (Fase I):** 5. Vista de gestión

## 2. Historia de usuario

Como técnico, quiero cambiar el estado de una solicitud asignada a *En proceso* cuando inicio la labor y a *Resuelto* al culminarla, para reflejar el avance real del servicio.

## 3. Criterios de aceptación

> El informe documenta los criterios de HU-09 y HU-10 de forma conjunta. Se muestran aquí los que corresponden directamente a HU-10.

- **CA-02:** El técnico solo puede cambiar el estado de una solicitud en estado Asignado a En proceso, y de En proceso a Resuelto.
- **CA-03:** El sistema bloquea cualquier transición de estado que no respete el flujo del ciclo de vida o que corresponda exclusivamente al supervisor (como Cerrado o Rechazado).

## 4. Escenarios BDD

### Escenario 10.1 – Cambio de estado de Asignado a En proceso y Resuelto (Flujo correcto)

**Dado** que el técnico está autenticado y accede a una solicitud asignada a su nombre con estado «Asignado»  
**Cuando** inicia el trabajo y actualiza el estado a «En proceso», y posteriormente al culminar la labor lo actualiza a «Resuelto»  
**Entonces** el sistema guarda cada transición de estado con su fecha y autor en el historial  
**Y** muestra la solicitud con el estado actual «Resuelto» lista para la revisión del supervisor.  

### Escenario 10.2 – Intento de transición de estado no permitida (Regla de negocio RF-15)

**Dado** que el técnico visualiza una solicitud en estado «Asignado»  
**Cuando** intenta cambiar el estado directamente a «Cerrado» o «Resuelto» sin haber pasado por «En proceso»  
**Entonces** el sistema impide la operación  
**Y** muestra únicamente las transiciones permitidas según el estado actual y su rol.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
