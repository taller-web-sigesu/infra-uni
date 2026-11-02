# Docker Desktop para desarrollo local

## Servicios

`compose.yaml` crea un único proyecto llamado **universidad-sm** con tres
servicios:

| Servicio | Dirección local | Función |
| --- | --- | --- |
| `frontend` | [http://localhost:3000](http://localhost:3000) | React + Vite, pantalla inicial y HMR |
| `backend` | [http://localhost:8080](http://localhost:8080) | API mínima Spring Boot; salud en `/actuator/health` |
| `mysql` | Sin puerto publicado | MySQL 8.4.13 con volumen persistente |

Los puertos del frontend y backend se enlazan solo a `127.0.0.1`. El proxy de
Vite reenvía `/api` a `http://backend:8080` dentro de Docker. El endpoint mínimo
`GET /api/v1/status` permite comprobar esa comunicación.

La red `app_net` conecta frontend y backend y permite publicar sus puertos
locales. La red `db_internal` es interna y conecta únicamente backend con
MySQL. MySQL no publica `3306` al host. Compose espera que MySQL esté saludable
antes de arrancar backend y que backend esté saludable antes de arrancar
frontend.

MySQL tiene límite de 1 CPU y 1 GiB de memoria. El límite anterior de 768 MiB se
subió para dar margen al arranque de MySQL 8.4 en computadoras del equipo. La
base inicial es `uni_services`; no se crean tablas ni lógica de negocio.

## Preparar e iniciar con doble clic

Requisitos en cada computadora:

- Docker Desktop instalado y con el motor Linux en ejecución.
- Los tres repositorios clonados en carpetas hermanas:

  ```text
  universidad-sm/
  ├── frontend-uni/
  ├── backend-uni/
  └── infra-uni/
  ```

Haz doble clic en `infra-uni/iniciar.bat`. El script localiza los repositorios
desde su propia ruta, comprueba Docker CLI, Compose, el motor y los archivos de
los tres proyectos, crea `.env` si falta y ejecuta `docker compose up -d
--build`. Mantiene la ventana abierta, muestra el estado de Compose y los logs
recientes si el inicio falla.

El `.env.example` incluye credenciales de ejemplo exclusivamente locales para
que el primer inicio funcione sin pasos manuales. Para personalizarlas antes
del primer inicio, copia ese archivo a `infra-uni/.env` y cambia
`MYSQL_PASSWORD` y `MYSQL_ROOT_PASSWORD`. No subas `.env` al repositorio.

Los valores de usuario, contraseña y base de datos se aplican cuando se crea
`mysql_data` por primera vez. Si editas `.env` con un volumen ya inicializado,
el volumen conserva las credenciales existentes; además, los contenedores
existentes deben recrearse para recibir nuevas variables. Ejecuta
`iniciar.bat` después del cambio. No elimines el volumen si necesitas conservar
la base local.

## Docker Desktop en el trabajo diario

En **Containers**, abre el grupo `universidad-sm`. Puedes iniciar, detener y
reiniciar el proyecto desde la interfaz. Si arrancas los contenedores de forma
individual, inicia primero `mysql` y espera el estado `healthy`, luego `backend`
y finalmente `frontend`. Al iniciar el grupo completo, la política de reinicio
permite que los servicios de aplicación vuelvan a intentar el arranque mientras
MySQL se inicia.

`detener.bat` usa `docker compose stop`: detiene los tres servicios y deja los
contenedores visibles en Docker Desktop para iniciarlos otra vez. No ejecuta
`down -v` y no borra `mysql_data`. Detener o reiniciar los contenedores desde
Docker Desktop tampoco elimina el volumen.

Para revisar un fallo, abre **Logs** en el servicio afectado en Docker Desktop.
`iniciar.bat` también deja los últimos logs en pantalla cuando Compose devuelve
un error. Si un contenedor aparece `unhealthy` o reinicia repetidamente, abre
sus logs y verifica primero que Docker Desktop tenga memoria disponible.

## Edición del código

Los repositorios se montan como carpetas de trabajo dentro de sus contenedores.
No es necesario instalar Node, Java ni Maven en el host.

- **Frontend:** edita archivos en `frontend-uni/src` desde VS Code. Vite usa
  polling para detectar cambios en el montaje de Windows y aplica HMR sin
  reconstruir la imagen. Si agregas o cambias dependencias en `package.json`,
  reinicia `frontend` desde Docker Desktop para que el arranque ejecute
  `npm install` en el volumen `frontend_node_modules`.
- **Backend:** Spring Boot DevTools reinicia al cambiar archivos compilados del
  classpath. Guardar un `.java` en VS Code no lo compila por sí solo. Después de
  editar Java, abre **Exec** en el contenedor `backend` y ejecuta `mvn compile`;
  Maven y el JDK ya están dentro del contenedor y DevTools detecta los `.class`
  actualizados. Los cambios de configuración o dependencias pueden requerir
  reiniciar el servicio.

## Datos y volúmenes

- `mysql_data`: datos de MySQL en `/var/lib/mysql`; persiste al detener,
  reiniciar o recrear contenedores.
- `backend_target`: clases compiladas que observa DevTools.
- `maven_cache`: dependencias Maven descargadas dentro del contenedor.
- `frontend_node_modules`: dependencias npm del contenedor Linux.

No elimines `mysql_data` desde la sección **Volumes** de Docker Desktop si
quieres conservar los datos. El puerto de MySQL no es accesible directamente
desde herramientas instaladas en Windows; el backend se conecta mediante el
nombre de servicio `mysql` por la red interna.

## Validaciones

En esta computadora se verificó la presencia de Docker CLI y Docker Compose,
pero el motor no está disponible para esta sesión: `docker info` devuelve
`permission denied` al conectarse a la tubería de Docker Desktop. Por eso aún
no se pueden confirmar contenedores en ejecución, estado saludable, conexión
real Spring Boot → MySQL, respuesta del navegador, HMR ni persistencia tras
reinicio. Además, npm no pudo resolver `registry.npmjs.org` (`ENOTFOUND`) desde
esta sesión, así que tampoco se ejecutó la instalación ni el build del
frontend. Cuando Docker y el acceso al registro estén disponibles, inicia
`iniciar.bat` y revisa los tres estados en Docker Desktop.
