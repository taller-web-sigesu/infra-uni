# DISENIO-BD.md — Base de datos MySQL del Sistema de Servicios Universitarios

> **Proyecto:** Sistema Web Inteligente para la Gestión Integral de Servicios Universitarios (Gestal).
> **Motor:** MySQL 8.4.13 (imagen `mysql:8.4.13` de `compose.yaml`).
> **Base de datos:** `uni_services`.
> **Estado:** diseño propuesto, pendiente de implementación con Flyway en `backend-uni`.
> **Fuentes:** `docs/requirements/user-stories/HU-01` a `HU-29`, `docs/requirements/Gestal_Requisitos_Funcionales.md`, `docs/requirements/Gestal_Requisitos_No_Funcionales.md`, `docs/EPICS.md`, `docs/ARCHITECTURE.md`, `compose.yaml` y `docs/DOCKER.md`.
> **Última actualización:** 2026-11-11 (evidencias, auto-registro y restablecimiento de contraseña, [decisiones 01](docs/decisiones/decisiones-01.md)); 2026-11-12 (rol `DOCENTE`, [decisiones 02](docs/decisiones/decisiones-02.md)).

---

## 1. Resumen ejecutivo

El modelo cubre los siete módulos del sistema: autenticación y roles, registro y seguimiento de solicitudes, ciclo de vida y asignaciones, dashboard, administración de catálogos, SLA/auditoría/encuesta y reserva de ambientes.

La pieza central es `solicitudes`. A su alrededor se agrupan:

- **Seguridad:** `roles`, `usuarios`, `sesiones_usuario`.
- **Catálogos:** `areas`, `prioridades`, `categorias`, `estados_solicitud`, `transiciones_estado`, `politicas_sla`.
- **Ciclo de vida:** `historial_estados`, `asignaciones`, `comentarios`, `encuestas_satisfaccion`.
- **Soporte:** `auditoria_eventos`, `secuencias_codigo_solicitud`.
- **Evidencias:** `adjuntos_solicitud` (metadatos; el archivo vive en Supabase Storage).
- **Reservas:** `tipos_espacio`, `espacios`, `horarios_espacio`, `estados_reserva`, `politicas_reserva`, `reservas`, `historial_estados_reserva`, `secuencias_codigo_reserva`.

El diseño prioriza:

1. **Trazabilidad:** cada cambio de estado, asignación y campo relevante deja historial o auditoría.
2. **Integridad histórica:** los catálogos y usuarios se desactivan; no se eliminan físicamente.
3. **Reglas explícitas:** la máquina de estados vive en `transiciones_estado`, no en código hardcodeado.
4. **Consultas rápidas:** índices compuestos alineados con “mis solicitudes”, bandeja del área, bandeja del técnico, SLA y dashboard.
5. **Compatibilidad MySQL 8.4:** InnoDB, `utf8mb4`, checks nativos, columnas generadas e índices únicos.
6. **Reservas sin doble uso:** el solapamiento se controla en transacción con bloqueo de la fila del espacio y un índice compuesto de disponibilidad.

---

## 2. Alcance y fuentes

### 2.1. Historias cubiertas

| Épica | Historias | Necesidad principal |
| --- | --- | --- |
| EP-01 | HU-01, HU-02, HU-27 | Login/logout, roles, autorización y auto-registro pendiente de aprobación. |
| EP-02 | HU-03, HU-04, HU-05, HU-06, HU-26 | Registrar, listar, detallar, historiar, comentar y adjuntar evidencias. |
| EP-03 | HU-07, HU-08, HU-09, HU-10, HU-11 | Filtrar por área, asignar/reasignar, atender, cerrar y rechazar. |
| EP-04 | HU-12, HU-13, HU-14 | Indicadores, filtros y exportación. |
| EP-05 | HU-15, HU-16, HU-17, HU-28, HU-29 | Usuarios, aprobación de cuentas, restablecimiento de contraseña, áreas, categorías, prioridades y estados. |
| EP-06 | HU-18, HU-19, HU-20 | SLA, auditoría y encuesta de satisfacción. |
| EP-07 | HU-21, HU-22, HU-23, HU-24, HU-25 | Reservar ambientes, aprobar/rechazar y administrar espacios. |

### 2.2. Fuera de alcance del esquema

- **Archivos de evidencias:** el binario no se guarda en MySQL; vive en Supabase Storage (ADR-0004). La base solo guarda metadatos en `adjuntos_solicitud` (HU-26).
- **Notificaciones, correo, chat o tiempo real:** no aparecen en las HU aprobadas. El auto-registro y el restablecimiento de contraseña se resuelven sin correo (HU-27 a HU-29).
- **Datos personales reales:** los seeds solo contienen catálogos; no se insertan usuarios con contraseñas por defecto.
- **Reportes exportados:** HU-14 no requiere persistencia; se resuelve con consultas y descarga directa.

---

## 3. Decisiones de diseño

| # | Decisión | Justificación | Alternativa descartada |
| --- | --- | --- | --- |
| D-01 | Ciclo de vida de las HU: `Nuevo → Asignado → En proceso → Resuelto → Cerrado`, con `Rechazado` como final alternativo. | Las HU, RF-13, RF-14, RF-15 y los escenarios BDD son la fuente funcional. `ARCHITECTURE.md` se corrige para que coincida. | El ciclo `Registrada → En evaluación → Asignada → En atención → Resuelta → Cerrada` de la versión anterior de `ARCHITECTURE.md`. |
| D-02 | Identificadores en español `snake_case`. | Coherencia con el dominio, los documentos y el equipo; se corrige `ARCHITECTURE.md`. | Identificadores en inglés. |
| D-03 | Un rol por usuario (`usuarios.rol_id`). | HU-15 habla de “asignarles un rol y un área”; no se requiere multi-rol. | Tabla puente `usuarios_roles`. |
| D-04 | La solicitud guarda `area_id` como copia del área de la categoría. | HU-07 exige filtrar por área del supervisor; si la categoría cambia de área, la solicitud conserva el área con la que fue registrada. | Calcular el área siempre con `JOIN categorias`. |
| D-05 | La prioridad inicial se toma de `categorias.prioridad_predeterminada_id`. | HU-03 CA-03 y RF-05. | Prioridad fija global. |
| D-06 | La máquina de estados se define en `transiciones_estado` con rol y `requiere_motivo`. | RF-15 y HU-10/HU-11; evita `if` hardcodeados y permite administrar reglas. | Validar transiciones solo en el servicio. |
| D-07 | Una sola asignación activa por solicitud, garantizada con columna generada + índice único. | HU-08 y HU-09; evita dos técnicos activos por error. | Validación solo en aplicación. |
| D-08 | La reasignación conserva el estado actual. | Decisión del equipo: no se pierde el avance “En proceso”. | Volver a `Asignado` en cada reasignación. |
| D-09 | El SLA se congela en la solicitud (`politica_sla_id`, `fecha_limite_sla`, `fecha_aviso_sla`). | HU-18; cambiar una política no debe alterar solicitudes ya creadas. | Calcular el SLA siempre contra la política vigente. |
| D-10 | `historial_estados` es la línea de tiempo visible; `auditoria_eventos` es el registro de cumplimiento. | HU-05/HU-10 piden historial; HU-19/RF-22 piden campo, valor anterior y valor nuevo. | Usar solo auditoría para reconstruir la línea de tiempo. |
| D-11 | Catálogos y usuarios se desactivan (`activo = 0`), no se eliminan. | HU-15 y HU-16; preserva integridad histórica y evita romper FKs. | Borrado físico con `ON DELETE CASCADE`. |
| D-12 | `sesiones_usuario` permite revocar sesiones en logout. | HU-01 CA-04 exige invalidar la sesión activa. | JWT sin revocación del lado servidor. |
| D-13 | Fechas en `DATETIME(6)` UTC. | Evita el límite 2038 de `TIMESTAMP` y conserva microsegundos. | `TIMESTAMP`. |
| D-14 | PKs surrogate `BIGINT UNSIGNED`. | Consistencia con `Long` de JPA y margen para auditoría/historial. | PKs naturales o `INT UNSIGNED`. |
| D-15 | Reserva de ambientes como módulo separado de `solicitudes`. | Ciclo de vida, actores y datos difieren; evita mezclar tickets con reservas. | Reutilizar `solicitudes` con una categoría de reserva. |
| D-16 | Aprobación obligatoria: `PENDIENTE → CONFIRMADA` o `RECHAZADA`. | Controla el uso de los ambientes y deja trazabilidad de la decisión. | Confirmación automática si no hay conflicto. |
| D-17 | Franja por `fecha` + `hora_inicio` + `hora_fin`. | Flexibilidad para reservar parcialmente un día. | Franjas fijas de una hora o reserva por día completo. |
| D-18 | Solapamiento validado en servicio con `SELECT … FOR UPDATE` sobre `espacios`, más índice único de franja exacta. | MySQL no tiene exclusion constraints; el bloqueo serializa la validación concurrente. | Confiar solo en una consulta sin bloqueo. |
| D-19 | `espacios.area_id` nullable; aprueba el supervisor del área o el administrador; sin área, solo el administrador. | Encaja con el RBAC y la organización por áreas existente. | Aprobación centralizada únicamente por el administrador. |
| D-20 | Estados operativos `EN_CURSO` y `FINALIZADA` derivados en vista, no almacenados. | Evita procesos programados de transición; coherente con `vw_estado_sla`. | Job periódico que actualice estados. |
| D-21 | Historial dedicado `historial_estados_reserva` más `auditoria_eventos`. | Misma separación que `solicitudes`: línea de tiempo visible y registro de cumplimiento. | Usar solo auditoría para reconstruir la línea de tiempo. |
| D-22 | Catálogos `tipos_espacio` y `estados_reserva` en tablas, no `ENUM`. | El administrador los gestiona (HU-25) sin migraciones de esquema. | Columnas `ENUM` fijas. |
| D-23 | `usuarios.estado_cuenta` (`PENDIENTE`, `ACTIVA`, `RECHAZADA`) separado de `activo`. | HU-27 y HU-28: distinguir una cuenta por aprobar de una cuenta desactivada por el administrador. | Reutilizar `activo = 0` para las pendientes. |
| D-24 | `estado_cuenta` y `origen_registro` como `VARCHAR` con `CHECK`, no como catálogo. | Son conjuntos fijos que controla el código de autenticación; nadie los administra. | Tabla catálogo como en D-22. |
| D-25 | El restablecimiento por administrador reutiliza `hash_contrasena`, `debe_cambiar_contrasena = 1` y la revocación de `sesiones_usuario`; no hay tabla de tokens. | HU-29 y decisión D3: sin recuperación por correo. | Tokens de recuperación enviados por correo. |
| D-26 | Evidencias: metadatos en `adjuntos_solicitud` y archivo en un bucket privado de Supabase Storage; la fila se borra lógicamente (`eliminado_en`) y el objeto se borra del bucket. | HU-26 y RNF-19: no inflar MySQL ni los backups y conservar la trazabilidad. | Guardar el archivo como `BLOB` en MySQL. |
| D-27 | Rol `DOCENTE` con los mismos permisos que `ESTUDIANTE` (solicitante), sin área y creado solo por el administrador. | Decisiones 02: el docente registra solicitudes y reservas igual que el estudiante; distinguirlo sirve para reportes. | Política de reservas o prioridad propias por rol. |

---

## 4. Convenciones MySQL

| Elemento | Convención |
| --- | --- |
| Motor | `InnoDB` en todas las tablas. |
| Charset | `utf8mb4`. |
| Collation | `utf8mb4_0900_ai_ci` (nativa de MySQL 8.4, insensible a mayúsculas y acentos). |
| PK | `BIGINT UNSIGNED AUTO_INCREMENT`. Excepción: `secuencias_codigo_solicitud.anio`. |
| FKs | Mismo tipo que la PK referenciada; `ON DELETE RESTRICT ON UPDATE RESTRICT`. |
| Booleanos | `TINYINT UNSIGNED` con `CHECK (columna IN (0,1))`. |
| Fechas | `DATETIME(6)` en UTC. `CURRENT_TIMESTAMP(6)` para creación/actualización. |
| Textos | `VARCHAR` para datos acotados; `TEXT` para descripción, motivo y comentarios. |
| Nombres | Tablas y columnas en español `snake_case`; índices `uk_`, `idx_`, `fk_`, `chk_`. |
| Borrado | Lógico (`activo = 0`) en catálogos/usuarios; las solicitudes no se eliminan. |
| Migraciones | Flyway en `backend-uni/src/main/resources/db/migration/`, por ejemplo `V1__esquema_inicial.sql`, `V2__catalogos_semilla.sql`. |
| Zona horaria | Conexión JDBC en UTC (`connectionTimeZone=UTC`, `hibernate.jdbc.time_zone=UTC`). |
| Modo SQL | `STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION`. |

> **Nota sobre la collation:** la skill `mysql-best-practices` recomienda `utf8mb4_unicode_ci` como opción segura y compatible. Para MySQL 8.4 se elige `utf8mb4_0900_ai_ci` por rendimiento y por ser la nativa; si el equipo necesita compatibilidad con versiones anteriores, se cambia en una sola línea sin afectar el modelo.

---

## 5. Modelo entidad-relación

```mermaid
erDiagram
    roles ||--o{ usuarios : "rol"
    areas ||--o{ usuarios : "area"
    usuarios ||--o{ sesiones_usuario : "sesiones"
    usuarios ||--o{ usuarios : "revisa cuenta"

    areas ||--o{ categorias : "responsable"
    prioridades ||--o{ categorias : "prioridad por defecto"
    prioridades ||--o{ politicas_sla : "alcance"
    categorias ||--o{ politicas_sla : "alcance"

    estados_solicitud ||--o{ transiciones_estado : "origen"
    estados_solicitud ||--o{ transiciones_estado : "destino"
    roles ||--o{ transiciones_estado : "autoriza"

    usuarios ||--o{ solicitudes : "solicita"
    usuarios ||--o{ solicitudes : "atiende"
    categorias ||--o{ solicitudes : "clasifica"
    areas ||--o{ solicitudes : "deriva"
    prioridades ||--o{ solicitudes : "prioriza"
    estados_solicitud ||--o{ solicitudes : "estado actual"
    politicas_sla ||--o{ solicitudes : "aplica"

    solicitudes ||--o{ historial_estados : "historial"
    solicitudes ||--o{ asignaciones : "asignaciones"
    solicitudes ||--o{ comentarios : "comentarios"
    solicitudes ||--o{ encuestas_satisfaccion : "encuesta"
    solicitudes ||--o{ auditoria_eventos : "auditoria"
    solicitudes ||--o{ adjuntos_solicitud : "evidencias"
    usuarios ||--o{ adjuntos_solicitud : "sube"

    usuarios ||--o{ historial_estados : "cambia"
    usuarios ||--o{ asignaciones : "tecnico"
    usuarios ||--o{ asignaciones : "asigna"
    usuarios ||--o{ comentarios : "autor"
    usuarios ||--o{ encuestas_satisfaccion : "responde"
    usuarios ||--o{ auditoria_eventos : "actor"
    tipos_espacio ||--o{ espacios : "tipo"
    areas ||--o{ espacios : "responsable"
    espacios ||--o{ horarios_espacio : "horario"
    espacios ||--o{ reservas : "reserva"
    usuarios ||--o{ reservas : "solicita"
    usuarios ||--o{ reservas : "aprueba"
    usuarios ||--o{ reservas : "cancela"
    estados_reserva ||--o{ reservas : "estado actual"
    reservas ||--o{ historial_estados_reserva : "historial"
    usuarios ||--o{ historial_estados_reserva : "cambia"
```

