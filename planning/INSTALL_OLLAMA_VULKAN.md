# Installation Guide: Ollama + Vulkan for Strix Halo

## Setup for Benchmark Testing

**Date**: 2026-02-19
**System**: Fedora 43 + Strix Halo (gfx1151)
**Purpose**: Install Ollama and Vulkan before running benchmark plan

---

## Current System Status (Verified Feb 19)

✅ **Already Good**:

- ROCm 7.7.0 installed and working
- vLLM 0.16.0rc1 running in podman on port 8000
- GTT allocated: 54272 (53GB) ✓
- Python 3.14.2 (latest)
- Fedora 43, Kernel 6.18.10

⚠️ **Need to Install**:

- Ollama 0.16.2
- Vulkan SDK 1.4.341+ tools

---

## Step-by-Step Installation

### Step 1: Install Vulkan Tools (sudo required)

Run this command (will ask for sudo password):

```bash
sudo dnf install -y vulkan-tools vulkan-loader vulkan-validation-layers-devel
```

**Verify installation**:

```bash
vulkaninfo --summary | head -20
```

Should show your Radeon 8060S GPU and "Vulkan" in output.

---

### Step 2: Install Ollama (sudo required)

Run this command (will ask for sudo password):

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Verify installation**:

```bash
ollama --version
# Should output: ollama version 0.16.2 (or higher)
```

---

### Step 3: Test Ollama with Vulkan

Start Ollama server with Vulkan enabled:

```bash
# In terminal 1: Start Ollama with Vulkan
OLLAMA_VULKAN=1 OLLAMA_HOST=127.0.0.1:11434 ollama serve
```

In another terminal, test with a tiny model:

```bash
# Terminal 2: Quick test with 0.6B model
ollama pull qwen3:0.6b
ollama run qwen3:0.6b "Say hello"
```

**What to expect**:

- First pull: ~100MB download, ~30 seconds
- First run: Model loads to GPU (should see "Loaded model" message)
- Response: "Hello!" (instantly)

**In Ollama logs, look for**:

```
[LLM Server] GPU: Vulkan (Device: AMD Radeon 8060S)
```

If you see this, Vulkan GPU detection ✅ works!

---

### Step 4: Pre-pull All Benchmark Models

Pull the models needed for testing (can run in parallel):

```bash
# Terminal: Pull all 5 models for testing
ollama pull qwen3:8b  &  # ~5GB, 5 min
ollama pull qwen3:14b &  # ~9GB, 8 min
ollama pull qwen3:32b &  # ~20GB, 15 min
ollama pull qwen3:72b &  # ~42GB, 25 min
wait

# Also pull 0.6b (already pulled above, but make sure)
ollama pull qwen3:0.6b
```

**Note**:

- 72B may fail with OOM (expected, we'll document "FAILED: exceeds GTT")
- If any pull fails due to disk space, check `df -h` (need ~290GB free available)

---

### Step 5: Create Ollama Modelfile for Qwen3-Coder-30B-MoE GGUF

This is the model we currently use with vLLM, but in GGUF format for Ollama.

```bash
# Create temporary directory
mkdir -p /tmp/qwen3-coder-gguf
cd /tmp/qwen3-coder-gguf

# Download the GGUF model from HuggingFace (~10GB)
# (Requires huggingface-cli or manual download)
huggingface-cli download unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF \
  Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf \
  --local-dir /tmp/qwen3-coder-gguf

# Create Ollama Modelfile
cat > Modelfile << 'EOF'
FROM /tmp/qwen3-coder-gguf/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
PARAMETER temperature 0.7
PARAMETER stop "<|im_end|>"
EOF

# Register in Ollama
ollama create qwen3-coder-30b-moe -f Modelfile
```

**Verify**:

```bash
ollama list | grep qwen3-coder-30b-moe
# Should show: qwen3-coder-30b-moe:latest  10GB
```

---

### Step 6: Verify Ollama OpenAI-Compatible API

Test that Ollama's OpenAI-compatible endpoint works (needed for OpenClaw):

```bash
# Verify API is responding
curl -s http://127.0.0.1:11434/v1/models | python3 -m json.tool

# Should return something like:
# {
#   "data": [
#     {"id": "qwen3:8b", "object": "model", ...},
#     {"id": "qwen3:14b", "object": "model", ...},
#     ...
#   ]
# }
```

---

## Troubleshooting

### Problem: "vulkaninfo: command not found"

**Solution**: Vulkan tools didn't install. Try:

```bash
sudo dnf install -y vulkan-tools
# or
sudo dnf install -y mesa-vulkan-drivers  # For AMD
```

### Problem: Ollama detects CPU, not GPU

**Check**:

```bash
# Look at Ollama logs during startup
OLLAMA_DEBUG=1 ollama serve

# Check for line:
# GPU: ...
# If it says "GPU: (No compatible devices)", then:
```

**Solutions**:

1. Verify AMDGPU kernel driver is loaded:

   ```bash
   lsmod | grep amdgpu
   # Should show: amdgpu (not empty)
   ```

2. Check GPU is detected:

   ```bash
   rocm-smi
   # Should show GPU[0] with your Radeon 8060S
   ```

3. Explicitly enable Vulkan:
   ```bash
   export OLLAMA_VULKAN=1
   ollama serve
   ```

### Problem: "Out of Memory" when pulling/running 72B model

**This is expected**. Document as:

```
Model: qwen3:72b
Status: FAILED - Exceeds 53GB GTT allocation
Notes: Expected failure; continue with 32B and smaller
```

### Problem: Ollama API returns 404 or connection refused

**Check**:

```bash
# Is Ollama running?
curl -s http://127.0.0.1:11434/api/tags

# If connection refused:
# - Ollama crashed, check logs
# - Port 11434 in use? netstat -tln | grep 11434
```

---

## Ready to Benchmark?

Once you can run:

```bash
✅ ollama --version
✅ vulkaninfo --summary | grep -i amd
✅ ollama run qwen3:0.6b "hi" (gets response in <5 seconds)
✅ curl http://127.0.0.1:11434/v1/models (lists models)
✅ All 5 models listed in 'ollama list'
```

**THEN**: Proceed to [Phase 1 of Benchmark Plan](generic-cooking-origami.md)

---

## Environment for Benchmark

When running benchmarks, use these environment variables:

```bash
# Enable Vulkan GPU support
export OLLAMA_VULKAN=1

# Set port
export OLLAMA_HOST=127.0.0.1:11434

# Optional: verbose logging (remove for production)
# export OLLAMA_DEBUG=1

# Start Ollama
ollama serve &
```

---

## Next: Run Benchmark Plan

After installation and verification:

1. **Go to**: `/home/fardochebot/.claude/plans/generic-cooking-origami.md`
2. **Start with**: Phase 1 (Shut Down vLLM)
3. **Follow**: All 7 phases for comprehensive testing

---

**Last updated**: 2026-02-19
**Status**: Ready for user execution
