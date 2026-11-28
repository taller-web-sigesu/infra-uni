<div class="portada">

# Verificación final de entrega

**Gestal / UniService**

Sistema Web para la Gestión Integral de Servicios Universitarios

Fase IV · Entrega final (`v1.0.0`) · 27/11/2026

Grupo 3 · Taller de construcción de software web · UNMSM, FISI, 2026-II

Verificación técnica: Persona 5 (QA Lead) · Aprobación final: Persona 1

</div>

## 1. Propósito

Este documento registra la verificación técnica ejecutada por Persona 5 sobre los repositorios, pipelines CI/CD, tags y releases, estructura del Drive, apertura y enlaces de los PDFs, evidencias de pruebas y preparación de la demostración, así como el espacio de validación y aprobación final de Persona 1.

## 2. Verificación de repositorios y CI

Estado comprobado el 27/11/2026 mediante GitHub CLI y API sobre la organización `taller-web-sigesu`.

| Repositorio | Rama | Commit `main` | CI en verde | Run verificado | Tags actuales |
| --- | --- | --- | --- | --- | --- |
| `backend-uni` | `main` | `8136b68` | Sí (`backend-ci`, `staging-smoke`) | `46075021436`, `46078054975` | `v1.0.0-rc.1`, `v1.0.0-rc.2` |
| `frontend-uni` | `main` | `0d950e3` | Sí (`ci`, `codeql`) | `46083003177`, `46083003163` | `v1.0.0-rc.1`, `v1.0.0-rc.2` |
| `infra-uni` | `main` | `942adc6` | Sí (`infra-ci`) | `46084152235` | `v1.0.0-rc.1`, `v1.0.0-rc.2` |

### Checklist de repositorios y tags (sección 11)

- [x] `backend-uni` en `main` (`8136b68`), limpio y CI verde.
- [x] `frontend-uni` en `main` (`0d950e3`), limpio y CI verde (incluye CodeQL SAST).
- [x] `infra-uni` en `main` (`942adc6`), limpio y CI verde (PR de P5 `docs/fase-4-verificacion` enviado para revisión de P4).
- [x] `v1.0.0-rc.2` se conserva como histórico en los 3 repositorios (`b00e92b`, `a7f9469`, `8672ed6`).
- [x] No existe ningún tag `v1.0.0` apuntando a commits antiguos (`c8fe871`, `9d88468`, `67475d8`).
- [x] Escaneo de secretos sin credenciales reales en historial ni árbol versionado (Gitleaks 8.28.0 + check de `infra-ci`).
- [ ] **Pendiente de P4 (tras aprobación de P1):** crear los tags anotados `v1.0.0` apuntando al `main` final en los 3 repositorios.
- [ ] **Pendiente de P4 (tras aprobación de P1):** publicar los 3 GitHub Releases `v1.0.0` (no prerelease) con `RELEASE-NOTES.md`.

Comandos de verificación que P5/P1 ejecutan inmediatamente después de que P4 publique `v1.0.0`:

```sh
git rev-parse 'v1.0.0^{commit}'
git rev-parse main
git ls-remote --tags origin v1.0.0
gh release view v1.0.0 --json tagName,isPrerelease,targetCommitish,url
```

## 3. Verificación del Drive y matriz de 13 PDFs

Se inspeccionaron las 8 carpetas de entrega y los PDFs existentes mediante PyMuPDF (apertura, conteo de páginas, extracción de texto y verificación HTTP de los 49 enlaces únicos contenidos en los PDFs).

| N.º | Carpeta | Archivo PDF | Responsable | Páginas | Estado de apertura y enlaces |
| --- | --- | --- | --- | ---: | --- |
| 1 | `01-Version-definitiva/` | `VERSION.pdf` | P4 | 3 | Abre OK · 17 enlaces verificados |
| 2 | `01-Version-definitiva/` | `RELEASE-NOTES.pdf` | P4 | 3 | Abre OK · 6 enlaces verificados |
| 3 | `02-Documentacion/` | `INFORME-FINAL-FASES-I-IV.pdf` | P4 | 44 | Abre OK · 23 enlaces verificados |
| 4 | `02-Documentacion/` | `INFORME-DE-PRUEBAS.pdf` | P5 | 8 | Abre OK · enlaces verificados |
| 5 | `02-Documentacion/` | `ANEXO-MEJORAS-UI-UX.pdf` | P3 | 2 | Abre OK · 5 enlaces Figma |
| 6 | `03-Manual-de-usuario/` | `MANUAL-DE-USUARIO.pdf` | P4 | 21 | Abre OK · 4 enlaces verificados |
| 7 | `04-Manual-tecnico/` | `MANUAL-TECNICO.pdf` | P4 | 11 | Abre OK · 3 enlaces verificados |
| 8 | `05-Repositorio/` | `GUIA-DEL-REPOSITORIO.pdf` | P4 | 7 | Abre OK · 11 enlaces verificados |
| 9 | `06-Evidencias/` | `INDICE-DE-EVIDENCIAS.pdf` | P5 | 5 | Abre OK · enlaces verificados |
| 10 | `06-Evidencias/` | `EVIDENCIAS-TECNICAS.pdf` | P2 | 9 | Abre OK · 26 enlaces verificados |
| 11 | `06-Evidencias/` | `VERIFICACION-FINAL.pdf` | P5 | 4 | Abre OK · checklist completo |
| 12 | `07-Presentacion/` | `PRESENTACION.pdf` | P4 | 13 | Abre OK · diapositivas completas |
| 13 | `08-Demostracion/` | `GUION-DE-DEMOSTRACION.pdf` | P5 | 5 | Abre OK · enlaces verificados |

