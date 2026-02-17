# Running the Dev Repo Without Impacting Your Standard Install

## Problem

You have a working OpenClaw installed globally (via `npm install -g openclaw`). You want to build and run the same repo (`~/Source/Openclaw/openclaw`) for development/testing without touching your existing `~/.openclaw` state, config, credentials, sessions, or daemon.

## How OpenClaw Resolves Paths

OpenClaw uses environment variables (with sane defaults) to locate everything. The key ones are:

| Variable | Default | What It Controls |
|---|---|---|
| `OPENCLAW_HOME` | `~` | Base directory for deriving `~/.openclaw` |
| `OPENCLAW_STATE_DIR` | `~/.openclaw` | Sessions, logs, caches, credentials |
| `OPENCLAW_CONFIG_PATH` | `~/.openclaw/openclaw.json` | Main config file |
| `OPENCLAW_GATEWAY_PORT` | `18789` | Gateway WebSocket port |
| `OPENCLAW_PROFILE` | *(unset = default)* | Isolates daemon service names (systemd/launchd) |

By overriding these, the dev build will be completely sandboxed from your production install.

---

## Step-by-Step Plan

### 1. Create an Isolated State Directory

```bash
mkdir -p ~/Source/Openclaw/openclaw/.dev-state
```

This will hold config, sessions, logs, and credentials for your dev version — completely separate from `~/.openclaw`.

### 2. Create a Minimal Dev Config

```bash
cat > ~/Source/Openclaw/openclaw/.dev-state/openclaw.json << 'EOF'
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-6"
      }
    }
  },
  "gateway": {
    "port": 28789
  }
}
EOF
```

> [!IMPORTANT]
> The gateway port is set to **28789** (instead of the default 18789) so it won't conflict with your running production gateway.
> Update the model to whatever you use, or add your API keys here.

### 3. Build the Dev Repo

```bash
cd ~/Source/Openclaw/openclaw
pnpm install
pnpm ui:build
pnpm build
```

### 4. Create a Launcher Script

Create a script that wraps every command with the right environment:

```bash
cat > ~/Source/Openclaw/openclaw/dev-run.sh << 'SCRIPT'
#!/usr/bin/env bash
# Run openclaw dev build in isolation from the standard install.
# Usage: ./dev-run.sh <any openclaw subcommand>
# Example: ./dev-run.sh gateway --verbose
#          ./dev-run.sh agent --message "Hello"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export OPENCLAW_STATE_DIR="${SCRIPT_DIR}/.dev-state"
export OPENCLAW_CONFIG_PATH="${SCRIPT_DIR}/.dev-state/openclaw.json"
export OPENCLAW_GATEWAY_PORT=28789
export OPENCLAW_PROFILE=dev

exec node "${SCRIPT_DIR}/scripts/run-node.mjs" "$@"
SCRIPT

chmod +x ~/Source/Openclaw/openclaw/dev-run.sh
```

### 5. Run the Dev Version

```bash
cd ~/Source/Openclaw/openclaw

# Start the isolated gateway
./dev-run.sh gateway --verbose

# In another terminal — talk to the dev gateway
./dev-run.sh agent --message "Hello from dev"

# Or use the dev loop with auto-reload
OPENCLAW_STATE_DIR=~/Source/Openclaw/openclaw/.dev-state \
OPENCLAW_CONFIG_PATH=~/Source/Openclaw/openclaw/.dev-state/openclaw.json \
OPENCLAW_GATEWAY_PORT=28789 \
OPENCLAW_PROFILE=dev \
pnpm gateway:watch
```

### 6. (Optional) Do NOT Install the Daemon

Skip `--install-daemon` when onboarding the dev copy. Running a second daemon would compete with your production one. Just run the dev gateway manually when you need it.

If you do want a daemon, the `OPENCLAW_PROFILE=dev` variable ensures it gets a separate systemd/launchd service name (`openclaw-gateway-dev` instead of `openclaw-gateway`), so they won't clash.

---

## Quick Reference: What Lives Where

| | Production (existing) | Dev (this repo) |
|---|---|---|
| **Binary** | `openclaw` (global npm) | `node scripts/run-node.mjs` (local) |
| **Config** | `~/.openclaw/openclaw.json` | `.dev-state/openclaw.json` |
| **State** | `~/.openclaw/` | `.dev-state/` |
| **Gateway port** | `18789` | `28789` |
| **Profile** | *(default)* | `dev` |
| **Daemon** | `openclaw-gateway` service | `openclaw-gateway-dev` (optional) |

---

## Checklist Before Testing

- [x] `pnpm install` completed successfully
- [x] `pnpm build` completed successfully
- [ ] `.dev-state/openclaw.json` exists with correct model + port
- [ ] Dev gateway starts on port 28789 without errors (needs model auth keys)
- [ ] Production gateway on port 18789 is unaffected

## Cleanup

When done, just remove the dev state:

```bash
rm -rf ~/Source/Openclaw/openclaw/.dev-state
rm ~/Source/Openclaw/openclaw/dev-run.sh
# If you installed a dev daemon:
systemctl --user disable --now openclaw-gateway-dev.service
rm ~/.config/systemd/user/openclaw-gateway-dev.service
```

Your production `~/.openclaw` is never touched.
