# Infraestructura local

Docker Compose reúne `frontend`, `backend` y `mysql` bajo el proyecto
`universidad-sm`.

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
`docker compose down -v`. En staging y producción se guardan en Supabase
Storage (ADR-0004).

## Trabajo en equipo

**Obligatorio:** crea una rama por cambio (`feature/...`, `fix/...` o `docs/...`)
desde `main`. No cambies ni confirmes trabajo directamente en `main`; integra
mediante una PR revisada por otro compañero.
