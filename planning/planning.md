# Planning

## Completed

- [x] Isolated dev setup — dev gateway running on port 28789, production unaffected. See [isolated-dev-setup.md](isolated-dev-setup.md)
- [x] OpenClaw dev version works with cloud AI models (Anthropic Claude)
- [x] Ollama provider registration fixed (`OLLAMA_API_KEY=ollama-local` in dev-run.sh and systemd service)

## Blocked

- Ollama Vulkan GPU offloading — Ollama can't detect Vulkan GPU in headless service mode. See [ollama-vulkan-fix.md](ollama-vulkan-fix.md)

## Next Steps

1. **Get local AI model working** — pick one approach from [ollama-vulkan-fix.md](ollama-vulkan-fix.md):
   - **Option A (recommended)**: Build `llama.cpp` from source with Vulkan, run `llama-server` as your user, point OpenClaw at it
   - **Option B**: Patch Ollama with a wrapper script to force VK env inheritance
   - **Option C**: Try ROCm instead of Vulkan (may have better AMD iGPU support)
   - **Option D**: File Ollama bug, wait for fix
2. See [hardware.md](hardware.md) for machine specs
3. Explore OpenClaw codebase for contributions (see [audit.md](audit.md) for architecture overview)

## Reference

- [isolated-dev-setup.md](isolated-dev-setup.md) — how to run dev vs production
- [hardware.md](hardware.md) — machine specs (GMKtec EVO x2, Ryzen AI Max+ 395, Radeon RX 8060S)
- [ollama-vulkan-fix.md](ollama-vulkan-fix.md) — Ollama Vulkan debugging log and next steps
- [audit.md](audit.md) — full technology and architecture audit
- [rules.md](rules.md) — planning directory conventions
