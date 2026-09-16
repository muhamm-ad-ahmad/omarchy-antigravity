# Omarchy Antigravity Integration & Quota Monitor

Seamless integration for Google's official **Antigravity CLI (`agy`)** into **[Omarchy Linux](https://omarchy.org/)**, replacing the deprecated Gemini CLI while preserving floating windows, shortcuts, and live top-bar quota telemetry.

---

## 🎯 The Problem

1. **Gemini CLI is Deprecated:** Google deprecated the legacy Gemini Code Assist CLI (`gemini`) in favor of **Google Antigravity (`agy`)**. Running the legacy CLI displays:
   > `This client is no longer supported for Gemini Code Assist for individuals...`
2. **Fragile Workaround on Discord:** Some community guides suggest modifying `/usr/bin/omarchy-agent` using `sudo nano`. However, `/usr/bin/omarchy-agent` is owned by Omarchy's system packages—any future `omarchy update` silently overwrites those edits.
3. **Missing Quota Telemetry:** Stock Omarchy only ships telemetry collectors for Claude, Codex, and Fireworks. Antigravity activity had no display in the top-bar agents panel.

---

## ✨ Features of This Solution

* 🛡️ **100% User-Space & Update-Safe:** Lives in `~/.local/bin/` and `~/.config/`. No `sudo` required. Never gets overwritten on `omarchy update`.
* 🪟 **Floating Terminal Window:** Opens in a centered, styled floating terminal window (`Super + Shift + Ctrl + A`).
* 📊 **Live Activity & Quota Tracking:** Custom collector script parses Antigravity history and SQLite conversation records, displaying prompt counts, sessions, active days, and 7-day activity charts directly inside the Omarchy shell top-bar widget.
* ⚡ **Seamless Keybinding & Bar Support:** Right-click the Agents icon in the top bar to launch; left-click to inspect usage.

---

## 🚀 Quick Install

Clone this repository and run the installer:

```bash
git clone https://github.com/<your-username>/omarchy-antigravity.git
cd omarchy-antigravity
./install.sh
```

Or install via one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/<your-username>/omarchy-antigravity/main/install.sh | bash
```

---

## 🛠️ How It Works

1. **`bin/gemini` (Compatibility Wrapper):**
   * Placed in `~/.local/bin/gemini`.
   * Omarchy's `omarchy-default-agent` checks `~/.local/bin/$agent` first and treats it as a user-level installation.
   * Transparently maps flags:
     * `--yolo` ➔ `--dangerously-skip-permissions`
     * `--prompt-interactive "<prompt>"` ➔ `-i "<prompt>"`
   * Hands execution to `agy`.
2. **`bin/omarchy-agent-usage-agy` (Telemetry Collector):**
   * Reads `~/.gemini/antigravity-cli/history.jsonl` and `~/.gemini/antigravity-cli/conversation_summaries.db`.
   * Formats a JSON record conforming to Omarchy's agent usage schema and writes to `~/.local/state/omarchy/agents/usage/gemini.json`.
   * Automatically triggered when an agent session closes and periodically via systemd user timer (`agy-usage.timer`).
3. **Hyprland Window Rule (`~/.config/hypr/hyprland.lua`):**
   ```lua
   o.window("^(org\\.omarchy\\.agent)$", {
       tag = "+floating-window",
       float = true,
       center = true,
       size = { 1100, 750 },
   })
   ```

---

## ⌨️ Usage

* **Keybinding:** Press `Super + Shift + Ctrl + A` to open a floating Antigravity window.
* **Status Bar:**
  * **Left-click** the Agents icon in the bar to inspect session metrics and 7-day message counts.
  * **Right-click** the Agents icon to launch a new session.
* **CLI:**
  ```bash
  omarchy agent
  omarchy agent prompt "Explain this code"
  ```

---

## 🗑️ Uninstall

```bash
./uninstall.sh
```

---

## 📄 License

MIT
