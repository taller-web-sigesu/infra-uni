# Decisiones 01 — Alcance del Módulo 1 y 2

- **Fecha:** 2026-11-11
- **Origen:** equipo. Resuelve la sección 7.1 a 7.3 de la [auditoría 01](../auditorias/auditoria-01/AUDITORIA-ALCANCE.md#7-decisiones-que-bloquean-la-fase-iiii).

| # | Tema | Decisión | Qué implica |
| --- | --- | --- | --- |
| D1 | Evidencias en la solicitud | **Sí, completo.** Adjuntar, ver y eliminar archivos en la solicitud, con almacenamiento en la nube en producción. | Tabla `adjuntos_solicitud`, endpoints `multipart/form-data`, validación de tipo y tamaño, acceso solo a quien puede ver la solicitud. En local, volumen Docker. |
| D2 | Registro de usuarios | **Auto-registro con aprobación del administrador.** El estudiante se registra con correo institucional; la cuenta queda pendiente hasta que el admin la aprueba o rechaza. | Rol por defecto Estudiante, sin correo de verificación, estado de cuenta pendiente, pantalla de registro y bandeja de aprobación para el admin. |
| D3 | Recuperación de contraseña | **Cambio de contraseña + restablecimiento por el administrador.** Sin recuperación por correo. | El admin genera una contraseña temporal y el usuario debe cambiarla al ingresar. El usuario puede cambiar su contraseña desde el perfil. |

## Pendiente antes de implementar

- [ ] Crear las HU nuevas: evidencias (EP-02), auto-registro y aprobación (EP-01/EP-05), restablecimiento por admin (EP-05).
- [ ] Actualizar `DISENIO-BD.md`: tabla `adjuntos_solicitud` y estado de cuenta pendiente en `usuarios`.
- [ ] Elegir el almacén en la nube para evidencias (S3, Cloudinary o Supabase) y registrarlo en `ADR-0004`.
- [ ] Reflejar D1–D3 en `ALCANCE-POR-ROL.html`.

Mientras falten las HU, la IA no debe implementar estas funciones: la regla es no inventar requisitos.
