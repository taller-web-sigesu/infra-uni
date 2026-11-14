# Promoción y rollback — UniService

- **Fecha:** 14/11/2026
- **Alcance:** paso de staging a producción y vuelta atrás segura.
- **Entornos:** local, staging y producción.

## 1. Modelo de ramas y despliegue

| Repo | Rama | Entorno | Plataforma |
| --- | --- | --- | --- |
| `frontend-uni` | `main` | Staging | Vercel `frontend-uni-tdk7` |
| `frontend-uni` | `production` | Producción | Vercel `frontend-uni-wx9m` |
| `backend-uni` | `main` | Staging | Render `uniservice-backend-staging` |
| `backend-uni` | `production` | Producción | Render `uniservice-backend-prod` |
| `infra-uni` | `main` | Documentación y CI | GitHub Actions |

Cada entorno tiene su rama y su base de datos. El frontend de producción usa la rama `production` porque su `vercel.json` apunta al backend de producción.

El backend de producción **no tiene auto-deploy**: Render está configurado con la rama `production` y `Auto-Deploy: Off`. El único disparador es el workflow `deploy-production.yml`, que exige aprobación del environment `production` antes de llamar al Deploy Hook.

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
   Vercel despliega el proyecto `frontend-uni-wx9m`. Luego se valida el smoke de producción (paso 5).

4. **Promover el backend.**
   ```bash
   git checkout main
   git pull --ff-only origin main
   git checkout production
   git merge main
   git push origin production
   ```
   - La rama `production` está protegida con PR y los mismos checks que `main`.
   - El push dispara `deploy-production.yml`.
   - El job queda en **Waiting** hasta que un revisor apruebe el environment `production` en GitHub.
   - Al aprobar, el workflow llama al **Deploy Hook** de Render (`RENDER_PROD_DEPLOY_HOOK`), espera `/actuator/health` en `UP` y ejecuta el smoke de producción.
   - Render no despliega por su cuenta: `Auto-Deploy` está en `Off`.

5. **Smoke de producción.**
   ```bash
   curl -fsS https://uniservice-backend-prod.onrender.com/actuator/health
   curl -fsS https://frontend-uni-wx9m.vercel.app/api/v1/status
   curl -fsS https://uniservice-backend-prod.onrender.com/v3/api-docs
   curl -fsS https://frontend-uni-wx9m.vercel.app/login
   ```
   - El workflow `deploy-production.yml` ejecuta estas verificaciones automáticamente y falla si alguna no responde.
   - Login manual con el admin de producción y revisión de cabeceras de seguridad como comprobación complementaria.

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

Como `Auto-Deploy` está en `Off`, un rollback manual no se pisa con un deploy automático. Después del rollback, alinear la rama `production` con el commit restaurado mediante PR para que el próximo deploy no reintroduzca el cambio.

### Workflow de producción

- Si el workflow falla después de disparar el Deploy Hook, Render puede haber desplegado igualmente. Revisar **Deploys** y hacer rollback si el health o el smoke no pasan.
- Reejecutar `deploy-production.yml` solo después de corregir la causa; requiere una nueva aprobación del environment.

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
- [ ] Aprobación del environment `production`.
- [ ] Run de `deploy-production.yml` en verde.
- [ ] Health y API status.
- [ ] Login y flujo crítico.
- [ ] Cabeceras de seguridad.
- [ ] Tag/release.
- [ ] Registro en `EVIDENCIAS.md`.
