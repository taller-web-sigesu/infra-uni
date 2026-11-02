# AGENTS.md — Infrastructure

## Política obligatoria de ramas
- Nunca edites ni confirmes cambios directamente en `main`.
- Antes de modificar infraestructura o documentación, verifica la rama actual y crea una rama por tarea desde `main` (`feature/...`, `fix/...` o `docs/...`).
- Integra cambios a `main` únicamente mediante una PR revisada por otro compañero.

## Dev environment tips
- Stack: Docker + Docker Compose + MySQL.
- This repository manages local development infrastructure and shared documentation.
- Read `docs/ARCHITECTURE.md` before changing infrastructure.
- Find user stories in `docs/requirements/user-stories/`.
- Frontend and backend are separate repositories located at `../frontend-uni/` and `../backend-uni/`.
- Keep Dockerfiles inside their respective application repositories.
- Use `.env.example` as the reference for environment variables.
- Never commit `.env`, passwords, or other secrets.
- Do not configure production infrastructure unless requested.

## Testing instructions
- Run `docker compose config` to validate Compose configuration.
- Run `docker compose up -d --build` when Docker and the required applications are available.
- Run `docker compose ps` to inspect service status.
- Use `docker compose logs` to investigate failures.
- Verify service connectivity, healthchecks, and MySQL persistence when applicable.
- Do not claim tests passed unless they were executed.

## PR instructions
- Title format: `[infra] Brief description`.
- Keep infrastructure changes minimal and reproducible.
- Update `README.md` or `docs/DOCKER.md` when setup instructions change.
- Never delete persistent volumes without explicit authorization.
- Include a summary of changes and verification results.
