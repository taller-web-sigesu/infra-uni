# ADR-0003: Observabilidad y retención

- **Estado:** Propuesto
- **Fecha:** 2026-11-04
- **Decisores:** Equipo del proyecto Gestal
- **Requisitos afectados:** RNF-15
- **Documentos relacionados:** [ARCHITECTURE.md](../ARCHITECTURE.md), [backend ARCHITECTURE](../../../backend-uni/ARCHITECTURE.md)

## Contexto

El sistema necesita identificar incidentes, depurar errores y demostrar salud operativa durante la evaluación. Hoy solo existe `GET /actuator/health`; no hay métricas, logs estructurados, correlación, trazas ni alertas. La arquitectura global dejó la retención de logs como decisión pendiente.

## Decisión

1. **Métricas:** Micrometer con Actuator; exponer `health`, `info`, `metrics` y `prometheus` solo en la red interna o con autorización. Métricas mínimas: latencia HTTP, tasa de errores, pool de conexiones, uso de CPU/memoria y salud de MySQL.
2. **Logs:** formato JSON en todos los entornos desplegados, con `timestamp`, `level`, `logger`, `message`, `correlationId`, `traceId`, `spanId` y `userId` cuando aplique. Prohibido registrar tokens, contraseñas, cuerpos completos de solicitudes o datos personales innecesarios.
3. **Correlación:** aceptar o generar `X-Correlation-ID` en el backend, propagarlo a logs y respuestas, y devolverlo al cliente para soporte.
4. **Trazas:** Micrometer Tracing con OpenTelemetry y exportación OTLP si el proveedor lo permite; en local se puede desactivar la exportación y conservar los identificadores en logs.
5. **Retención:** logs 30 días, métricas 15 días, trazas 7 días. La retención de `auditoria_eventos` se decide con Producto y no se confunde con logs técnicos.
6. **Alertas:** disponibilidad del servicio, tasa de 5xx superior al 1 %, latencia p95 superior a 2 segundos y conexiones MySQL por encima del 80 %.
7. **Protección:** Actuator y endpoints operativos requieren autorización o exposición restringida; nunca se publican credenciales ni detalles internos en las respuestas.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
| --- | --- |
| Solo logs de texto sin correlación | Dificulta reconstruir una operación entre frontend, backend y BD. |
| Sin trazas | Impide medir cuellos de botella entre capas. |
| Retención indefinida | Costo y riesgo de privacidad; la auditoría tiene su propia política. |
| Exponer Actuator públicamente | Superficie de ataque innecesaria. |

## Consecuencias

- Se añaden dependencias de Micrometer Tracing y, si aplica, OpenTelemetry.
- Los logs deben pasar por un filtro de redacción antes de salir a la plataforma.
- Las alertas requieren un canal definido (correo del equipo o servicio de monitoreo).
- La retención depende del plan del proveedor y debe verificarse en staging.
