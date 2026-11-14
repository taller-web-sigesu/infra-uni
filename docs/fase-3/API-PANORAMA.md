# Panorama de APIs — REST, GraphQL, gRPC, webhooks y API Gateway

- **Fecha:** 14/11/2026
- **Alcance:** justificar las decisiones de interfaz de UniService y dejar documentadas las alternativas.
- **Decisión vigente:** API REST versionada en `/api/v1`, monolito modular Spring Boot.

## REST

Es la interfaz oficial del producto.

| Elemento | Implementación |
| --- | --- |
| Recursos | Solicitudes, reservas, usuarios, catálogos, espacios, SLA, dashboard y adjuntos |
| Rutas | `/api/v1/...`; recursos anidados para historial, comentarios, auditoría y adjuntos |
| Parámetros | Filtros por estado, categoría, prioridad, área y rango de fechas |
| Códigos | `200`, `201`, `204`, `400`, `401`, `403`, `404`, `409`, `429`, `500` |
| Documentación | `backend-uni/docs/api/openapi.yaml` y Swagger UI |
| Pruebas | Contrato OpenAPI en CI, pruebas de integración y E2E |
| Errores | `application/problem+json` con código estable y `fieldErrors` |

**Versionado:** el prefijo `/api/v1` es obligatorio. Un cambio incompatible requiere `/api/v2` o una ventana de deprecación documentada; no se eliminan campos sin aviso.

## GraphQL

**No se implementa.** El producto tiene operaciones bien delimitadas, pantallas con endpoints concretos y reportes agregados. GraphQL agregaría:

- complejidad de autorización por campo y por relación;
- riesgo de consultas costosas o abusivas;
- caché y observabilidad más difíciles;
- un cliente adicional sin una necesidad de producto demostrada.

Queda como alternativa si en el futuro se necesita una API pública con consultas variables. En ese caso se evaluaría persistencia de consultas, límites de profundidad y autorización por campo.

## gRPC

**No se implementa.** El sistema es un monolito modular: los módulos se comunican por llamadas Java, no por red. gRPC sería útil si se separaran servicios internos con requisitos de latencia o streaming; hoy agregaría infraestructura y contratos sin beneficio.

## Webhooks

**No se implementan en esta versión.** Serían útiles para:

- notificar cambios de estado a sistemas externos;
- integrar pagos o servicios de mensajería;
- sincronizar con el sistema académico.

Antes de implementarlos habría que definir firma HMAC, reintentos, idempotencia, cola de eventos y política de secretos. No forman parte del alcance actual.

## API Gateway

**No se usa un gateway propio.** El monolito se despliega detrás de la plataforma:

- Vercel recibe el frontend y hace de proxy same-origin para `/api`.
- Render recibe el backend por HTTPS.
- Railway aloja MySQL en una red privada/proxy.
- TLS, DNS y balanceo básico los resuelve la plataforma.

Un gateway dedicado (Kong, Traefik, AWS API Gateway) tendría sentido si hubiera varios servicios, políticas centralizadas de rate limiting, autenticación compartida o múltiples consumidores. Para un monolito con un frontend, añadiría un componente operativo sin necesidad demostrada.

| Alternativa | Ventaja | Costo | Decisión |
| --- | --- | --- | --- |
| Sin gateway (actual) | Menos piezas, despliegue simple | Menos control centralizado | ✅ |
| Gateway en la nube | Rate limit, WAF, federación | Costo y configuración | Futuro |
| Gateway self-hosted | Control total | Operación y alta disponibilidad | No justificado |

## Matriz de decisión

| Necesidad | REST | GraphQL | gRPC | Webhooks | Gateway |
| --- | --- | --- | --- | --- | --- |
| CRUD y pantallas actuales | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Reportes agregados | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| Integración con terceros | ✅ | ⚠️ | ⚠️ | ✅ | ⚠️ |
| Comunicación interna | N/A | N/A | ⚠️ | N/A | N/A |
| Rate limiting central | ❌ | ❌ | ❌ | ❌ | ✅ |

## Pendientes

- [ ] Definir política formal de deprecación y fechas de soporte para `/api/v1`.
- [ ] Evaluar un gateway solo si se agrega un segundo servicio o un cliente externo.
- [ ] Documentar webhooks si se incorpora mensajería o pagos.
