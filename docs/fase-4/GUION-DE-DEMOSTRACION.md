<div class="portada">

# Guion de demostración

**Gestal / UniService**

Sistema Web para la Gestión Integral de Servicios Universitarios

Fase IV · Entrega final (`v1.0.0`) · 27/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

Responsable: Persona 5 (QA y verificación)

</div>

## 1. Objetivo y duración

Este guion guía la demostración en vivo de Gestal / UniService frente al docente. El recorrido está diseñado para completarse en **12 minutos**, dejando margen para preguntas técnicas o repetición de algún paso.

El recorrido demuestra los flujos principales de las Fases I a IV: autenticación con sesión única, registro y ciclo de vida de solicitudes con control de acceso por rol y área, reserva y aprobación de ambientes con los datos de demostración de Fase IV (Laboratorio 10 y Cancha deportiva), panel administrativo con las mejoras de UI/UX y evidencia de operación (API documentada y salud del servicio).

## 2. Entorno principal y verificaciones previas

Antes de iniciar la exposición (al menos 5 minutos antes), el expositor realiza esta preparación:

1. Abrir el frontend de staging: <https://frontend-uni-tdk7.vercel.app>
2. Despertar el backend en Render (plan gratuito puede estar en reposo y demorar 30–50 segundos en el primer arranque) abriendo <https://uniservice-backend-staging.onrender.com/actuator/health> y confirmando la respuesta `{"status":"UP"}`.
3. Abrir en una pestaña secundaria la documentación OpenAPI: <https://uniservice-backend-staging.onrender.com/swagger-ui/index.html>.
4. Tener abiertas dos ventanas del navegador (una normal y una de incógnito) para mostrar la política de sesión única sin cerrar manualmente la primera sesión.
5. Verificar que la resolución de pantalla sea al menos 1280 × 720 (o 1440 × 900) y el zoom del navegador esté en 100 %.

## 3. Cuentas y datos de demostración

Todas las cuentas de staging comparten la contraseña `Demo2026!` y corresponden a usuarios ficticios cargados mediante las migraciones de `backend-uni/src/main/resources/db/demo/` (`V1000` y `V1001`).

| Rol | Correo | Área | Uso en la demo |
| --- | --- | --- | --- |
| Estudiante | `ana.demo@universidad.example` | — | Sesión única, alta de solicitud, reserva de cancha |
| Docente | `pedro.demo@universidad.example` | — | Aislamiento entre usuarios (no ve solicitudes de Ana) |
| Supervisor TI | `supervisor.ti.demo@universidad.example` | Soporte Informático | Asignación de técnico, prioridad, cierre/rechazo |
| Técnico TI | `tecnico.ti.demo@universidad.example` | Soporte Informático | Atención de solicitud (`EN_PROCESO` y `RESUELTO`) |
| Supervisor SG | `supervisor.sg.demo@universidad.example` | Servicios Generales | Aprobación de reserva de `CANCHA-01` |
| Técnico SG | `tecnico.sg.demo@universidad.example` | Servicios Generales | Disponibilidad de personal en Servicios Generales |
| Administrador | `admin.demo@universidad.example` | Global | Inicio con indicadores, usuarios, catálogos y ambientes |

Ambientes incorporados en Fase IV (`V1001__ambientes_y_cuentas_fase_iv.sql`):

- **Laboratorio 10** (`LAB-10`): tipo Laboratorio, área Soporte Informático, Pabellón nuevo, capacidad 30, horario lunes a viernes de 07:00 a 22:00.
- **Cancha deportiva** (`CANCHA-01`): tipo Otro, área Servicios Generales, Zona deportiva, capacidad 40, horario lunes a viernes de 07:00 a 22:00.

## 4. Secuencia paso a paso (12 minutos)

