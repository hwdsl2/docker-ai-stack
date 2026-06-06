# Changelog

All notable changes to docker-ai-stack are documented here.

## 2026-06-05

### Fixed

- AnythingLLM `server/.env` now persists across container recreation via the
  `anythingllm-data` volume. Previously, the file lived only in the container
  filesystem and was destroyed on container recreation (`docker compose down
  && up`, `pull && up` on a new image, etc.), silently dropping any password
  set via Settings → Security and any UI-configured provider keys. The
  bootstrap script now symlinks `/app/server/.env` → `/app/server/storage/.env`
  (inside the volume) on every container start.

  **Action required to benefit from this fix:**
  1. Pull the latest code: `cd docker-ai-stack && git pull`
  2. Recreate the AnythingLLM container so the updated bootstrap script
     runs: `docker compose up -d --force-recreate anythingllm`

     ⚠️ This step destroys the old container, so any password currently
     set via Settings → Security will be cleared during the recreation
     and AnythingLLM will revert to its default no-password state —
     leaving the UI publicly accessible until step 3 is done. This is
     the last time that will happen.
  3. Set your password again from Settings → Security. From this point
     onward it will persist across container recreation and upgrades.