---

## 6. Diccionario de datos

### 6.1. `roles`

Catálogo RBAC. Los códigos son estables; el nombre visible puede ajustarse sin romper la autorización.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(30)` | No | — | UK | `ESTUDIANTE`, `DOCENTE`, `TECNICO`, `SUPERVISOR`, `ADMINISTRADOR`. |
| `nombre` | `VARCHAR(60)` | No | — | UK | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Propósito del rol. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Habilitado/deshabilitado. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

### 6.2. `usuarios`

Cuenta de acceso. `area_id` es obligatorio para `TECNICO` y `SUPERVISOR` y queda `NULL` para `ESTUDIANTE` y `DOCENTE`; la regla se valida en la capa de servicio porque depende del rol. Solo puede iniciar sesión una cuenta con `activo = 1` y `estado_cuenta = 'ACTIVA'` (HU-27, HU-28).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `rol_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Rol del usuario. |
| `area_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Área responsable (técnico/supervisor). |
| `nombre_completo` | `VARCHAR(150)` | No | — | — | Nombre y apellidos. |
| `correo` | `VARCHAR(150)` | No | — | UK | Correo institucional, único e insensible a mayúsculas. |
| `hash_contrasena` | `VARCHAR(255)` | No | — | — | BCrypt/Argon2id; nunca texto plano. |
| `telefono` | `VARCHAR(20)` | Sí | `NULL` | — | Contacto opcional. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `estado_cuenta` | `VARCHAR(20)` | No | `'ACTIVA'` | IDX | `PENDIENTE`, `ACTIVA` o `RECHAZADA` (HU-27, HU-28). |
| `origen_registro` | `VARCHAR(20)` | No | `'ADMINISTRADOR'` | — | `ADMINISTRADOR` (HU-15) o `AUTO_REGISTRO` (HU-27). |
| `revisado_por_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Administrador que aprobó o rechazó la cuenta. |
| `revisado_en` | `DATETIME(6)` | Sí | `NULL` | — | Fecha de la aprobación o el rechazo. |
| `motivo_rechazo` | `TEXT` | Sí | `NULL` | — | Obligatorio cuando `estado_cuenta = 'RECHAZADA'`. |
| `debe_cambiar_contrasena` | `TINYINT UNSIGNED` | No | `1` | — | Fuerza el cambio de la contraseña inicial o temporal (HU-15, HU-29). En auto-registro vale `0`. |
| `ultimo_acceso_en` | `DATETIME(6)` | Sí | `NULL` | — | Último login exitoso. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `uk_usuarios_correo`, `idx_usuarios_rol_activo (rol_id, activo)`, `idx_usuarios_area_activo (area_id, activo)`, `idx_usuarios_estado_cuenta (estado_cuenta, creado_en)` para la bandeja de cuentas pendientes.

### 6.3. `sesiones_usuario`

Sesiones emitidas y revocadas. Se guarda el hash del token, nunca el token en claro.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `usuario_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Usuario autenticado. |
| `hash_token` | `CHAR(64)` | No | — | UK | SHA-256 hex del token/sesión. |
| `emitida_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Inicio de sesión. |
| `expira_en` | `DATETIME(6)` | No | — | — | Expiración. |
| `revocada_en` | `DATETIME(6)` | Sí | `NULL` | IDX | Logout o revocación. |
| `ip` | `VARCHAR(45)` | Sí | `NULL` | — | IPv4/IPv6. |
| `agente_usuario` | `VARCHAR(255)` | Sí | `NULL` | — | Navegador/cliente. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |

### 6.4. `areas`

Áreas responsables de atender categorías.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(50)` | No | — | UK | Código estable. |
| `nombre` | `VARCHAR(120)` | No | — | UK | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Alcance del área. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

### 6.5. `prioridades`

Catálogo configurable por el administrador (HU-17). `nivel` define el orden de urgencia.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(30)` | No | — | UK | `BAJA`, `MEDIA`, `ALTA`, `CRITICA`. |
| `nombre` | `VARCHAR(60)` | No | — | UK | Nombre visible. |
| `nivel` | `TINYINT UNSIGNED` | No | — | UK | 1 = menor urgencia; mayor = más urgente. |
| `color` | `CHAR(7)` | Sí | `NULL` | — | Hex `#RRGGBB` para la UI. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

### 6.6. `categorias`

Cada categoría pertenece obligatoriamente a un área y define la prioridad inicial de la solicitud (HU-03, HU-16).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `area_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Área responsable. |
| `prioridad_predeterminada_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Prioridad inicial. |
| `codigo` | `VARCHAR(50)` | No | — | UK | Código estable. |
| `nombre` | `VARCHAR(120)` | No | — | UK | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Alcance de la categoría. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

### 6.7. `estados_solicitud`

Estados del ciclo de vida. `codigo` es inmutable; `nombre` es el texto visible que el administrador puede personalizar (HU-17).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(30)` | No | — | UK | `NUEVO`, `ASIGNADO`, `EN_PROCESO`, `RESUELTO`, `CERRADO`, `RECHAZADO`. |
| `nombre` | `VARCHAR(60)` | No | — | — | Nombre visible editable. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Significado del estado. |
| `es_final` | `TINYINT UNSIGNED` | No | `0` | IDX | 1 para `CERRADO` y `RECHAZADO`. |
| `orden` | `TINYINT UNSIGNED` | No | — | UK | Orden visual. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

### 6.8. `transiciones_estado`

Matriz de transiciones permitidas por rol. Implementa RF-15 y el motivo obligatorio del rechazo.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `estado_origen_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Estado actual. |
| `estado_destino_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Estado siguiente. |
| `rol_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Rol autorizado. |
| `requiere_motivo` | `TINYINT UNSIGNED` | No | `0` | — | 1 para rechazo. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Permite desactivar una regla. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índice único:** `uk_transiciones (estado_origen_id, estado_destino_id, rol_id)`.

### 6.9. `politicas_sla`

Tiempo máximo de atención por prioridad **o** por categoría (HU-18). Exactamente una de las dos columnas de alcance debe estar informada.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `prioridad_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Alcance por prioridad. |
| `categoria_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Alcance por categoría. |
| `horas_objetivo` | `SMALLINT UNSIGNED` | No | — | — | Horas para resolver. |
| `horas_aviso` | `SMALLINT UNSIGNED` | No | — | — | Horas antes del límite para marcar “por vencer”. |
| `vigente_desde` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Inicio de vigencia. |
| `vigente_hasta` | `DATETIME(6)` | Sí | `NULL` | — | Fin de vigencia; `NULL` = vigente. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Precedencia:** si existe una política activa para la categoría, se usa esa; si no, se usa la de la prioridad; si no hay ninguna, la solicitud queda sin SLA (`fecha_limite_sla = NULL`).

### 6.10. `solicitudes`

Entidad central. `area_id` es una copia del área de la categoría al momento del registro; `responsable_actual_id` se actualiza con la asignación vigente.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(20)` | No | — | UK | `SOL-2026-000001`. |
| `solicitante_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Estudiante o docente que registra. |
| `categoria_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Categoría. |
| `area_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Área derivada de la categoría. |
| `prioridad_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Prioridad actual. |
| `estado_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Estado actual. |
| `responsable_actual_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Técnico asignado vigente. |
| `politica_sla_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Política aplicada al crear. |
| `ubicacion` | `VARCHAR(255)` | No | — | — | Lugar del problema. |
| `descripcion` | `TEXT` | No | — | — | Detalle del requerimiento. |
| `motivo_rechazo` | `TEXT` | Sí | `NULL` | — | Obligatorio al rechazar. |
| `fecha_limite_sla` | `DATETIME(6)` | Sí | `NULL` | IDX | Vencimiento calculado. |
| `fecha_aviso_sla` | `DATETIME(6)` | Sí | `NULL` | — | Umbral “por vencer”. |
| `resuelta_en` | `DATETIME(6)` | Sí | `NULL` | — | Paso a `RESUELTO`. |
| `cerrada_en` | `DATETIME(6)` | Sí | `NULL` | — | Paso a `CERRADO`. |
| `version_fila` | `INT UNSIGNED` | No | `0` | — | Bloqueo optimista JPA. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Registro. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `uk_solicitudes_codigo`, `idx_solicitudes_solicitante (solicitante_id, creado_en)`, `idx_solicitudes_area_estado_prioridad (area_id, estado_id, prioridad_id, creado_en)`, `idx_solicitudes_responsable (responsable_actual_id, estado_id, prioridad_id, creado_en)`, `idx_solicitudes_categoria (categoria_id, creado_en)`, `idx_solicitudes_sla (fecha_limite_sla, estado_id)`, `idx_solicitudes_creado (creado_en)`.

### 6.11. `historial_estados`

Línea de tiempo de estados. En el alta, `estado_origen_id` es `NULL` y `estado_destino_id` es `NUEVO`.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `solicitud_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Solicitud. |
| `estado_origen_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Estado anterior; `NULL` en el alta. |
| `estado_destino_id` | `BIGINT UNSIGNED` | No | — | FK | Estado nuevo. |
| `cambiado_por_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Usuario que ejecuta. |
| `motivo` | `TEXT` | Sí | `NULL` | — | Motivo de rechazo/cierre o nota. |
| `cambiado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Fecha del cambio. |

**Índice:** `idx_historial_solicitud (solicitud_id, cambiado_en)`.

### 6.12. `asignaciones`

Historial de asignaciones. `finalizada_en = NULL` identifica la asignación vigente.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `solicitud_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Solicitud. |
| `tecnico_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Técnico responsable. |
| `asignado_por_id` | `BIGINT UNSIGNED` | No | — | FK | Supervisor que asigna. |
| `asignada_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Inicio. |
| `finalizada_en` | `DATETIME(6)` | Sí | `NULL` | IDX | Fin de la asignación. |
| `motivo_fin` | `VARCHAR(255)` | Sí | `NULL` | — | Reasignación, cierre, etc. |
| `solicitud_activa_id` | `BIGINT UNSIGNED` | Sí | Generada | UK | `solicitud_id` si está activa; `NULL` si finalizó. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |

**Índices:** `uk_asignaciones_activa (solicitud_activa_id)`, `idx_asignaciones_tecnico (tecnico_id, finalizada_en)`, `idx_asignaciones_solicitud (solicitud_id, asignada_en)`.

### 6.13. `comentarios`

Comentarios de seguimiento (HU-06). El autor se registra automáticamente.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `solicitud_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Solicitud. |
| `autor_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Autor. |
| `contenido` | `TEXT` | No | — | — | Texto no vacío. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Publicación. |
| `editado_en` | `DATETIME(6)` | Sí | `NULL` | — | Última edición. |

**Índice:** `idx_comentarios_solicitud (solicitud_id, creado_en)`.

### 6.14. `encuestas_satisfaccion`

Una encuesta por solicitud cerrada (HU-20).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `solicitud_id` | `BIGINT UNSIGNED` | No | — | FK, UK | Solicitud cerrada. |
| `respondida_por_id` | `BIGINT UNSIGNED` | No | — | FK | Solicitante. |
| `calificacion` | `TINYINT UNSIGNED` | No | — | — | 1 a 5. |
| `comentario` | `TEXT` | Sí | `NULL` | — | Comentario libre. |
| `respondida_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Fecha. |

### 6.15. `auditoria_eventos`

Registro de cumplimiento (HU-19/RF-22). No sustituye al historial de estados: lo complementa.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `entidad` | `VARCHAR(60)` | No | — | IDX | Tabla afectada. |
| `entidad_id` | `BIGINT UNSIGNED` | No | — | IDX | PK del registro afectado. |
| `solicitud_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Solicitud relacionada, si aplica. |
| `accion` | `VARCHAR(30)` | No | — | — | `CREAR`, `ACTUALIZAR`, `CAMBIO_ESTADO`, `ASIGNACION`, `COMENTARIO`, `LOGIN`, `LOGOUT`, `REGISTRO`, `APROBAR_CUENTA`, `RECHAZAR_CUENTA`, `RESTABLECER_CONTRASENA`, `ADJUNTAR`, `ELIMINAR_ADJUNTO`. |
| `campo` | `VARCHAR(80)` | Sí | `NULL` | — | Campo modificado. |
| `valor_anterior` | `TEXT` | Sí | `NULL` | — | Valor previo legible. |
| `valor_nuevo` | `TEXT` | Sí | `NULL` | — | Valor nuevo legible. |
| `actor_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Usuario; `NULL` para procesos del sistema. |
| `ocurrido_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Fecha. |
| `id_correlacion` | `CHAR(36)` | Sí | `NULL` | — | UUID para agrupar una operación. |
| `ip` | `VARCHAR(45)` | Sí | `NULL` | — | Origen. |

**Índices:** `idx_auditoria_solicitud (solicitud_id, ocurrido_en)`, `idx_auditoria_entidad (entidad, entidad_id, ocurrido_en)`, `idx_auditoria_actor (actor_id, ocurrido_en)`.

### 6.16. `secuencias_codigo_solicitud`

Secuencia atómica por año para generar códigos legibles sin colisiones.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `anio` | `SMALLINT UNSIGNED` | No | — | PK | Año de la secuencia. |
| `ultimo_valor` | `INT UNSIGNED` | No | `0` | — | Último consecutivo usado. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última actualización. |


### 6.17. `tipos_espacio`

Catálogo de tipos de ambiente. `codigo` es estable; `nombre` es el texto visible y administrable (HU-25).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(40)` | No | — | UK | `AULA`, `LABORATORIO`, `SALA_ESTUDIO`, `AUDITORIO`, `SALA_REUNIONES`, `OTRO`. |
| `nombre` | `VARCHAR(80)` | No | — | UK | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Alcance del tipo. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Checks:** `chk_tipos_espacio_activo CHECK (activo IN (0,1))`.

### 6.18. `espacios`

