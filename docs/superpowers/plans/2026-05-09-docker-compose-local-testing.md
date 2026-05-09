# Docker Compose Local Testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `compose.yaml` to the project root so developers can run `docker compose up --build` and get a fully functional Django + PostgreSQL local environment with hot-reload.

**Architecture:** Two services — `db` (postgres:16) and `app` (built from existing Dockerfile with source bind-mounted). A named volume at `/app/.venv` preserves the uv-installed virtualenv through the source mount. Entrypoint is overridden in compose to run `migrate` then `runserver` instead of gunicorn.

**Tech Stack:** Docker Compose v2, PostgreSQL 16, Django 5.1 runserver, uv

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `.gitignore` | Ignore `.env.compose` |
| Create | `.env.compose.example` | Committed template showing required env vars |
| Create | `compose.yaml` | Defines `db` and `app` services with volumes and healthcheck |

---

### Task 1: Ignore `.env.compose` in git

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add `.env.compose` to `.gitignore`**

The current `.gitignore` contents:
```
*.json
*.pyc
*.sqlite3
/.env
/.venv
/.superpowers/
```

Add one line after `/.env`:
```
/.env.compose
```

Final file:
```
*.json
*.pyc
*.sqlite3
/.env
/.env.compose
/.venv
/.superpowers/
```

- [ ] **Step 2: Verify the pattern works**

Run:
```bash
echo "check=1" > .env.compose && git status .env.compose && rm .env.compose
```

Expected output: `.env.compose` is NOT listed (git ignores it). If it appears as "Untracked", the pattern is wrong.

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore .env.compose"
```

---

### Task 2: Create `.env.compose.example`

**Files:**
- Create: `.env.compose.example`

- [ ] **Step 1: Create the example env file**

```bash
cat > .env.compose.example << 'EOF'
# Copy this file to .env.compose and adjust if needed.
# These values match the defaults in compose.yaml — safe for local dev only.
DEBUG=true
DATABASE_URL=postgres://postgres:postgres@db:5432/globaldetective
SECRET_KEY=django-insecure-local-dev-only
EOF
```

- [ ] **Step 2: Verify it was created**

Run:
```bash
cat .env.compose.example
```

Expected: three lines shown (DEBUG, DATABASE_URL, SECRET_KEY).

- [ ] **Step 3: Commit**

```bash
git add .env.compose.example
git commit -m "chore: add .env.compose.example for local dev"
```

---

### Task 3: Create `compose.yaml`

**Files:**
- Create: `compose.yaml`

- [ ] **Step 1: Create compose.yaml**

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: globaldetective
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pg_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  app:
    build: .
    entrypoint: []
    command: >
      sh -c "uv run manage.py migrate &&
             uv run manage.py runserver 0.0.0.0:8000"
    volumes:
      - .:/app
      - venv_data:/app/.venv
    ports:
      - "8000:8000"
    env_file:
      - .env.compose
    depends_on:
      db:
        condition: service_healthy

volumes:
  pg_data:
  venv_data:
```

- [ ] **Step 2: Validate compose file syntax**

Run:
```bash
docker compose config
```

Expected: YAML dump of the resolved config with no errors. If you see `Error`, check indentation and that all keys are valid.

- [ ] **Step 3: Copy example env and do a first build**

```bash
cp .env.compose.example .env.compose
docker compose up --build
```

Expected sequence of output:
1. Postgres container starts, healthcheck passes
2. App container builds (uv sync runs — takes ~30s on first build)
3. `migrate` runs (you'll see Django migration output)
4. `runserver` starts: `Starting development server at http://0.0.0.0:8000/`

If build fails at `uv sync`, check that the AlmaLinux base image can reach the internet.

- [ ] **Step 4: Verify the app is reachable**

In a second terminal:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/
```

Expected: `200` (or `302` if the root redirects — both are fine). A `500` means a settings or migration problem; check the compose logs.

- [ ] **Step 5: Verify hot-reload works**

1. Open `project/views.py` in an editor and make a trivial change (add a comment, then remove it — or touch the file with `touch project/views.py`).
2. Watch compose output — you should see: `Watching for file changes with StatReloader`
3. Django should log `Reloading...` within 1-2 seconds.

- [ ] **Step 6: Stop the stack**

```bash
docker compose down
```

Expected: containers stop. Data in `pg_data` volume persists. Confirm with:
```bash
docker compose up
```

Migrations should NOT re-run for already-applied migrations (Django migration state is stored in postgres, which is in `pg_data`).

- [ ] **Step 7: Commit**

```bash
git add compose.yaml
git commit -m "feat: add Docker Compose dev setup with PostgreSQL"
```