### Resultado de revisión de enlaces en los PDFs de P2, P3 y P4

- Total de URLs HTTP(S) únicas detectadas: **49**.
- Enlaces externos con respuesta HTTP `2xx`/`3xx`: **37**.
- Enlaces locales (`http://localhost:3000` / `8080`, esperados para Docker local): **5**.
- Enlaces a Figma (requieren sesión de navegador, devuelven `403` a clientes automatizados): **5**.
- Raíz de API staging/producción (`401` esperado en `/` sin token o cold start de Render free): **2**.
- Enlaces rotos (`404` / dominio inválido): **0**.

### Checklist del Drive

- [x] 8 carpetas creadas con la nomenclatura exacta (`01-Version-definitiva` a `08-Demostracion`).
- [x] Los 13 PDFs de la matriz existen, abren correctamente y no están vacíos.
- [x] Nombres en mayúsculas, sin acentos y separados por guiones.
- [x] `EVIDENCIAS-TECNICAS.pdf` (P2) y `ANEXO-MEJORAS-UI-UX.pdf` (P3) enlazados desde `INDICE-DE-EVIDENCIAS.pdf` e `INFORME-DE-PRUEBAS.pdf`.
- [ ] **Observación para P4:** retirar los archivos `.md` vacíos (0 bytes) que quedaron dentro de las carpetas `01`, `02`, `03`, `04`, `05` y `07` antes de la entrega final en Drive (P5 retiró los propios).

## 4. Verificación de pruebas, evidencias y demostración

- [x] `INFORME-DE-PRUEBAS.pdf` completo con resultados reales de CI, local y 19 casos en staging (18 aprobados, 1 hallazgo `DEF-01` documentado).
- [x] SAST (CodeQL backend y frontend) y DAST activo (OWASP ZAP 2.17.0, 0 altos) verificados.
- [x] Pruebas de carga y estrés (k6 local y smoke staging) y restauración MySQL (27 tablas, 460 filas) verificadas.
- [x] Accesibilidad (axe-core WCAG 2.0/2.1/2.2 AA, 0 infracciones graves) y cross-browser (108/108 ejecutadas en Chromium, Mobile, Firefox y WebKit) verificadas.
- [x] `GUION-DE-DEMOSTRACION.pdf` listo con cuentas demo verificadas, tiempos (12 min) y Plan B (Docker Compose local y evidencias/video).
- [ ] **Pendiente de sesión grupal (Bloque 2):** completar firmas del acta UAT y registro de 5–8 participantes de usabilidad en `INFORME-DE-PRUEBAS.pdf`.
- [ ] **Pendiente de sesión grupal (Bloque 2):** realizar ensayo cronometrado de la demostración y grabar video de respaldo (Plan B2).

## 5. Observaciones registradas para corrección o decisión

| N.º | Responsable | Observación | Impacto |
| --- | --- | --- | --- |
| 1 | P4 | Eliminar los `.md` vacíos (0 B) en carpetas `01`, `02`, `03`, `04`, `05` y `07` del Drive antes de entregar. | Cumplimiento de regla 0.1 (solo PDFs). |
| 2 | P4 | Actualizar en `VERSION.pdf` (si aplica) los SHA definitivos al crear los tags `v1.0.0` y publicar los 3 GitHub Releases. | Requisito sección 11. |
| 3 | P1 / P4 | Definir si los PDFs complementarios `CIERRE-P2.pdf` y `CIERRE-P2-SEGURIDAD.pdf` se mantienen junto a `EVIDENCIAS-TECNICAS.pdf` en `06-Evidencias/`. | Orden del Drive. |
| 4 | P2 | Evaluar `DEF-01` (rate limit de login tras proxy inverso de Render) para `v1.0.1` o evolución. | No bloqueante para `v1.0.0`. |

## 6. Revisión y aprobación final

| Rol | Integrante | Estado | Fecha | Firma / Visto bueno |
| --- | --- | --- | --- | --- |
| Verificación técnica (P5) | Gianpierre Rodrigo Dulanto Romero | Completada (pendiente tags `v1.0.0`, firmas UAT/usabilidad y ensayo) | 27/11/2026 | Verificado |
| Aprobación final (P1) | Sebastian Andree Tejeda Alata | Pendiente de revisión y firma | ____ / 11 / 2026 | |
