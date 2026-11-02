# Local Docker Desktop Environment Implementation Plan

**Goal:** Prepare the three sibling repositories for local development through
Docker Desktop, with no host Node.js, Java, Maven, or MySQL requirement.

**Architecture:** Compose project `universidad-sm` builds React + Vite,
Spring Boot, and MySQL. The two application ports bind to loopback. Frontend and
backend share a bridge network; backend and MySQL share a separate internal
network. MySQL data and application dependency/build caches use named volumes.

**Scope:** Development only. No business features, authentication, production,
cloud, Kubernetes, or extra services.

## Work items

- [x] Bootstrap a single React status screen using `frontend-uni/DESIGN.md`.
- [x] Configure Vite proxy `/api`, HMR with polling for Windows mounts, and the
  frontend development image.
- [x] Bootstrap a minimal Spring Boot API, datasource environment variables,
  JPA, Actuator, and DevTools.
- [x] Add the backend development image and a persistent Maven cache/compiled
  classes volume.
- [x] Compose all three services with service healthchecks, dependencies, local
  port bindings, isolated MySQL access, and persistent data.
- [x] Add double-click Windows start/stop scripts and usage documentation.
- [x] Parse and inspect the resolved Compose configuration with the sample
  environment; confirmed service definitions, dependencies, ports, networks,
  volumes, memory cap, and healthchecks.
- [ ] Build images and verify HTTP, health, HMR, database connectivity, and
  persistence with a running Docker Desktop engine.

## Verification limits

The Compose CLI is installed, but the Docker engine returned `permission denied`
for `npipe:////./pipe/dockerDesktopLinuxEngine` during this implementation, so
runtime verification remains pending. npm package resolution was also
unavailable from this session (`ENOTFOUND registry.npmjs.org`); the first
dependency install and frontend build must be confirmed when registry access is
available.
