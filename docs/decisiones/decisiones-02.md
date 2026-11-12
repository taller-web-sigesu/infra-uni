# Decisiones 02 — Rol Docente

- **Fecha:** 2026-11-12
- **Origen:** equipo.

| # | Tema | Decisión | Qué implica |
| --- | --- | --- | --- |
| D4 | Permisos del docente | **Igual que el estudiante.** Registra y sigue solicitudes, adjunta evidencias, comenta, responde la encuesta y reserva ambientes con la misma política. | Rol `DOCENTE` nuevo; las HU de solicitudes y la encuesta pasan a decir «solicitante (estudiante o docente)». Sin tablas ni pantallas nuevas. |
| D5 | Cuenta del docente | **Solo la crea el administrador** (HU-15). El auto-registro sigue siendo solo para estudiantes. | HU-15 suma CA-02 y el escenario 15.2; HU-27 rechaza pedir el rol Docente. |
| D6 | Área del docente | **Sin área**, como el estudiante. | `usuarios.area_id = NULL` para `DOCENTE`. |

## Cambios hechos

- HU-02, HU-03 a HU-06, HU-15, HU-20, HU-26 y HU-27; requisitos funcionales RF-03 a RF-08, RF-24 y RF-31.
- [`DISENIO-BD.md`](../../DISENIO-BD.md): rol `DOCENTE` en el catálogo, las semillas y el DDL; decisión D-27.
- [`ALCANCE-POR-ROL.html`](../ALCANCE-POR-ROL.html), [`ALCANCE-POR-ROL.md`](../ALCANCE-POR-ROL.md) y [`ARCHITECTURE.md`](../ARCHITECTURE.md).
- Documentación de la API en `backend-uni` y planes de frontend y Figma en `frontend-uni`.

## Pendiente

- Figma: leyenda de roles, matriz rol × pantalla, selector de rol en P12 y etiqueta «Docente» en topbar y perfil. Detalle en [`falta-implementar-03.md`](https://github.com/taller-web-sigesu/frontend-uni/blob/main/docs/FIGMA/v2/falta-implementar-03.md) de frontend-uni.
