# Deliberadamente no hecho — Gestal / UniService

> Las primeras secciones documentan el alcance del Release Candidate `v1.0.0-rc.2` de la Fase III. Las secciones 7 y 8 recogen las exclusiones de alcance y el trabajo pendiente para el cierre de la Fase IV, la última del proyecto.

---

## 1. Producto y alcance

| Elemento | Decisión | Motivo |
|---|---|---|
| Notificaciones in-app o por correo | No implementadas | Requieren proveedor de mensajería, plantillas, reintentos y reglas de negocio; quedan como evolución. |
| Recuperación de contraseña por correo | No implementada | Se cubre con cambio de contraseña y restablecimiento por el administrador; no se depende de correo. |
| Integración con sistemas de la universidad | No implementada | Fuera del problema planteado. |
| Reservas recurrentes o periódicas | No implementadas | La reserva simple está implementada; la recurrencia exige reglas adicionales. |
| Varios roles por usuario | No implementado | Cada cuenta tiene un rol principal. |
| Chatbot con IA dentro del producto | No implementado | El curso exige registrar el uso de IA en el desarrollo, no integrar un chatbot. |
| Pagos o facturación | No implementados | Fuera del alcance del sistema de servicios universitarios. |

## 2. Arquitectura y API

| Elemento | Decisión | Motivo |
|---|---|---|
| GraphQL | No implementado | REST cubre las pantallas y reportes; GraphQL añadiría autorización por campo y consultas costosas. Documentado en `API-PANORAMA.md`. |
| gRPC | No implementado | Monolito modular; los módulos se comunican en Java, no por red. |
| Webhooks | No implementados | No hay integración con terceros ni mensajería externa en el alcance. |
| API Gateway propio | No usado | Vercel y Render resuelven TLS, proxy y balanceo; un gateway no aporta valor con un solo backend. |
| Docker de producción del frontend | No usado | Vercel construye y publica el frontend; Docker está cubierto para desarrollo (frontend/backend) y para el backend de producción. |

## 3. Operación y calidad

| Elemento | Decisión | Motivo |
|---|---|---|
| Observabilidad completa | Diferida a Fase IV | El RC tiene health, logs, `correlationId` y métricas básicas; faltan trazas, dashboards, alertas y retención centralizada. |
| DAST / OWASP ZAP | Diferido a Fase IV | La Fase III cubre SAST (CodeQL), revisión de dependencias y pruebas de autorización. |
| Pruebas de carga y estrés con k6 | Diferidas a Fase IV | No son requisito de Fase III. |
| Backups automáticos y restauración | Diferidos a Fase IV | ADR-0004 define la política; falta implementarla y probarla. |
| Manual de usuario y manual técnico | Diferidos a Fase IV | Documentos de cierre del curso. |
| Informe final de pruebas | Diferido a Fase IV | El RC entrega evidencias y matriz HU → prueba; el informe consolidado es de Fase IV. |

## 4. Datos y evidencias

| Elemento | Decisión | Motivo |
|---|---|---|
| Supabase Storage persistente | Diferido | El RC usa almacenamiento local temporal en Render y un volumen Docker en local. La integración con Supabase queda como evolución acordada (ADR-0004). |
| Retención definitiva de auditoría | Pendiente de producto | El mecanismo está implementado; falta decidir cuánto se conserva. |
| Catálogos reales de la universidad | Pendiente de producto | El RC usa datos ficticios de demostración. |

## 5. Decisiones de seguridad aceptadas en el RC.2

| Tema | Decisión | Motivo |
|---|---|---|
| **CSP** | No se añade Content-Security-Policy en el RC. | Vercel ya envía HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` y `Permissions-Policy`. Una CSP no probada podía romper la demo; se implementa en Fase IV. |
| **Swagger/Actuator públicos** | Swagger/OpenAPI se mantienen públicos para la demo; Actuator solo expone `health` sin detalles. | La rúbrica exige API documentada. Se restringirán por red/rol en Fase IV. |
| **Rotación de secretos** | Se documenta como procedimiento de Fase IV. | Rotar durante el RC invalidaría sesiones y credenciales de la demo. Los secretos ya están en variables de entorno. |
| **Threat model formal** | No se elabora para el RC. | El mapeo OWASP y las pruebas de autorización cubren los riesgos principales; se considera documentación de Fase IV, no un bloqueante. |
| **Logs centralizados y alertas** | Diferidos a Fase IV. | El RC tiene logs, `correlationId` y health; faltan métricas, trazas y alertas. |

## 6. Lo que sí está cubierto

- Cloud, Docker, ambientes, Git, ramas, CI, despliegue y pipeline.
- API REST: recursos, rutas, parámetros, códigos, documentación y pruebas.
- Autenticación, autorización, roles, JWT + refresh, validación, secretos, variables de entorno y OWASP.
- Pruebas unitarias, integración, API, aceptación, automatización y revisión de pruebas asistidas por IA.
- Aplicación desplegada, API documentada, CI/CD y Release Candidate `v1.0.0-rc.2`.

## 7. Exclusiones de la entrega final

| Elemento | Decisión | Motivo |
| --- | --- | --- |
| Detección, bloqueo y vinculación automáticos de duplicados | Fuera de `v1.0.0` | El supervisor revisa los posibles duplicados y registra el motivo del rechazo conforme a HU-11. |
| Asignación de solicitudes por el administrador | Fuera del alcance de la Fase IV | HU-08 asigna esta función al supervisor del área. |
| Transferencia directa de solicitudes entre áreas | Exclusión definitiva de `v1.0.0` | El supervisor rechaza el reporte mal dirigido con un motivo e indica la categoría correcta. El solicitante registra un nuevo reporte que se dirige al área correspondiente. |

Ver [DECISIONES-FASE-IV.md](DECISIONES-FASE-IV.md#4-transferencia-de-solicitudes-entre-áreas) para consultar el flujo completo y su criterio de verificación.

## 8. Trabajo que debe cerrarse en la Fase IV actual

| Frente | Entregable o verificación |
| --- | --- |
| Reglas de negocio y datos de demostración | Implementar la sesión única, verificar las cuatro decisiones de alcance y comprobar los datos de Laboratorio 10, cancha y cuentas de Servicios Generales. |
| Observabilidad y operación | Verificar métricas, trazas, logs, alertas y runbook. Implementar y probar el respaldo y la restauración previstos. |
| Seguridad y rendimiento | Completar la revisión de controles, las pruebas de seguridad y las pruebas de carga y estrés con sus evidencias. |
| Interfaz y aceptación | Completar los cambios acordados de UI/UX y registrar los resultados de las pruebas funcionales, accesibilidad, navegadores, UAT y usabilidad. |
| Documentación y entrega | Consolidar los 13 PDF, verificar el Drive y ensayar la demo. Publicar `v1.0.0` después de la verificación y aprobación del equipo. |

Los diferimientos del RC.2 describen lo que quedó abierto al terminar la Fase III. El trabajo requerido para la entrega se cierra en la Fase IV actual. Un cambio se registra como cerrado cuando se cuenta con la verificación correspondiente.

## 9. Referencias

- Informe final: [`INFORME-GESTAL-FASES-I-III.md`](https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/entregables/INFORME-GESTAL-FASES-I-III.md)
- Evidencias: [`EVIDENCIAS.md`](https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-3/EVIDENCIAS.md)
- OWASP: [`OWASP-TOP-10.md`](https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-3/OWASP-TOP-10.md)
- API: [`API-PANORAMA.md`](https://github.com/taller-web-sigesu/infra-uni/blob/main/docs/fase-3/API-PANORAMA.md)
