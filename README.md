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

## Trabajo en equipo

**Obligatorio:** crea una rama por cambio (`feature/...`, `fix/...` o `docs/...`)
desde `main`. No cambies ni confirmes trabajo directamente en `main`; integra
mediante una PR revisada por otro compañero.
