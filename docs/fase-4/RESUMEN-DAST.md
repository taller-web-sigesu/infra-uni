# DAST activo — P2

**Fecha:** 27/11/2026, Lima.  
**Herramienta:** OWASP ZAP 2.17.0, `-quickurl` con spider tradicional + escaneo activo.  
**Alcance:** superficie pública de staging: login del frontend, Swagger UI y estado del backend.  
**Resultado:** 0 hallazgos altos; 4 medios, 1 bajo y 9 informativos, todos clasificados o aceptados.

## Objetivos y resultados

| Objetivo | Alto | Medio | Bajo | Informativo | Reporte |
| --- | ---: | ---: | ---: | ---: | --- |
| `https://frontend-uni-tdk7.vercel.app/login` | 0 | 2 | 0 | 4 | [`zap-frontend-active.html`](evidencias-dast/zap-frontend-active.html) |
| `https://uniservice-backend-staging.onrender.com/swagger-ui/index.html` | 0 | 2 | 1 | 4 | [`zap-backend-swagger-active.html`](evidencias-dast/zap-backend-swagger-active.html) |
| `https://uniservice-backend-staging.onrender.com/api/v1/status` | 0 | 0 | 0 | 1 | [`zap-backend-status-active.html`](evidencias-dast/zap-backend-status-active.html) |

## Hallazgos y clasificación

| ID | Riesgo | Hallazgo | Clasificación |
| --- | --- | --- | --- |
| DAST-01 | Medio | `CSP: style-src unsafe-inline` en el frontend | **Aceptado.** La SPA usa estilos dinámicos en dos componentes; el resto de la CSP sí está restringido. No se detectó XSS. |
| DAST-02 | Medio | `Cross-Domain Misconfiguration` en recursos estáticos públicos | **Aceptado.** `Access-Control-Allow-Origin: *` sobre HTML/JS público sin credenciales. Es el mismo SEG-02 del informe pasivo. |
| DAST-03 | Medio | CSP ausente en Swagger UI | **Aceptado.** Swagger UI es documentación pública de la API; no es una pantalla de usuario final y la sesión no se procesa allí. |
| DAST-04 | Medio | Spring Actuator Information Leak en `/actuator/health` | **Aceptado.** Solo expone `status` y nombres de grupos; no hay detalles, componentes ni variables. |
| DAST-05 | Bajo | Timestamp Disclosure en `swagger-ui-bundle.js` | **Falso positivo.** Constantes internas del bundle de Swagger UI; no son datos de la aplicación. |
| DAST-06 | Informativo | Comentarios sospechosos, SPA moderna, caché y user-agent fuzzer | **Informativo.** Revisado; no hay secretos ni rutas privadas expuestas. |

No se encontraron hallazgos altos. Las pruebas autenticadas de autorización por rol y recurso se cubren en la matriz de `MATRIZ-AUTORIZACION-P2.md` y en `TelemetryIT`, `AuthIT`, `RequestLifecycleIT` y `AttachmentIT`.

## Reproducción

```powershell
# Frontend
zap.bat -cmd -silent -notel -quickurl https://frontend-uni-tdk7.vercel.app/login `
  -quickout evidencias-dast/zap-frontend-active.html -quickprogress

# Swagger UI
zap.bat -cmd -silent -notel -config connection.timeoutInSecs=120 `
  -quickurl https://uniservice-backend-staging.onrender.com/swagger-ui/index.html `
  -quickout evidencias-dast/zap-backend-swagger-active.html -quickprogress
```

> No se ejecutó un escaneo activo contra producción ni contra endpoints que modifican datos. El DAST se limitó a staging y a la superficie pública.
