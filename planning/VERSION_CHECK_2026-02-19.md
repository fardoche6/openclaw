# Version Check Report — Feb 19, 2026

## Ollama + Vulkan Benchmark Preparation

**Date**: 2026-02-19
**System**: GMKtec EVO-X2 (Strix Halo gfx1151, 64GB LPDDR5x)
**Task**: Pre-flight check before Ollama+Vulkan benchmark implementation

---

## Current System State

| Component             | Current Version         | Status                         |
| --------------------- | ----------------------- | ------------------------------ |
| **OS**                | Fedora 43               | ✅ Current                     |
| **Kernel**            | 6.18.10-200.fc43.x86_64 | ✅ Current                     |
| **Python**            | 3.14.2                  | ✅ Latest                      |
| **GPU Driver (ROCm)** | 7.7.0                   | ✅ Up-to-date (newer than 7.2) |
| **Ollama**            | Not installed           | ⚠️ **ACTION NEEDED**           |
| **Vulkan**            | Not installed           | ⚠️ **ACTION NEEDED**           |
| **vLLM**              | 0.16.0rc1.dev155        | ✅ Pre-release of 0.16.0       |
| **GTT Allocation**    | 54272 (53GB)            | ✅ Correct                     |

---

## Latest Available Software Versions (Feb 2026)

### 1. **Ollama** → **v0.16.2** (Feb 17, 2026) ✅

- **Current system**: Not installed
- **Action**: INSTALL from https://ollama.com or GitHub releases
- **Install command** (Fedora/Linux):
  ```bash
  curl -fsSL https://ollama.ai/install.sh | sh
  ```
- **Key features in 0.16.2**:
  - Improved image generation timeout handling (OLLAMA_LOAD_TIMEOUT)
  - Better installation progress display
  - Stable Vulkan support for Linux
  - OpenAI-compatible API (port 11434)

**Sources**:

