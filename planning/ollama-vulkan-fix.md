# Ollama Vulkan GPU Offloading Fix

## Status: BLOCKED — Ollama can't detect Vulkan GPU in headless service mode

## Problem

Ollama runs on CPU only (`size_vram: 0`, `GPULayers: []`) despite Vulkan config. A 3B model consumes 16+ GB RAM and takes minutes per response due to 128K default context on CPU.

## Diagnosis (completed)

- Vulkan works at OS level: `vulkaninfo` shows AMD Radeon GFX1151 (GPU0), RADV driver
- Ollama user (`ollama`) has correct groups: `video`, `render`
- `/dev/dri/renderD128` permissions are correct (`crw-rw----+ root:render`)
- Vulkan libraries exist: `/usr/local/lib/ollama/vulkan/libggml-vulkan.so`
- Ollama loads the Vulkan library path but its GPU discovery subprocess does NOT inherit `VK_ICD_FILENAMES` or `XDG_RUNTIME_DIR`
- `sudo -u ollama vulkaninfo` fails: `XDG_RUNTIME_DIR is invalid or not set`
- Result: subprocess detects CPU only → `inference compute: id=cpu library=cpu`

## What was tried

1. Removed `GGML_VK_VISIBLE_DEVICES=0` from override (was causing warning) — no effect
2. Added `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.json` to service — not passed to subprocess
3. Added `XDG_RUNTIME_DIR=/run/user/997` to service — not passed to subprocess
4. Removed override.conf entirely — no effect
5. Fixed inline `#` comments in service file that broke systemd env parsing

## Root Cause

Ollama's GPU bootstrap subprocess (`ollama runner`) only forwards specific env vars (OLLAMA\_\*, LD_LIBRARY_PATH). It does NOT forward `VK_ICD_FILENAMES`, `VK_DRIVER_FILES`, or `XDG_RUNTIME_DIR`. Without these, Vulkan ICD discovery fails for the `ollama` system user (no display session).

This is likely an Ollama limitation/bug with headless Vulkan on AMD iGPU systems.

## Next Steps (pick one)

### Option A: Build llama.cpp with Vulkan directly (recommended)

Skip Ollama entirely. Build `llama.cpp` from source with `-DGGML_VULKAN=ON`, run `llama-server` as your own user (which has working Vulkan), and point OpenClaw at it as an OpenAI-compatible endpoint.

```bash
# Build
git clone https://github.com/ggerganov/llama.cpp ~/Source/llama.cpp
cd ~/Source/llama.cpp
cmake -B build -DGGML_VULKAN=ON
cmake --build build --config Release -j$(nproc)

# Run (reuse Ollama's downloaded model)
# Find the GGUF blob:
ls -la /usr/share/ollama/.ollama/models/blobs/

# Start server on port 8080 with Vulkan GPU offload
./build/bin/llama-server \
  -m /usr/share/ollama/.ollama/models/blobs/<gguf-file> \
  --port 8080 -ngl 99 -c 4096

# Configure OpenClaw to use it as an OpenAI-compatible provider
```

### Option B: Patch Ollama's wrapper to force env inheritance

Create `/usr/local/bin/ollama-vulkan-wrapper.sh` that exports `VK_ICD_FILENAMES` and `XDG_RUNTIME_DIR` before exec'ing ollama. Use it as `ExecStart` in the service. (Attempted but not yet tested.)

### Option C: Try ROCm instead of Vulkan

ROCm may work better for AMD GPUs and Ollama already ships ROCm runners (`/usr/local/lib/ollama/rocm`). The Ryzen AI Max+ 395 iGPU (RDNA 4 / GFX1151) may need `HSA_OVERRIDE_GFX_VERSION` set. ROCm generally has better LLM support than Vulkan on AMD hardware.

```bash
# Check if ROCm is installed
rocminfo 2>&1 | head -20
# If not, install: https://rocm.docs.amd.com/
# Then set OLLAMA_LLM_LIBRARY=rocm instead of vulkan
```

### Option D: File Ollama bug / wait for fix

Report the issue: Ollama's GPU discovery subprocess doesn't forward Vulkan ICD env vars on headless systems. RDNA 4 (GFX1151) may also need specific support.

## Current Service Config (cleaned up)

### /etc/systemd/system/ollama.service

```ini
[Unit]
Description=Ollama Vulkan iGPU Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_LLM_LIBRARY=vulkan"
Environment="OLLAMA_FLASH_ATTENTION=true"
Environment="OLLAMA_NUM_GPU_LAYERS=99"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_MAX_CONTEXT=4096"
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_DEBUG=1"
Environment="VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.json"
Environment="VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.json"
Environment="XDG_RUNTIME_DIR=/run/user/997"

[Install]
WantedBy=default.target
```

override.conf: **removed** (was causing conflicts)
