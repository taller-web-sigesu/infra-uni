# Prompt maestro de pruebas — Gestal / UniService

> **Propósito:** guiar a un agente o a una persona para verificar comportamiento real, no la implementación.  
> **Proyecto:** Gestal / UniService — React 19 + Vite, Spring Boot 4, MySQL 8.4, Playwright, Vitest, JUnit 5 y Testcontainers.  
> **Regla de oro:** una prueba existe para detectar un fallo que importa; si no puede fallar por una razón de negocio, no es una prueba útil.

---

## 1. Prompt para el agente

Copia y pega este bloque como instrucción principal:

```text
Actúa como ingeniero de calidad senior del proyecto Gestal / UniService.

Tu objetivo es verificar que el sistema hace lo que el negocio necesita, no que el código
hace lo que el código ya hace. Prefiere pruebas E2E para las funciones complejas y usa
pruebas unitarias solo cuando aporten una señal distinta.

CONTEXTO
- Frontend: React 19 + Vite, React Router, MSW para la API simulada, Vitest + Testing Library.
- Backend: Spring Boot 4, JdbcClient, MySQL 8.4, Flyway, JUnit 5, Testcontainers.
- E2E: Playwright en escritorio (1440×900) y móvil (360×740).
- Comandos: `npm run lint`, `npm test`, `npm run build`, `npm run test:e2e`,
  `E2E_API=real npx playwright test --project=chromium`, `mvn -B verify`.

REGLAS OBLIGATORIAS
1. Prefiere altamente las pruebas E2E. Úsalas para verificar que las funciones complejas
   funcionan de extremo a extremo, con roles, permisos, estados y persistencia reales.
2. Antes de escribir una sola línea de código de prueba, enumera TODAS las formas en que
   el sistema podría fallar para ese flujo. Después escribe el código.
3. Al final de las pruebas E2E, produce un artefacto verificable y repetible: comando exacto,
   reporte HTML, trace/video/screenshot si falla, y un resumen legible de resultados.
4. Elige un escenario E2E de dificultad media o alta. No elijas el camino más simple solo
   para demostrar que “funciona”.
5. No escribas pruebas tautológicas. Una prueba que pasa sin poder fallar si se rompe la
   regla de negocio es perjudicial.
6. No escribas pruebas detectoras de cambios. No verifiques detalles internos, clases,
   nombres de métodos o estructura del código; verifica comportamiento observable.
7. No crees pruebas de regresión para corregir un bug si no existe una brecha genuina en
   las pruebas de comportamiento. Primero demuestra que el comportamiento no estaba cubierto.
8. Cada prueba debe fallar si se elimina la regla que protege. Si no falla, la prueba no sirve.
9. Usa datos deterministas, reloj controlado cuando aplique y fixtures explícitas.
10. No uses `sleep` ni esperas arbitrarias. Espera por condición observable.
11. No expongas tokens, contraseñas, datos personales ni secretos en pruebas, logs o capturas.
12. Nombra las pruebas con lenguaje de comportamiento: “el supervisor no puede aprobar su
    propia reserva”, no “testAssignDialogReturns403”.

FLUJO DE TRABAJO
Fase 1 — Riesgos:
- Lista los modos de fallo: permisos, estados inválidos, concurrencia, datos incompletos,
  límites, roles, persistencia, errores de red, accesibilidad y responsive.
- Clasifica cada riesgo por impacto y probabilidad.
- Define qué evidencia demostraría que el riesgo está cubierto.

Fase 2 — Escenarios:
- Escribe escenarios E2E de dificultad media/alta que crucen más de una capa.
- Incluye al menos un caso negativo y una regla de negocio.
- Evita el camino feliz trivial; usa estados intermedios, reasignaciones, conflictos,
  permisos cruzados o datos que cambian entre la consulta y el envío.

Fase 3 — Implementación:
- Implementa el escenario con Playwright.
- Usa roles, etiquetas y textos visibles; no selectores frágiles de CSS.
- Aísla los datos con sufijos únicos y limpia lo que creaste.
- Si el flujo es de backend, añade la prueba de integración con Testcontainers solo si
  aporta una señal que el E2E no puede dar.

Fase 4 — Evidencia:
- Ejecuta el comando exacto.
- Guarda el reporte y, si falla, el trace.
- Resume: escenario, resultado, evidencia, riesgos residuales.
- Indica claramente lo que NO se ejecutó y por qué.

CRITERIO DE CIERRE
Una prueba está terminada cuando:
- falla si se rompe la regla;
- pasa con la implementación correcta;
- no depende de otra prueba;
- no usa esperas arbitrarias;
- deja evidencia reproducible;
- su nombre describe el comportamiento;
- su escenario es de dificultad media o alta cuando es E2E.
```

---

## 2. Principios, en corto

