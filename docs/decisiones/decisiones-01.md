# Decisiones 01 — Alcance del Módulo 1 y 2

- **Fecha:** 2026-11-11
- **Origen:** equipo. Resuelve la sección 7.1 a 7.3 de la [auditoría 01](../auditorias/auditoria-01/AUDITORIA-ALCANCE.md#7-decisiones-que-bloquean-la-fase-iiii).

| # | Tema | Decisión | Qué implica |
| --- | --- | --- | --- |
| D1 | Evidencias en la solicitud | **Sí, completo.** Adjuntar, ver y eliminar archivos en la solicitud, con almacenamiento en la nube en producción. | Tabla `adjuntos_solicitud`, endpoints `multipart/form-data`, validación de tipo y tamaño, acceso solo a quien puede ver la solicitud. En local, volumen Docker. |
| D2 | Registro de usuarios | **Auto-registro con aprobación del administrador.** El estudiante se registra con su correo institucional `@unmsm.edu.pe`; la cuenta queda pendiente hasta que el admin la aprueba o rechaza. | Rol por defecto Estudiante, sin correo de verificación, estado de cuenta pendiente, pantalla de registro y bandeja de aprobación para el admin. |
| D3 | Recuperación de contraseña | **Cambio de contraseña + restablecimiento por el administrador.** Sin recuperación por correo. | El admin genera una contraseña temporal y el usuario debe cambiarla al ingresar. El usuario puede cambiar su contraseña desde el perfil. |

## Pendientes resueltos

- [x] HU nuevas: [HU-26](../requirements/user-stories/EP-02-Solicitudes/HU-26-Adjuntar-Evidencias-Solicitud.md) evidencias, [HU-27](../requirements/user-stories/EP-01-Autenticacion/HU-27-Registrarse-En-El-Sistema.md) auto-registro, [HU-28](../requirements/user-stories/EP-05-Administracion/HU-28-Aprobar-Rechazar-Cuentas.md) aprobar cuentas y [HU-29](../requirements/user-stories/EP-05-Administracion/HU-29-Restablecer-Contrasena-Usuario.md) restablecer contraseña. Requisitos RF-31 a RF-34 y RNF-19.
- [x] [`DISENIO-BD.md`](../../DISENIO-BD.md): tabla `adjuntos_solicitud` (6.25), estado de cuenta en `usuarios` (6.2) y reglas 7.9 y 7.10.
- [x] Almacén de evidencias: **Supabase Storage**, bucket privado por entorno ([ADR-0004](../adr/ADR-0004-despliegue-persistencia.md), punto 10).
- [x] [`ALCANCE-POR-ROL.html`](../ALCANCE-POR-ROL.html) actualizado.
- [x] Dominio institucional del auto-registro: `unmsm.edu.pe` (solo ese dominio, sin subdominios).

## Aún por definir

- Crear la cuenta y los proyectos de Supabase (staging y producción) cuando llegue la Fase 5.
