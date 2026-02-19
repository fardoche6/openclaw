# OpenClaw — Shared Memory

> AI-agnostic knowledge base. Keep entries concise and factual.
> Update this file as new patterns or decisions are confirmed, then commit + push.

---

## Project Overview

OpenClaw is a **multi-channel AI gateway** (personal AI assistant platform).

- **Version**: 2026.2.17
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

| Path                                                                                | Purpose                                                |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `src/`                                                                              | Core: CLI, commands, routing, channels, media pipeline |
| `src/cli`                                                                           | CLI wiring                                             |
| `src/commands`                                                                      | Command implementations                                |
| `src/routing`                                                                       | Message routing logic                                  |
| `src/channels`                                                                      | Built-in channel adapters                              |
| `src/telegram`, `src/discord`, `src/slack`, `src/signal`, `src/imessage`, `src/web` | Per-channel code                                       |
| `extensions/`                                                                       | Channel/feature plugins (workspace packages)           |
| `packages/`                                                                         | Shared monorepo packages                               |
| `skills/`                                                                           | AI assistant skills                                    |
| `ui/`                                                                               | Web UI                                                 |
| `apps/`                                                                             | iOS / Android apps                                     |
| `docs/`                                                                             | Mintlify documentation                                 |
| `test/`                                                                             | Integration / e2e tests                                |
| `scripts/`                                                                          | Build and utility scripts                              |
| `planning/`                                                                         | Rules, memory, plans (this directory)                  |

---

## Important Files

| File                        | Purpose                                 |
| --------------------------- | --------------------------------------- |
| `AGENTS.md` (= `CLAUDE.md`) | Repository guidelines for AI assistants |
| `CONTRIBUTING.md`           | Contribution guidelines                 |
| `CHANGELOG.md`              | Version history                         |
| `VISION.md`                 | Project vision                          |
| `planning/RULES.md`         | Project rules (AI-agnostic)             |
| `planning/MEMORY.md`        | This file                               |
| `planning/plans/`           | Per-task implementation plans           |

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

## System Version Checklist

Keep these up to date. Before any major work, verify versions match or exceed these minimums.

### Host System (GMKtec EVO X2)

| Component         | Current Version                                          | Min Required                             | How to Check              | How to Update                                  |
| ----------------- | -------------------------------------------------------- | ---------------------------------------- | ------------------------- | ---------------------------------------------- |
| **OS**            | Fedora 43                                                | Fedora 42+                               | `cat /etc/fedora-release` | `sudo dnf upgrade --refresh`                   |
| **Kernel**        | 6.18.10-200.fc43                                         | 6.12+ (amdgpu gfx1151 support)           | `uname -r`                | `sudo dnf upgrade kernel`                      |
| **Kernel params** | `iommu=pt amdgpu.gttsize=54272 ttm.pages_limit=13893632` | Must be set for iGPU memory (53 GiB GTT) | `cat /proc/cmdline`       | `sudo grubby --update-kernel=ALL --args="..."` |
| **Node.js**       | 22.22.0                                                  | 22+                                      | `node -v`                 | `sudo dnf install nodejs` or nvm               |
| **npm**           | 10.9.4                                                   | 10+                                      | `npm -v`                  | `npm install -g npm@latest`                    |
| **Git**           | 2.53.0                                                   | 2.30+                                    | `git --version`           | `sudo dnf install git`                         |
| **Podman**        | 5.7.1                                                    | 5.0+                                     | `podman --version`        | `sudo dnf install podman`                      |
| **Toolbox**       | 0.3                                                      | 0.3+                                     | `toolbox --version`       | `sudo dnf install toolbox`                     |

### OpenClaw

| Component              | Current Version             | How to Check           | How to Update                   |
| ---------------------- | --------------------------- | ---------------------- | ------------------------------- |
| **openclaw (npm)**     | 2026.2.17                   | `openclaw --version`   | `sudo npm i -g openclaw@latest` |
| **openclaw (dev/git)** | main branch                 | `git log --oneline -1` | `git pull`                      |
| **Config**             | `~/.openclaw/openclaw.json` | Read file              | Edit directly                   |

### vLLM Toolbox (inside container)