Ambientes reservables. `area_id` define quién aprueba: el supervisor del área o el administrador; si es `NULL`, solo el administrador. `pabellon` usa cadena vacía por defecto para que el índice único funcione aunque no se informe.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `tipo_espacio_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Tipo de ambiente. |
| `area_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Área responsable de aprobar y mantener. |
| `codigo` | `VARCHAR(40)` | No | — | UK | Código estable, por ejemplo `LAB-204`. |
| `nombre` | `VARCHAR(120)` | No | — | UK con pabellón | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Detalle del ambiente. |
| `pabellon` | `VARCHAR(60)` | No | `''` | parte de UK | Pabellón o edificio. |
| `piso` | `VARCHAR(20)` | Sí | `NULL` | — | Nivel o piso. |
| `ubicacion_detallada` | `VARCHAR(255)` | Sí | `NULL` | — | Referencia adicional. |
| `capacidad` | `SMALLINT UNSIGNED` | No | — | CHECK | Aforo máximo; debe ser mayor que cero. |
| `requiere_aprobacion` | `TINYINT UNSIGNED` | No | `1` | — | 1 = la reserva queda pendiente (EP-07 exige 1); 0 reservado para una política futura. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica; no se elimina con reservas. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `uk_espacios_codigo`, `uk_espacios_nombre_pabellon (nombre, pabellon)`, `idx_espacios_tipo_activo (tipo_espacio_id, activo)`, `idx_espacios_area_activo (area_id, activo)`, `idx_espacios_pabellon_activo (pabellon, activo)`.

**Checks:** `chk_espacios_capacidad CHECK (capacidad > 0)`, `chk_espacios_requiere_aprobacion CHECK (requiere_aprobacion IN (0,1))`, `chk_espacios_activo CHECK (activo IN (0,1))`.

### 6.19. `horarios_espacio`

Horario semanal de atención. Un día sin fila se considera cerrado.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `espacio_id` | `BIGINT UNSIGNED` | No | — | FK, UK compuesto | Espacio. |
| `dia_semana` | `TINYINT UNSIGNED` | No | — | UK compuesto | 1 = lunes … 7 = domingo (ISO-8601). |
| `hora_apertura` | `TIME` | No | — | — | Inicio de atención. |
| `hora_cierre` | `TIME` | No | — | — | Fin de atención; debe ser mayor que la apertura. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | — | Permite desactivar el horario sin borrarlo. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `uk_horarios_espacio_dia (espacio_id, dia_semana)`.

**Checks:** `chk_horarios_dia CHECK (dia_semana BETWEEN 1 AND 7)`, `chk_horarios_horas CHECK (hora_cierre > hora_apertura)`, `chk_horarios_activo CHECK (activo IN (0,1))`.

### 6.20. `estados_reserva`

Estados del ciclo de vida de una reserva. `codigo` es inmutable; `nombre` es visible.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(30)` | No | — | UK | `PENDIENTE`, `CONFIRMADA`, `RECHAZADA`, `CANCELADA`. |
| `nombre` | `VARCHAR(60)` | No | — | — | Nombre visible. |
| `descripcion` | `VARCHAR(255)` | Sí | `NULL` | — | Significado del estado. |
| `es_final` | `TINYINT UNSIGNED` | No | `0` | IDX | 1 para `RECHAZADA` y `CANCELADA`. |
| `orden` | `TINYINT UNSIGNED` | No | — | UK | Orden visual. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | — | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Checks:** `chk_estados_reserva_final CHECK (es_final IN (0,1))`, `chk_estados_reserva_activo CHECK (activo IN (0,1))`.

### 6.21. `politicas_reserva`

Política vigente de reservas. Se guarda una sola fila activa; los cambios se aplican a reservas nuevas.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `duracion_minima_minutos` | `SMALLINT UNSIGNED` | No | `30` | — | Duración mínima de una reserva. |
| `duracion_maxima_minutos` | `SMALLINT UNSIGNED` | No | `240` | — | Duración máxima. |
| `dias_anticipacion_maxima` | `SMALLINT UNSIGNED` | No | `30` | — | Días hacia adelante en que se puede reservar. |
| `horas_anticipacion_minima` | `SMALLINT UNSIGNED` | No | `1` | — | Antelación mínima antes del inicio. |
| `max_reservas_activas_por_dia` | `TINYINT UNSIGNED` | No | `2` | — | Límite por usuario y día. |
| `vigente_desde` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Inicio de vigencia. |
| `vigente_hasta` | `DATETIME(6)` | Sí | `NULL` | — | Fin de vigencia; `NULL` = vigente. |
| `activo` | `TINYINT UNSIGNED` | No | `1` | IDX | Alta/baja lógica. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Alta. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `idx_politicas_reserva_vigente (activo, vigente_desde)`.

**Checks:** `chk_politicas_reserva_duracion CHECK (duracion_minima_minutos > 0 AND duracion_maxima_minutos >= duracion_minima_minutos)`, `chk_politicas_reserva_vigencia CHECK (vigente_hasta IS NULL OR vigente_hasta > vigente_desde)`, `chk_politicas_reserva_activo CHECK (activo IN (0,1))`.

### 6.22. `reservas`

Entidad central de EP-07. Una reserva ocupa una franja de un espacio y pasa por aprobación.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `codigo` | `VARCHAR(20)` | No | — | UK | `RES-2026-000001`. |
| `espacio_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Ambiente reservado. |
| `solicitante_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Usuario que registra. |
| `estado_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Estado actual. |
| `fecha` | `DATE` | No | — | IDX compuesto | Día de la reserva. |
| `hora_inicio` | `TIME` | No | — | IDX compuesto | Inicio de la franja. |
| `hora_fin` | `TIME` | No | — | — | Fin de la franja; debe ser posterior al inicio. |
| `motivo` | `VARCHAR(255)` | No | — | — | Motivo de la reserva; no vacío. |
| `num_asistentes` | `SMALLINT UNSIGNED` | Sí | `NULL` | — | Asistentes previstos; no supera la capacidad. |
| `aprobada_por_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Aprobador; se llena solo al aprobar. |
| `aprobada_en` | `DATETIME(6)` | Sí | `NULL` | — | Fecha de aprobación. |
| `motivo_rechazo` | `TEXT` | Sí | `NULL` | — | Obligatorio al rechazar. |
| `cancelada_por_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK, IDX | Usuario que cancela. |
| `cancelada_en` | `DATETIME(6)` | Sí | `NULL` | — | Fecha de cancelación. |
| `version_fila` | `INT UNSIGNED` | No | `0` | — | Bloqueo optimista JPA. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Registro. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última modificación. |

**Índices:** `uk_reservas_codigo`, `uk_reservas_franja_exacta (espacio_id, fecha, hora_inicio, estado_id)`, `idx_reservas_disponibilidad (espacio_id, fecha, estado_id, hora_inicio, hora_fin)`, `idx_reservas_solicitante (solicitante_id, fecha)`, `idx_reservas_estado_fecha (estado_id, fecha)`, `idx_reservas_aprobador (aprobada_por_id, aprobada_en)`.

**Checks:** `chk_reservas_horas CHECK (hora_fin > hora_inicio)`, `chk_reservas_motivo CHECK (CHAR_LENGTH(TRIM(motivo)) > 0)`, `chk_reservas_asistentes CHECK (num_asistentes IS NULL OR num_asistentes > 0)`, `chk_reservas_aprobacion CHECK ((aprobada_por_id IS NULL AND aprobada_en IS NULL) OR (aprobada_por_id IS NOT NULL AND aprobada_en IS NOT NULL))`.

> **Solapamiento:** MySQL no ofrece exclusion constraints. La aplicación bloquea la fila del espacio con `SELECT … FOR UPDATE`, consulta las reservas activas que se cruzan y recién entonces inserta o aprueba. `uk_reservas_franja_exacta` es la segunda barrera contra duplicados exactos en el mismo estado; incluye `estado_id` para no bloquear una franja que quedó cancelada o rechazada.

### 6.23. `historial_estados_reserva`

Línea de tiempo de la reserva. En el alta, `estado_origen_id` es `NULL` y `estado_destino_id` es `PENDIENTE`.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `reserva_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Reserva. |
| `estado_origen_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Estado anterior; `NULL` en el alta. |
| `estado_destino_id` | `BIGINT UNSIGNED` | No | — | FK | Estado nuevo. |
| `cambiado_por_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Usuario que ejecuta. |
| `motivo` | `TEXT` | Sí | `NULL` | — | Motivo de rechazo/cancelación o nota. |
| `cambiado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Fecha del cambio. |

**Índices:** `idx_historial_reserva (reserva_id, cambiado_en)`, `idx_historial_reserva_origen (estado_origen_id)`, `idx_historial_reserva_destino (estado_destino_id)`, `idx_historial_reserva_usuario (cambiado_por_id)`.

### 6.24. `secuencias_codigo_reserva`

Secuencia atómica por año para generar `RES-AAAA-NNNNNN` sin colisiones.

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `anio` | `SMALLINT UNSIGNED` | No | — | PK | Año de la secuencia. |
| `ultimo_valor` | `INT UNSIGNED` | No | `0` | — | Último consecutivo usado. |
| `actualizado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | — | Última actualización. |

### 6.25. `adjuntos_solicitud`

Metadatos de las evidencias de una solicitud (HU-26). El archivo vive fuera de MySQL: en Supabase Storage (staging y producción) o en un volumen Docker (local).

| Columna | Tipo | Nulo | Default | Clave/Índice | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | No | `AUTO_INCREMENT` | PK | Identificador. |
| `solicitud_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Solicitud a la que pertenece. |
| `autor_id` | `BIGINT UNSIGNED` | No | — | FK, IDX | Usuario que subió el archivo. |
| `nombre_original` | `VARCHAR(255)` | No | — | — | Nombre mostrado al usuario; nunca se usa como ruta. |
| `proveedor_almacenamiento` | `VARCHAR(20)` | No | `'SUPABASE'` | — | `SUPABASE` o `LOCAL`. |
| `clave_objeto` | `VARCHAR(500)` | No | — | UK | Ruta en el bucket: `solicitudes/{solicitud_id}/{uuid}.{ext}`. |
| `tipo_mime` | `VARCHAR(100)` | No | — | — | `image/jpeg`, `image/png` o `application/pdf`, detectado por contenido. |
| `tamano_bytes` | `INT UNSIGNED` | No | — | — | De 1 byte a 5 MB (5 242 880 bytes). |
| `hash_sha256` | `CHAR(64)` | No | — | — | Integridad del archivo. |
| `creado_en` | `DATETIME(6)` | No | `CURRENT_TIMESTAMP(6)` | IDX | Fecha de carga. |
| `eliminado_en` | `DATETIME(6)` | Sí | `NULL` | IDX | Borrado lógico; `NULL` si está vigente. |
| `eliminado_por_id` | `BIGINT UNSIGNED` | Sí | `NULL` | FK | Usuario que la eliminó. |

**Índices:** `uk_adjuntos_clave_objeto`, `idx_adjuntos_solicitud (solicitud_id, eliminado_en, creado_en)`, `idx_adjuntos_autor (autor_id)`.

---

## 7. Reglas de integridad y negocio

### 7.1. Ciclo de vida

```text
NUEVO ──asignar──► ASIGNADO ──iniciar──► EN_PROCESO ──resolver──► RESUELTO ──cerrar──► CERRADO
  │                    │                       │
  └────rechazar───────┴───────rechazar────────┴──► RECHAZADO
```

Matriz inicial (roles: 2 = Técnico, 3 = Supervisor):

| Origen | Destino | Rol | ¿Motivo? | Historia |
| --- | --- | --- | --- | --- |
| `NUEVO` | `ASIGNADO` | Supervisor | No | HU-08, RF-10 |
| `NUEVO` | `RECHAZADO` | Supervisor | Sí | HU-11, RF-14 |
| `ASIGNADO` | `EN_PROCESO` | Técnico | No | HU-10, RF-13 |
| `ASIGNADO` | `RECHAZADO` | Supervisor | Sí | HU-11, RF-14 |
| `EN_PROCESO` | `RESUELTO` | Técnico | No | HU-10, RF-13 |
| `EN_PROCESO` | `RECHAZADO` | Supervisor | Sí | HU-11, RF-14 |
| `RESUELTO` | `CERRADO` | Supervisor | No | HU-11, RF-14 |

Reglas adicionales:

- `CERRADO` y `RECHAZADO` son terminales: no admiten nuevas transiciones ni reasignaciones.
- El técnico solo puede cambiar el estado de una solicitud asignada a él y solo `ASIGNADO → EN_PROCESO` y `EN_PROCESO → RESUELTO`.
- El supervisor no puede saltar de `ASIGNADO` a `RESUELTO`; debe pasar por `EN_PROCESO` (HU-10, escenario 10.2).
- La reasignación no cambia el estado; finaliza la asignación vigente e inserta una nueva.
- La asignación desde `NUEVO` cambia el estado a `ASIGNADO` en la misma transacción y deja fila en `historial_estados`.

### 7.2. Asignaciones

- Solo puede existir **una** fila con `finalizada_en IS NULL` por solicitud; lo garantiza `uk_asignaciones_activa`.
- Al reasignar: `UPDATE asignaciones SET finalizada_en = UTC_TIMESTAMP(6), motivo_fin = 'REASIGNACION' WHERE solicitud_id = ? AND finalizada_en IS NULL;` y luego insertar la nueva.
- `solicitudes.responsable_actual_id` debe coincidir con `asignaciones.tecnico_id` de la asignación activa.
- El técnico debe pertenecer al área de la solicitud y estar activo; se valida en servicio.

### 7.3. SLA

Al crear la solicitud:

1. Buscar política activa por `categoria_id`; si no existe, por `prioridad_id`.
2. Guardar `politica_sla_id`.
3. Calcular `fecha_limite_sla = UTC_TIMESTAMP(6) + INTERVAL horas_objetivo HOUR`.
4. Calcular `fecha_aviso_sla = fecha_limite_sla - INTERVAL horas_aviso HOUR`.

Estados derivados (vista `vw_estado_sla`):

- `CERRADA`: la solicitud está en un estado final.
- `SIN_SLA`: no se aplicó política.
- `VENCIDA`: `UTC_TIMESTAMP(6) > fecha_limite_sla` y no es final.
- `POR_VENCER`: `UTC_TIMESTAMP(6) >= fecha_aviso_sla` y aún no vence.
- `EN_PLAZO`: el resto.

### 7.4. Rechazo

- El supervisor debe escribir `solicitudes.motivo_rechazo` antes de ejecutar la transición.
- La transición correspondiente tiene `requiere_motivo = 1`.
- El motivo se copia también en `historial_estados.motivo` para que el solicitante lo vea en la línea de tiempo.
- No se permite rechazar una solicitud ya `CERRADA` o `RECHAZADA`.

### 7.5. Auditoría

