# Entregables del proyecto

| Archivo | Descripción |
| --- | --- |
| `INFORME-GESTAL-FASES-I-III.md` | Versión editable del informe final de las fases I, II y III. |
| `INFORME-GESTAL-FASES-I-III.docx` | Versión Word para entrega y revisión del docente. |
| `DELIBERADAMENTE-NO-HECHO.md` | Decisiones de exclusión, diferimiento y riesgos aceptados del RC.2. |
| `DECISIONES-FASE-IV.md` | Decisiones de alcance de la Fase IV. |
| `VERSION.md` | Fuente de `VERSION.pdf` (Drive `01-Version-definitiva/`). |
| `RELEASE-NOTES.md` | Fuente de `RELEASE-NOTES.pdf` y de las notas de los GitHub Releases `v1.0.0`. |
| `INFORME-FINAL-FASES-I-IV.md` | Fuente de `INFORME-FINAL-FASES-I-IV.pdf` (Drive `02-Documentacion/`). |
| `MANUAL-DE-USUARIO.md` | Fuente de `MANUAL-DE-USUARIO.pdf` (Drive `03-Manual-de-usuario/`). |
| `MANUAL-TECNICO.md` | Fuente de `MANUAL-TECNICO.pdf` (Drive `04-Manual-tecnico/`). |
| `GUIA-DEL-REPOSITORIO.md` | Fuente de `GUIA-DEL-REPOSITORIO.pdf` (Drive `05-Repositorio/`). |
| `PRESENTACION.html` | Fuente de `PRESENTACION.pdf` (Drive `07-Presentacion/`), diapositivas 16:9. |
| `assets/` | Capturas del manual (entorno local con cuentas ficticias) e imágenes del informe. |
| `tools/build-pdf.sh` | Genera los PDF en `pdf/` (ignorada por Git) con pandoc y Chrome. |

El informe cubre problema, objetivos, actores, alcance, requerimientos, épicas, historias, tareas, criterios de aceptación, BDD, arquitectura, prototipo, evidencias de las tres fases, rúbrica de Fase III y registro de uso de IA.

La estrategia y el prompt de pruebas están en [`../testing/PROMPT-PRUEBAS.md`](../testing/PROMPT-PRUEBAS.md).

## Generar los PDF

Requiere pandoc y Google Chrome o Edge. Desde Git Bash, en esta carpeta:

```sh
./tools/build-pdf.sh                 # los 7 documentos
./tools/build-pdf.sh VERSION         # uno solo
```

En el Drive solo se suben los PDF; los `.md` son la fuente.

**Release Candidate:** `v1.0.0-rc.2`. **Versión final:** `v1.0.0` (se etiqueta después de la verificación final).