| Component           | Current Version                                   | How to Check                             | How to Update                             |
| ------------------- | ------------------------------------------------- | ---------------------------------------- | ----------------------------------------- |
| **Container image** | `kyuz0/vllm-therock-gfx1151:latest` (2 weeks old) | `podman images \| grep vllm`             | `cd ~/strix-vllm && ./refresh_toolbox.sh` |
| **vLLM**            | 0.16.0rc1.dev155 (ROCm 7.12)                      | `toolbox run -c vllm pip show vllm`      | Refresh toolbox (new image)               |
| **ROCm SMI**        | 4.0.0 / lib 7.8.0                                 | `toolbox run -c vllm rocm-smi --version` | Refresh toolbox (new image)               |
| **Python**          | 3.13.11                                           | `toolbox run -c vllm python3 --version`  | Refresh toolbox (new image)               |

### GPU & Drivers

| Component         | Current                                        | How to Check                     | Notes                                 |
| ----------------- | ---------------------------------------------- | -------------------------------- | ------------------------------------- |
| **GPU**           | AMD Radeon RX 8060S (gfx1151, 40 CUs, 2.9 GHz) | `lspci \| grep VGA`              | Strix Halo iGPU                       |
| **amdgpu driver** | Kernel-bundled (6.18.10)                       | `modinfo amdgpu \| grep version` | Updates with kernel                   |
| **GPU devices**   | `/dev/dri`, `/dev/kfd`                         | `ls /dev/dri /dev/kfd`           | Must exist for ROCm                   |
| **GPU memory**    | ~53GB GTT (of 61GB usable RAM)                 | `free -h`                        | Set via kernel params (gttsize=54272) |

### API Keys & Providers

| Provider                         | Status                               | How to Check                           |
| -------------------------------- | ------------------------------------ | -------------------------------------- |
| **Anthropic** (Claude Haiku 4.5) | Working                              | `curl` test or OpenClaw chat           |
| **NVIDIA** (Kimi K2.5)           | Working                              | `curl` test                            |
| **Groq** (Llama 3.1 8B)          | Working                              | `curl` test                            |
| **Google** (Gemini 2.0 Flash)    | Quota exceeded (free tier)           | Needs billing enabled                  |
| **Brave Search**                 | Set (untested)                       | Test via OpenClaw web search           |
| **Telegram Bot**                 | Working (@FerdinantArchambault_bot)  | `curl` getMe                           |
| **vLLM local** (Qwen3-14B-AWQ)   | Working (util=0.20, ctx=8192, eager) | `curl http://127.0.0.1:8000/v1/models` |

---

## Patterns & Decisions Log

<!-- Append new entries as they are discovered. Format: YYYY-MM-DD | Summary -->

| Date       | Note                                                                                                                                                                                                                                                                |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-02-19 | `planning/` directory created; all AI assistants should read this file at session start and commit+push after any update                                                                                                                                            |
| 2026-02-19 | Shared config at `~/.openclaw/openclaw.json` — all 3 versions (dev/test/stable) read from same file. API keys in `env` block, referenced via `${VAR}` in providers. Empty env vars with `${}` references crash the config loader — remove unused providers instead. |
| 2026-02-19 | Telegram bot paired: @FerdinantArchambault_bot, user ID 7430205461                                                                                                                                                                                                  |
| 2026-02-19 | Git remote switched to SSH: `git@github.com:fardoche6/openclaw.git`                                                                                                                                                                                                 |
| 2026-02-19 | **CRITICAL**: `amdgpu.gttsize` must NOT exceed physical RAM. Old value 126976 (124G) on 64G system caused OOM crashes. Fixed to 54272 (53G). vLLM reports GTT as "total GPU memory" and allocates based on `--gpu-memory-utilization * total`.                      |
| 2026-02-19 | vLLM safe settings for Strix Halo (53G GTT): `--gpu-memory-utilization 0.95` → ~50G usable. Always use `--enforce-eager` on first run to avoid graph compilation memory spikes.                                                                                     |
| 2026-02-19 | Local model serving: Qwen3-14B-AWQ via vLLM on port 8000, connected to OpenClaw as `local/Qwen/Qwen3-14B-AWQ` (alias: `local`). Config uses `auth: api-key` with dummy key since vLLM has no auth.                                                                  |
| 2026-02-19 | vLLM toolbox (kyuz0/vllm-therock-gfx1151) set up for local AI via AMD Strix Halo iGPU                                                                                                                                                                               |
| 2026-02-19 | Google Gemini API key is on free tier — quota exhausted. Needs billing enabled or new key.                                                                                                                                                                          |