- Cada operación de escritura relevante genera una fila en `auditoria_eventos` dentro de la misma transacción.
- Para cambios de estado se registra además `historial_estados`.
- `valor_anterior` y `valor_nuevo` guardan valores legibles (por ejemplo, `NUEVO` → `ASIGNADO`), no solo IDs.
- No se registran tokens, contraseñas ni datos sensibles.

### 7.6. Encuesta

- Solo el solicitante puede responder.
- Solo cuando `solicitudes.estado_id` corresponde a `CERRADO`.
- Una sola respuesta por solicitud (`uk_encuestas_solicitud`).
- `calificacion` entre 1 y 5.

### 7.7. Generación del código

La aplicación ejecuta, dentro de la transacción de alta:

```sql
SET @anio = YEAR(UTC_TIMESTAMP());

INSERT INTO secuencias_codigo_solicitud (anio, ultimo_valor)
VALUES (@anio, LAST_INSERT_ID(1))
ON DUPLICATE KEY UPDATE ultimo_valor = LAST_INSERT_ID(ultimo_valor + 1);

SELECT CONCAT('SOL-', @anio, '-', LPAD(LAST_INSERT_ID(), 6, '0')) AS codigo;
```

`LAST_INSERT_ID(expr)` es atómico por conexión y evita códigos duplicados en concurrencia.


### 7.8. Reservas de ambientes

Máquina de estados:

```text
PENDIENTE ──aprobar──► CONFIRMADA ──cancelar──► CANCELADA
    │                                                  ▲
    ├──rechazar (motivo)──► RECHAZADA                  │
    └──cancelar────────────────────────────────────────┘
```

| Origen | Destino | Rol | ¿Motivo? | Historia |
| --- | --- | --- | --- | --- |
| `PENDIENTE` | `CONFIRMADA` | Supervisor del área / Administrador | No | HU-23, RF-28 |
| `PENDIENTE` | `RECHAZADA` | Supervisor del área / Administrador | Sí | HU-23, RF-28 |
| `PENDIENTE` | `CANCELADA` | Solicitante / Administrador | No | HU-24, RF-29 |
| `CONFIRMADA` | `CANCELADA` | Solicitante / Administrador | No | HU-24, RF-29 |

Reglas:

- `RECHAZADA` y `CANCELADA` son terminales: no admiten nuevas transiciones.
- No puede haber solapamiento para un mismo `espacio_id` + `fecha` entre reservas `PENDIENTE` o `CONFIRMADA`. Hay conflicto cuando `nueva.hora_inicio < existente.hora_fin AND nueva.hora_fin > existente.hora_inicio`.
- La validación se ejecuta dentro de una transacción: `SELECT id FROM espacios WHERE id = ? FOR UPDATE`, luego la consulta de solapamiento y finalmente el `INSERT` o la aprobación. `uk_reservas_franja_exacta` es la segunda barrera. Incluye `estado_id` para no bloquear una franja liberada por cancelación o rechazo.
- Duración, anticipación, horario y límite diario se toman de la `politicas_reserva` activa. La fecha pasada se valida en servicio porque un `CHECK` de MySQL no puede usar `CURRENT_DATE`.
- `num_asistentes`, si se informa, debe ser menor o igual a `espacios.capacidad`.
- Al aprobar se revalida el solapamiento. Un aprobador no puede aprobar su propia reserva (segregación de funciones).
- La cancelación solo procede antes de `fecha + hora_inicio`.
- Toda transición inserta en `historial_estados_reserva` y en `auditoria_eventos` con `entidad = 'reservas'`.
- El estado operativo (`PROXIMA`, `EN_CURSO`, `FINALIZADA`) se calcula en `vw_reservas_operativas`; no se persiste.

### 7.9. Cuentas y contraseñas

- El auto-registro (HU-27) crea la cuenta con el rol `ESTUDIANTE`, `area_id = NULL`, `estado_cuenta = 'PENDIENTE'`, `origen_registro = 'AUTO_REGISTRO'` y `debe_cambiar_contrasena = 0`. El rol que envíe el cliente se ignora. Las cuentas `DOCENTE` solo las crea el administrador (HU-15).
- Solo se aceptan correos que terminan exactamente en `@unmsm.edu.pe` (sin subdominios), comparados sin distinguir mayúsculas. El valor se lee de una variable de entorno para poder cambiarlo sin tocar código. Un correo ya registrado, en cualquier estado, no puede volver a registrarse.
- `PENDIENTE → ACTIVA` (aprobar) o `PENDIENTE → RECHAZADA` (rechazar con motivo) solo los ejecuta el administrador (HU-28); se guardan `revisado_por_id` y `revisado_en`. `RECHAZADA` es terminal salvo que el administrador la apruebe después.
- Las cuentas creadas por el administrador (HU-15) nacen `ACTIVA` con `origen_registro = 'ADMINISTRADOR'`.
- El login exige `activo = 1` y `estado_cuenta = 'ACTIVA'`. Con cuenta pendiente o rechazada responde un mensaje claro sin emitir sesión.
- El restablecimiento (HU-29) reemplaza `hash_contrasena` por el de una contraseña temporal aleatoria, pone `debe_cambiar_contrasena = 1` y marca `revocada_en` en todas las sesiones vigentes, en una sola transacción. La contraseña temporal no se guarda ni se registra.
- Cada registro, aprobación, rechazo y restablecimiento inserta una fila en `auditoria_eventos` con `entidad = 'usuarios'`.

### 7.10. Evidencias

- Pueden adjuntar el solicitante, el técnico con asignación activa y el supervisor del área, mientras la solicitud no esté `CERRADO` ni `RECHAZADO`.
- Máximo 5 evidencias vigentes (`eliminado_en IS NULL`) por solicitud. La cuenta se valida en servicio con `SELECT … FOR UPDATE` sobre la fila de `solicitudes` para evitar carreras.
- Tipo (`image/jpeg`, `image/png`, `application/pdf`) y tamaño (≤ 5 MB) se validan en el backend por contenido; los `CHECK` son la segunda barrera.
- Orden de escritura: se sube el objeto al almacenamiento y luego se inserta la fila. Si el `INSERT` falla, se borra el objeto. Al eliminar, se marca `eliminado_en` y `eliminado_por_id` y se borra el objeto.
- Solo el autor elimina su evidencia, y solo con la solicitud abierta. Ver y descargar exige poder ver la solicitud (misma regla que HU-05).
- La descarga usa una URL firmada de Supabase con vigencia de 5 minutos, generada por el backend. El bucket es privado y el frontend nunca recibe la clave de servicio.
- Cada carga y eliminación inserta en `auditoria_eventos` con `entidad = 'adjuntos_solicitud'` y la `solicitud_id` correspondiente.

---

## 8. Índices y rendimiento

| Índice | Tabla | Columnas | Consulta que soporta |
| --- | --- | --- | --- |
| `uk_usuarios_correo` | `usuarios` | `correo` | Login y unicidad. |
| `idx_usuarios_rol_activo` | `usuarios` | `rol_id, activo` | Listado de usuarios por rol. |
| `idx_usuarios_area_activo` | `usuarios` | `area_id, activo` | Técnicos/supervisores de un área. |
| `idx_categorias_area_activo` | `categorias` | `area_id, activo` | Catálogo por área. |
| `idx_solicitudes_solicitante` | `solicitudes` | `solicitante_id, creado_en` | “Mis solicitudes” paginado. |
| `idx_solicitudes_area_estado_prioridad` | `solicitudes` | `area_id, estado_id, prioridad_id, creado_en` | Bandeja del supervisor con filtros. |
| `idx_solicitudes_responsable` | `solicitudes` | `responsable_actual_id, estado_id, prioridad_id, creado_en` | Bandeja del técnico ordenada por prioridad/fecha. |
| `idx_solicitudes_categoria` | `solicitudes` | `categoria_id, creado_en` | Dashboard por categoría. |
| `idx_solicitudes_sla` | `solicitudes` | `fecha_limite_sla, estado_id` | Vencidas y próximas a vencer. |
| `idx_solicitudes_creado` | `solicitudes` | `creado_en` | Filtros por rango de fechas. |
| `idx_historial_solicitud` | `historial_estados` | `solicitud_id, cambiado_en` | Línea de tiempo del detalle. |
| `uk_asignaciones_activa` | `asignaciones` | `solicitud_activa_id` | Una asignación activa. |
| `idx_asignaciones_tecnico` | `asignaciones` | `tecnico_id, finalizada_en` | Historial del técnico. |
| `idx_asignaciones_solicitud` | `asignaciones` | `solicitud_id, asignada_en` | Historial de la solicitud. |
| `idx_comentarios_solicitud` | `comentarios` | `solicitud_id, creado_en` | Comentarios del detalle. |
| `idx_auditoria_solicitud` | `auditoria_eventos` | `solicitud_id, ocurrido_en` | Auditoría por solicitud. |
| `idx_auditoria_entidad` | `auditoria_eventos` | `entidad, entidad_id, ocurrido_en` | Auditoría genérica. |
| `idx_auditoria_actor` | `auditoria_eventos` | `actor_id, ocurrido_en` | Actividad por usuario. |
| `idx_sesiones_usuario` | `sesiones_usuario` | `usuario_id, revocada_en` | Sesiones activas. |
| `uk_espacios_codigo` | `espacios` | `codigo` | Código único del ambiente. |
| `uk_espacios_nombre_pabellon` | `espacios` | `nombre, pabellon` | Evita ambientes duplicados en el mismo pabellón. |
| `idx_espacios_tipo_activo` | `espacios` | `tipo_espacio_id, activo` | Catálogo filtrado por tipo. |
| `idx_espacios_area_activo` | `espacios` | `area_id, activo` | Espacios de un área para aprobación. |
| `idx_espacios_pabellon_activo` | `espacios` | `pabellon, activo` | Filtro por pabellón. |
| `uk_horarios_espacio_dia` | `horarios_espacio` | `espacio_id, dia_semana` | Un horario por día y espacio. |
| `uk_reservas_codigo` | `reservas` | `codigo` | Código único de reserva. |
| `uk_reservas_franja_exacta` | `reservas` | `espacio_id, fecha, hora_inicio, estado_id` | Bloquea duplicados exactos en el mismo estado. |
| `idx_reservas_disponibilidad` | `reservas` | `espacio_id, fecha, estado_id, hora_inicio, hora_fin` | Disponibilidad y detección de solapamiento. |
| `idx_reservas_solicitante` | `reservas` | `solicitante_id, fecha` | “Mis reservas” paginado. |
| `idx_reservas_estado_fecha` | `reservas` | `estado_id, fecha` | Bandeja de pendientes y agenda. |
| `idx_reservas_aprobador` | `reservas` | `aprobada_por_id, aprobada_en` | Historial de aprobaciones. |
| `idx_historial_reserva` | `historial_estados_reserva` | `reserva_id, cambiado_en` | Línea de tiempo de la reserva. |

**Paginación:** usar `LIMIT ? OFFSET ?` o keyset (`(creado_en, id) < (?, ?)`) para listados grandes. Los índices incluyen `creado_en` para evitar filesort en los listados principales.

**Orden del técnico:** `ORDER BY p.nivel DESC, s.creado_en ASC`; el índice `idx_solicitudes_responsable` cubre el filtro principal y el orden por fecha; para el orden por prioridad, MySQL puede usar el índice compuesto y un sort acotado.


### 8.1. Consultas de disponibilidad de reservas

```sql
-- Franjas ocupadas de un espacio en una fecha.
SELECT hora_inicio, hora_fin
FROM reservas
WHERE espacio_id = :espacio_id
  AND fecha = :fecha
  AND estado_id IN (:pendiente_id, :confirmada_id)
ORDER BY hora_inicio;

-- Detección de solapamiento dentro de la transacción.
SELECT 1
FROM reservas
WHERE espacio_id = :espacio_id
  AND fecha = :fecha
  AND estado_id IN (:pendiente_id, :confirmada_id)
  AND hora_inicio < :hora_fin
  AND hora_fin > :hora_inicio
LIMIT 1;
```

`idx_reservas_disponibilidad` cubre el filtro por espacio, fecha y estado y permite resolver el solapamiento sin escanear la tabla. En tablas pequeñas MySQL puede elegir `uk_reservas_franja_exacta`, que también cubre `espacio_id` y `fecha`; ambos aparecen en `possible_keys`. Con volumen real, revisar `EXPLAIN` y, si hace falta, forzar `USE INDEX (idx_reservas_disponibilidad)`. Evitar `YEAR(fecha)` o `DATE(fecha)` en los filtros: aplican una función sobre la columna e impiden el uso del índice.

**Concurrencia:** la validación se ejecuta dentro de una transacción con `SELECT id FROM espacios WHERE id = :espacio_id FOR UPDATE`; así dos solicitudes concurrentes para el mismo espacio se serializan. `uk_reservas_franja_exacta` evita además el duplicado exacto en el mismo estado.

---

## 9. Vistas

### 9.1. `vw_solicitudes_detalle`

Vista de lectura para el detalle y los listados. Evita repetir los `JOIN` de catálogos en cada consulta.

```sql
CREATE OR REPLACE VIEW vw_solicitudes_detalle AS
SELECT
    s.id,
    s.codigo,
    s.solicitante_id,
    sol.nombre_completo AS solicitante,
    s.categoria_id,
    c.nombre AS categoria,
    s.area_id,
    a.nombre AS area,
    s.prioridad_id,
    p.nombre AS prioridad,
    p.nivel AS prioridad_nivel,
    s.estado_id,
    e.codigo AS estado_codigo,
    e.nombre AS estado,
    e.es_final,
    s.responsable_actual_id,
    tec.nombre_completo AS responsable,
    s.ubicacion,
    s.descripcion,
    s.motivo_rechazo,
    s.fecha_limite_sla,
    s.fecha_aviso_sla,
    s.resuelta_en,
    s.cerrada_en,
    s.creado_en,
    s.actualizado_en
FROM solicitudes s
JOIN usuarios sol ON sol.id = s.solicitante_id
JOIN categorias c ON c.id = s.categoria_id
JOIN areas a ON a.id = s.area_id
JOIN prioridades p ON p.id = s.prioridad_id
JOIN estados_solicitud e ON e.id = s.estado_id
LEFT JOIN usuarios tec ON tec.id = s.responsable_actual_id;
```

### 9.2. `vw_estado_sla`

Calcula el estado SLA en tiempo de consulta. No se persiste porque depende de `NOW()`.

