# Planning

## Completed

- [x] Isolated dev setup — dev gateway running on port 28789, production unaffected. See [isolated-dev-setup.md](isolated-dev-setup.md)
- [x] OpenClaw dev version works with cloud AI models (Anthropic Claude)
- [x] Ollama provider registration fixed (`OLLAMA_API_KEY=ollama-local` in dev-run.sh and systemd service)
- [x] Local AI model working via llama.cpp — Vulkan GPU offload confirmed, ~105 tok/sec. See [llama-cpp-setup.md](llama-cpp-setup.md)

## Blocked

- Ollama Vulkan GPU offloading — Ollama can't detect Vulkan GPU in headless service mode. See [ollama-vulkan-fix.md](ollama-vulkan-fix.md). **Workaround**: using llama.cpp directly instead.

## Next Steps

1. **Create systemd service for llama-server** — auto-start on boot so it's always available
2. **Test with larger context** — 32K+ to suppress OpenClaw low-context warning
3. **Test Mistral Nemo model** — `/home/fardoche/models/llama.cpp/mistral-nemo-q4.gguf`
4. **Investigate ROCm** — may provide better performance than Vulkan on AMD iGPU
5. Explore OpenClaw codebase for contributions (see [audit.md](audit.md) for architecture overview)

## Reference

- [isolated-dev-setup.md](isolated-dev-setup.md) — how to run dev vs production
- [hardware.md](hardware.md) — machine specs (GMKtec EVO x2, Ryzen AI Max+ 395, Radeon RX 8060S)
- [llama-cpp-setup.md](llama-cpp-setup.md) — llama.cpp build, config, and performance
- [ollama-vulkan-fix.md](ollama-vulkan-fix.md) — Ollama Vulkan debugging log and next steps
- [audit.md](audit.md) — full technology and architecture audit
- [rules.md](rules.md) — planning directory conventions
