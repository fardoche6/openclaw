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
export OLLAMA_API_KEY="${OLLAMA_API_KEY:-ollama-local}"

exec node "${SCRIPT_DIR}/scripts/run-node.mjs" "$@"
