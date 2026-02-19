# OpenClaw — Project Rules

> AI-agnostic guidelines for any assistant working on this repo.
> For deeper context see `AGENTS.md` (or its symlink `CLAUDE.md`) and `CONTRIBUTING.md`.

---

## Planning Workflow

- All rules, shared memory, and implementation plans live in `planning/`.
- **After every change to any file in `planning/`, immediately:**
  ```
  git add planning/
  git commit -m "planning: <short description>"
  git push
  ```
  This keeps every machine and every AI assistant in sync.
- Per-session implementation plans go in `planning/plans/YYYY-MM-DD-<topic>.md`.

---

## Tech Stack

| Concern | Tool/Version |
|---|---|
| Runtime | Node 22+ (Bun also supported) |
| Language | TypeScript (ESM, strict mode) |
| Package manager | pnpm (lockfile: `pnpm-lock.yaml`) |
| Test runner | Vitest (`pnpm test`) |
| Lint/format | Oxlint + Oxfmt (`pnpm check`, `pnpm format:fix`) |
| Type check | `pnpm tsgo` or `pnpm build` |

---

## Repository Layout

```
src/          CLI, commands, routing, channels, media pipeline
extensions/   Channel plugins (Teams, Matrix, Zalo, voice-call…)
packages/     Shared monorepo packages
skills/       AI assistant skills
ui/           Web UI
apps/         Mobile (iOS/Android)
docs/         Mintlify docs (docs.openclaw.ai)
test/         Integration/e2e tests
scripts/      Build and utility scripts
planning/     ← this directory (rules, memory, plans)
```

- Plugin-only deps stay in the extension's own `package.json`.
- Do not use `workspace:*` in plugin `dependencies` (npm install breaks).
- When touching shared logic (routing, allowlists, onboarding), consider all channels.

---

## Coding Conventions

- TypeScript only; avoid `any`; never add `@ts-nocheck`.
- No prototype mutation (`applyPrototypeMixins`, `Object.defineProperty` on `.prototype`). Use explicit class inheritance or composition.
- Formatting via Oxfmt; linting via Oxlint — run `pnpm check` before every commit.
- Keep files under ~700 LOC; extract helpers rather than creating "V2" copies.
- Use existing patterns for CLI options and `createDefaultDeps` for dependency injection.
- Product name: **OpenClaw** (headings/docs); CLI command/package/paths: `openclaw`.

---

## Git & Safety Rules

- Never force-push to `main`.
- Never run destructive git ops (`reset --hard`, `clean -f`, `branch -D`) without explicit user confirmation.
- Never skip pre-commit hooks (`--no-verify`) unless the user explicitly requests it.
- Never auto-commit code changes unless the user explicitly asks.
- **Exception — `planning/` files**: always commit + push immediately after any update.

---

## Docs (Mintlify)

- Docs: `docs/` → hosted at `docs.openclaw.ai`.
- Internal links: root-relative, no `.md`/`.mdx` extension.
- Do not edit `docs/zh-CN/**` unless explicitly asked (it is generated).
- Avoid em dashes and apostrophes in headings (they break Mintlify anchors).
- README links must be absolute (`https://docs.openclaw.ai/...`).
- Docs content must be generic — no personal device names, hostnames, or paths.
