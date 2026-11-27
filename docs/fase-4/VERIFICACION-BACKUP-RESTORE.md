# Verificación de respaldo y restauración — P2

**Fecha:** 27/11/2026, Lima.  
**Alcance:** base MySQL de staging (`railway`) y restauración en una base temporal aislada.  
**Resultado:** ✅ **OK** — 27 tablas y 460 filas restauradas sin diferencias.

## Procedimiento

1. Se generó un volcado lógico de las tablas base de staging con `pymysql`.
2. El volcado incluyó `CREATE TABLE` y `INSERT` de las columnas no generadas.
3. Se creó una base temporal `gestal_restore_test_<timestamp>` en el mismo servidor MySQL.
4. Se restauró el volcado completo en la base temporal.
5. Se compararon los conteos de filas de las 27 tablas.
6. Se eliminó la base temporal al terminar.

No se versionó el volcado porque contiene datos de demostración. Solo se conserva el resultado agregado.

## Resultado

| Métrica | Valor |
| --- | --- |
| Tablas restauradas | 27 |
| Filas origen | 460 |
| Filas restauradas | 460 |
| Diferencias | 0 |
| Tamaño del volcado | 197.347 bytes |
| SHA-256 del volcado | `412EAFECB867C81C633759E37D70DD1D7BB27F337E7997D52E447A06E5671136` |
| Base temporal | Eliminada |

Resultado legible por máquina: [`evidencias-backup/restore-result.json`](evidencias-backup/restore-result.json).

## Conclusión

La restauración de un respaldo lógico de staging quedó verificada. El procedimiento es reproducible y no requiere un proveedor de respaldo pago.
