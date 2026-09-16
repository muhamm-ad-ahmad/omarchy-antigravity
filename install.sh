#!/usr/bin/env bash
# ==============================================================================
# Omarchy Antigravity Fix & Quota Collector Installer
# Replaces deprecated Gemini CLI with Google Antigravity (agy) in Omarchy
# Fully user-space — safe from `omarchy update` overrides!
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}${BOLD}==> Installing Google Antigravity for Omarchy...${NC}"

# 1. Ensure Antigravity CLI (agy) is installed
if ! command -v agy &>/dev/null; then
  echo -e "${YELLOW}[!] Antigravity CLI (agy) was not found in PATH.${NC}"
  echo -e "${BLUE}[*] Installing Antigravity CLI...${NC}"
  curl -fsSL https://antigravity.google/cli/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v agy &>/dev/null; then
    echo -e "${RED}[✗] Failed to install agy. Please install manually and re-run.${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}[✓] Antigravity CLI detected:${NC} $(agy --version 2>/dev/null || echo 'installed')"

# 2. Clean up deprecated Gemini CLI from mise (if present)
if command -v mise &>/dev/null; then
  if mise list 2>/dev/null | grep -q "gemini"; then
    echo -e "${BLUE}[*] Removing deprecated gemini package from mise...${NC}"
    mise uninstall gemini 2>/dev/null || true
  fi
  if [[ -f "$HOME/.config/mise/config.toml" ]]; then
    sed -i '/gemini =/d' "$HOME/.config/mise/config.toml" 2>/dev/null || true
  fi
fi

# 3. Install user-space compatibility wrapper
mkdir -p "$HOME/.local/bin"
echo -e "${BLUE}[*] Installing ~/.local/bin/gemini wrapper...${NC}"
cp -f "$SCRIPT_DIR/bin/gemini" "$HOME/.local/bin/gemini"
chmod +x "$HOME/.local/bin/gemini"

# 4. Install telemetry / quota collector
echo -e "${BLUE}[*] Installing ~/.local/bin/omarchy-agent-usage-agy collector...${NC}"
cp -f "$SCRIPT_DIR/bin/omarchy-agent-usage-agy" "$HOME/.local/bin/omarchy-agent-usage-agy"
chmod +x "$HOME/.local/bin/omarchy-agent-usage-agy"

# 5. Install systemd timer for periodic quota collection
mkdir -p "$HOME/.config/systemd/user"
echo -e "${BLUE}[*] Installing systemd user timer (agy-usage)...${NC}"
cp -f "$SCRIPT_DIR/systemd/agy-usage.service" "$HOME/.config/systemd/user/agy-usage.service"
cp -f "$SCRIPT_DIR/systemd/agy-usage.timer" "$HOME/.config/systemd/user/agy-usage.timer"

systemctl --user daemon-reload
systemctl --user enable --now agy-usage.timer >/dev/null 2>&1 || true

# 6. Configure Omarchy default agent
mkdir -p "$HOME/.config/omarchy/defaults"
echo "gemini" > "$HOME/.config/omarchy/defaults/agent"
echo -e "${GREEN}[✓] Omarchy default agent set to: gemini (routed to agy)${NC}"

# 7. Add Hyprland floating window rule if not present
HYPR_CONF="$HOME/.config/hypr/hyprland.lua"
if [[ -f "$HYPR_CONF" ]]; then
  if ! grep -q "org\\.omarchy\\.agent" "$HYPR_CONF"; then
    echo -e "${BLUE}[*] Adding floating window rule to ~/.config/hypr/hyprland.lua...${NC}"
    cat << 'EOF' >> "$HYPR_CONF"

o.window("^(org\\.omarchy\\.agent)$", {
    tag = "+floating-window",
    float = true,
    center = true,
    size = { 1100, 750 },
})
EOF
    if command -v hyprctl &>/dev/null; then
      hyprctl reload >/dev/null 2>&1 || true
    fi
  else
    echo -e "${GREEN}[✓] Hyprland window rule for agent already present.${NC}"
  fi
fi

# 8. Run initial usage collection
"$HOME/.local/bin/omarchy-agent-usage-agy" >/dev/null 2>&1 || true

echo -e "\n${GREEN}${BOLD}🎉 Installation complete!${NC}"
echo -e "• Shortcut: Press ${BOLD}Super + Shift + Ctrl + A${NC} to launch Antigravity in a floating window."
echo -e "• Bar widget: Right-click the Agents icon to launch; left-click to view Antigravity activity & quota."
echo -e "• CLI: Run ${BOLD}omarchy agent${NC} or ${BOLD}agy${NC} anytime."
