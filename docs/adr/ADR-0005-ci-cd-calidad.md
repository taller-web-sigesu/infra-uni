# ADR-0005: CI/CD y puertas de calidad

- **Estado:** Propuesto
- **Fecha:** 2026-11-04
- **Decisores:** Equipo del proyecto Gestal
- **Requisitos afectados:** RNF-14
- **Documentos relacionados:** [ARCHITECTURE.md](../ARCHITECTURE.md)

## Contexto

Los tres repositorios no tienen workflows de integración continua. La arquitectura exige pruebas automatizadas, análisis estático, SAST/DAST, build de imagen y smoke tests, pero hoy no existe ninguna puerta que impida integrar código roto. La política de ramas exige PR revisada y `main` protegida.

## Decisión

1. **GitHub Actions por repositorio**, con workflows independientes y `main` protegida.
2. **Backend:** `mvn verify` con unitarias y Testcontainers MySQL; análisis estático; escaneo de dependencias; build y publicación de imagen Docker; smoke test en staging.
3. **Frontend:** `npm ci`, lint, tests con Vitest, build de producción y smoke/E2E con Playwright cuando el entorno lo permita.
4. **Infraestructura:** `docker compose config`, validación de scripts, escaneo de secretos y verificación de enlaces/documentos.
5. **Seguridad:** SAST en backend y frontend; OWASP ZAP baseline contra staging autorizado; reporte archivado.
6. **Carga:** k6 para un escenario mínimo de humo y latencia antes de producción.
7. **Puertas obligatorias:** compilación, tests, lint y build. Un PR no se integra con checks fallidos.
8. **Evidencia:** cada ejecución conserva reportes y artefactos; no se declara una prueba aprobada sin revisar la salida.
9. **Secretos:** solo en GitHub Secrets o el proveedor; nunca en logs ni artefactos.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
| --- | --- |
| Sin CI, validación manual | No hay evidencia reproducible y se integran errores. |
| Un único workflow para los tres repos | Los repos son independientes y tienen stacks distintos. |
| Solo build, sin tests | No cubre reglas de negocio ni integración con MySQL. |
| Despliegue automático a producción en cada push | Riesgo alto sin aprobación ni staging. |

## Consecuencias

- Hay que mantener los workflows y las versiones de las acciones.
- Testcontainers requiere Docker en el runner.
- Los tiempos de CI aumentan con integración, SAST y E2E; se aceptan por la calidad exigida.
- La protección de `main` y la revisión por otro integrante son obligatorias.