- [Ollama GitHub Releases](https://github.com/ollama/ollama/releases)
- [Ollama Download](https://ollama.com/)

### 2. **Vulkan SDK** → **1.4.341.1** (Feb 4, 2026) ✅

- **Current system**: Not detected
- **Action**: INSTALL Vulkan SDK and drivers
- **Components needed**:
  - Vulkan SDK tools (validation layers, tools)
  - AMD Vulkan drivers (part of AMDGPU driver)
  - `vulkan-tools` package for testing

- **Install command** (Fedora):

  ```bash
  # Vulkan SDK/tools
  sudo dnf install vulkan-tools vulkan-loader vulkan-validation-layers

  # Verify installation
  vulkaninfo | head -20
  ```

**Sources**:

- [Vulkan SDK Home (LunarG)](https://vulkan.lunarg.com/sdk/home)
- [Vulkan Latest Release](https://www.vulkan.org/)

### 3. **AMD AMDGPU Driver** → **7.2 (revision 25.35)** (Jan 21, 2026) ✅

- **Current system**: Detected (rocm-smi works), exact version unknown
- **Action**: VERIFY installed version, UPDATE if needed
- **Installation**:

  ```bash
  # Check current version
  rocm-smi --version

  # Update AMDGPU driver (Fedora)
  sudo dnf install amdgpu-install
  sudo amdgpu-install -y --usecase=graphics,opencl,hip,rocm
  ```

**Sources**:

- [AMD Linux Driver Download](https://www.amd.com/en/support/download/linux-drivers.html)
- [ROCm on Strix Halo (gfx1151) Documentation](https://community.frame.work/t/linux-rocm-january-2026-stable-configurations-update/79876)

### 4. **AMD ROCm** → **7.2 (official) or 7.11 (TheRock nightly)** (Feb 2026) ⚠️

- **Current system**: ROCm 7.x (exact version unknown, detected by rocm-smi)
- **Status Notes**:
  - **gfx1151 (Strix Halo) is NOT officially supported** on AMD's support matrix
  - **ROCm 7.2** works but may have stability issues after 4-5 turns
  - **TheRock 7.11 nightly** is reportedly "dramatically faster" on gfx1151
  - Recommendation: Keep current ROCm 7.2, test Ollama Vulkan as alternative

- **Check version**:
  ```bash
  rocm-smi
  ```

**Sources**:

- [ROCm Strix Halo Support (Framework)](https://community.frame.work/t/linux-rocm-january-2026-stable-configurations-update/79876)
- [TheRock 7.11 Discussion (GitHub ROCm)](https://github.com/ROCm/TheRock/discussions/2845)

### 5. **vLLM** → **v0.16.0** (Feb 12, 2026) ✅

- **Current system**: Unknown version (running in podman)
- **Action**: CHECK version in container
- **Check command**:
  ```bash
  # Inside podman container
  podman exec vllm python3 -c "import vllm; print(vllm.__version__)"
  ```

**Sources**:

- [vLLM Releases (GitHub)](https://github.com/vllm-project/vllm/releases)
- [vLLM Documentation](https://docs.vllm.ai/en/latest/)

### 6. **Python** → **3.14.2** (Latest) ✅

- **Current system**: Python 3.14.2 (installed and working)
- **Status**: Already at latest
- **Compatibility**: Fully compatible with vLLM 0.16.0 and Ollama

---

## Ollama + Vulkan Specific Requirements

### For Ollama Vulkan to Work on Strix Halo (gfx1151):

| Requirement                  | Needed | Current             | Status          |
| ---------------------------- | ------ | ------------------- | --------------- |
| **Vulkan Loader**            | ✅     | ❓                  | Need to install |
| **Vulkan Validation Layers** | ✅     | ❓                  | Need to install |
| **AMD DRI Drivers**          | ✅     | ✅ (rocm-smi works) | Likely present  |
| **AMDGPU Kernel Module**     | ✅     | ✅ (loaded)         | OK              |
| **Ollama (binary)**          | ✅     | ❌                  | Need to install |
| **GTT Allocation**           | ✅     | ✅ (53G)            | Already set     |

### Environment Variables for Testing:

```bash
# Enable Vulkan on Ollama
export OLLAMA_VULKAN=1

# Set host/port
export OLLAMA_HOST=127.0.0.1:11434

# Optional: verbose debugging
export OLLAMA_DEBUG=1
```

---

## Next Steps (Execution Order)

### ✅ Phase 0: Verification (5 min)

**Before proceeding with Phase 1 of benchmark plan:**

1. **Check current versions**:

   ```bash
   # ROCm version
   rocm-smi --version

   # vLLM version (in container)
   podman exec vllm python3 -c "import vllm; print(vllm.__version__)"

   # Kernel and system
   uname -a
   ```

2. **Install Vulkan tools**:

   ```bash
   sudo dnf install -y vulkan-tools vulkan-loader vulkan-validation-layers
   vulkaninfo | head -20  # Should show device info
   ```

3. **Install Ollama**:

   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ollama --version  # Should show v0.16.2
   ```

4. **Verify Vulkan GPU detection**:

   ```bash
   # Start Ollama with Vulkan
   OLLAMA_VULKAN=1 OLLAMA_HOST=127.0.0.1:11434 ollama serve &
   sleep 2

   # Quick test (should show "Vulkan" in logs)
   ollama run qwen3:0.6b "hi"
   ```

### ➜ Phase 1: Shut Down vLLM

_Begin main benchmark plan after Phase 0 completes successfully_

---

## Risk Mitigation

| Risk                                      | Mitigation                                                                                       |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Vulkan not detected after install**     | Check `vulkaninfo` for GPU; set `OLLAMA_VULKAN=1` explicitly; check dmesg for amdgpu load errors |
| **Ollama can't allocate 50GB+ for model** | Verify GTT still 53G: `cat /proc/cmdline \| grep amdgpu.gttsize`                                 |
| **vLLM breaks during testing**            | Automated restart via `podman start vllm` and `bash ~/.openclaw/start-vllm.sh`                   |
| **Old vLLM process still running**        | `pkill -9 -f vllm.entrypoints` before starting new config                                        |
| **CUDA/ROCm conflict with Vulkan**        | Ollama uses Vulkan exclusively (no ROCm), vLLM stays in podman (isolated)                        |

---

## Summary Table: Software Status

| Software       | Latest (Feb 2026) | System        | Gap   | Action                 |
| -------------- | ----------------- | ------------- | ----- | ---------------------- |
| **Ollama**     | 0.16.2            | Not installed | Major | **INSTALL**            |
| **Vulkan SDK** | 1.4.341.1         | Not detected  | Major | **INSTALL**            |
| **AMD AMDGPU** | 7.2 (rev 25.35)   | 7.x (check)   | Minor | **VERIFY**             |
| **ROCm**       | 7.2 (stable)      | 7.x (check)   | Minor | **VERIFY**             |
| **vLLM**       | 0.16.0            | Unknown       | Minor | **CHECK** in container |
| **Python**     | 3.14.2            | 3.14.2        | None  | ✅ OK                  |
| **Kernel**     | 6.18.10+          | 6.18.10       | None  | ✅ OK                  |
| **Fedora**     | 43                | 43            | None  | ✅ OK                  |

---

## Approval to Proceed

Once Phase 0 verification completes and:

- ✅ Ollama 0.16.2 installed and `ollama --version` shows it
- ✅ Vulkan 1.4.341+ tools installed and `vulkaninfo` shows GPU
- ✅ Ollama Vulkan test passes (small model loads on GPU)
- ✅ vLLM still running and healthy on port 8000

**THEN PROCEED** → Full benchmark plan (Phase 1-7)

---

**Document created**: 2026-02-19 by Claude Code
**Repository**: https://github.com/openclaw/openclaw