```sql
CREATE OR REPLACE VIEW vw_estado_sla AS
SELECT
    s.id AS solicitud_id,
    s.codigo,
    s.estado_id,
    e.codigo AS estado_codigo,
    e.es_final,
    s.fecha_limite_sla,
    s.fecha_aviso_sla,
    CASE
        WHEN e.es_final = 1 THEN 'CERRADA'
        WHEN s.fecha_limite_sla IS NULL THEN 'SIN_SLA'
        WHEN UTC_TIMESTAMP(6) > s.fecha_limite_sla THEN 'VENCIDA'
        WHEN s.fecha_aviso_sla IS NOT NULL
             AND UTC_TIMESTAMP(6) >= s.fecha_aviso_sla THEN 'POR_VENCER'
        ELSE 'EN_PLAZO'
    END AS estado_sla,
    CASE
        WHEN e.codigo = 'CERRADO'
             AND s.fecha_limite_sla IS NOT NULL
             AND s.resuelta_en IS NOT NULL
        THEN (s.resuelta_en <= s.fecha_limite_sla)
        ELSE NULL
    END AS cumplio_sla
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id;
```


### 9.3. `vw_reservas_detalle`

Vista de lectura para listados y detalle de reservas, con espacio, tipo, área, solicitante, estado y aprobador.

```sql
CREATE OR REPLACE VIEW vw_reservas_detalle AS
SELECT
    r.id,
    r.codigo,
    r.espacio_id,
    esp.nombre AS espacio,
    te.nombre AS tipo_espacio,
    a.nombre AS area,
    r.solicitante_id,
    sol.nombre_completo AS solicitante,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.motivo,
    r.num_asistentes,
    r.estado_id,
    er.codigo AS estado_codigo,
    er.nombre AS estado,
    er.es_final,
    r.aprobada_por_id,
    apr.nombre_completo AS aprobador,
    r.aprobada_en,
    r.motivo_rechazo,
    r.cancelada_por_id,
    r.cancelada_en,
    r.creado_en,
    r.actualizado_en
FROM reservas r
JOIN espacios esp ON esp.id = r.espacio_id
JOIN tipos_espacio te ON te.id = esp.tipo_espacio_id
LEFT JOIN areas a ON a.id = esp.area_id
JOIN usuarios sol ON sol.id = r.solicitante_id
JOIN estados_reserva er ON er.id = r.estado_id
LEFT JOIN usuarios apr ON apr.id = r.aprobada_por_id;
```

### 9.4. `vw_reservas_operativas`

Deriva el estado operativo sin persistirlo. Las reservas no confirmadas conservan su estado almacenado.

```sql
CREATE OR REPLACE VIEW vw_reservas_operativas AS
SELECT
    r.id AS reserva_id,
    r.codigo,
    r.espacio_id,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.estado_id,
    er.codigo AS estado_codigo,
    CASE
        WHEN er.codigo <> 'CONFIRMADA' THEN er.codigo
        WHEN TIMESTAMP(r.fecha, r.hora_fin) < UTC_TIMESTAMP(6) THEN 'FINALIZADA'
        WHEN TIMESTAMP(r.fecha, r.hora_inicio) <= UTC_TIMESTAMP(6) THEN 'EN_CURSO'
        ELSE 'PROXIMA'
    END AS estado_operativo
FROM reservas r
JOIN estados_reserva er ON er.id = r.estado_id;
```

---

## 10. Dashboard: los 9 indicadores

Los filtros `:fecha_desde`, `:fecha_hasta` y `:area_id` son parámetros de la capa de servicio. En JDBC se traducen a `?`. El rango siempre es `[fecha_desde, fecha_hasta)`.

### 10.1. Solicitudes registradas

```sql
SELECT COUNT(*) AS registradas
FROM solicitudes s
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id);
```

### 10.2. Solicitudes pendientes

```sql
SELECT COUNT(*) AS pendientes
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id)
  AND e.codigo IN ('NUEVO', 'ASIGNADO', 'EN_PROCESO');
```

### 10.3. Solicitudes atendidas

```sql
SELECT COUNT(*) AS atendidas
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id)
  AND e.codigo IN ('RESUELTO', 'CERRADO');
```

### 10.4. Por categoría

```sql
SELECT c.nombre AS categoria, COUNT(*) AS total
FROM solicitudes s
JOIN categorias c ON c.id = s.categoria_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id)
GROUP BY c.id, c.nombre
ORDER BY total DESC, c.nombre ASC;
```

### 10.5. Por prioridad

```sql
SELECT p.nombre AS prioridad, COUNT(*) AS total
FROM solicitudes s
JOIN prioridades p ON p.id = s.prioridad_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id)
GROUP BY p.id, p.nombre, p.nivel
ORDER BY p.nivel DESC;
```

### 10.6. Por responsable

```sql
SELECT COALESCE(t.nombre_completo, 'Sin asignar') AS responsable,
       COUNT(*) AS total
FROM solicitudes s
LEFT JOIN usuarios t ON t.id = s.responsable_actual_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id)
GROUP BY s.responsable_actual_id, t.nombre_completo
ORDER BY total DESC;
```

### 10.7. Tiempo promedio de atención

Se mide desde el registro hasta `resuelta_en`, en horas.

```sql
SELECT COALESCE(
         ROUND(
           AVG(TIMESTAMPDIFF(MINUTE, s.creado_en, s.resuelta_en)) / 60,
           2
         ),
         0
       ) AS promedio_horas
FROM solicitudes s
WHERE s.resuelta_en IS NOT NULL
  AND s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id);
```

### 10.8. Porcentaje de resueltas

```sql
SELECT COALESCE(
         ROUND(
           100.0 * SUM(CASE WHEN e.codigo IN ('RESUELTO', 'CERRADO') THEN 1 ELSE 0 END)
           / NULLIF(COUNT(*), 0),
           2
         ),
         0
       ) AS porcentaje_resueltas
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id);
```

### 10.9. Solicitudes vencidas y próximas a vencer

```sql
SELECT
    COALESCE(SUM(v.estado_sla = 'VENCIDA'), 0)    AS vencidas,
    COALESCE(SUM(v.estado_sla = 'POR_VENCER'), 0) AS por_vencer
FROM vw_estado_sla v
JOIN solicitudes s ON s.id = v.solicitud_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id);
```

### 10.10. Cumplimiento de SLA (indicador complementario)

```sql
SELECT COALESCE(
         ROUND(
           100.0 * SUM(v.cumplio_sla = 1)
           / NULLIF(SUM(v.cumplio_sla IS NOT NULL), 0),
           2
         ),
         0
       ) AS porcentaje_cumplimiento_sla
FROM vw_estado_sla v
JOIN solicitudes s ON s.id = v.solicitud_id
WHERE s.creado_en >= :fecha_desde
  AND s.creado_en <  :fecha_hasta
  AND (:area_id IS NULL OR s.area_id = :area_id);
```

---

## 11. Datos semilla

Los seeds son **catálogos de demostración**, no datos reales. Se cargan con una migración separada para poder sustituirlos por el catálogo oficial de la universidad.

| Catálogo | Valores iniciales |
| --- | --- |
| `roles` | `ESTUDIANTE`, `DOCENTE`, `TECNICO`, `SUPERVISOR`, `ADMINISTRADOR`. |
| `areas` | Soporte informático, Mantenimiento, Servicios generales, Biblioteca. |
| `prioridades` | Baja (1), Media (2), Alta (3), Crítica (4). |
| `estados_solicitud` | Nuevo, Asignado, En proceso, Resuelto, Cerrado, Rechazado. |
| `categorias` | Soporte informático, Mantenimiento, Servicios generales, Biblioteca. |
| `politicas_sla` | 72/12 h (Baja), 48/8 h (Media), 24/4 h (Alta), 8/2 h (Crítica); 24/4 h específica para Soporte informático. |
| `transiciones_estado` | Matriz de la sección 7.1. |
| `tipos_espacio` | `AULA`, `LABORATORIO`, `SALA_ESTUDIO`, `AUDITORIO`, `SALA_REUNIONES`, `OTRO`. |
| `estados_reserva` | `PENDIENTE`, `CONFIRMADA`, `RECHAZADA`, `CANCELADA`. |
| `espacios` | 6–8 ambientes de demostración: aulas, laboratorios, sala de estudio y auditorio. |
| `horarios_espacio` | Lunes a viernes 07:00–22:00; sábado 07:00–13:00 en biblioteca. |
| `politicas_reserva` | 30–240 min, 30 días de anticipación, 1 h mínima y 2 reservas activas por día. |

> **Usuarios:** no se insertan. El primer administrador se crea con un hash BCrypt/Argon2id generado por la aplicación, `activo = 1`, `estado_cuenta = 'ACTIVA'` y `debe_cambiar_contrasena = 1`.

---

## 12. Trazabilidad HU/RF → tablas

| HU | RF | Tablas principales |
| --- | --- | --- |
| HU-01 | RF-01 | `usuarios`, `sesiones_usuario`, `roles` |
| HU-02 | RF-02 | `roles`, `usuarios` |
| HU-03 | RF-03, RF-04, RF-05 | `solicitudes`, `categorias`, `prioridades`, `historial_estados`, `secuencias_codigo_solicitud` |
| HU-04 | RF-06 | `solicitudes`, `categorias`, `estados_solicitud`, `prioridades` |
| HU-05 | RF-07 | `solicitudes`, `historial_estados`, `asignaciones`, `comentarios` |
| HU-06 | RF-08 | `comentarios` |
| HU-07 | RF-09 | `solicitudes`, `areas`, `categorias`, `estados_solicitud`, `prioridades` |
| HU-08 | RF-10, RF-11, RF-15 | `solicitudes`, `asignaciones`, `historial_estados`, `transiciones_estado`, `auditoria_eventos` |
| HU-09 | RF-12 | `solicitudes`, `asignaciones`, `prioridades` |
| HU-10 | RF-13, RF-15 | `solicitudes`, `historial_estados`, `transiciones_estado` |
| HU-11 | RF-14, RF-15 | `solicitudes`, `historial_estados`, `transiciones_estado` |
| HU-12 | RF-16 | `solicitudes`, catálogos, `politicas_sla`, `vw_estado_sla` |
| HU-13 | RF-17 | `solicitudes`, `areas`, `vw_estado_sla` |
| HU-14 | RF-23 | `vw_solicitudes_detalle` (sin tabla nueva) |
| HU-15 | RF-18 | `usuarios`, `roles`, `areas` |
| HU-16 | RF-19 | `categorias`, `areas` |
| HU-17 | RF-20 | `prioridades`, `estados_solicitud` |
| HU-18 | RF-21 | `politicas_sla`, `solicitudes`, `vw_estado_sla` |
| HU-19 | RF-22 | `auditoria_eventos`, `historial_estados` |
| HU-20 | RF-24 | `encuestas_satisfaccion`, `solicitudes` |
| HU-21 | RF-25 | `espacios`, `tipos_espacio`, `horarios_espacio`, `reservas`, `estados_reserva` |
| HU-22 | RF-26, RF-27 | `reservas`, `espacios`, `politicas_reserva`, `estados_reserva`, `historial_estados_reserva`, `secuencias_codigo_reserva` |
| HU-23 | RF-28 | `reservas`, `historial_estados_reserva`, `estados_reserva`, `auditoria_eventos` |
| HU-24 | RF-29 | `reservas`, `historial_estados_reserva`, `estados_reserva` |
| HU-25 | RF-30 | `espacios`, `tipos_espacio`, `horarios_espacio`, `politicas_reserva` |
| HU-26 | RF-31 | `adjuntos_solicitud`, `solicitudes`, `auditoria_eventos` |
| HU-27 | RF-32 | `usuarios`, `roles`, `auditoria_eventos` |
| HU-28 | RF-33 | `usuarios`, `auditoria_eventos` |
| HU-29 | RF-34 | `usuarios`, `sesiones_usuario`, `auditoria_eventos` |

---

## 13. Seguridad y operación

### 13.1. Usuarios de base de datos

En local, el Compose crea `uni_app` sobre `uni_services`. Para la aplicación se recomienda:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON uni_services.* TO 'uni_app'@'%';
```

- `uni_app` **no** debe tener `CREATE`, `ALTER`, `DROP` ni acceso a `mysql.*`.
- Las migraciones Flyway pueden usar un usuario separado con permisos DDL solo en el entorno de despliegue.
- No se otorgan privilegios globales.

### 13.2. Contraseñas y sesiones

- `hash_contrasena` almacena BCrypt (preferido) o Argon2id; nunca texto plano (RNF-05).
- `sesiones_usuario.hash_token` almacena SHA-256 del token; el token original solo viaja al cliente.
- El logout actualiza `revocada_en`; el backend rechaza tokens revocados.
- El login exitoso actualiza `usuarios.ultimo_acceso_en`.
- El restablecimiento por administrador revoca todas las sesiones del usuario y fuerza el cambio de contraseña (sección 7.9).

### 13.3. Respaldos

```bash
docker compose exec mysql mysqldump \
  --single-transaction --routines --triggers \
  -u root -p uni_services > backup_uni_services.sql
```

- Probar la restauración en una base temporal antes de la sustentación.
- No versionar respaldos con datos personales.
- `docker compose down -v` elimina el volumen; usarlo solo con respaldo previo.

### 13.4. Flyway

Orden sugerido de migraciones:

1. `V1__esquema_inicial.sql`: tablas, FKs, índices, checks y vistas.
2. `V2__catalogos_semilla.sql`: roles, áreas, prioridades, estados, categorías, transiciones y SLA.
3. `V3__datos_demostracion.sql` (opcional, solo entornos de demo): usuarios y solicitudes de ejemplo con datos ficticios.

La aplicación Spring Boot debe configurar:

```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/uni_services?connectionTimeZone=UTC&characterEncoding=utf8
    username: ${MYSQL_USER}
    password: ${MYSQL_PASSWORD}
  jpa:
    properties:
      hibernate:
        jdbc:
          time_zone: UTC
  flyway:
    enabled: true
```

### 13.5. Integridad y mantenimiento

- `ANALYZE TABLE` tras cargas masivas.
- Revisar `EXPLAIN` de las consultas del dashboard con datos de demostración.
- No usar `OPTIMIZE TABLE` en caliente sin ventana de mantenimiento.
- Monitorear crecimiento de `auditoria_eventos`; si supera varios millones de filas, evaluar particionado por año o archivado.

### 13.6. Almacenamiento de evidencias

- Supabase Storage, bucket privado `evidencias-solicitudes`, uno por entorno (staging y producción). En local, volumen Docker.
- El backend usa la clave de servicio de Supabase desde variables de entorno (RNF-08); nunca llega al frontend, al repositorio ni a los logs.
- Los backups de MySQL no incluyen los archivos. La retención y el respaldo del bucket se documentan en el runbook de la Fase 4.

---

## 14. Extensiones futuras

### 14.1. Adjuntos de solicitud

Ya incorporados: ver la tabla 6.25 `adjuntos_solicitud`, las reglas 7.10 y HU-26.

### 14.2. Otras extensiones

- **Reservas de ambientes:** ya incorporadas como EP-07; no se consideran una extensión futura.
- **Notificaciones internas:** tabla `notificaciones` con `usuario_id`, `solicitud_id`, `tipo`, `leida_en`.
- **Historial de prioridad:** si se necesita reportar cambios de prioridad, ya quedan en `auditoria_eventos`; no hace falta una tabla adicional.
- **Particionado de auditoría:** por año si el volumen lo justifica.

---

## 15. Anexo A: DDL completo

> **Uso:** este bloque está pensado para revisión y para crear una base de prueba. En Flyway, omite `CREATE DATABASE` y `USE`; la base la provisiona el entorno. Ejecuta el DDL en MySQL 8.4.13.

```sql
-- ============================================================
-- DISENIO-BD.md — Anexo A
-- Sistema de Servicios Universitarios (Gestal)
-- MySQL 8.4.13
-- ============================================================

