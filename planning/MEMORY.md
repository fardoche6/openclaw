# OpenClaw — Shared Memory

> AI-agnostic knowledge base. Keep entries concise and factual.
> Update this file as new patterns or decisions are confirmed, then commit + push.

---

## Project Overview

OpenClaw is a **multi-channel AI gateway** (personal AI assistant platform).

- **Version**: 2026.2.16
- **Repo**: https://github.com/openclaw/openclaw
- **Docs**: https://docs.openclaw.ai

The gateway is the control plane; the AI assistant is the product.

---

## Architecture

```
User devices / chat channels
        ↓
    Gateway (Node.js / TypeScript)
        ↓
  AI models (Anthropic Claude, OpenAI, local models, Gemini, …)
```

- Channels are pluggable: built-in (Telegram, Discord, Slack, Signal, iMessage, WhatsApp web, Web) + extensions (Teams, Matrix, Zalo, voice-call, …).
- Skills extend assistant capabilities (`skills/`).

---

## Key Directories

| Path | Purpose |
|---|---|
| `src/` | Core: CLI, commands, routing, channels, media pipeline |
| `src/cli` | CLI wiring |
| `src/commands` | Command implementations |
| `src/routing` | Message routing logic |
| `src/channels` | Built-in channel adapters |
| `src/telegram`, `src/discord`, `src/slack`, `src/signal`, `src/imessage`, `src/web` | Per-channel code |
| `extensions/` | Channel/feature plugins (workspace packages) |
| `packages/` | Shared monorepo packages |
| `skills/` | AI assistant skills |
| `ui/` | Web UI |
| `apps/` | iOS / Android apps |
| `docs/` | Mintlify documentation |
| `test/` | Integration / e2e tests |
| `scripts/` | Build and utility scripts |
| `planning/` | Rules, memory, plans (this directory) |

---

## Important Files

| File | Purpose |
|---|---|
| `AGENTS.md` (= `CLAUDE.md`) | Repository guidelines for AI assistants |
| `CONTRIBUTING.md` | Contribution guidelines |
| `CHANGELOG.md` | Version history |
| `VISION.md` | Project vision |
| `planning/RULES.md` | Project rules (AI-agnostic) |
| `planning/MEMORY.md` | This file |
| `planning/plans/` | Per-task implementation plans |

---

## Deployment Targets

- **Fly.io** — primary cloud deployment
- **Docker** — containerized self-hosting
- **Local** — `openclaw gateway run` on macOS / Linux / WSL2
- **exe.dev VMs** — development/staging VMs

---

## Dev Commands (Quick Reference)

```bash
pnpm install          # install deps
pnpm test             # run tests (vitest)
pnpm build            # type-check + build
pnpm tsgo             # TypeScript check only
pnpm check            # lint + format check
pnpm format:fix       # auto-fix formatting
pnpm openclaw ...     # run CLI in dev (bun)
```

---

## Patterns & Decisions Log

<!-- Append new entries as they are discovered. Format: YYYY-MM-DD | Summary -->

| Date | Note |
|---|---|
| 2026-02-19 | `planning/` directory created; all AI assistants should read this file at session start and commit+push after any update |