| Principio | Qué significa | Qué evitar |
|---|---|---|
| **E2E primero** | Verifica el flujo completo: UI → API → MySQL → UI. | Unitarias que solo confirman que un mock devolvió lo que se le pidió. |
| **Falla primero** | Enumera los modos de fallo antes de escribir código. | Escribir la prueba después y acomodarla a lo que ya funciona. |
| **Comportamiento** | La prueba describe una regla de negocio observable. | Verificar nombres de funciones, clases o estructura interna. |
| **Señal real** | La prueba falla si se rompe la regla. | Pruebas que pasan siempre, incluso con el código roto. |
| **Escenario difícil** | Cruza roles, estados, permisos o concurrencia. | El camino feliz más corto. |
| **Evidencia** | Comando, reporte, trace y resumen. | “Funciona en mi máquina” sin artefacto. |
| **Determinismo** | Datos únicos, reloj controlado, sin sleeps. | `waitForTimeout(3000)` y datos compartidos. |
| **Regresión justificada** | Solo si había una brecha real de comportamiento. | Añadir una prueba por cada bug sin analizar la causa. |

---

## 3. Anti-patrones prohibidos

- **Tautológica:** `expect(true).toBe(true)`, o un mock que devuelve exactamente lo que la prueba espera sin pasar por la lógica.
- **Detectora de cambios:** verificar que una función se llama, que un componente tiene cierto nombre interno o que un archivo tiene cierta estructura.
- **Regresión sin brecha:** agregar una prueba solo porque hubo un bug, sin demostrar que el comportamiento no estaba cubierto.
- **Dependiente del orden:** una prueba que solo pasa si otra se ejecutó antes.
- **Espera arbitraria:** `sleep`, `waitForTimeout` o reintentos manuales para “que pase”.
- **Datos reales:** correos personales, tokens, contraseñas o información sensible.
- **Selector frágil:** `.css-1x2y3z`, índices de nodos o rutas internas.
- **Falso positivo:** una prueba que pasa aunque se elimine la regla que debería proteger.

---

## 4. Flujo recomendado para este proyecto

```text
1. Leer la HU y sus criterios de aceptación.
2. Escribir la lista de modos de fallo.
3. Elegir un escenario E2E de dificultad media/alta.
4. Implementar la prueba.
5. Ejecutarla y comprobar que falla si se rompe la regla.
6. Ejecutarla con el código correcto.
7. Guardar evidencia reproducible.
8. Actualizar la matriz HU → prueba.
```

### Comandos

```bash
# Frontend
npm run lint
npm test
npm run build
npm run test:e2e

# E2E contra el backend real (Compose de infra-uni)
E2E_API=real npx playwright test --project=chromium

# Backend
mvn -B verify
```

### Artefacto de evidencia

```text
Prueba:       solicitudes › HU-19: la auditoría registra asignación y prioridad…
Comando:      npx playwright test e2e/solicitudes.spec.js -g "HU-19"
Resultado:    2/2 en verde (chromium y mobile)
Evidencia:    playwright-report/ y trace en test-results/
Riesgos:      el escenario real se repite tras desplegar el catálogo de prioridades
No ejecutado: pruebas de carga y DAST (Fase IV)
```

---

## 5. Checklist de revisión

- [ ] La prueba falla si se elimina la regla de negocio.
- [ ] El escenario E2E es de dificultad media o alta.
- [ ] Cubre al menos un caso negativo o un permiso cruzado.
- [ ] Usa datos únicos y no contamina otras pruebas.
- [ ] No usa `sleep` ni esperas arbitrarias.
- [ ] No verifica detalles internos de implementación.
- [ ] No es tautológica.
- [ ] No es detectora de cambios.
- [ ] No es una regresión sin brecha de comportamiento.
- [ ] Deja un artefacto verificable y repetible.
- [ ] El nombre describe el comportamiento, no la implementación.
- [ ] Se actualizó la matriz HU → prueba.

---

---

## 6. Evidencia de la última ejecución

| Dato | Resultado |
|---|---|
| **Fecha** | 2026-11-16 |
| **Comando E2E simulado** | `npm run test:e2e` |
| **Resultado E2E simulado** | **52 en verde y 2 omitidas** (proyectos `chromium` y `mobile`) |
| **Comando E2E real** | `E2E_API=real npx playwright test -g "HU-1[69]" --project=chromium` |
| **Resultado E2E real** | **2 de 2 en verde** (`HU-16` y `HU-19`) contra el Compose local del RC.2 |
| **Casos nuevos** | `administracion › HU-16…` y `solicitudes › HU-19…` |
| **Reporte** | `frontend-uni/playwright-report/` |
| **Trazas de fallo** | `frontend-uni/test-results/` |
| **Unitarias afectadas** | **57 pruebas en verde** en 6 archivos: catálogos, gestión, dashboard, detalle y mocks |
| **Lint / build** | `npm run lint` y `npm run build` en verde |
| **Backend** | `mvn -B verify` en CI de `main` y en el deploy de producción del RC.2 |
| **No ejecutado en host** | `mvn -B verify` local: requiere Java 21/Maven; sí se ejecutó en GitHub Actions |

**Lectura correcta:** los E2E nuevos se validaron en simulado y en real contra el Compose local. El backend de staging aún no refleja el cambio de prioridades; producción sí está actualizada y el deploy/smoke pasó.

> **Recordatorio:** el objetivo no es tener muchas pruebas, sino tener pruebas que puedan fallar por la razón correcta. Una prueba que no puede fallar no protege nada.
