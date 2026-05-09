# Docker Compose Local Testing Setup — Design

**Date:** 2026-05-09
**Status:** Approved

## Overview

Add a dev-friendly `compose.yaml` to the globaldetective project root that spins up PostgreSQL and the Django app together. The app container mounts source code for hot-reload, while a named volume preserves the uv-installed venv across restarts.

## Architecture

Two services:

- **`db`** — `postgres:16` with a named data volume and a healthcheck
- **`app`** — built from the existing `Dockerfile`, source-mounted, venv preserved via named volume overlay, entrypoint overridden to run `runserver`

The existing `Dockerfile` is reused as-is for the image build (it installs deps via `uv sync`). Only the runtime entrypoint/command is overridden in compose.

## Services

### db

```
image: postgres:16
POSTGRES_DB: globaldetective
POSTGRES_USER: postgres
POSTGRES_PASSWORD: postgres
volume: pg_data → /var/lib/postgresql/data
healthcheck: pg_isready -U postgres (interval 5s, retries 5)
```

### app

```
build: . (existing Dockerfile)
entrypoint: [] (clears Dockerfile ENTRYPOINT)
command: uv run manage.py migrate && uv run manage.py runserver 0.0.0.0:8000
volumes:
  - .:/app                     (source bind mount)
  - venv_data:/app/.venv       (named volume overlay — preserves uv venv from image build)
ports: 8000:8000
depends_on: db (condition: service_healthy)
env_file: .env.compose
```

## Environment

`compose.yaml` references an `env_file: .env.compose`. A `.env.compose.example` is committed to the repo. The actual `.env.compose` is git-ignored.

Minimum contents of `.env.compose`:

```
DEBUG=true
DATABASE_URL=postgres://postgres:postgres@db:5432/globaldetective
SECRET_KEY=django-insecure-local-dev-only
```

## Named Volumes

| Volume | Purpose |
|--------|---------|
| `pg_data` | Postgres data — survives `docker compose down`, cleared by `docker compose down -v` |
| `venv_data` | uv virtualenv — populated from image on first run, avoids re-syncing on every container start |

## Key Design Decisions

- **Reuse existing Dockerfile** — keeps the single source of truth for image build; compose only overrides runtime behaviour.
- **Named venv volume** — mounting `.:/app` would shadow `/app/.venv` built into the image. The named volume at `/app/.venv` is populated from the image on first creation, then persists independently of the source mount.
- **No gunicorn in dev** — `runserver` provides auto-reload on code changes without image rebuilds.
- **`DEBUG=true` skips collectstatic** — Django's built-in static file serving works in dev mode; no need to run `collectstatic` in the compose workflow.
- **`service_healthy` dependency** — prevents the app from starting before postgres accepts connections, avoiding migration race conditions.

## Files to Create

1. `compose.yaml` — main compose file
2. `.env.compose.example` — committed example env file
3. Update `.gitignore` — add `.env.compose`
