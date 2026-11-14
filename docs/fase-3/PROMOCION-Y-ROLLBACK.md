# Promoción y rollback — UniService

- **Fecha:** 14/11/2026
- **Alcance:** paso de staging a producción y vuelta atrás segura.
- **Entornos:** local, staging y producción.

## 1. Modelo de ramas y despliegue

| Repo | Rama | Entorno | Plataforma |
| --- | --- | --- | --- |
| `frontend-uni` | `main` | Staging | Vercel `frontend-uni-tdk7` |
| `frontend-uni` | `production` | Producción | Vercel `frontend-uni-wx9m` |
| `backend-uni` | `main` | Staging y producción | Render `uniservice-backend-staging` y `uniservice-backend-prod` |
| `infra-uni` | `main` | Documentación y CI | GitHub Actions |

El backend usa la misma rama `main` en ambos entornos; la separación se hace por variables de entorno y base de datos. El frontend de producción usa la rama `production` porque su `vercel.json` apunta al backend de producción.

## 2. Promoción a producción

### Requisitos previos

- [ ] PR revisada y CI en verde en el repo afectado.
- [ ] Pruebas locales o de staging aprobadas.
- [ ] Migraciones Flyway revisadas y no destructivas.
- [ ] Variables de entorno de producción actualizadas.
- [ ] Backup o snapshot de la base de producción disponible.

### Pasos

1. **Integrar el cambio a `main`.**
   - PR con revisión.
   - CI de frontend/backend/infra en verde.
   - Merge a `main`; esto actualiza staging automáticamente.

2. **Validar staging.**
   - Health: `GET /actuator/health` → `UP`.
   - Login con una cuenta de staging.
   - Flujo crítico: solicitud → asignación → estado → cierre.
   - Revisar logs de Render y errores 5xx.

3. **Promover el frontend a producción.**
   ```bash
   git checkout main
   git pull --ff-only origin main
   git checkout production
   git merge main
   git push origin production
   ```
   Vercel despliega el proyecto `frontend-uni-wx9m`.

4. **Promover el backend.**
   - El backend de producción se despliega desde `main` en Render.
   - Verificar que el deploy terminó en `Live` y que Flyway aplicó las migraciones.
   - Si se requiere aprobación manual, usar el botón **Manual Deploy** de Render con el commit validado.

5. **Smoke de producción.**
   ```bash
   curl -fsS https://uniservice-backend-prod.onrender.com/actuator/health
   curl -fsS https://frontend-uni-wx9m.vercel.app/api/v1/status
   ```
   - Login con el admin de producción.
   - Verificar lectura y escritura en la base.
   - Revisar cabeceras de seguridad.

6. **Registrar evidencia.**
   - URL desplegada.
   - Commit/tag.
   - Run de CI/CD.
   - Captura del smoke.
   - Actualizar `docs/fase-3/EVIDENCIAS.md`.

## 3. Rollback

### Frontend

1. Vercel → proyecto `frontend-uni-wx9m` → **Deployments**.
2. Elegir el deployment anterior estable.
3. **Instant Rollback** o **Promote to Production**.
4. Verificar `/login` y `/api/v1/status`.

No se requiere revertir el repositorio para un rollback inmediato.

### Backend

1. Render → `uniservice-backend-prod` → **Deploys**.
2. Elegir el deploy anterior estable.
3. **Rollback** / redeploy de ese commit.
4. Verificar `/actuator/health` y login.
5. Revisar logs.

### Base de datos

- Las migraciones Flyway son **forward-only**. No se revierten con un rollback de aplicación.
- Si una migración es incompatible:
  1. Restaurar el backup previo.
  2. Revertir la aplicación al deploy anterior.
  3. Corregir la migración en una nueva versión.
- Nunca borrar la base ni el volumen sin autorización.

## 4. Criterios de abortar la promoción

- CI en rojo.
- Health distinto de `UP`.
- Login o refresh fallando.
- Errores 5xx repetidos en Render.
- Migración Flyway fallida.
- Smoke de API o flujo crítico fallando.
- Cabeceras de seguridad ausentes.

## 5. Responsables

| Actividad | Responsable |
| --- | --- |
| Aprobar PR y promoción | Equipo |
| Ejecutar smoke | Equipo |
| Rollback de frontend | Equipo |
| Rollback de backend | Equipo |
| Restauración de base | Responsable de infraestructura |

## 6. Evidencia mínima de una promoción

- [ ] PR y checks.
- [ ] Run de CI.
- [ ] Deploy de staging y producción.
- [ ] Health y API status.
- [ ] Login y flujo crítico.
- [ ] Cabeceras de seguridad.
- [ ] Tag/release.
- [ ] Registro en `EVIDENCIAS.md`.
