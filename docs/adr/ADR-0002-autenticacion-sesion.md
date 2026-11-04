# ADR-0002: Autenticación y sesión

- **Estado:** Propuesto
- **Fecha:** 2026-11-04
- **Decisores:** Equipo del proyecto Gestal
- **Historias afectadas:** HU-01, HU-02
- **Requisitos afectados:** RNF-05, RNF-06, RNF-07, RNF-08
- **Documentos relacionados:** [ARCHITECTURE.md](../ARCHITECTURE.md), [DISENIO-BD.md](../../DISENIO-BD.md)

## Contexto

El frontend es una SPA React y el backend una API REST Spring Boot. El sistema necesita autenticación, autorización por rol y control por recurso, además de poder revocar una sesión al cerrar sesión (HU-01, CA-04). El esquema ya contempla `sesiones_usuario` con `hash_token`, `expira_en` y `revocada_en`, lo que permite mantener revocación del lado del servidor.

La arquitectura dejó abierta la elección entre JWT y sesión de servidor. Una decisión es necesaria antes de implementar Spring Security y las pantallas de login.

## Decisión

1. **Access token JWT de corta duración:** 15 minutos, firmado con HS256 o RS256, mantenido **solo en memoria** del frontend. No se guarda en `localStorage` ni en `sessionStorage`.
2. **Refresh token opaco:** 256 bits aleatorios, enviado en cookie `HttpOnly`, `Secure` y `SameSite=Lax`. En desarrollo local sobre HTTP se permite `Secure=false` únicamente en el perfil `local`.
3. **Persistencia de sesión:** se guarda el **hash SHA-256** del refresh token en `sesiones_usuario.hash_token`, junto con `emitida_en`, `expira_en`, `ip` y `agente_usuario`. Nunca se almacena el token en claro.
4. **Rotación:** cada llamada a `/auth/refresh` invalida el refresh anterior y emite uno nuevo. Si se reutiliza un refresh ya rotado, se revoca toda la sesión.
5. **Logout:** marca `sesiones_usuario.revocada_en` y elimina la cookie. El access token deja de renovarse; el backend rechaza refresh revocados.
6. **Vigencia:** access 15 minutos; refresh con vigencia absoluta de 7 días.
7. **Autorización:** RBAC por rol (`ESTUDIANTE`, `TECNICO`, `SUPERVISOR`, `ADMINISTRADOR`) **más** control por recurso: propietario, técnico asignado, área del supervisor y administrador.
8. **Contraseñas:** BCrypt o Argon2id correctamente configurado; nunca texto plano.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
| --- | --- |
| JWT de larga duración en `localStorage` | Expuesto a XSS y sin revocación efectiva. |
| Sesión de servidor pura con cookie | Válida, pero la API ya se diseñó para JWT y el cliente necesita un access token para llamadas cross-origin. |
| JWT sin registro de sesión | Impide logout revocable y rotación; incumple HU-01 CA-04. |
| Refresh token en `localStorage` | Mismo riesgo de XSS que el access token. |

## Consecuencias

- El frontend debe centralizar el refresh y reintentar una vez la petición que recibe 401.
- Hay que coordinar CORS con credenciales, `SameSite`, CSRF y el dominio del frontend.
- Se necesita limpieza periódica de sesiones expiradas y pruebas de revocación.
- El reloj del servidor debe estar sincronizado para validar `exp` y `expira_en`.
- Los endpoints `/auth/login`, `/auth/refresh` y `/auth/logout` deben documentarse en OpenAPI y cubrirse con pruebas de integración.
