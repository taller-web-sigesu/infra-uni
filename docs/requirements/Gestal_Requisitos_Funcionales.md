# Requisitos funcionales — Gestal

| ID | Requerimiento | Actor | Alcance | Prioridad |
| ----- | ----- | ----- | ----- | ----- |
| RF-01 | El sistema debe permitir iniciar y cerrar sesión con correo y contraseña. | Todos | AL-01 | Alta |
| RF-02 | El sistema debe mostrar solo las opciones y datos permitidos al rol del usuario. | Todos | AL-01 | Alta |
| RF-03 | El sistema debe permitir registrar una solicitud indicando categoría, descripción y ubicación. | Estudiante | AL-02 | Alta |
| RF-04 | El sistema debe validar los campos obligatorios antes de registrar la solicitud y mostrar mensajes claros cuando falten datos. | Estudiante | AL-02 | Alta |
| RF-05 | El sistema debe asignar automáticamente a cada solicitud un código, la fecha de registro, el solicitante, la prioridad inicial y el estado Nuevo. | Sistema | AL-02 | Alta |
| RF-06 | El sistema debe mostrar al solicitante el listado de sus solicitudes con código, categoría, estado, prioridad y fecha. | Estudiante | AL-03 | Alta |
| RF-07 | El sistema debe mostrar el detalle de una solicitud con sus datos, responsable, estado actual e historial de estados. | Estudiante, Técnico, Supervisor | AL-03 | Alta |
| RF-08 | El sistema debe permitir añadir comentarios a una solicitud, registrando autor y fecha. | Estudiante, Técnico, Supervisor | AL-03 | Alta |
| RF-09 | El sistema debe mostrar al supervisor las solicitudes de su área, con filtros por estado, categoría y prioridad. | Supervisor | AL-04 | Alta |
| RF-10 | El sistema debe permitir al supervisor asignar o reasignar una solicitud a un técnico de su área. | Supervisor | AL-04 | Alta |
| RF-11 | El sistema debe permitir al supervisor ajustar la prioridad de una solicitud. | Supervisor | AL-04 | Alta |
| RF-12 | El sistema debe mostrar al técnico las solicitudes asignadas, ordenadas por prioridad y fecha. | Técnico | AL-04 | Alta |
| RF-13 | El sistema debe permitir al técnico cambiar el estado de una solicitud asignada a En proceso y a Resuelto. | Técnico | AL-04 | Alta |
| RF-14 | El sistema debe permitir al supervisor cerrar una solicitud resuelta o rechazar una solicitud indicando el motivo. | Supervisor | AL-04 | Alta |
| RF-15 | El sistema debe impedir los cambios de estado no permitidos por el ciclo de vida de la solicitud. | Sistema | AL-04 | Alta |
| RF-16 | El sistema debe mostrar un dashboard con solicitudes registradas, pendientes, atendidas, por categoría, por prioridad y por responsable, tiempo promedio de atención, porcentaje de resueltas y solicitudes vencidas. | Supervisor, Administrador | AL-05 | Alta |
| RF-17 | El sistema debe permitir filtrar los indicadores del dashboard por rango de fechas y área. | Supervisor, Administrador | AL-05 | Media |
| RF-18 | El sistema debe permitir crear, consultar, editar y desactivar usuarios, y asignarles un rol y un área. | Administrador | AL-06 | Alta |
| RF-19 | El sistema debe permitir gestionar categorías y áreas responsables, asociando cada categoría a un área. | Administrador | AL-06 | Alta |
| RF-20 | El sistema debe permitir gestionar prioridades y los nombres visibles de los estados. | Administrador | AL-06 | Media |
| RF-21 | El sistema debe permitir definir un tiempo máximo de atención (SLA) por prioridad o categoría y marcar las solicitudes vencidas o próximas a vencer. | Administrador, Sistema | AL-07 | Media |
| RF-22 | El sistema debe registrar cada cambio de una solicitud (campo, valor anterior, valor nuevo, usuario y fecha). | Sistema | AL-07 | Media |
| RF-23 | El sistema debe permitir exportar reportes de solicitudes e indicadores. | Supervisor, Administrador | — | Baja |
| RF-24 | El sistema debe permitir al solicitante responder una encuesta de satisfacción cuando su solicitud se cierra. | Estudiante | — | Baja |
| RF-25 | El sistema debe permitir consultar los espacios reservables y su disponibilidad por fecha y hora. | Todos | AL-08 | Alta |
| RF-26 | El sistema debe permitir registrar una reserva indicando espacio, fecha, hora de inicio, hora de fin y motivo; la reserva queda pendiente de aprobación. | Todos | AL-08 | Alta |
| RF-27 | El sistema debe impedir reservas solapadas o duplicadas y las que incumplan horario, duración, anticipación o capacidad. | Sistema | AL-08 | Alta |
| RF-28 | El sistema debe permitir al supervisor del área del espacio o al administrador aprobar o rechazar reservas pendientes, registrando responsable, fecha y motivo. | Supervisor, Administrador | AL-08 | Alta |
| RF-29 | El sistema debe permitir al solicitante consultar y cancelar sus reservas vigentes. | Todos | AL-08 | Alta |
| RF-30 | El sistema debe permitir administrar espacios, tipos de espacio, horarios y la política de reservas. | Administrador | AL-08 | Media |