| Bloque | Tiempo | Actor | Qué se muestra |
| --- | --- | --- | --- |
| 1. Acceso y sesión única | 0:00 – 2:00 | Estudiante | Marca UNMSM, ingreso, segunda sesión en incógnito que revoca la primera |
| 2. Solicitud y ciclo de vida | 2:00 – 5:30 | Estudiante, Supervisor TI, Técnico TI | Registro de incidencia en Laboratorio 10, asignación, prioridad, atención y cierre |
| 3. Reserva de ambientes | 5:30 – 8:00 | Estudiante, Supervisor SG | Disponibilidad de `LAB-10` y `CANCHA-01`, solicitud de reserva y aprobación |
| 4. Administración y UI/UX | 8:00 – 10:30 | Administrador | Inicio con KPIs, menú contraíble, breadcrumbs, usuarios, catálogos y ambientes |
| 5. API, calidad y cierre | 10:30 – 12:00 | Expositor | Swagger UI, `/actuator/health`, CI en verde y evidencias de seguridad y carga |

### Bloque 1: Acceso y política de sesión única (2 min)

1. En la ventana principal, abrir <https://frontend-uni-tdk7.vercel.app/login>. Señalar la marca **UNMSM** y el formulario accesible.
2. Iniciar sesión con `ana.demo@universidad.example` / `Demo2026!`. Confirmar el ingreso al inicio del estudiante y el menú lateral con la acción **Cerrar sesión** al pie.
3. En la ventana de incógnito, iniciar sesión con la misma cuenta `ana.demo@universidad.example`.
4. Volver a la ventana principal y recargar o abrir **Mis solicitudes**. Mostrar que la sesión anterior fue revocada automáticamente (la API responde `401` y el frontend redirige al ingreso), mientras la sesión de incógnito continúa operativa.

### Bloque 2: Ciclo de vida de solicitudes y separación por área (3 min 30 s)

1. Con `ana.demo@universidad.example`, ir a **Mis solicitudes** y pulsar **Registrar nueva solicitud**.
2. Seleccionar la categoría **Soporte informático**, ubicación `Laboratorio 10, puesto 12`, descripción `Proyector sin señal HDMI en Laboratorio 10`, y registrar. Anotar el código generado (`SOL-2026-XXXXXX`).
3. Cerrar sesión e ingresar como `supervisor.ti.demo@universidad.example`. Mostrar la pantalla inicial de **Indicadores** y luego pasar a **Gestión de solicitudes**.
4. Abrir la solicitud recién creada, asignar a `Técnico Demo TI` (`tecnico.ti.demo@universidad.example`) y actualizar la prioridad. Explicar brevemente que el administrador no puede asignar solicitudes y que un supervisor de otra área no tiene visibilidad sobre solicitudes de Soporte Informático.
5. Ingresar como `tecnico.ti.demo@universidad.example`, abrir la bandeja de asignaciones, pasar la solicitud a **En proceso** y luego a **Resuelto** con comentario técnico.
6. Volver a `supervisor.ti.demo@universidad.example`, verificar el historial completo y pasar la solicitud a **Cerrado**. Mencionar la política de duplicados y reportes mal dirigidos (rechazo motivado según HU-11).

### Bloque 3: Reserva de ambientes de Fase IV (2 min 30 s)

1. Ingresar nuevamente como `ana.demo@universidad.example` y abrir **Mis reservas** > **Nueva reserva**.
2. Mostrar ambos espacios de Fase IV en el selector: **Laboratorio 10** (`LAB-10`, capacidad 30) y **Cancha deportiva** (`CANCHA-01`, capacidad 40).
3. Elegir **Cancha deportiva** (`CANCHA-01`) para un día hábil futuro dentro del horario 07:00–22:00 (por ejemplo, 14:00 a 16:00), ingresar motivo `Entrenamiento equipo FISI` y registrar la reserva.
4. Cerrar sesión e ingresar como `supervisor.sg.demo@universidad.example`.
5. Ir a **Aprobación de reservas**. Señalar la mejora UI/UX del punto 10: tanto el código de la reserva como el botón del ojo abren el diálogo de revisión.
6. Revisar disponibilidad y aprobar la reserva. Verificar que cambia de estado y queda registrada en el historial.

### Bloque 4: Panel de administrador y mejoras UI/UX (2 min 30 s)

