# ADR-0004: Despliegue y persistencia en la nube

- **Estado:** Propuesto
- **Fecha:** 2026-11-04
- **Decisores:** Equipo del proyecto Gestal
- **Documentos relacionados:** [ARCHITECTURE.md](../ARCHITECTURE.md), [DOCKER.md](../DOCKER.md), [DISENIO-BD.md](../../DISENIO-BD.md)

## Contexto

La arquitectura propone Vercel para el frontend y Render para el backend, pero no hay proveedor de MySQL definido, ni entornos staging/producción, ni procedimiento de backup y rollback. El sistema debe estar disponible para la evaluación y conservar datos entre despliegues.

## Decisión

1. **Frontend:** Vercel, build estático de Vite, variables de entorno por entorno y dominio con HTTPS.
2. **Backend:** Render con imagen Docker de producción; healthcheck en `/actuator/health`; variables de entorno y secretos del proveedor.
3. **Base de datos:** MySQL gestionado compatible (Aiven, Railway o Clever Cloud; se elige por costo, backup y latencia). No se publica el puerto de MySQL a Internet.
4. **Entornos:** `staging` y `production` separados, con bases de datos y credenciales distintas. `local` sigue con Docker Compose.
5. **Migraciones:** Flyway se ejecuta al desplegar; las migraciones son versionadas y no destructivas. Los cambios de esquema se prueban primero en staging.
6. **Secretos:** variables de entorno del proveedor o GitHub Secrets; nunca en el repositorio, la imagen ni los logs.
7. **Backups:** backup automático diario con retención mínima de 7 días; prueba de restauración documentada antes de la sustentación.
8. **Rollback:** conservar la imagen anterior del backend y el deployment anterior del frontend; el rollback no revierte migraciones destructivas.
9. **TLS:** HTTPS obligatorio entre navegador, backend y MySQL gestionado.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
| --- | --- |
| MySQL local expuesto | Riesgo de seguridad y disponibilidad. |
| Un único VPS con todo | Más operación y un solo punto de fallo. |
| Microservicios | Contradice el monolito modular y no hay necesidad medida. |
| Sin staging | Impide validar migraciones y smoke tests antes de producción. |

## Consecuencias

- Costo recurrente de Render, Vercel y MySQL gestionado.
- Hay que definir el dominio, CORS y cookies `Secure` por entorno.
- La ventana de despliegue debe coordinar migraciones y rollback.
- Los backups deben probarse, no solo configurarse.
