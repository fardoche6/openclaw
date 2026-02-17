# Hardware Specs

## Dev Machine: GMKtec EVO x2

- **RAM**: 64 GB
- **CPU**: AMD Ryzen AI Max+ 395 — 64 MB L3 cache, boost up to 5.1 GHz
- **GPU**: AMD Radeon RX 8060S (iGPU) — 40 CUs, up to 2.9 GHz
- **Ollama**: Configured for Vulkan iGPU (`ollama.service` with override.conf)

## Notes

- Ollama runs on CPU only (`size_vram: 0`) despite Vulkan config — GPU offloading needs investigation
- 128K default context window causes excessive RAM usage (~17 GB for a 3B model) — use `num_ctx: 2048-4096` for local testing
- If Vulkan offloading works, the 40 CU iGPU with shared 64 GB RAM should handle 7B+ models comfortably
