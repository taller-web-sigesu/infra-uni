# Pruebas asistidas por IA — proceso y revisión

- **Fecha:** 14/11/2026
- **Alcance:** generación, revisión y registro de pruebas unitarias, de integración, E2E y de API con asistencia de IA.
- **Herramientas permitidas:** asistentes de código conectados al repositorio. No se envían secretos, credenciales reales ni datos personales a los modelos.

## 1. Cuándo usar IA

Se puede usar IA para:

- proponer casos límite y datos de prueba;
- redactar esqueletos de pruebas unitarias o de integración;
- explicar una falla y proponer una reproducción;
- revisar nombres, legibilidad y duplicación en pruebas.

No se usa IA para:

- aprobar una prueba sin ejecutarla;
- inventar respuestas de la API o códigos HTTP;
- generar credenciales o secretos;
- sustituir la revisión de reglas de negocio.

## 2. Flujo obligatorio

1. **Contexto:** se entrega a la IA la HU, el criterio de aceptación, el contrato OpenAPI y el archivo de prueba existente.
2. **Generación:** la IA propone el caso, los datos y las aserciones.
3. **Revisión humana:** otra persona o el responsable técnico verifica:
   - que la prueba falle si se rompe la regla;
   - que no dependa de datos no deterministas;
   - que no use secretos ni datos personales;
   - que respete el rol y el alcance;
   - que no agregue esperas arbitrarias;
   - que el nombre describa el comportamiento.
4. **Ejecución:** se corre la prueba de forma local y en CI.
5. **Registro:** se agrega una fila en `docs/ai/AI_USAGE_LOG.md` con herramienta, prompt, resultado, validación y modificaciones.

## 3. Checklist de revisión

- [ ] La prueba falla si se elimina la regla que protege.
- [ ] Usa fixtures deterministas o un reloj controlado.
- [ ] No comparte estado entre pruebas.
- [ ] Verifica status HTTP, cuerpo y efecto en base cuando aplica.
- [ ] Cubre el caso feliz y al menos un caso negativo.
- [ ] No introduce sleeps ni esperas fijas.
- [ ] No expone tokens, contraseñas ni datos reales.
- [ ] El nombre de la prueba describe el comportamiento, no la implementación.
- [ ] La prueba se ejecutó y su salida quedó en el reporte de CI.

## 4. Casos donde la IA aporta más valor

| Tipo | Uso recomendado |
| --- | --- |
| Unitarias | Casos límite de validadores, reglas de transición y cálculo de SLA |
| Integración | Combinaciones de rol, recurso y estado; errores 403/404/409 |
| E2E | Flujos por rol y estados vacíos |
| API | Contratos, códigos de error y validación de campos |
| Accesibilidad | Revisión de nombres accesibles y foco |

## 5. Registro

Cada sesión debe quedar en `infra-uni/docs/ai/AI_USAGE_LOG.md`. Como mínimo:

| Campo | Contenido |
| --- | --- |
| Fecha | Día de la sesión |
| Fase | Actividad o entrega |
| Repo | `frontend-uni`, `backend-uni` o `infra-uni` |
| Herramienta | Asistente y modelo |
| Prompt | Objetivo concreto |
| Resultado | Archivos o pruebas generadas |
| ¿Se usó? | Sí/No |
| Validación | Pruebas ejecutadas y revisión |
| Modificaciones | Cambios hechos tras la revisión |
| Responsable | Persona que revisó y aprobó |

## 6. Estado actual

El registro existe en `docs/ai/AI_USAGE_LOG.md`. Las filas históricas deben completar el campo **Responsable** y agregar las sesiones de QA, rediseño del login y despliegue staging.

## 7. Evidencia para la presentación

- Enlace al registro de IA.
- Una prueba generada o revisada con IA y su ejecución en CI.
- Checklist de revisión firmado por el responsable.