CREATE DATABASE IF NOT EXISTS uni_services
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE uni_services;

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- ------------------------------------------------------------
-- 1. roles
-- ------------------------------------------------------------
CREATE TABLE roles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_roles_codigo (codigo),
    UNIQUE KEY uk_roles_nombre (nombre),
    CONSTRAINT chk_roles_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 2. areas
-- ------------------------------------------------------------
CREATE TABLE areas (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(50) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_areas_codigo (codigo),
    UNIQUE KEY uk_areas_nombre (nombre),
    CONSTRAINT chk_areas_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 3. usuarios
-- ------------------------------------------------------------
CREATE TABLE usuarios (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    rol_id BIGINT UNSIGNED NOT NULL,
    area_id BIGINT UNSIGNED NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    hash_contrasena VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'ACTIVA',
    origen_registro VARCHAR(20) NOT NULL DEFAULT 'ADMINISTRADOR',
    revisado_por_id BIGINT UNSIGNED NULL,
    revisado_en DATETIME(6) NULL,
    motivo_rechazo TEXT NULL,
    debe_cambiar_contrasena TINYINT UNSIGNED NOT NULL DEFAULT 1,
    ultimo_acceso_en DATETIME(6) NULL,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_usuarios_correo (correo),
    KEY idx_usuarios_rol_activo (rol_id, activo),
    KEY idx_usuarios_area_activo (area_id, activo),
    KEY idx_usuarios_estado_cuenta (estado_cuenta, creado_en),
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id)
        REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_usuarios_area FOREIGN KEY (area_id)
        REFERENCES areas (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_usuarios_activo CHECK (activo IN (0, 1)),
    CONSTRAINT fk_usuarios_revisor FOREIGN KEY (revisado_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_usuarios_debe_cambiar
        CHECK (debe_cambiar_contrasena IN (0, 1)),
    CONSTRAINT chk_usuarios_estado_cuenta
        CHECK (estado_cuenta IN ('PENDIENTE', 'ACTIVA', 'RECHAZADA')),
    CONSTRAINT chk_usuarios_origen
        CHECK (origen_registro IN ('ADMINISTRADOR', 'AUTO_REGISTRO')),
    CONSTRAINT chk_usuarios_motivo_rechazo
        CHECK (estado_cuenta <> 'RECHAZADA'
               OR (motivo_rechazo IS NOT NULL AND CHAR_LENGTH(TRIM(motivo_rechazo)) > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 4. sesiones_usuario
-- ------------------------------------------------------------
CREATE TABLE sesiones_usuario (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT UNSIGNED NOT NULL,
    hash_token CHAR(64) NOT NULL,
    emitida_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    expira_en DATETIME(6) NOT NULL,
    revocada_en DATETIME(6) NULL,
    ip VARCHAR(45) NULL,
    agente_usuario VARCHAR(255) NULL,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_sesiones_token (hash_token),
    KEY idx_sesiones_usuario (usuario_id, revocada_en),
    CONSTRAINT fk_sesiones_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 5. prioridades
-- ------------------------------------------------------------
CREATE TABLE prioridades (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    nivel TINYINT UNSIGNED NOT NULL,
    color CHAR(7) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_prioridades_codigo (codigo),
    UNIQUE KEY uk_prioridades_nombre (nombre),
    UNIQUE KEY uk_prioridades_nivel (nivel),
    CONSTRAINT chk_prioridades_activo CHECK (activo IN (0, 1)),
    CONSTRAINT chk_prioridades_nivel CHECK (nivel BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 6. estados_solicitud
-- ------------------------------------------------------------
CREATE TABLE estados_solicitud (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(255) NULL,
    es_final TINYINT UNSIGNED NOT NULL DEFAULT 0,
    orden TINYINT UNSIGNED NOT NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_estados_codigo (codigo),
    UNIQUE KEY uk_estados_orden (orden),
    CONSTRAINT chk_estados_final CHECK (es_final IN (0, 1)),
    CONSTRAINT chk_estados_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 7. categorias
-- ------------------------------------------------------------
CREATE TABLE categorias (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    area_id BIGINT UNSIGNED NOT NULL,
    prioridad_predeterminada_id BIGINT UNSIGNED NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_categorias_codigo (codigo),
    UNIQUE KEY uk_categorias_nombre (nombre),
    KEY idx_categorias_area_activo (area_id, activo),
    KEY idx_categorias_prioridad (prioridad_predeterminada_id),
    CONSTRAINT fk_categorias_area FOREIGN KEY (area_id)
        REFERENCES areas (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_categorias_prioridad FOREIGN KEY (prioridad_predeterminada_id)
        REFERENCES prioridades (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_categorias_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 8. transiciones_estado
-- ------------------------------------------------------------
CREATE TABLE transiciones_estado (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    estado_origen_id BIGINT UNSIGNED NOT NULL,
    estado_destino_id BIGINT UNSIGNED NOT NULL,
    rol_id BIGINT UNSIGNED NOT NULL,
    requiere_motivo TINYINT UNSIGNED NOT NULL DEFAULT 0,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_transiciones (estado_origen_id, estado_destino_id, rol_id),
    KEY idx_transiciones_origen (estado_origen_id, activo),
    KEY idx_transiciones_destino (estado_destino_id, activo),
    KEY idx_transiciones_rol (rol_id, activo),
    CONSTRAINT fk_transiciones_origen FOREIGN KEY (estado_origen_id)
        REFERENCES estados_solicitud (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_transiciones_destino FOREIGN KEY (estado_destino_id)
        REFERENCES estados_solicitud (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_transiciones_rol FOREIGN KEY (rol_id)
        REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_transiciones_motivo CHECK (requiere_motivo IN (0, 1)),
    CONSTRAINT chk_transiciones_activo CHECK (activo IN (0, 1)),
    CONSTRAINT chk_transiciones_distintos
        CHECK (estado_origen_id <> estado_destino_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 9. politicas_sla
-- ------------------------------------------------------------
CREATE TABLE politicas_sla (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    prioridad_id BIGINT UNSIGNED NULL,
    categoria_id BIGINT UNSIGNED NULL,
    horas_objetivo SMALLINT UNSIGNED NOT NULL,
    horas_aviso SMALLINT UNSIGNED NOT NULL,
    vigente_desde DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    vigente_hasta DATETIME(6) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_politicas_prioridad (prioridad_id, activo),
    KEY idx_politicas_categoria (categoria_id, activo),
    CONSTRAINT fk_politicas_prioridad FOREIGN KEY (prioridad_id)
        REFERENCES prioridades (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_politicas_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_politicas_alcance CHECK (
        (prioridad_id IS NOT NULL AND categoria_id IS NULL)
        OR (prioridad_id IS NULL AND categoria_id IS NOT NULL)
    ),
    CONSTRAINT chk_politicas_horas CHECK (
        horas_objetivo > 0
        AND horas_aviso >= 0
        AND horas_aviso < horas_objetivo
    ),
    CONSTRAINT chk_politicas_vigencia CHECK (
        vigente_hasta IS NULL OR vigente_hasta > vigente_desde
    ),
    CONSTRAINT chk_politicas_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 10. solicitudes
-- ------------------------------------------------------------
CREATE TABLE solicitudes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL,
    solicitante_id BIGINT UNSIGNED NOT NULL,
    categoria_id BIGINT UNSIGNED NOT NULL,
    area_id BIGINT UNSIGNED NOT NULL,
    prioridad_id BIGINT UNSIGNED NOT NULL,
    estado_id BIGINT UNSIGNED NOT NULL,
    responsable_actual_id BIGINT UNSIGNED NULL,
    politica_sla_id BIGINT UNSIGNED NULL,
    ubicacion VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    motivo_rechazo TEXT NULL,
    fecha_limite_sla DATETIME(6) NULL,
    fecha_aviso_sla DATETIME(6) NULL,
    resuelta_en DATETIME(6) NULL,
    cerrada_en DATETIME(6) NULL,
    version_fila INT UNSIGNED NOT NULL DEFAULT 0,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_solicitudes_codigo (codigo),
    KEY idx_solicitudes_solicitante (solicitante_id, creado_en),
    KEY idx_solicitudes_area_estado_prioridad
        (area_id, estado_id, prioridad_id, creado_en),
    KEY idx_solicitudes_responsable
        (responsable_actual_id, estado_id, prioridad_id, creado_en),
    KEY idx_solicitudes_categoria (categoria_id, creado_en),
    KEY idx_solicitudes_sla (fecha_limite_sla, estado_id),
    KEY idx_solicitudes_creado (creado_en),
    CONSTRAINT fk_solicitudes_solicitante FOREIGN KEY (solicitante_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_area FOREIGN KEY (area_id)
        REFERENCES areas (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_prioridad FOREIGN KEY (prioridad_id)
        REFERENCES prioridades (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_estado FOREIGN KEY (estado_id)
        REFERENCES estados_solicitud (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_responsable FOREIGN KEY (responsable_actual_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_solicitudes_politica FOREIGN KEY (politica_sla_id)
        REFERENCES politicas_sla (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_solicitudes_descripcion
        CHECK (CHAR_LENGTH(TRIM(descripcion)) > 0),
    CONSTRAINT chk_solicitudes_ubicacion
        CHECK (CHAR_LENGTH(TRIM(ubicacion)) > 0),
    CONSTRAINT chk_solicitudes_fechas CHECK (
        (resuelta_en IS NULL OR resuelta_en >= creado_en)
        AND (cerrada_en IS NULL OR cerrada_en >= creado_en)
        AND (cerrada_en IS NULL OR resuelta_en IS NULL OR cerrada_en >= resuelta_en)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 11. historial_estados
-- ------------------------------------------------------------
CREATE TABLE historial_estados (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    solicitud_id BIGINT UNSIGNED NOT NULL,
    estado_origen_id BIGINT UNSIGNED NULL,
    estado_destino_id BIGINT UNSIGNED NOT NULL,
    cambiado_por_id BIGINT UNSIGNED NOT NULL,
    motivo TEXT NULL,
    cambiado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_historial_solicitud (solicitud_id, cambiado_en),
    KEY idx_historial_origen (estado_origen_id),
    KEY idx_historial_destino (estado_destino_id),
    KEY idx_historial_usuario (cambiado_por_id),
    CONSTRAINT fk_historial_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_origen FOREIGN KEY (estado_origen_id)
        REFERENCES estados_solicitud (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_destino FOREIGN KEY (estado_destino_id)
        REFERENCES estados_solicitud (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_usuario FOREIGN KEY (cambiado_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_historial_distintos CHECK (
        estado_origen_id IS NULL OR estado_origen_id <> estado_destino_id
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 12. asignaciones
-- ------------------------------------------------------------
CREATE TABLE asignaciones (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    solicitud_id BIGINT UNSIGNED NOT NULL,
    tecnico_id BIGINT UNSIGNED NOT NULL,
    asignado_por_id BIGINT UNSIGNED NOT NULL,
    asignada_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    finalizada_en DATETIME(6) NULL,
    motivo_fin VARCHAR(255) NULL,
    solicitud_activa_id BIGINT UNSIGNED GENERATED ALWAYS AS (
        CASE WHEN finalizada_en IS NULL THEN solicitud_id ELSE NULL END
    ) STORED,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_asignaciones_activa (solicitud_activa_id),
    KEY idx_asignaciones_tecnico (tecnico_id, finalizada_en),
    KEY idx_asignaciones_solicitud (solicitud_id, asignada_en),
    KEY idx_asignaciones_asignador (asignado_por_id),
    CONSTRAINT fk_asignaciones_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_asignaciones_tecnico FOREIGN KEY (tecnico_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_asignaciones_asignador FOREIGN KEY (asignado_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_asignaciones_fechas CHECK (
        finalizada_en IS NULL OR finalizada_en >= asignada_en
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 13. comentarios
-- ------------------------------------------------------------
CREATE TABLE comentarios (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    solicitud_id BIGINT UNSIGNED NOT NULL,
    autor_id BIGINT UNSIGNED NOT NULL,
    contenido TEXT NOT NULL,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    editado_en DATETIME(6) NULL,
    PRIMARY KEY (id),
    KEY idx_comentarios_solicitud (solicitud_id, creado_en),
    KEY idx_comentarios_autor (autor_id),
    CONSTRAINT fk_comentarios_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_comentarios_autor FOREIGN KEY (autor_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_comentarios_contenido
        CHECK (CHAR_LENGTH(TRIM(contenido)) > 0),
    CONSTRAINT chk_comentarios_edicion
        CHECK (editado_en IS NULL OR editado_en >= creado_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 14. encuestas_satisfaccion
-- ------------------------------------------------------------
CREATE TABLE encuestas_satisfaccion (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    solicitud_id BIGINT UNSIGNED NOT NULL,
    respondida_por_id BIGINT UNSIGNED NOT NULL,
    calificacion TINYINT UNSIGNED NOT NULL,
    comentario TEXT NULL,
    respondida_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_encuestas_solicitud (solicitud_id),
    KEY idx_encuestas_respondedor (respondida_por_id),
    CONSTRAINT fk_encuestas_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_encuestas_respondedor FOREIGN KEY (respondida_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_encuestas_calificacion
        CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 15. auditoria_eventos
-- ------------------------------------------------------------
CREATE TABLE auditoria_eventos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    entidad VARCHAR(60) NOT NULL,
    entidad_id BIGINT UNSIGNED NOT NULL,
    solicitud_id BIGINT UNSIGNED NULL,
    accion VARCHAR(30) NOT NULL,
    campo VARCHAR(80) NULL,
    valor_anterior TEXT NULL,
    valor_nuevo TEXT NULL,
    actor_id BIGINT UNSIGNED NULL,
    ocurrido_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    id_correlacion CHAR(36) NULL,
    ip VARCHAR(45) NULL,
    PRIMARY KEY (id),
    KEY idx_auditoria_solicitud (solicitud_id, ocurrido_en),
    KEY idx_auditoria_entidad (entidad, entidad_id, ocurrido_en),
    KEY idx_auditoria_actor (actor_id, ocurrido_en),
    KEY idx_auditoria_fecha (ocurrido_en),
    CONSTRAINT fk_auditoria_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_auditoria_actor FOREIGN KEY (actor_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_auditoria_entidad
        CHECK (CHAR_LENGTH(TRIM(entidad)) > 0),
    CONSTRAINT chk_auditoria_accion
        CHECK (CHAR_LENGTH(TRIM(accion)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 16. secuencias_codigo_solicitud
-- ------------------------------------------------------------
CREATE TABLE secuencias_codigo_solicitud (
    anio SMALLINT UNSIGNED NOT NULL,
    ultimo_valor INT UNSIGNED NOT NULL DEFAULT 0,
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (anio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- Vistas
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_solicitudes_detalle AS
SELECT
    s.id,
    s.codigo,
    s.solicitante_id,
    sol.nombre_completo AS solicitante,
    s.categoria_id,
    c.nombre AS categoria,
    s.area_id,
    a.nombre AS area,
    s.prioridad_id,
    p.nombre AS prioridad,
    p.nivel AS prioridad_nivel,
    s.estado_id,
    e.codigo AS estado_codigo,
    e.nombre AS estado,
    e.es_final,
    s.responsable_actual_id,
    tec.nombre_completo AS responsable,
    s.ubicacion,
    s.descripcion,
    s.motivo_rechazo,
    s.fecha_limite_sla,
    s.fecha_aviso_sla,
    s.resuelta_en,
    s.cerrada_en,
    s.creado_en,
    s.actualizado_en
FROM solicitudes s
JOIN usuarios sol ON sol.id = s.solicitante_id
JOIN categorias c ON c.id = s.categoria_id
JOIN areas a ON a.id = s.area_id
JOIN prioridades p ON p.id = s.prioridad_id
JOIN estados_solicitud e ON e.id = s.estado_id
LEFT JOIN usuarios tec ON tec.id = s.responsable_actual_id;

CREATE OR REPLACE VIEW vw_estado_sla AS
SELECT
    s.id AS solicitud_id,
    s.codigo,
    s.estado_id,
    e.codigo AS estado_codigo,
    e.es_final,
    s.fecha_limite_sla,
    s.fecha_aviso_sla,
    CASE
        WHEN e.es_final = 1 THEN 'CERRADA'
        WHEN s.fecha_limite_sla IS NULL THEN 'SIN_SLA'
        WHEN UTC_TIMESTAMP(6) > s.fecha_limite_sla THEN 'VENCIDA'
        WHEN s.fecha_aviso_sla IS NOT NULL
             AND UTC_TIMESTAMP(6) >= s.fecha_aviso_sla THEN 'POR_VENCER'
        ELSE 'EN_PLAZO'
    END AS estado_sla,
    CASE
        WHEN e.codigo = 'CERRADO'
             AND s.fecha_limite_sla IS NOT NULL
             AND s.resuelta_en IS NOT NULL
        THEN (s.resuelta_en <= s.fecha_limite_sla)
        ELSE NULL
    END AS cumplio_sla
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id;

-- ------------------------------------------------------------
-- Datos semilla (catálogos)
-- ------------------------------------------------------------
INSERT INTO roles (id, codigo, nombre, descripcion) VALUES
    (1, 'ESTUDIANTE', 'Estudiante', 'Registra y consulta sus propias solicitudes.'),
    (2, 'TECNICO', 'Técnico', 'Atiende las solicitudes asignadas a su área.'),
    (3, 'SUPERVISOR', 'Supervisor', 'Gestiona, asigna y cierra solicitudes de su área.'),
    (4, 'ADMINISTRADOR', 'Administrador', 'Administra usuarios y catálogos del sistema.'),
    (5, 'DOCENTE', 'Docente', 'Registra y consulta sus propias solicitudes y reservas; cuenta creada por el administrador.');

INSERT INTO areas (id, codigo, nombre, descripcion) VALUES
    (1, 'SOPORTE_INFORMATICO', 'Soporte informático',
     'Hardware, software, red, cuentas y equipos.'),
    (2, 'MANTENIMIENTO', 'Mantenimiento',
     'Infraestructura, mobiliario e instalaciones.'),
    (3, 'SERVICIOS_GENERALES', 'Servicios generales',
     'Limpieza, seguridad y servicios comunes.'),
    (4, 'BIBLIOTECA', 'Biblioteca',
     'Préstamos, catálogo y espacios de biblioteca.');

INSERT INTO prioridades (id, codigo, nombre, nivel, color) VALUES
    (1, 'BAJA', 'Baja', 1, '#6B7280'),
    (2, 'MEDIA', 'Media', 2, '#F59E0B'),
    (3, 'ALTA', 'Alta', 3, '#EF4444'),
    (4, 'CRITICA', 'Crítica', 4, '#991B1B');

INSERT INTO estados_solicitud
    (id, codigo, nombre, descripcion, es_final, orden) VALUES
    (1, 'NUEVO', 'Nuevo', 'Registrada y pendiente de evaluación.', 0, 1),
    (2, 'ASIGNADO', 'Asignado', 'Con técnico responsable asignado.', 0, 2),
    (3, 'EN_PROCESO', 'En proceso', 'El técnico inició la atención.', 0, 3),
    (4, 'RESUELTO', 'Resuelto', 'Atendida, pendiente de cierre por el supervisor.', 0, 4),
    (5, 'CERRADO', 'Cerrado', 'Cierre conforme; estado final.', 1, 5),
    (6, 'RECHAZADO', 'Rechazado', 'Improcedente o duplicada; estado final.', 1, 6);

INSERT INTO categorias
    (id, area_id, prioridad_predeterminada_id, codigo, nombre, descripcion) VALUES
    (1, 1, 2, 'SOPORTE_INFORMATICO', 'Soporte informático',
     'Problemas de hardware, software, red o cuentas.'),
    (2, 2, 2, 'MANTENIMIENTO', 'Mantenimiento',
     'Infraestructura, mobiliario e instalaciones.'),
    (3, 3, 1, 'SERVICIOS_GENERALES', 'Servicios generales',
     'Limpieza, seguridad y servicios comunes.'),
    (4, 4, 1, 'BIBLIOTECA', 'Biblioteca',
     'Préstamos, catálogo y espacios de biblioteca.');

INSERT INTO transiciones_estado
    (id, estado_origen_id, estado_destino_id, rol_id, requiere_motivo) VALUES
    (1, 1, 2, 3, 0),  -- NUEVO -> ASIGNADO (Supervisor)
    (2, 1, 6, 3, 1),  -- NUEVO -> RECHAZADO (Supervisor)
    (3, 2, 3, 2, 0),  -- ASIGNADO -> EN_PROCESO (Técnico)
    (4, 2, 6, 3, 1),  -- ASIGNADO -> RECHAZADO (Supervisor)
    (5, 3, 4, 2, 0),  -- EN_PROCESO -> RESUELTO (Técnico)
    (6, 3, 6, 3, 1),  -- EN_PROCESO -> RECHAZADO (Supervisor)
    (7, 4, 5, 3, 0);  -- RESUELTO -> CERRADO (Supervisor)

INSERT INTO politicas_sla
    (id, prioridad_id, categoria_id, horas_objetivo, horas_aviso) VALUES
    (1, 1, NULL, 72, 12),  -- Baja
    (2, 2, NULL, 48, 8),   -- Media
    (3, 3, NULL, 24, 4),   -- Alta
    (4, 4, NULL, 8, 2),    -- Crítica
    (5, NULL, 1, 24, 4);   -- Soporte informático (prevalece sobre prioridad)

-- ============================================================
-- Reservas de ambientes (EP-07)
-- ============================================================

-- ------------------------------------------------------------
-- 17. tipos_espacio
-- ------------------------------------------------------------
CREATE TABLE tipos_espacio (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_tipos_espacio_codigo (codigo),
    UNIQUE KEY uk_tipos_espacio_nombre (nombre),
    CONSTRAINT chk_tipos_espacio_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 18. espacios
-- ------------------------------------------------------------
CREATE TABLE espacios (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo_espacio_id BIGINT UNSIGNED NOT NULL,
    area_id BIGINT UNSIGNED NULL,
    codigo VARCHAR(40) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(255) NULL,
    pabellon VARCHAR(60) NOT NULL DEFAULT '',
    piso VARCHAR(20) NULL,
    ubicacion_detallada VARCHAR(255) NULL,
    capacidad SMALLINT UNSIGNED NOT NULL,
    requiere_aprobacion TINYINT UNSIGNED NOT NULL DEFAULT 1,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_espacios_codigo (codigo),
    UNIQUE KEY uk_espacios_nombre_pabellon (nombre, pabellon),
    KEY idx_espacios_tipo_activo (tipo_espacio_id, activo),
    KEY idx_espacios_area_activo (area_id, activo),
    KEY idx_espacios_pabellon_activo (pabellon, activo),
    CONSTRAINT fk_espacios_tipo FOREIGN KEY (tipo_espacio_id)
        REFERENCES tipos_espacio (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_espacios_area FOREIGN KEY (area_id)
        REFERENCES areas (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_espacios_capacidad CHECK (capacidad > 0),
    CONSTRAINT chk_espacios_requiere_aprobacion
        CHECK (requiere_aprobacion IN (0, 1)),
    CONSTRAINT chk_espacios_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 19. horarios_espacio
-- ------------------------------------------------------------
CREATE TABLE horarios_espacio (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    espacio_id BIGINT UNSIGNED NOT NULL,
    dia_semana TINYINT UNSIGNED NOT NULL,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_horarios_espacio_dia (espacio_id, dia_semana),
    CONSTRAINT fk_horarios_espacio FOREIGN KEY (espacio_id)
        REFERENCES espacios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_horarios_dia CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_horarios_horas CHECK (hora_cierre > hora_apertura),
    CONSTRAINT chk_horarios_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 20. estados_reserva
-- ------------------------------------------------------------
CREATE TABLE estados_reserva (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(255) NULL,
    es_final TINYINT UNSIGNED NOT NULL DEFAULT 0,
    orden TINYINT UNSIGNED NOT NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_estados_reserva_codigo (codigo),
    UNIQUE KEY uk_estados_reserva_orden (orden),
    CONSTRAINT chk_estados_reserva_final CHECK (es_final IN (0, 1)),
    CONSTRAINT chk_estados_reserva_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 21. politicas_reserva
-- ------------------------------------------------------------
CREATE TABLE politicas_reserva (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    duracion_minima_minutos SMALLINT UNSIGNED NOT NULL DEFAULT 30,
    duracion_maxima_minutos SMALLINT UNSIGNED NOT NULL DEFAULT 240,
    dias_anticipacion_maxima SMALLINT UNSIGNED NOT NULL DEFAULT 30,
    horas_anticipacion_minima SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    max_reservas_activas_por_dia TINYINT UNSIGNED NOT NULL DEFAULT 2,
    vigente_desde DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    vigente_hasta DATETIME(6) NULL,
    activo TINYINT UNSIGNED NOT NULL DEFAULT 1,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_politicas_reserva_vigente (activo, vigente_desde),
    CONSTRAINT chk_politicas_reserva_duracion CHECK (
        duracion_minima_minutos > 0
        AND duracion_maxima_minutos >= duracion_minima_minutos
    ),
    CONSTRAINT chk_politicas_reserva_vigencia CHECK (
        vigente_hasta IS NULL OR vigente_hasta > vigente_desde
    ),
    CONSTRAINT chk_politicas_reserva_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 22. reservas
-- ------------------------------------------------------------
CREATE TABLE reservas (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL,
    espacio_id BIGINT UNSIGNED NOT NULL,
    solicitante_id BIGINT UNSIGNED NOT NULL,
    estado_id BIGINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    num_asistentes SMALLINT UNSIGNED NULL,
    aprobada_por_id BIGINT UNSIGNED NULL,
    aprobada_en DATETIME(6) NULL,
    motivo_rechazo TEXT NULL,
    cancelada_por_id BIGINT UNSIGNED NULL,
    cancelada_en DATETIME(6) NULL,
    version_fila INT UNSIGNED NOT NULL DEFAULT 0,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_reservas_codigo (codigo),
    UNIQUE KEY uk_reservas_franja_exacta (espacio_id, fecha, hora_inicio, estado_id),
    KEY idx_reservas_disponibilidad
        (espacio_id, fecha, estado_id, hora_inicio, hora_fin),
    KEY idx_reservas_solicitante (solicitante_id, fecha),
    KEY idx_reservas_estado_fecha (estado_id, fecha),
    KEY idx_reservas_aprobador (aprobada_por_id, aprobada_en),
    CONSTRAINT fk_reservas_espacio FOREIGN KEY (espacio_id)
        REFERENCES espacios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_reservas_solicitante FOREIGN KEY (solicitante_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_reservas_estado FOREIGN KEY (estado_id)
        REFERENCES estados_reserva (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_reservas_aprobador FOREIGN KEY (aprobada_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_reservas_cancelador FOREIGN KEY (cancelada_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_reservas_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT chk_reservas_motivo CHECK (CHAR_LENGTH(TRIM(motivo)) > 0),
    CONSTRAINT chk_reservas_asistentes
        CHECK (num_asistentes IS NULL OR num_asistentes > 0),
    CONSTRAINT chk_reservas_aprobacion CHECK (
        (aprobada_por_id IS NULL AND aprobada_en IS NULL)
        OR (aprobada_por_id IS NOT NULL AND aprobada_en IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 23. historial_estados_reserva
-- ------------------------------------------------------------
CREATE TABLE historial_estados_reserva (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    reserva_id BIGINT UNSIGNED NOT NULL,
    estado_origen_id BIGINT UNSIGNED NULL,
    estado_destino_id BIGINT UNSIGNED NOT NULL,
    cambiado_por_id BIGINT UNSIGNED NOT NULL,
    motivo TEXT NULL,
    cambiado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_historial_reserva (reserva_id, cambiado_en),
    KEY idx_historial_reserva_origen (estado_origen_id),
    KEY idx_historial_reserva_destino (estado_destino_id),
    KEY idx_historial_reserva_usuario (cambiado_por_id),
    CONSTRAINT fk_historial_reserva FOREIGN KEY (reserva_id)
        REFERENCES reservas (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_reserva_origen FOREIGN KEY (estado_origen_id)
        REFERENCES estados_reserva (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_reserva_destino FOREIGN KEY (estado_destino_id)
        REFERENCES estados_reserva (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_historial_reserva_usuario FOREIGN KEY (cambiado_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_historial_reserva_distintos CHECK (
        estado_origen_id IS NULL OR estado_origen_id <> estado_destino_id
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 24. secuencias_codigo_reserva
-- ------------------------------------------------------------
CREATE TABLE secuencias_codigo_reserva (
    anio SMALLINT UNSIGNED NOT NULL,
    ultimo_valor INT UNSIGNED NOT NULL DEFAULT 0,
    actualizado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (anio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- 25. adjuntos_solicitud (HU-26)
-- ------------------------------------------------------------
CREATE TABLE adjuntos_solicitud (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    solicitud_id BIGINT UNSIGNED NOT NULL,
    autor_id BIGINT UNSIGNED NOT NULL,
    nombre_original VARCHAR(255) NOT NULL,
    proveedor_almacenamiento VARCHAR(20) NOT NULL DEFAULT 'SUPABASE',
    clave_objeto VARCHAR(500) NOT NULL,
    tipo_mime VARCHAR(100) NOT NULL,
    tamano_bytes INT UNSIGNED NOT NULL,
    hash_sha256 CHAR(64) NOT NULL,
    creado_en DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    eliminado_en DATETIME(6) NULL,
    eliminado_por_id BIGINT UNSIGNED NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_adjuntos_clave_objeto (clave_objeto),
    KEY idx_adjuntos_solicitud (solicitud_id, eliminado_en, creado_en),
    KEY idx_adjuntos_autor (autor_id),
    CONSTRAINT fk_adjuntos_solicitud FOREIGN KEY (solicitud_id)
        REFERENCES solicitudes (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_adjuntos_autor FOREIGN KEY (autor_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_adjuntos_eliminado_por FOREIGN KEY (eliminado_por_id)
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_adjuntos_nombre
        CHECK (CHAR_LENGTH(TRIM(nombre_original)) > 0),
    CONSTRAINT chk_adjuntos_proveedor
        CHECK (proveedor_almacenamiento IN ('SUPABASE', 'LOCAL')),
    CONSTRAINT chk_adjuntos_tipo
        CHECK (tipo_mime IN ('image/jpeg', 'image/png', 'application/pdf')),
    CONSTRAINT chk_adjuntos_tamano
        CHECK (tamano_bytes BETWEEN 1 AND 5242880),
    CONSTRAINT chk_adjuntos_eliminacion
        CHECK ((eliminado_en IS NULL AND eliminado_por_id IS NULL)
               OR (eliminado_en IS NOT NULL AND eliminado_por_id IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
-- Vistas de reservas
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_reservas_detalle AS
SELECT
    r.id,
    r.codigo,
    r.espacio_id,
    esp.nombre AS espacio,
    te.nombre AS tipo_espacio,
    a.nombre AS area,
    r.solicitante_id,
    sol.nombre_completo AS solicitante,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.motivo,
    r.num_asistentes,
    r.estado_id,
    er.codigo AS estado_codigo,
    er.nombre AS estado,
    er.es_final,
    r.aprobada_por_id,
    apr.nombre_completo AS aprobador,
    r.aprobada_en,
    r.motivo_rechazo,
    r.cancelada_por_id,
    r.cancelada_en,
    r.creado_en,
    r.actualizado_en
FROM reservas r
JOIN espacios esp ON esp.id = r.espacio_id
JOIN tipos_espacio te ON te.id = esp.tipo_espacio_id
LEFT JOIN areas a ON a.id = esp.area_id
JOIN usuarios sol ON sol.id = r.solicitante_id
JOIN estados_reserva er ON er.id = r.estado_id
LEFT JOIN usuarios apr ON apr.id = r.aprobada_por_id;

CREATE OR REPLACE VIEW vw_reservas_operativas AS
SELECT
    r.id AS reserva_id,
    r.codigo,
    r.espacio_id,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.estado_id,
    er.codigo AS estado_codigo,
    CASE
        WHEN er.codigo <> 'CONFIRMADA' THEN er.codigo
        WHEN TIMESTAMP(r.fecha, r.hora_fin) < UTC_TIMESTAMP(6) THEN 'FINALIZADA'
        WHEN TIMESTAMP(r.fecha, r.hora_inicio) <= UTC_TIMESTAMP(6) THEN 'EN_CURSO'
        ELSE 'PROXIMA'
    END AS estado_operativo
FROM reservas r
JOIN estados_reserva er ON er.id = r.estado_id;

-- ------------------------------------------------------------
-- Datos semilla de reservas (catálogos y ambientes de demostración)
-- ------------------------------------------------------------
INSERT INTO tipos_espacio (id, codigo, nombre, descripcion) VALUES
    (1, 'AULA', 'Aula', 'Espacio para clases y actividades académicas.'),
    (2, 'LABORATORIO', 'Laboratorio', 'Espacio equipado para prácticas.'),
    (3, 'SALA_ESTUDIO', 'Sala de estudio', 'Espacio para estudio individual o grupal.'),
    (4, 'AUDITORIO', 'Auditorio', 'Espacio para eventos y presentaciones.'),
    (5, 'SALA_REUNIONES', 'Sala de reuniones', 'Espacio para reuniones de trabajo.'),
    (6, 'OTRO', 'Otro', 'Ambiente no clasificado en las categorías anteriores.');

INSERT INTO estados_reserva
    (id, codigo, nombre, descripcion, es_final, orden) VALUES
    (1, 'PENDIENTE', 'Pendiente', 'Registrada y pendiente de aprobación.', 0, 1),
    (2, 'CONFIRMADA', 'Confirmada', 'Aprobada por el responsable del área.', 0, 2),
    (3, 'RECHAZADA', 'Rechazada', 'Rechazada con motivo; estado final.', 1, 3),
    (4, 'CANCELADA', 'Cancelada', 'Cancelada por el solicitante o el administrador; estado final.', 1, 4);

INSERT INTO espacios
    (id, tipo_espacio_id, area_id, codigo, nombre, descripcion, pabellon, piso,
     ubicacion_detallada, capacidad, requiere_aprobacion) VALUES
    (1, 2, 1, 'LAB-204', 'Laboratorio 204', 'Laboratorio de cómputo.',
     'Pabellón nuevo', '2', 'Laboratorio 204 - Pabellón nuevo', 30, 1),
    (2, 1, NULL, 'AULA-101', 'Aula 101', 'Aula teórica.',
     'Pabellón antiguo', '1', 'Aula 101 - Pabellón antiguo', 40, 1),
    (3, 3, 4, 'SALA-EST-01', 'Sala de estudio 1', 'Sala de estudio grupal.',
     'Biblioteca', '1', 'Sala de estudio 1 - Biblioteca', 12, 1),
    (4, 4, NULL, 'AUD-01', 'Auditorio principal', 'Auditorio para eventos.',
     'Pabellón central', '1', 'Auditorio principal - Pabellón central', 200, 1),
    (5, 5, 2, 'SALA-REU-01', 'Sala de reuniones 1', 'Sala para reuniones.',
     'Pabellón administrativo', '2', 'Sala de reuniones 1 - Pabellón administrativo', 10, 1);

INSERT INTO horarios_espacio (espacio_id, dia_semana, hora_apertura, hora_cierre)
SELECT e.id, d.dia, '07:00:00', '22:00:00'
FROM espacios e
CROSS JOIN (
    SELECT 1 AS dia UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5
) d;

INSERT INTO horarios_espacio (espacio_id, dia_semana, hora_apertura, hora_cierre)
VALUES (3, 6, '08:00:00', '13:00:00');

INSERT INTO politicas_reserva
    (duracion_minima_minutos, duracion_maxima_minutos, dias_anticipacion_maxima,
     horas_anticipacion_minima, max_reservas_activas_por_dia, vigente_desde, activo)
VALUES
    (30, 240, 30, 1, 2, UTC_TIMESTAMP(6), 1);
```

---

## 16. Anexo B: verificación

### 16.1. Comprobaciones de estructura

```sql
SHOW TABLES;

SELECT codigo, nombre, es_final, orden
FROM estados_solicitud
ORDER BY orden;

SELECT
    o.codigo AS origen,
    d.codigo AS destino,
    r.codigo AS rol,
    t.requiere_motivo
FROM transiciones_estado t
JOIN estados_solicitud o ON o.id = t.estado_origen_id
JOIN estados_solicitud d ON d.id = t.estado_destino_id
JOIN roles r ON r.id = t.rol_id
ORDER BY o.orden, d.orden;

SELECT * FROM vw_solicitudes_detalle LIMIT 10;
SELECT * FROM vw_estado_sla LIMIT 10;
```

### 16.2. Comprobaciones de integridad

```sql
-- Debe fallar: categoría sin área (NOT NULL).
INSERT INTO categorias
    (area_id, prioridad_predeterminada_id, codigo, nombre)
VALUES (NULL, 1, 'PRUEBA', 'Prueba');

-- Debe fallar: calificación fuera de 1..5.
INSERT INTO encuestas_satisfaccion
    (solicitud_id, respondida_por_id, calificacion)
VALUES (999999, 999999, 6);

-- Debe fallar: dos asignaciones activas para la misma solicitud.
-- (Requiere una solicitud existente; se prueba en un entorno de test.)
```

### 16.3. `EXPLAIN` de consultas críticas

```sql
EXPLAIN FORMAT=JSON
SELECT s.id, s.codigo
FROM solicitudes s
WHERE s.solicitante_id = 1
ORDER BY s.creado_en DESC
LIMIT 20;

EXPLAIN FORMAT=JSON
SELECT s.id, s.codigo
FROM solicitudes s
JOIN estados_solicitud e ON e.id = s.estado_id
WHERE s.area_id = 1
  AND e.codigo = 'NUEVO'
  AND s.prioridad_id = 3
ORDER BY s.creado_en ASC
LIMIT 20;

EXPLAIN FORMAT=JSON
SELECT s.id, s.codigo
FROM solicitudes s
WHERE s.responsable_actual_id = 2
  AND s.estado_id IN (2, 3)
ORDER BY s.prioridad_id DESC, s.creado_en ASC
LIMIT 20;
```

### 16.4. Checklist de aceptación del diseño

- [ ] El DDL crea las 25 tablas y 4 vistas sin errores en MySQL 8.4.13.
- [ ] `chk_usuarios_estado_cuenta` y `chk_usuarios_motivo_rechazo` rechazan estados inválidos y rechazos sin motivo.
- [ ] `chk_adjuntos_tipo` y `chk_adjuntos_tamano` rechazan tipos no permitidos y archivos de más de 5 MB.
- [ ] Los `CHECK` de reservas rechazan franjas invertidas, textos vacíos y capacidades no positivas.
- [ ] `uk_reservas_franja_exacta` impide duplicar una franja exacta en el mismo estado.
- [ ] `EXPLAIN` de disponibilidad usa un índice de `reservas` que cubra `espacio_id` y `fecha` (`idx_reservas_disponibilidad` o `uk_reservas_franja_exacta`).
- [ ] Los seeds cargan tipos de espacio, estados de reserva, espacios, horarios y política.
- [ ] Los `CHECK` rechazan calificaciones fuera de rango, políticas SLA inválidas y textos vacíos.
- [ ] `uk_asignaciones_activa` impide dos asignaciones activas.
- [ ] `uk_encuestas_solicitud` impide dos encuestas por solicitud.
- [ ] Los seeds cargan roles, áreas, prioridades, estados, categorías, transiciones y SLA.
- [ ] Las consultas de los 9 indicadores devuelven datos coherentes con los seeds.
- [ ] `EXPLAIN` muestra uso de índices en “mis solicitudes”, bandeja del área y bandeja del técnico.
- [ ] `ARCHITECTURE.md` usa el ciclo de vida de las HU y los nombres de tablas en español.


### 16.5. Comprobaciones de reservas

```sql
-- Debe fallar: hora_fin <= hora_inicio.
INSERT INTO reservas
    (codigo, espacio_id, solicitante_id, estado_id, fecha, hora_inicio, hora_fin, motivo)
VALUES
    ('RES-2026-999999', 1, 1, 1, '2026-11-10', '12:00:00', '11:00:00', 'Prueba inválida');

-- Debe fallar: duplicado exacto de franja.
INSERT INTO reservas
    (codigo, espacio_id, solicitante_id, estado_id, fecha, hora_inicio, hora_fin, motivo)
VALUES
    ('RES-2026-999998', 1, 1, 1, '2026-11-10', '10:00:00', '12:00:00', 'Prueba'),
    ('RES-2026-999997', 1, 1, 1, '2026-11-10', '10:00:00', '11:00:00', 'Duplicado');

-- Debe fallar: capacidad cero.
INSERT INTO espacios (tipo_espacio_id, codigo, nombre, capacidad)
VALUES (1, 'PRUEBA-0', 'Prueba', 0);

-- Debe fallar: horario con cierre anterior a la apertura.
INSERT INTO horarios_espacio (espacio_id, dia_semana, hora_apertura, hora_cierre)
VALUES (1, 7, '18:00:00', '08:00:00');

EXPLAIN FORMAT=JSON
SELECT hora_inicio, hora_fin
FROM reservas
WHERE espacio_id = 1
  AND fecha = '2026-11-10'
  AND estado_id IN (1, 2)
ORDER BY hora_inicio;
```

> Los `INSERT` requieren que existan el espacio y el usuario referenciados por las FK. Ejecutar estas comprobaciones en una base de prueba con los seeds cargados y descartar la base al terminar.

---

## 17. Decisiones pendientes

| Tema | Estado | Responsable |
| --- | --- | --- |
| Catálogo real de áreas y categorías de la universidad. | Pendiente de validación con el negocio. | Producto / administrador. |
| Valores definitivos de SLA por prioridad/categoría. | Los seeds son ejemplos demostrativos. | Administrador. |
| Política de retención de `auditoria_eventos`. | Sin definir; evaluar a partir del volumen real. | Infraestructura / backend. |
| Implementación de adjuntos. | Resuelto: HU-26, tabla 6.25 y Supabase Storage (ADR-0004). | — |
| Dominio institucional permitido en el auto-registro. | Resuelto: `unmsm.edu.pe` ([decisiones 01](docs/decisiones/decisiones-01.md)). | — |
| Límites definitivos de evidencias (5 archivos, 5 MB, JPG/PNG/PDF). | Valores iniciales del equipo; ajustables. | Producto. |
| Multi-rol por usuario. | Se asume un rol por usuario (HU-15). | Producto. |
| Nombres visibles definitivos de los estados. | Editables por administración (HU-17). | Administrador. |
| Catálogo real de espacios, pabellones y horarios de la universidad. | Pendiente de validación con el negocio. | Producto / administrador. |
| Aprobación de reservas por área frente a aprobación centralizada. | Se adopta área con respaldo del administrador. | Producto. |
| Feriados y días no laborables. | Sin definir; hoy se valida solo el horario semanal. | Administrador / backend. |
| Límites definitivos de la política de reservas. | Los seeds son ejemplos demostrativos. | Administrador. |
| Notificaciones de aprobación, rechazo y cancelación. | Fuera de alcance inicial de EP-07. | Producto. |
| Reservas recurrentes o periódicas. | Fuera de alcance inicial de EP-07. | Producto. |

---

**Fin del documento.**
