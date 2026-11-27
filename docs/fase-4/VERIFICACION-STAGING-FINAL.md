# Verificación final de staging — P2

**Fecha:** 27/11/2026, Lima.  
**SHA desplegado:** `8136b68` (`main` de `backend-uni`).  
**Servicio:** `uniservice-backend-staging` en Render.  
**Estado:** cerrado; sin pendientes de P2.

## 1. Despliegue y salud

| Comprobación | Resultado |
| --- | --- |
| Render sirve el commit | `8136b68` |
| `GET /actuator/health` | `200` · `status=UP` |
| `GET /api/v1/status` | `200` · `status=UP` |
| `staging-smoke` | ✅ [run 46078054975](https://github.com/taller-web-sigesu/backend-uni/actions/runs/46078054975) |
| `/actuator/prometheus` anónimo | `401` (protegido) |
| CSP en frontend staging | ✅ header presente y login operativo |

La migración demo `V1001` quedó idempotente en `backend-uni` (`8136b68`). Se eliminó de la base de staging la fila fallida `1001` de `flyway_schema_history` antes del redeploy.

## 2. Datos de demostración

| Comprobación | Resultado |
| --- | --- |
| `supervisor.sg.demo@universidad.example` | `200` · rol `SUPERVISOR` · área 3 |
| `tecnico.sg.demo@universidad.example` | `200` · rol `TECNICO` · área 3 |
| `LAB-10` | visible, área 1, capacidad 30 |
| `CANCHA-01` | visible, área 3, capacidad 40 |
| Reserva `RES-2026-000005` | creada como estudiante y aprobada por supervisor de área 3 |

## 3. Sesión única

- Se inició sesión dos veces con la misma cuenta.
- El token anterior recibió `401` en un endpoint protegido.
- El token nuevo recibió `200`.
- `/api/v1/status` es público: no sirve para comprobar revocación de sesión.

## 4. Performance de staging

Smoke k6 ejecutado con `tests/performance/staging-smoke.js` contra el SHA `8136b68`:

| Métrica | Resultado |
| --- | --- |
| Peticiones | 6 |
| Checks | 12/12 |
| Errores | 0 % |
| p95 | 441,89 ms |
| p99 | 493,66 ms |
| Máximo | 506,61 ms |
| Duración | 7,64 s |

Resumen sanitizado: [`evidencias-performance/staging-final/smoke-k6.json`](evidencias-performance/staging-final/smoke-k6.json).

## 5. Seguridad

- `SEG-01` (CSP ausente) cerrado: `Content-Security-Policy` presente en Vercel staging.
- `/actuator/health` responde solo con estado y grupos; sin detalles internos.
- `/actuator/prometheus` y `/actuator/info` rechazan acceso anónimo.
- La matriz de autorización y el informe de seguridad se mantienen como evidencia.
- ZAP pasivo previo sobre staging se conserva; no se añadieron endpoints nuevos después de esa pasada.

## 6. Limitaciones aceptadas

Estas limitaciones son de infraestructura, no tareas abiertas de P2:

- Render free no ofrece shell ni one-off jobs; la verificación se hizo por API y dashboard.
- La pila Grafana/Prometheus/Tempo se validó en local; no se despliega en Render free.
- El canal externo de alertas y la retención de logs de 30 días dependen del proveedor y se aceptan como limitación de la demo.
- Render free puede dormir la instancia; el cold start se documenta aparte.

## 7. Conclusión

Staging quedó alineado con `main`, con datos demo completos, sesión única operativa, CSP activo y smoke de disponibilidad en verde. P2 no deja pendientes de implementación ni de verificación en staging.
