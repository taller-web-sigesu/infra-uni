# Decisiones de Fase IV — Gestal / UniService

**Fase IV en curso · Decisiones para la entrega final**

La Fase IV es la última fase del proyecto. Las cuatro decisiones de alcance de P2 quedan definidas en este documento. La implementación y sus verificaciones deben completarse antes de la entrega final.

## 1. Solicitudes duplicadas

**Decisión final.** El sistema acepta los reportes y el supervisor del área revisa los posibles duplicados. Si confirma que un reporte está duplicado, lo rechaza indicando el motivo, conforme a [HU-11](../requirements/user-stories/EP-03-Ciclo-Vida/HU-11-Cerrar-Rechazar-Solicitud.md). Se conservan el reporte original y el historial del rechazo.

**Verificación pendiente.** Registrar dos reportes del mismo incidente, rechazar el duplicado y comprobar que su motivo aparece en el historial y que el original conserva su estado.

## 2. Sesión única por cuenta

**Decisión final.** El último inicio de sesión válido reemplaza a los anteriores de la misma cuenta. La política amplía [HU-01](../requirements/user-stories/EP-01-Autenticacion/HU-01-Iniciar-Cerrar-Sesion.md) y reutiliza la revocación del [ADR de autenticación](../adr/ADR-0002-autenticacion-sesion.md).

**Implementación pendiente.** Tras validar las credenciales, bloquear la cuenta y comprobar que continúa habilitada y que las credenciales validadas siguen vigentes. Revocar sus sesiones anteriores y emitir la nueva en la misma transacción. Si falla la emisión, la transacción conserva la sesión anterior. En el despliegue, verificar que las cuentas con sesiones ya emitidas también respeten la política. Para cuentas con varias sesiones vigentes, conservar la última emitida y revocar las demás.

**Verificación pendiente.** Tras dos inicios válidos, comprobar que el acceso y la renovación funcionan con la sesión más reciente y se rechazan con la anterior. Un intento inválido debe conservar la sesión vigente. Con inicios concurrentes debe quedar una sola sesión activa. Añadir un caso con sesiones anteriores al despliegue.

## 3. Asignación de solicitudes por rol

**Decisión final.** El supervisor asigna y reasigna solicitudes de su propia área a técnicos habilitados de esa misma área, conforme a [HU-08](../requirements/user-stories/EP-03-Ciclo-Vida/HU-08-Asignar-Reasignar-Tecnico-Prioridad.md). El administrador gestiona cuentas y catálogos.

**Verificación pendiente.** Guardar evidencia de la asignación autorizada, del rechazo de un técnico de otra área y de las denegaciones al administrador y al supervisor de otra área.

## 4. Transferencia de solicitudes entre áreas

**Decisión final.** La transferencia directa de solicitudes entre áreas queda excluida de `v1.0.0`. La [HU-03](../requirements/user-stories/EP-02-Solicitudes/HU-03-Registrar-Solicitud.md) permite registrar una solicitud con la categoría correcta y la [HU-11](../requirements/user-stories/EP-03-Ciclo-Vida/HU-11-Cerrar-Rechazar-Solicitud.md) cubre el rechazo motivado del reporte mal dirigido. Una transferencia directa exigiría reglas nuevas de asignación, acceso al historial y plazos de atención.

**Flujo de atención.**

1. El supervisor del área que recibió el reporte lo revisa. Si corresponde a otra área y su estado permite el rechazo, lo rechaza e indica el motivo y la categoría correcta.
2. El solicitante consulta el motivo y registra una nueva solicitud con la categoría indicada. Puede citar el código anterior en la descripción para facilitar el seguimiento.
3. El sistema genera un código nuevo y dirige el reporte al área asociada a la categoría elegida. El historial del reporte original conserva el rechazo.

**Verificación.** Comprobar que el solicitante puede consultar el motivo del rechazo y que el nuevo reporte, con un código distinto, aparece en la bandeja del área correcta.

Las exclusiones de la entrega se registran en [DELIBERADAMENTE-NO-HECHO.md](DELIBERADAMENTE-NO-HECHO.md).


## Estado de cierre — 27/11/2026

| Decisión | Estado real |
| --- | --- |
| Duplicados | Política manual: el supervisor rechaza el duplicado con motivo. Flujo verificado en staging. |
| Sesión única | Implementada y verificada en staging: el segundo login revoca el token anterior; el token anterior recibe 401 en endpoints protegidos. |
| Admin y asignación | Se mantiene la separación: el administrador no asigna solicitudes; el supervisor del área sí. Verificado contra la matriz de autorización. |
| Transferencia de área | Excluida de `v1.0.0`; el flujo es rechazo motivado y nueva solicitud. |

La verificación final de staging está en [`docs/fase-4/VERIFICACION-STAGING-FINAL.md`](../fase-4/VERIFICACION-STAGING-FINAL.md).
