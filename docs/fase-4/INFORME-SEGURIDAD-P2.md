# Gestal · Informe de seguridad de Fase IV

**Fecha** 21 de noviembre de 2026, Lima. **Alcance** backend, configuración local de observabilidad, tráfico normal de staging y secretos versionados de `backend-uni` e `infra-uni`. El contrato por rol, método, ruta y recurso figura en la [matriz de autorización](MATRIZ-AUTORIZACION-P2.md).

## Registro de hallazgos y pendientes

| ID | Severidad | Control y evidencia redactada | Estado y responsable |
| --- | --- | --- | --- |
| SEG-01 | Media | `GET /login` de Vercel respondió `200` sin `Content-Security-Policy` ni variante `Report-Only`. El documento tampoco declaró CSP mediante `meta`. ZAP 10038, confianza alta. | **Cerrado.** CSP añadida en `frontend-uni/vercel.json` (PR #24, `bc7d78f`) y verificada en staging el 27/11/2026; el login y la navegación funcionan con la política. |
| SEG-02 | Informativa | ZAP 10098 marcó recursos públicos. Confirmado `Access-Control-Allow-Origin: *` para el HTML de login y el bundle JS servido públicamente; ninguno de esos dos GET anunció `Access-Control-Allow-Credentials`. La observación corresponde a esos recursos públicos. | Clasificado como informativo para las respuestas verificadas. P2/frontend: conservar la comprobación en regresión si cambia el alcance del gateway o el caché de la aplicación. |
| SEG-03 | Informativa | Gitleaks `generic-api-key` en una clave ficticia de la prueba unitaria del adaptador de Supabase, presente en historia y árbol versionado. El transporte se simula con `MockRestServiceServer`. Valor redactado. | Falso positivo. C clasifica; sin rotación para esta fixture. |
| SEG-04 | Baja | En una pasada exploratoria sobre el directorio de trabajo, Gitleaks marcó cinco XML Failsafe con la contraseña de desarrollo generada por la autoconfiguración de Spring Security. Los XML viven en `target/`. Las regresiones demuestran el rechazo de Basic en negocio y el proveedor dedicado de Actuator acepta solo la cuenta recolectora. | Revisar supresión de la credencial generada en logs al publicar evidencias. Responsable A/C. Conservar únicamente los resúmenes redactados de esta revisión. |
| SEG-05 | Cerrado | El candidato pasó controles de autorización en local. Staging respondió con `8136b68` confirmado en Render. | **Cerrado.** SHA `8136b68` desplegado y verificado; health/status 200 y smoke oficial en verde. |
| SEG-06 | Aceptado | El Compose de B vincula Grafana local a loopback. La pila de observabilidad no se despliega en Render free. | **Aceptado para la demo.** Las alertas se validaron en local; el detalle queda en [`VERIFICACION-STAGING-FINAL.md`](../VERIFICACION-STAGING-FINAL.md). |
| SEG-07 | Aceptado | Los datos demo de Fase III documentan cuentas ficticias y una contraseña compartida para staging. | **Aceptado para la demo.** Son cuentas ficticias; se deshabilitan al cerrar la demostración. |

## Verificación local

- Clon aislado `p2c-backend`. La primera revisión comenzó antes de recibir el candidato de E. Base `b00e92b`, insumos `8001dc9` (#16), `6e7d20c` (#17), `fc6bbbea54eab85b4a52fd76e389ec9b614e2edb` (A), `b3a53da38b5fc7b0684d1276a14b8162b039ee23` y `02144df719be36bdaf1752f2eb7cdfcbfe404b3a` (B). El segundo commit de B incluye el primero. Candidato inicial de seguridad `21b223ecbc2619f4bf934ebe291be89ddb9671b9`. En `docs/DATABASE.md` se conservaron las filas de `R__consolidar_sesiones_vigentes.sql` y `db/demo/V1001__ambientes_y_cuentas_fase_iv.sql`.
- `backend-uni` rama auxiliar `fix/fase-4-p2-seguridad`, commit propio `79262803162332bf6ca4018077d3a7341758cf8f`. E puede aplicar ese único commit sobre su candidato con los insumos citados. Cambia cinco archivos de pruebas: `OpenApiContractIT.java`, `TelemetryIT.java`, `AttachmentIT.java`, `SignedDownloadIT.java` y `RequestLifecycleIT.java`. Se añadieron comprobaciones de UI de Swagger, rechazo de JWT E y métodos no permitidos para telemetría, historial y comentarios ajenos, carga ajena y ausencia de firma al descargar sin autorización. El código productivo de A se conservó.
- Java 21.0.5, Maven 3.9.11, Docker Desktop y Testcontainers con `mysql:8.4.13`. `mvn -B -ntp verify` en el candidato inicial pasó con 13 unitarias y 93 integraciones. `mvn -B -ntp clean verify` en el candidato con las nuevas pruebas pasó con **13 unitarias, 94 integraciones, 0 fallos, 0 errores y 0 omitidas**. La ejecución local en Windows fijó `JAVA_HOME` al JDK 21 y `-Dmaven.repo.local` al caché de Maven de la máquina.
- `AuthIT` y `RegistrationRateLimitIT` cubrieron la revocación de JWT y refresh, concurrencia, reutilización, cuentas ficticias y límites `429`. `RequestLifecycleIT` y `ReservationIT` cubrieron propiedad, asignación y área. Las pruebas de adjuntos emplearon almacenamiento local y adaptador de firma simulado. `TelemetryIT` verificó `UP` mínimo público; `401` para anónimo y JWT de administrador y estudiante; `200` para la cuenta recolectora válida; `403` con dicha cuenta para endpoints ajenos de Actuator o métodos no habilitados. `OpenApiContractIT` verificó Swagger y sus 64 operaciones de API.
- Evidencia local reproducible en `target/surefire-reports`, `target/failsafe-reports` y `target/openapi.yaml` del clon. `output/p2c-maven-resumen.txt` conserva los conteos y extractos filtrados. La salida completa puede incluir credenciales efímeras de la autoconfiguración de pruebas. `git diff --check` pasó antes del commit.

### Candidato entregado por E

- Base exacta `backend-uni@3fd0c0dfd84d6bc4c73130044a3f6ab221a1fa53`, rama de E `feature/fase-4-p2-candidato-local`, importada desde su bundle. Según el traspaso de E, esa base pasó `mvn -o -B -ntp verify` con 13 unitarias y 93 integraciones y un smoke con `infra-uni@979090d912505ded349e3ac7bf029bf168a0b450`. La evidencia de esa corrida está en `p2e-integracion/TRASPASO.md` del workspace.
- La única diferencia entre la base temporal de C y la de E es el orden de las dos filas en `docs/DATABASE.md`. El SHA `79c5cdd17e5ffb944b3c9057e892a5f140b190ce` aplica el mismo parche de seguridad sobre el candidato exacto de E, en la rama aislada `verify/fase-4-p2-seguridad-en-e`. `git patch-id --stable` confirmó la equivalencia con `79262803162332bf6ca4018077d3a7341758cf8f` y `git diff --check` pasó. E debe integrar solo una de las dos versiones del parche.
- La corrida de C sobre `79c5cdd17e5ffb944b3c9057e892a5f140b190ce` ejecutó `mvn -o -B -ntp clean verify` con Java 21.0.5 y MySQL 8.4.13 de Testcontainers. Resultado `BUILD SUCCESS`, **13 unitarias y 94 integraciones, sin fallos, errores ni omitidas**. El resumen redactado por clase está en `output/p2c-maven-candidato-e-resumen.txt`. El smoke Compose de E corresponde a su base `3fd0c0d`. La revisión de staging corresponde al tráfico desplegado que se describe más abajo, con SHA pendiente de confirmar.

## CI

`gh run view` confirmó `backend-ci` completado con `success` en `8001dc9` y `6e7d20c`. El registro de P2 consigna 13 unitarias y 84 integraciones para #16, y 13 unitarias y 86 integraciones para #17, todos sin fallos, errores ni omitidas. Queda pendiente el CI del SHA consolidado del cuarto PR y su comparación OpenAPI, CodeQL, dependencias y smoke de imagen. Responsable E. [CI de sesión única, #16](https://github.com/taller-web-sigesu/backend-uni/actions/runs/44666790351/job/136057916192) · [CI de datos demo y reglas, #17](https://github.com/taller-web-sigesu/backend-uni/actions/runs/44929783650).

## Staging

ZAP 2.16.1 corrió en modo `safe`, con análisis pasivo limitado a los dos orígenes autorizados. Un navegador aislado visitó el login, se autenticó con la cuenta estudiante ficticia, navegó de `/inicio` a `/solicitudes`, cerró sesión y abrió el health público de Render. El proxy registró 22 respuestas, entre ellas `401` al refresh inicial sin sesión, `200` al login y `204` al logout. La cola de análisis llegó a cero. Se usaron solo lecturas normales de navegador y peticiones del propio flujo de sesión. El JSON `output/p2c-zap-pasivo.json` conserva rutas, estados y alertas sin cuerpos, cookies, credenciales ni parámetros de consulta. Para reproducir, usar un perfil descartable detrás del proxy ZAP local, incluir ambos orígenes en el contexto, activar `scanOnlyInScope`, repetir el recorrido y esperar a que `recordsToScan` llegue a cero. El guion `output/p2c-tools/zap-passive.cjs` usa Playwright Core 1.56.1, JDK 21 y Edge. [Orígenes documentados](../ARCHITECTURE.md) · [OWASP ZAP Passive Scan](https://www.zaproxy.org/docs/desktop/start/features/pscan/).

| Respuesta | Cabeceras observadas y alcance |
| --- | --- |
| Vercel `GET /login` → `200` | `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`, `Access-Control-Allow-Origin: *`, `Cache-Control: public, max-age=0, must-revalidate`. CSP y CSP Report-Only ausentes. |
| Vercel `GET /assets/index-CD4WCa4f.js` → `200` | `Access-Control-Allow-Origin: *`, `Cache-Control: public, max-age=0, must-revalidate`, `Content-Type: application/javascript; charset=utf-8`. Recurso público. |
| Render `GET /actuator/health` → `200` tras un primer timeout | `Strict-Transport-Security: max-age=31536000 ; includeSubDomains`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Cache-Control: no-cache, no-store, max-age=0, must-revalidate`, `Content-Type: application/vnd.spring-boot.actuator.v3+json`. El JSON observado a través del proxy contiene `groups` y `status`. CSP, Referrer-Policy y Permissions-Policy ausentes en esta respuesta JSON. |

Alertas informativas del recorrido: caché en HTML y recursos estáticos (`10015`, `10050`), SPA (`10109`), respuesta de sesión (`10112`) y comentario sospechoso en un bundle público (`10027`, confianza baja, sin valor sensible en el resumen). `10116` señala la antigüedad de la herramienta. Las alertas medias se registran como SEG-01/02. Para reproducir las cabeceras, hacer `curl --silent --show-error --max-time 55 --dump-header - --output NUL URL` en Windows y conservar sólo la lista anterior. Los GET directos registran cabeceras; el proxy registra el tráfico que recibió del navegador.

## Escaneo de secretos

Gitleaks **8.28.0**, binario Windows contrastado con el SHA-256 de su [distribución oficial](https://github.com/gitleaks/gitleaks/releases/tag/v8.28.0). Alcance histórico `git --all` sobre las referencias Git disponibles en los clones aislados, incluidas las referencias importadas de A/B y los PR #16/#17. El árbol se exportó con `git archive HEAD` y se analizó por separado. Quedan fuera las referencias remotas sin copiar, los archivos ignorados, el entorno de los proveedores y los restantes repositorios. `frontend-uni` quedó fuera del escaneo.

```powershell
gitleaks git $repo --log-opts='--all' --redact=100 --report-format=json --report-path=historia.json
git -C $repo archive --format=tar --output=versionado.tar HEAD
New-Item -ItemType Directory -Path versionado
tar.exe -xf versionado.tar -C versionado
gitleaks dir versionado --redact=100 --report-format=json --report-path=arbol.json
```

| Repositorio | Historia | Árbol versionado | Disposición |
| --- | --- | --- | --- |
| `backend-uni` | 40 commits de las referencias con el candidato de E, 1 coincidencia | 1 coincidencia en `79c5cdd` | Es el mismo valor ficticio en `src/test/java/pe/edu/universidad/servicios/attachments/SupabaseAttachmentStorageTest.java:30`. Introducido en `ae0721c7d550b0150bcf2fbf607bfd8522030884`. Valor `[redactado]`. |
| `infra-uni` | 33 commits, 0 coincidencias | 0 coincidencias en el árbol revisado para entrega | Sin coincidencias en el alcance indicado. |

Evidencias redactadas en `output/p2c-backend-candidato-e-gitleaks-{history,versionado}.json` y `output/p2c-infra-gitleaks-{history,versionado}.json`. La pasada exploratoria que incluyó `target/` explica SEG-04. Sin credenciales reales identificadas por estas reglas dentro del alcance versionado. Los valores locales y demo conocidos se clasificaron por su definición y uso.

### Procedimiento de rotación ante una credencial real

1. P2 abre el incidente en canal privado y registra tipo, repositorio, ruta, revisión, entorno, responsable y primer uso conocido. El propietario del servicio comprueba alcance y uso en logs del proveedor. Registra solo un identificador o huella redactada.
2. El operador de Render y backend coordina `APP_JWT_SECRET`, las instancias que firman y validan JWT y el momento de corte. Despliega el secreto nuevo de forma coordinada, retira el anterior y revoca las sesiones afectadas según el incidente. Prueba JWT y refresh anteriores rechazados y nuevo login emitido por cada instancia. Para `APP_BOOTSTRAP_ADMIN_PASSWORD`, cambia o deshabilita primero la cuenta ya creada, revoca sesiones y actualiza o elimina el valor de bootstrap según el entorno.
3. El operador de observabilidad con A/B cambia la contraseña de `prometheus`, actualiza el BCrypt en `APP_TELEMETRY_PASSWORD_HASH` y la contraseña original en el almacén del recolector. Valida health público, rechazo de la credencial anterior y `up=1` con la nueva. Si se usaron credenciales OTLP, coordina el nuevo valor entre backend y receptor y verifica ingestión de una traza ficticia.
4. El operador de Railway/MySQL o Supabase crea una credencial de reemplazo con los permisos requeridos, actualiza en Render `SPRING_DATASOURCE_PASSWORD` o `APP_STORAGE_SUPABASE_SERVICE_KEY` y prueba desde el servicio (Flyway y health, o alta, URL firmada y descarga ficticia, según el proveedor). Revoca la credencial anterior y comprueba que no autentique. Si se expuso el hook, el propietario de Render lo regenera, E actualiza `RENDER_PROD_DEPLOY_HOOK` en GitHub Secrets y valida únicamente con el procedimiento autorizado de despliegue.
5. E registra el evento de despliegue y su SHA, verifica métricas, errores, auditoría y permisos, repite el escaneo versionado e histórico y revisa que los artefactos sanitizados omitan valores. P2 cierra el incidente después de revisar los accesos afectados y las evidencias. Durante esta revisión no se rotaron credenciales ni se modificaron proveedores.

## Cierre de DAST y SAST (27/11/2026)

- **SAST frontend:** CodeQL para JavaScript/TypeScript agregado en `frontend-uni/.github/workflows/codeql.yml`; el check `Análisis estático (CodeQL)` pasó en el PR #25 y quedó en `main`.
- **DAST activo:** ZAP 2.17.0 sobre el login de staging, Swagger UI y `/api/v1/status`. Resultado: 0 altos, 4 medios aceptados, 1 bajo (falso positivo de Swagger UI) y 9 informativos. Reporte y clasificación en [`RESUMEN-DAST.md`](RESUMEN-DAST.md).
- **CSP:** cerrada en frontend staging; DAST confirmó la política y solo marcó `style-src 'unsafe-inline'` por los dos estilos dinámicos de la SPA.
- **Restauración:** verificada en una base temporal aislada; 27 tablas y 460 filas sin diferencias. Ver [`VERIFICACION-BACKUP-RESTORE.md`](VERIFICACION-BACKUP-RESTORE.md).
