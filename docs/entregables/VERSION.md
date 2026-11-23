# Versión definitiva — Gestal / UniService

| Campo | Valor |
| :---- | :---- |
| Sistema | Sistema Web Inteligente para la Gestión Integral de Servicios Universitarios (Gestal / UniService) |
| Versión | **`v1.0.0`**: release final de la Fase IV |
| Versión anterior | `v1.0.0-rc.2`: Release Candidate de la Fase III, 16/11/2026 |
| Fecha del documento | 22/11/2026 |
| Curso | Taller de construcción de software web, 2026-II, UNMSM, FISI |
| Profesor | Candela Arce, David Felix |
| Equipo | Grupo 3 |
| Organización GitHub | [taller-web-sigesu](https://github.com/taller-web-sigesu) |

## 1. Responsables

Integrantes del Grupo 3:

| Integrante |
| :---- |
| Sebastian Andree Tejeda Alata (líder) |
| Marcos Luis Basualdo Ale |
| Bizarro Ortiz Luis Junior Alfredo |
| Gianpierre Rodrigo Dulanto Romero |
| Albert Marco Aurelio Huaman Ñahuinlla |

## 2. Repositorios y commits

Cada repositorio tiene su propio tag `v1.0.0`. El tag apunta al último commit de `main` de ese repositorio y se crea después de que el equipo complete la verificación final.

| Repositorio | URL | Tag RC (histórico) | Commit RC.2 | `main` al 22/11/2026 |
| :---- | :---- | :---- | :---- | :---- |
| `backend-uni` | <https://github.com/taller-web-sigesu/backend-uni> | `v1.0.0-rc.2` | `b00e92b` | `d8c7f4a` (PR #18) |
| `frontend-uni` | <https://github.com/taller-web-sigesu/frontend-uni> | `v1.0.0-rc.2` | `a7f9469` | `a7f9469` |
| `infra-uni` | <https://github.com/taller-web-sigesu/infra-uni> | `v1.0.0-rc.2` | `8672ed6` | `98d6ff9` (PR #26) |

> **Commit del tag `v1.0.0`.** Los SHA de la última columna corresponden al estado de `main` al cierre del bloque 1. Aún pueden entrar los cambios de UI/UX en `frontend-uni` y las fuentes documentales en `infra-uni`. El SHA definitivo de cada repositorio se toma con `git rev-parse 'v1.0.0^{commit}'` al crear el tag y se registra en `VERIFICACION-FINAL.pdf`.

## 3. Componentes y versiones tecnológicas

| Componente | Tecnología | Versión |
| :---- | :---- | :---- |
| Frontend | React + Vite + React Router | React 19.3.0, Vite 8.3.5, React Router 7 |
| Backend | Java + Spring Boot (monolito modular) | Java 21, Spring Boot 4.1.2, Maven 3.9.16 |
| Base de datos | MySQL + Flyway | MySQL 8.4.13 |
| Observabilidad | Micrometer/Prometheus, OpenTelemetry, Tempo, Grafana | Pila en `backend-uni/observability/` |
| Pruebas | JUnit 5, Testcontainers, Vitest, Playwright, k6, OWASP ZAP, Gitleaks | k6 2.4.0, ZAP 2.16.1, Gitleaks 8.28.0 |
| Contenedores | Docker Compose (local), imagen Docker del backend | Compose v2 |

## 4. Entornos publicados

| Entorno | Frontend | Backend | Rama |
| :---- | :---- | :---- | :---- |
| Staging | <https://frontend-uni-tdk7.vercel.app> | <https://uniservice-backend-staging.onrender.com> | `main` |
| Producción | <https://frontend-uni-wx9m.vercel.app> | <https://uniservice-backend-prod.onrender.com> | `production` |
| Local | <http://localhost:3000> | <http://localhost:8080> | Cualquiera (Docker Compose) |

## 5. Historial de versiones

| Versión | Fecha | Hito |
| :---- | :---- | :---- |
| `v1.0.0-rc.1` | 14/11/2026 | Primer Release Candidate de la Fase III. |
| `v1.0.0-rc.2` | 16/11/2026 | Release Candidate final de la Fase III: API documentada, nube, CI/CD y seguridad. |
| `v1.0.0` | Al aprobarse la verificación final | Release final de la Fase IV: sesión única, datos demo, observabilidad, seguridad, rendimiento, UI/UX y documentación. |

## 6. Política de versiones

- `v1.0.0-rc.1` y `v1.0.0-rc.2` se conservan como histórico.
- Un tag publicado no se mueve ni se reutiliza. Un cambio posterior a `v1.0.0` se publica como `v1.0.1`.
- Se eliminaron los tags `v1.0.0` antiguos (`c8fe871`, `9d88468` y `67475d8`). No existe ningún `v1.0.0` que apunte a esos commits.

## 7. Documentos relacionados

- `RELEASE-NOTES.pdf`: cambios, correcciones y limitaciones de esta versión.
- `GUIA-DEL-REPOSITORIO.pdf`: estructura, ramas y procedimiento de etiquetado.
- `VERIFICACION-FINAL.pdf`: comprobación de tags, CI y Drive.
