# Decisiones de Fase IV — Gestal / UniService

**Propuesta de P2 · En revisión**

## 1. Solicitudes duplicadas

Se propone mantener el registro de solicitudes y dejar que el supervisor del área revise los posibles duplicados. Si confirma que una solicitud está duplicada, puede rechazarla indicando el motivo, como establece [HU-11](../requirements/user-stories/EP-03-Ciclo-Vida/HU-11-Cerrar-Rechazar-Solicitud.md). Así se conserva el reporte y queda constancia del motivo del rechazo.

**Verificación.** Un usuario puede registrar un reporte sobre un incidente ya comunicado. El supervisor del área puede rechazar el reporte duplicado con un motivo. La detección, el bloqueo y la vinculación automáticos quedan como evolución.

## 2. Sesión única por cuenta

Se propone aceptar un nuevo inicio de sesión válido y revocar las sesiones anteriores de la cuenta en la misma transacción que emite la nueva. La cuenta se bloquea durante la operación para que dos inicios concurrentes dejen a lo sumo una sesión vigente. La política amplía [HU-01](../requirements/user-stories/EP-01-Autenticacion/HU-01-Iniciar-Cerrar-Sesion.md) y reutiliza la revocación del [ADR de autenticación](../adr/ADR-0002-autenticacion-sesion.md).

**Verificación.** Tras dos inicios válidos, solo los tokens de la sesión más reciente permiten el acceso y la renovación. Un intento con credenciales inválidas conserva la sesión vigente. Una prueba concurrente confirma que queda una sola sesión activa.

## 3. Asignación de solicitudes por rol

Se propone mantener la asignación y reasignación a cargo del supervisor, sobre solicitudes y técnicos de su propia área, conforme a [HU-08](../requirements/user-stories/EP-03-Ciclo-Vida/HU-08-Asignar-Reasignar-Tecnico-Prioridad.md). El administrador conserva sus funciones de gestión de cuentas y catálogos. Esta decisión conserva la separación entre gestión de la plataforma y atención de solicitudes.

**Verificación.** El supervisor del área puede asignar a un técnico habilitado de su área. El administrador y el supervisor de otra área reciben una denegación al intentar asignar esa solicitud.

## 4. Transferencia de solicitudes entre áreas

Se propone diferir la transferencia de área hasta definir quién puede iniciarla, qué ocurre con el técnico asignado, cómo cambia la visibilidad y cómo queda registrada en el historial. Si el equipo confirma que es P0, esos criterios se acuerdan antes de implementar el flujo.

El alcance propuesto de las exclusiones queda registrado en [DELIBERADAMENTE-NO-HECHO.md](DELIBERADAMENTE-NO-HECHO.md).
