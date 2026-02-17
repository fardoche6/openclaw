# llama.cpp Local AI Setup

## Status: WORKING — Vulkan GPU offload confirmed

## Architecture

```
OpenClaw dev gateway (port 28789)
  → llama-server (port 8080, OpenAI-compatible API)
    → Llama 3.2 3B Q4 GGUF (Vulkan GPU, all 29/29 layers offloaded)
```

## Build

llama.cpp was built from source with Vulkan support:

```bash
git clone https://github.com/ggerganov/llama.cpp ~/Source/llama.cpp
cd ~/Source/llama.cpp
cmake -B build -DGGML_VULKAN=ON
cmake --build build --config Release -j$(nproc)
```

Binary: `/home/fardoche/Source/llama.cpp/build/bin/llama-server`

## Running

```bash
/home/fardoche/Source/llama.cpp/build/bin/llama-server \
  -m /home/fardoche/models/llama.cpp/llama-3.2-3b-q4.gguf \
  --port 8080 -ngl 99 -c 16384
```

- `-ngl 99`: offload all layers to GPU
- `-c 16384`: context window (OpenClaw minimum is 16000)

## OpenClaw Configuration

In `.dev-state/openclaw.json`, add a `models.providers` section:

```json
{
  "models": {
    "providers": {
      "llama-server": {
        "baseUrl": "http://127.0.0.1:8080/v1",
        "apiKey": "local",
        "api": "openai-completions",
        "models": [
          {
            "id": "llama-3.2-3b-q4.gguf",
            "name": "Llama 3.2 3B (Q4, Vulkan)",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 16384,
            "maxTokens": 2048
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "llama-server/llama-3.2-3b-q4.gguf"
      }
    }
  }
}
```

Key points:

- `api: "openai-completions"` — llama-server exposes an OpenAI-compatible `/v1/chat/completions` endpoint
- `apiKey: "local"` — any value works, llama-server doesn't validate
- Model ref format: `provider-name/model-id` → `llama-server/llama-3.2-3b-q4.gguf`

## Performance (observed)

- Prompt processing: ~510 tokens/sec
- Generation: ~105 tokens/sec
- GPU: AMD Radeon GFX1151 (RADV), 29/29 layers offloaded via Vulkan
- VRAM usage: ~1918 MB model buffer

## Available Models

Location: `/home/fardoche/models/llama.cpp/`

- `llama-3.2-3b-q4.gguf` — Llama 3.2 3B (currently loaded)
- `mistral-nemo-q4.gguf` — Mistral Nemo (available for testing)

## Why Not Ollama?

Ollama can't detect Vulkan GPU in headless systemd service mode. See [ollama-vulkan-fix.md](ollama-vulkan-fix.md) for full diagnosis. Running llama-server directly as your user bypasses this issue entirely.

## TODO

- [ ] Create a systemd user service for llama-server (auto-start)
- [ ] Test with larger context window (32K+) to suppress warning
- [ ] Test mistral-nemo model
- [ ] Investigate ROCm as alternative to Vulkan for potentially better performance