1. Ingresar como `admin.demo@universidad.example`.
2. Mostrar la pantalla **Inicio** del administrador: indicadores del mes de Lima (registradas, pendientes y atendidas) y los seis accesos rápidos.
3. Demostrar el control de expandir/contraer el menú lateral dentro de la barra, el indicador activo con borde izquierdo y la ubicación de **UNMSM** en la cabecera del menú.
4. Abrir **Usuarios**: señalar las migas de navegación (`Inicio / Usuarios`) y los controles **Editar** (énfasis azul), **Desactivar** y **Restablecer contraseña**.
5. Abrir **Catálogos**: señalar las migas (`Inicio / Catálogos`), las pestañas (Áreas, Categorías, Prioridades y Estados) y las acciones disponibles.

### Bloque 5: Documentación de API, salud y evidencias (1 min 30 s)

1. Mostrar la pestaña de Swagger UI (<https://uniservice-backend-staging.onrender.com/swagger-ui/index.html>) con las 64 operaciones documentadas.
2. Mostrar `/actuator/health` (solo `status` y `groups`, sin detalles internos) y comentar que `/actuator/prometheus` exige credenciales de recolector (`401` anónimo).
3. Referenciar los PDFs de respaldo del Drive (`EVIDENCIAS-TECNICAS.pdf`, `INFORME-DE-PRUEBAS.pdf` y `INDICE-DE-EVIDENCIAS.pdf`) para preguntas sobre carga (k6), observabilidad (Grafana/Prometheus/Tempo), seguridad (CodeQL y ZAP) y respaldo/restauración.

## 5. Plan B ante contingencias

Si durante la exposición ocurre una caída de red, latencia excesiva o suspensión prolongada de Render/Vercel, se aplica el siguiente plan de respaldo en orden:

### Plan B1: Entorno local con Docker Compose (recomendado)

El equipo lleva el entorno local preconstruido en una laptop con Docker Desktop iniciado antes de la sesión.

1. Abrir una terminal en la raíz de `infra-uni` y ejecutar `iniciar.bat` (o `docker compose up -d`).
2. Confirmar que los contenedores `mysql`, `backend` y `frontend` están en estado `healthy`/`running`.
3. Ejecutar exactamente el mismo guion sobre <http://localhost:3000> (frontend) y <http://localhost:8080/swagger-ui.html> (API), usando las mismas cuentas `*.demo@universidad.example` y contraseña `Demo2026!`.
4. Ventaja adicional: en local también se puede levantar la pila de observabilidad (`backend-uni/observability/compose.yaml`) para mostrar Grafana en vivo en `http://127.0.0.1:3001`.

### Plan B2: Evidencias estáticas y grabación de respaldo

Si falla la red y además no estuviera disponible Docker en la máquina de exposición:

1. Mostrar las capturas de pantallas reales integradas en `03-Manual-de-usuario/MANUAL-DE-USUARIO.pdf` y `02-Documentacion/INFORME-FINAL-FASES-I-IV.pdf`.
2. Mostrar las capturas de Grafana, resultados k6 y reportes ZAP consolidados en `06-Evidencias/EVIDENCIAS-TECNICAS.pdf`.
3. Reproducir el video de ensayo pregrabado del recorrido completo (almacenado localmente en la laptop de presentación y enlazado en `INDICE-DE-EVIDENCIAS.pdf` tras el ensayo general).

## 6. Checklist previo al ensayo y a la presentación

- [ ] Backend staging responde `200 UP` en `/actuator/health` 5 minutos antes de iniciar.
- [ ] Frontend staging carga `/login` sin errores en consola.
- [ ] Cuentas `ana.demo`, `supervisor.ti.demo`, `tecnico.ti.demo`, `supervisor.sg.demo` y `admin.demo` autenticadas sin bloqueo por intentos fallidos.
- [ ] Espacios `LAB-10` y `CANCHA-01` visibles y con horario hábil disponible para la fecha de demostración.
- [ ] Entorno local Docker Compose verificado como Plan B1.
- [ ] Ensayo cronometrado completado dentro de los 12 minutos previstos.
