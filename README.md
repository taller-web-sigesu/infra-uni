# Infraestructura local

Docker Compose reúne `frontend`, `backend` y `mysql` bajo el proyecto
`universidad-sm`.

## Despliegues

Hay **dos despliegues separados**:

| Entorno | Frontend | Backend | Rama frontend | Rama backend |
| --- | --- | --- | --- | --- |
| Staging | https://frontend-uni-tdk7.vercel.app | https://uniservice-backend-staging.onrender.com | `main` | `main` |
| Producción | https://frontend-uni-wx9m.vercel.app | https://uniservice-backend-prod.onrender.com | `production` | `production` |

Producción usa una base MySQL distinta y no tiene auto-deploy en Render: se despliega con el workflow `deploy-production.yml`, que exige aprobación del environment `production` y ejecuta un smoke.

### Usuarios de prueba (staging)

Todas las cuentas usan la contraseña **`Demo2026!`**:

| Correo | Rol |
| --- | --- |
| `admin.demo@universidad.example` | Administrador |
| `supervisor.ti.demo@universidad.example` | Supervisor TI |
| `supervisor.mant.demo@universidad.example` | Supervisor Mantenimiento |
| `supervisor.bib.demo@universidad.example` | Supervisor Biblioteca |
| `tecnico.ti.demo@universidad.example` | Técnico TI |
| `tecnica.ti.demo@universidad.example` | Técnica TI |
| `tecnico.mant.demo@universidad.example` | Técnico Mantenimiento |
| `ana.demo@universidad.example` | Estudiante |
| `pedro.demo@universidad.example` | Docente |

Producción no carga cuentas demo. Su administrador inicial es `admin@uniservice.app` y la contraseña se entrega por el canal privado.

El informe completo está en [`docs/fase-3/INFORME-FASE-III.md`](docs/fase-3/INFORME-FASE-III.md).

## Iniciar

1. Clona los tres repositorios en carpetas hermanas y abre Docker Desktop.
2. Haz doble clic en [iniciar.bat](iniciar.bat). Crea `.env` si falta y levanta
   los servicios.
3. Abre [http://localhost:3000](http://localhost:3000).

En Docker Desktop, busca **Containers** → `universidad-sm` para iniciar,
detener o reiniciar el grupo. [detener.bat](detener.bat) lo detiene sin borrar
los datos de MySQL.

Los cambios del frontend se actualizan con HMR. Para aplicar cambios Java,
ejecuta `mvn compile` en **Exec** del contenedor `backend`. No necesitas
instalar Node.js, Java, Maven ni MySQL en tu computadora.

Las credenciales de `.env.example` son solo para desarrollo local. Para
personalizarlas antes del primer inicio, copia el archivo como `.env` y edítalo.

## Cuentas de demostración y evidencias

El backend local carga cuentas ficticias con la contraseña `Demo2026!`:
`admin.demo`, `supervisor.ti.demo`, `tecnico.ti.demo`, `ana.demo` (estudiante)
y `pedro.demo` (docente), todas `@universidad.example`. No uses estas cuentas
ni el secreto JWT del Compose fuera de tu computadora.

Las evidencias adjuntas a las solicitudes se guardan en el volumen
`evidencias_data`. Se conservan al reiniciar y se borran solo con
`docker compose down -v`. En staging y producción se usa almacenamiento local
temporal en Render (`/tmp/evidencias`); la integración con Supabase Storage
queda como evolución acordada (ADR-0004).

## Trabajo en equipo

**Obligatorio:** crea una rama por cambio (`feature/...`, `fix/...` o `docs/...`)
desde `main`. No cambies ni confirmes trabajo directamente en `main`; integra
mediante una PR revisada por otro compañero.
