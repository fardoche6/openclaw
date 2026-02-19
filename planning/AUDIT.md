# OpenClaw — Project Audit

> Last updated: 2026-02-19
> This document is a comprehensive audit of the OpenClaw project.
> It serves as a quick-reference for any person or AI assistant joining the project.

---

## Table of Contents

1. [What Is OpenClaw?](#1-what-is-openclaw)
2. [Architecture](#2-architecture)
3. [Complete Feature List](#3-complete-feature-list)
4. [Extensions, Skills & Plugins](#4-extensions-skills--plugins)
5. [Mobile & Desktop Apps](#5-mobile--desktop-apps)
6. [Performance Tuning Opportunities](#6-performance-tuning-opportunities)
7. [Configuration Surface](#7-configuration-surface)
8. [Testing & Quality](#8-testing--quality)
9. [Dependencies Audit](#9-dependencies-audit)
10. [Suggestions & Recommendations](#10-suggestions--recommendations)

---

## 1. What Is OpenClaw?

OpenClaw is a **multi-channel AI gateway** — a personal AI assistant platform you self-host. It connects 26+ messaging channels to multiple AI model providers through a single local gateway.

- **Version**: 2026.2.16 (date-based versioning)
- **Repo**: https://github.com/openclaw/openclaw
- **Docs**: https://docs.openclaw.ai
- **License**: MIT (Copyright 2025 Peter Steinberger)
- **Stack**: Node 22+, TypeScript (ESM), pnpm monorepo
- **History**: Evolved from `warelay` CLI → `Clawdbot` → `Moltbot` → **OpenClaw**

This repo (`fardoche6/openclaw`) is a **fork** of the official `openclaw/openclaw` repository.

---

## 2. Architecture

### High-Level Flow

```
User devices / chat channels (WhatsApp, Telegram, Discord, Slack, …)
        │
        ▼
┌─────────────────────────────────────┐
│     Gateway (Control Plane)         │
│     ws://127.0.0.1:18789            │
│                                     │
│  ┌─ Channel Health Monitor          │
│  ├─ Message Routing & Allowlists    │
│  ├─ Media Pipeline (download/MIME)  │
│  ├─ Sanitization (NFC, null bytes)  │
│  └─ Session Key Derivation          │
└─────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│     Agent Runtime (RPC Mode)        │
│     @mariozechner/pi-agent-core     │
│                                     │
│  ┌─ System Prompt Assembly          │
│  ├─ Tool Invocation (30+ tools)     │
│  ├─ Memory Injection                │
│  ├─ Streaming (block delimiters)    │
│  └─ Context Window (150k cap)       │
└─────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│     LLM Provider                    │
│     Anthropic / OpenAI / Ollama /   │
│     Gemini / xAI / local models     │
│                                     │
│  ┌─ Auth Profile Rotation           │
│  ├─ Failover Chains                 │
│  ├─ Batch Processing                │
│  └─ Usage Tracking                  │
└─────────────────────────────────────┘
        │
        ▼
    Delivery back to channel
    (chunking, threading, streaming, reactions)
```

### Entry Points

| Entry | Description |
|-------|-------------|
| CLI (`openclaw.mjs`) | Commander.js routing → commands |
| Gateway (`src/gateway/server.ts`) | WebSocket + HTTP server |
| Web UI (`ui/`) | Lit web components + Vite |
| iOS/Android/macOS apps | Native apps connecting via WebSocket |

### Key Abstractions

- **Sessions**: `main` (1:1), named (parallel), group (multi-participant)
- **Agents**: Per-workspace configs, subagent spawning (depth 2 default)
- **Channels**: Pluggable adapters with allowlists, DM policies, mention gating
- **Tools**: 30+ built-in (browser, canvas, memory, cron, exec, web, messaging)
- **Plugins**: Extensions loaded via Jiti with `openclaw.plugin.json` manifests

### Storage

| Data | Location | Format |
|------|----------|--------|
| Session transcripts | `~/.openclaw/agents/<id>/sessions/` | JSONL (0o600 perms) |
| Configuration | `~/.openclaw/config.json` | JSON5 |
| Credentials | `~/.openclaw/credentials/` | JSON per provider |
| Cron jobs | `~/.openclaw/agents/<id>/cron/` | JSONL + metadata |
| Memory (builtin) | `~/.openclaw/agents/<id>/memory.db` | SQLite |
| Memory (QMD) | Markdown + LanceDB vector store | Files + SQLite |
| Pairing tokens | `~/.openclaw/pairing/` | Token files |

### Repository Layout

```
src/             Core: CLI, commands, routing, channels, media, agents, gateway
extensions/      36 channel/feature plugins (workspace packages)
skills/          52 AI assistant skills (SKILL.md documentation files)
packages/        2 backward-compat shims (clawdbot, moltbot)
apps/            iOS (Swift/SwiftUI), Android (Kotlin/Compose), macOS
ui/              Web UI (Lit + Vite)
docs/            Mintlify docs (docs.openclaw.ai)
test/            Integration / e2e tests
scripts/         Build and utility scripts
Swabble/         Voice wake-word daemon (macOS/iOS)
planning/        Rules, memory, plans (this directory)
```

---

## 3. Complete Feature List

### 3.1 Messaging Channels (26 total)

#### Built-in (13)

| Channel | Technology | Notes |
|---------|-----------|-------|
| WhatsApp | Baileys (web) | Unofficial API |
| Telegram | grammY | Polls, reactions, draft-mode streaming |
| Slack | Bolt | Rich components, typing indicators |
| Discord | discord.js | Components v2, embeds, forum threads, voice |
| Google Chat | Google Chat API | Enterprise integration |
| Signal | signal-cli | Secure messaging |
| BlueBubbles | Webhooks | Recommended iMessage bridge |
| iMessage | imsg (legacy) | Direct macOS integration |
| WebChat | Built-in | Gateway-served web interface |
| macOS | Native | Menu bar app |
| iOS | Native | Voice Wake, Talk Mode, Canvas |
| Android | Native | Talk Mode, camera, screen recording, SMS |
| LINE | LINE Bot SDK | Japanese messaging platform |

#### Extensions (13)

| Channel | Files | Tests | Maturity |
|---------|-------|-------|----------|
| Microsoft Teams | 49 | 14 | High |
| Matrix | 57 | 12 | High |
| Feishu (Lark) | 35 | 7 | High |
| Mattermost | 20 | 5 | Medium |
| Twitch | 22 | 10 | Medium |
| IRC | 17 | 7 | Medium |
| Zalo | 15 | 2 | Medium |
| Zalo (User) | 13 | 2 | Medium |
| Nextcloud Talk | 15 | 2 | Medium |
| Tlon (Urbit) | 22 | 6 | Medium |
| Nostr | 13 | 10 | Medium |
| Phone Control | 1 | 0 | Stub |
| Talk Voice | 1 | 0 | Stub |

#### Cross-Channel Features

- Per-channel allowlists & denial lists
- DM policies (pairing / open / none)
- Message routing & forwarding
- Reply threading (Telegram topics, Discord threads, Slack threads)
- Mention gating (group control)
- Typing indicators & presence
- Streaming/chunking with channel-specific sizes
- Rich interactive components (buttons, selects, forms)
- Reaction/emoji handling

### 3.2 AI Model Providers (15+)

**OAuth (Subscription-based):**
- Anthropic (Claude Pro/Max)
- OpenAI (ChatGPT)

**API Key:**
- Anthropic, OpenAI, Google Gemini, OpenRouter, xAI Grok
- Hugging Face, Moonshot (Kimi.ai), AWS Bedrock
- Minimax Portal, Qwen Portal, OpenCode Zen

**Local/Self-hosted:**
- Ollama (with Qwen 3 reasoning support)
- vLLM
- LiteLLM (proxy gateway)

**Other:**
- GitHub Copilot (via extension proxy)

**Model Features:**
- Per-model context window configuration
- Thinking/reasoning mode with budget control
- Model failover chains
- Auth profile rotation + cooldown
- Streaming support (`tool_stream`)
- Batch processing (OpenAI/Gemini/Voyage)
- Cost tracking and usage reporting

### 3.3 CLI Commands (20+)

| Command | Purpose |
|---------|---------|
| `openclaw agent` | Send messages to the agent |
| `openclaw message send` | Deliver to specific channels |
| `openclaw gateway` | Run the control plane |
| `openclaw tui` | Terminal UI |
| `openclaw onboard` | Setup wizard |
| `openclaw doctor` | Diagnostics + repairs |
| `openclaw dashboard` | Web control panel |
| `openclaw status` | State snapshot |
| `openclaw models` | List/configure LLM providers |
| `openclaw channels` | Manage channel connections |
| `openclaw agents` | Multi-agent management |
| `openclaw sessions` | Conversation session control |
| `openclaw cron` | Scheduled job management |
| `openclaw update` | Version management |
| `openclaw uninstall` | Cleanup |
| `openclaw reset` | State reset |
| `openclaw qr` | Pairing QR generation |
| `openclaw pairing` | Device pairing management |
| `openclaw node` | Node mode operation |
| `openclaw nodes` | Multi-node management |

### 3.4 Agent Tools (30+)

Browser control, Canvas (A2UI push/reset/eval), message send/read/react/edit/delete/pin, session management, memory (get/add/delete/list/status), cron scheduling, Discord/Slack/Telegram/WhatsApp actions, web search/fetch, image analysis, exec (sandboxed), subagent spawning.

### 3.5 Memory System

| Backend | Storage | Search |
|---------|---------|--------|
| Builtin | SQLite + FTS | Full-text search |
| QMD | Markdown + LanceDB | Hybrid vector + keyword |

Features: MMR reranking, temporal decay, query expansion, per-agent scoped collections, session file sync.

### 3.6 Automation & Scheduling

- **Cron jobs** — rich scheduling syntax (Croner), per-job isolation
- **Webhooks** — inbound/outbound with token auth
- **Gmail Pub/Sub** — email integration
- **Heartbeat** — configurable polling
- **Session reaper** — auto-cleanup of stale conversations

### 3.7 Voice & Media

- **Voice Wake** — on-device speech recognition (macOS/iOS/Android)
- **Talk Mode** — real-time voice conversation overlay
- **Swabble** — standalone wake-word daemon (Speech.framework)
- **ElevenLabs TTS** — voice selection and caching
- **Whisper** — transcription (local CLI + API)
- **Image handling** — resize, compress (Sharp/sips), EXIF
- **Video** — frame extraction, recording
- **PDF** — analysis via pdfjs-dist

### 3.8 Browser Control

Dedicated Chrome/Chromium with Playwright: click, type, scroll, screenshot, form filling, upload, multi-profile, DNS resolution control (SSRF mitigation).

### 3.9 Canvas (A2UI)

Agent-driven UI: push/reset/eval operations, live updates, multi-platform (macOS/iOS/Android).

### 3.10 Security

- Device pairing via QR code + token auth
- DM policies (pairing-gated by default)
- Sandbox execution (Docker + AppArmor/seccomp)
- File permissions (0o600 for transcripts)
- SSRF protection (URL allowlists)
- Credential redaction in logs
- Security audit tool (`src/security/audit.ts`)
- Tool approval gating for dangerous operations

---

## 4. Extensions, Skills & Plugins

### 4.1 Extension Summary

**36 total extensions** across categories:

| Category | Count | Examples |
|----------|-------|---------|
| Communication channels | 25 | Teams, Matrix, IRC, Twitch, Nostr, Feishu |
| Feature plugins | 7 | voice-call, memory-lancedb, llm-task, diagnostics-otel |
| Auth providers | 4 | Gemini CLI auth, Minimax, Qwen, Google Antigravity |

**Maturity tiers:**
- **High** (10+ tests, 30+ files): Matrix, Teams, Voice-Call, Feishu, BlueBubbles
- **Medium** (2-10 tests): Mattermost, Tlon, Twitch, Nextcloud, Zalo, IRC, Google Chat, Nostr
- **Stubs** (0-1 files): device-pair, phone-control, talk-voice, open-prose, shared

### 4.2 Skills (52 total)

All skills follow the pattern `skills/<name>/SKILL.md` with YAML frontmatter.

| Category | Skills |
|----------|--------|
| Dev & DevOps | github, gh-issues, coding-agent, skill-creator, mcporter, tmux |
| Productivity | apple-notes, apple-reminders, bear-notes, obsidian, notion, trello, things-mac |
| Communication | discord, slack, imsg, himalaya (email), bluebubbles, voice-call, wacli |
| Media | openai-whisper, openai-whisper-api, openai-image-gen, sherpa-onnx-tts, video-frames, camsnap, gifgrep |
| Data & Utility | nano-pdf, model-usage, summarize, session-logs, healthcheck, weather |
| Music | spotify-player, sonoscli, songsee |
| Smart Home | openhue (Philips Hue), sonoscli (Sonos) |
| AI Models | gemini, nano-banana-pro, sag |
| Security | 1password |
| Other | food-order, goplaces, blogwatcher, peekaboo, canvas, clawhub, ordercli, eightctl |

### 4.3 Plugin System Architecture

```
Extension Discovery (scan extensions/)
        │
        ▼
Manifest Load (openclaw.plugin.json)
        │
        ▼
Jiti Dynamic Import (TypeScript/JS)
        │
        ▼
Plugin Registration:
  ├─ Channels (auth, messaging, outbound, status, heartbeat)
  ├─ Agent Tools (tool factories with context)
  ├─ HTTP Handlers (webhook routes)
  ├─ Hooks (before_agent_start, before_tool_call, llm_input/output, …)
  ├─ Commands (CLI command dispatch)
  └─ Memory Backends
```

**SDK exports** at `openclaw/plugin-sdk` (17 files in `src/plugin-sdk/`).

### 4.4 Packages

Only 2 backward-compat shims: `clawdbot` and `moltbot` (forward CLI to `openclaw`).

---

## 5. Mobile & Desktop Apps

### iOS (Alpha)

- Swift 6.0 / SwiftUI, minimum iOS 18.0
- Voice Wake, Talk Mode, Canvas, Camera, Location
- Share Extension (forward URLs/text/images)
- Bonjour/mDNS pairing, QR-code onboarding
- EventKit integration (reminders, calendar)

### Android (Internal)

- Kotlin / Jetpack Compose, minimum SDK 31
- Talk Mode, Canvas, Camera (photo/video/audio)
- Foreground service for persistent connection
- NSD/mDNS discovery

### macOS

- Menu bar app with Voice Wake + Talk Mode
- Live Canvas (A2UI), WebChat embedded
- ElevenLabs TTS, Sparkle auto-update

### Swabble (Voice Wake-Word Daemon)

- macOS 26+ / iOS 26+ via Speech.framework
- Default wake-word: "clawd" (aliases: "claude")
- Local-only (zero network), hook system for dispatch

### Shared Framework (OpenClawKit)

Cross-platform Swift: transport, types, gateway protocol, chat UI, canvas infrastructure.

---

## 6. Performance Tuning Opportunities

### Critical

| Issue | Where | Impact | Recommendation |
|-------|-------|--------|----------------|
| **Synchronous SQLite** | `src/memory/manager.ts`, `qmd-manager.ts` | Blocks event loop on every DB call | Add async wrapper or connection pool; enable WAL mode |
| **No SQLITE_BUSY retry** | `src/memory/qmd-manager.ts:34-35` | Fails silently under contention | Implement exponential backoff |
| **Large PDFs in RAM** | pdfjs-dist usage | Memory spikes on big documents | Stream or cap page count |

### Medium

| Issue | Where | Impact | Recommendation |
|-------|-------|--------|----------------|
| **Embedding concurrency hardcoded** | `src/memory/manager-embedding-ops.ts:28` | Can't tune for hardware | Make `EMBEDDING_INDEX_CONCURRENCY` configurable |
| **No HTTP compression** | Gateway HTTP handlers | Larger payloads over network | Add gzip middleware |
| **Image EXIF parsed every time** | `src/media/image-ops.ts` | Redundant work on re-processed images | Cache EXIF results |
| **Plugin loading not cached** | `src/plugins/loader.ts` | Jiti re-compiles on config change | Pre-compile or lazy-load heavy plugins |
| **Batch sizes hardcoded** | `EMBEDDING_BATCH_MAX_TOKENS = 8000` | Can't optimize for provider | Make configurable |

### Low / Nice-to-Have

| Issue | Recommendation |
|-------|----------------|
| No startup profiling | Add boot timing metrics |
| Shell env loading has timeout but is synchronous | Consider async shell env |
| File watchers accumulate debounce timers | Verify cleanup on session end |
| No API token budget enforcement | Add per-session/per-user cost caps |
| No cost-aware model selection | Route cheaper queries to cheaper models |

---

## 7. Configuration Surface

### Environment Variables (from `.env.example`)

**Gateway:**
```
OPENCLAW_GATEWAY_TOKEN, OPENCLAW_GATEWAY_PASSWORD
OPENCLAW_STATE_DIR, OPENCLAW_CONFIG_PATH, OPENCLAW_HOME
OPENCLAW_LOAD_SHELL_ENV, OPENCLAW_SHELL_ENV_TIMEOUT_MS
```

**Model Providers:**
```
ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY, OPENROUTER_API_KEY
ZAI_API_KEY, AI_GATEWAY_API_KEY, MINIMAX_API_KEY
```

**Channels:**
```
TELEGRAM_BOT_TOKEN, DISCORD_BOT_TOKEN, SLACK_BOT_TOKEN, SLACK_APP_TOKEN
MATTERMOST_BOT_TOKEN, MATTERMOST_URL, ZALO_BOT_TOKEN, OPENCLAW_TWITCH_ACCESS_TOKEN
```

**Tools & Media:**
```
BRAVE_API_KEY, PERPLEXITY_API_KEY, FIRECRAWL_API_KEY
ELEVENLABS_API_KEY, DEEPGRAM_API_KEY
OPENCLAW_IMAGE_BACKEND (sharp | sips)
```

### Config File (`~/.openclaw/config.json`)

155 config type modules in `src/config/`. Key tunable areas:

| Area | Config Key | Default |
|------|-----------|---------|
| Agent concurrency | `agents.defaults.maxConcurrent` | 4 |
| Subagent concurrency | `agents.defaults.subagents.maxConcurrent` | 8 |
| Bootstrap file limit | `bootstrapMaxChars` | 20KB |
| Bootstrap total limit | `bootstrapTotalMaxChars` | 150KB |
| Memory search results | `memory.qmd.limits.maxResults` | 6 |
| Memory snippet size | `memory.qmd.limits.maxSnippetChars` | 700 |
| Memory query timeout | `memory.qmd.limits.timeoutMs` | 4s |
| QMD command timeout | `memory.qmd.update.commandTimeoutMs` | 30s |
| QMD update timeout | `memory.qmd.update.updateTimeoutMs` | 120s |
| Channel health check | `gateway.channelHealthCheckMinutes` | 30 |
| Gateway bind | `gateway.bind` | loopback |
| Gateway port | `gateway.port` | 18789 |

### What's Hardcoded That Shouldn't Be

| Value | Location | Current |
|-------|----------|---------|
| Auth rate limit max attempts | `auth-rate-limit.ts` | 10 |
| Auth rate limit window | `auth-rate-limit.ts` | 60s |
| Auth rate limit lockout | `auth-rate-limit.ts` | 300s |
| Embedding batch tokens | `manager-embedding-ops.ts` | 8000 |
| Embedding concurrency | `manager-embedding-ops.ts` | 4 |
| Embedding retry attempts | `manager-embedding-ops.ts` | 3 |
| Tool loop detection | Agent runtime | 30 repeats |

---

## 8. Testing & Quality

### Coverage

| Metric | Value |
|--------|-------|
| Total test files | ~1210 in `src/` |
| Unit tests | ~861 files |
| E2E/integration tests | ~349 files (`.e2e.test.ts`, `.live.test.ts`) |
| Coverage threshold (lines) | 70% |
| Coverage threshold (branches) | 55% |
| Test runner | Vitest (forked pool) |
| Max workers (CI) | 3 |
| Test timeout | 120s |

### What's Covered

- Core logic, config parsing, routing, media pipeline, memory
- Plugin SDK

### What's NOT Covered (by design)

- CLI command wiring (`src/cli/`, `src/commands/`)
- Channel integrations (validated manually / via E2E)
- Gateway server runtime (validated via E2E)
- Interactive UIs (TUI, wizard)
- Batch embedding operations (partially)

### Extension Test Coverage

Highly variable: Matrix (12 tests), Teams (14 tests), Twitch (10 tests), but Discord/Signal/Slack/iMessage have **0 tests**.

---

## 9. Dependencies Audit

### Heavy Dependencies

| Package | Size | Notes |
|---------|------|-------|
| `@mariozechner/pi-*` | Large | Core AI runtime (4 packages) |
| `sharp` | Native | Image processing; install issues on ARM/Synology |
| `pdfjs-dist` | ~5MB | PDF parsing; loads full PDFs into memory |
| `playwright-core` | ~100MB+ | Browser automation; optional Docker install |
| `@whiskeysockets/baileys` | Native | WhatsApp (RC version 7.0.0-rc.9) |
| `sqlite-vec` | Alpha | Vector DB (0.1.7-alpha.2) — stability risk |

### Notable Overrides (pnpm)

```
fast-xml-parser@5.3.4, form-data@2.5.4, qs@6.14.2
@sinclair/typebox@0.34.48, tar@7.5.9, tough-cookie@4.1.3
```

### Security Notes

- `.detect-secrets.cfg` + `.secrets.baseline` (71KB) for secret scanning
- HMAC-based gateway auth (`src/security/secret-equal.js`)
- No external crypto library — relies on Node.js `crypto` module
- Sandbox isolation via Docker + seccomp/AppArmor

---

## 10. Suggestions & Recommendations

### Architecture & Code Quality

| # | Suggestion | Priority | Effort |
|---|-----------|----------|--------|
| 1 | **Add async SQLite wrapper** — synchronous DB access blocks the event loop; this is the single biggest performance win | High | Medium |
| 2 | **Enable SQLite WAL mode** — allows concurrent reads during writes | High | Low |
| 3 | **Add HTTP compression** (gzip/brotli) to the gateway server | Medium | Low |
| 4 | **Make hardcoded limits configurable** (embedding concurrency, batch sizes, rate limits) | Medium | Low |
| 5 | **Pre-compile or lazy-load extensions** — Jiti re-compiles on every config change | Medium | Medium |
| 6 | **Add SQLITE_BUSY retry with exponential backoff** | Medium | Low |
| 7 | **Stream large PDFs** instead of loading entirely into memory | Medium | Medium |
| 8 | **Cache EXIF data** to avoid re-parsing on the same image | Low | Low |

### Documentation & Onboarding

| # | Suggestion | Priority | Effort |
|---|-----------|----------|--------|
| 9 | **Add READMEs to all extensions** — only 12/36 have them | High | Medium |
| 10 | **This AUDIT.md** now serves as the architecture quick-reference | Done | — |
| 11 | **Document the plugin SDK API** with examples and migration guides | Medium | Medium |
| 12 | **Add architecture diagrams** (Mermaid) to `docs/` | Low | Low |

### Testing

| # | Suggestion | Priority | Effort |
|---|-----------|----------|--------|
| 13 | **Add tests for untested extensions** (Discord, Signal, Slack, iMessage — all at 0) | High | High |
| 14 | **Add performance benchmarks** for memory queries and agent startup | Medium | Medium |
| 15 | **Add stress tests** for concurrent agent runs | Medium | Medium |
| 16 | **Add config validation snapshot tests** | Low | Low |

### Features & Product

| # | Suggestion | Priority | Effort |
|---|-----------|----------|--------|
| 17 | **Token budget enforcement** — add per-session/user cost caps to prevent runaway API costs | High | Medium |
| 18 | **Cost-aware model routing** — route simple queries to cheaper/faster models automatically | Medium | High |
| 19 | **Finish stubs** — clarify purpose or remove: device-pair, phone-control, talk-voice, open-prose, shared | Low | Low |
| 20 | **Complete Teams resumable upload** (TODO in `extensions/msteams/src/graph-upload.ts` for files >4MB) | Low | Medium |

### Operations & Reliability

| # | Suggestion | Priority | Effort |
|---|-----------|----------|--------|
| 21 | **Add startup profiling** — measure boot phases to identify slow plugin loads | Medium | Low |
| 22 | **Add health metrics export** (Prometheus/OpenTelemetry) — `diagnostics-otel` extension exists but is minimal | Medium | Medium |
| 23 | **Monitor sqlite-vec stability** — it's alpha (0.1.7-alpha.2); have a fallback plan | Medium | Low |
| 24 | **Validate extension transitive dependencies** — some have undeclared deps | Low | Low |

---

## Summary Metrics

| Metric | Value |
|--------|-------|
| Messaging channels | 26 (13 built-in + 13 extensions) |
| LLM providers | 15+ |
| Skills | 52 |
| Extensions | 36 |
| CLI commands | 20+ |
| Agent tools | 30+ |
| Mobile platforms | 3 (iOS, Android, macOS) |
| Test files | ~1,210 |
| Coverage threshold | 70% lines, 55% branches |
| Config modules | 155 |
| Packages | 2 (backward-compat shims) |
