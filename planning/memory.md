# OpenClaw Project Memory

## Planning Rules

- All knowledge learned about this project goes in `planning/` directory
- When adding to `planning/`: commit and PR on GitHub (keep info up to date across sessions)
- See `planning/rules.md` for the full rules

## Key Files

- `planning/planning.md` — Current status, next steps, references
- `planning/rules.md` — Planning directory conventions
- `planning/audit.md` — Full technology & architecture audit
- `planning/isolated-dev-setup.md` — Dev setup (port 28789, `.dev-state/`)
- `planning/hardware.md` — Machine specs (GMKtec EVO x2, Ryzen AI Max+ 395, Radeon RX 8060S iGPU, 64GB)
- `planning/ollama-vulkan-fix.md` — Ollama Vulkan debugging (BLOCKED)

## Dev Setup

- Dev: port 28789, `.dev-state/`, `./dev-run.sh`, systemd `openclaw-gateway-dev.service`
- Production: `openclaw` global npm, port 18789, `~/.openclaw/`
- `OLLAMA_API_KEY=ollama-local` needed for Ollama provider registration

## Local Models

- GGUF models stored at: `/home/fardoche/models/llama.cpp`
- Ollama models at: `/usr/share/ollama/.ollama/models/blobs/`

## Known Issues

- Ollama Vulkan broken in headless mode — subprocess doesn't forward VK_ICD_FILENAMES
- Next: try llama.cpp from source with Vulkan, or ROCm
- Never run interactive/blocking commands from Claude — they hang

## Active PR

- PR #1: `planning/add-rules-and-roadmap` branch on `fardoche6/openclaw`
