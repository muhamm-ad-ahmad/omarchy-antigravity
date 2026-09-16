#!/usr/bin/env bash
# ==============================================================================
# Omarchy Antigravity Fix & Quota Collector Uninstaller
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}==> Uninstalling Google Antigravity Omarchy integration...${NC}"

# 1. Stop and disable systemd timer
systemctl --user disable --now agy-usage.timer >/dev/null 2>&1 || true
rm -f "$HOME/.config/systemd/user/agy-usage.service" "$HOME/.config/systemd/user/agy-usage.timer"
systemctl --user daemon-reload >/dev/null 2>&1 || true

# 2. Remove wrapper and collector
rm -f "$HOME/.local/bin/gemini" "$HOME/.local/bin/omarchy-agent-usage-agy"

# 3. Clean usage telemetry cache
rm -f "$HOME/.local/state/omarchy/agents/usage/gemini.json"

# 4. Refresh shell widget if running
if command -v omarchy-shell &>/dev/null; then
  omarchy-shell omarchy.agents refresh >/dev/null 2>&1 || true
fi

echo -e "${GREEN}[✓] Uninstalled successfully.${NC}"
echo -e "Note: ~/.config/hypr/hyprland.lua window rules and ~/.config/omarchy/defaults/agent were preserved."
