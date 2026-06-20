#!/usr/bin/env bash
#
# One-time setup for the FREE + PRIVATE InterviewStack.io daily digest.
# Runs the recurring digest on a LOCAL open model (Ollama) - no hosted-AI key,
# no per-token bills, your resume/profile never leaves your machine.
#
# What it does:
#   1. checks python3 + Ollama (installs Ollama if missing, with your OK)
#   2. pulls the open model (default qwen3:8b)
#   3. scaffolds ~/.config/interviewstack-digest/ from the examples here
#   4. stores your MCP key in env (chmod 600 - never committed)
#   5. installs a JITTERED daily schedule (launchd on macOS, cron on Linux)
#
# JITTER MATTERS: a daily digest is the classic thundering-herd risk. If every
# user fires at 09:00 sharp, the shared job DB takes one synchronized spike. This
# picks a RANDOM minute (and random hour in your window) so load spreads out. The
# digest is not time-critical; jitter costs you nothing and keeps it fast for all.
#
# Usage:
#   INTERVIEWSTACK_MCP_KEY=isk_... ./setup.sh
#   (or run it and paste the key when prompted)
#
# Env knobs: MODEL (default qwen3:8b), WINDOW_START / WINDOW_END (default 6..9)

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CONF_DIR="$HOME/.config/interviewstack-digest"
MODEL="${MODEL:-qwen3:8b}"
WINDOW_START="${WINDOW_START:-6}"
WINDOW_END="${WINDOW_END:-9}"

say() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ── 1. python3 ──────────────────────────────────────────────────────────────
command -v python3 >/dev/null 2>&1 || die "python3 not found. Install Python 3 and re-run."

# ── 2. Ollama (the local open-model runtime) ────────────────────────────────
if ! command -v ollama >/dev/null 2>&1; then
  say "Ollama (the local open-model runtime) is not installed."
  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        read -r -p "Install Ollama via Homebrew now? [y/N] " a
        [[ "$a" == [yY]* ]] && brew install ollama || die "Ollama required. See https://ollama.com/download"
      else
        die "Install Ollama from https://ollama.com/download then re-run."
      fi ;;
    Linux)
      read -r -p "Install Ollama via the official script now? [y/N] " a
      [[ "$a" == [yY]* ]] && curl -fsSL https://ollama.com/install.sh | sh || die "Ollama required. See https://ollama.com/download"
      ;;
    *) die "Unsupported OS. Install Ollama from https://ollama.com/download then re-run." ;;
  esac
fi

# make sure the Ollama server is up (macOS app or `ollama serve`)
if ! curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
  say "Starting Ollama server in the background..."
  (ollama serve >/dev/null 2>&1 &) || true
  for _ in $(seq 1 20); do curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1 && break; sleep 1; done
fi

# ── 3. pull the model ───────────────────────────────────────────────────────
if ! ollama list 2>/dev/null | grep -q "^${MODEL%%:*}"; then
  say "Pulling open model '$MODEL' (one-time download)..."
  ollama pull "$MODEL"
else
  say "Model '$MODEL' already present."
fi

# ── 4. scaffold config dir ──────────────────────────────────────────────────
mkdir -p "$CONF_DIR"
cp -n "$HERE/digest.py" "$CONF_DIR/digest.py"
chmod +x "$CONF_DIR/digest.py"
if [ ! -f "$CONF_DIR/config.json" ]; then
  cp "$HERE/config.example.json" "$CONF_DIR/config.json"
  say "Wrote $CONF_DIR/config.json - EDIT it: set candidateProfile + your search criteria."
fi
# point the config at the chosen model if it differs from the example default
python3 - "$CONF_DIR/config.json" "$MODEL" <<'PY'
import json, sys
p, model = sys.argv[1], sys.argv[2]
c = json.load(open(p)); c["ollamaModel"] = model
json.dump(c, open(p, "w"), indent=2)
PY

# ── 5. store the key (secret, chmod 600) ────────────────────────────────────
KEY="${INTERVIEWSTACK_MCP_KEY:-}"
if [ -z "$KEY" ]; then
  echo "Get your key at https://app.interviewstack.io/sidenav/job-search-mcp"
  read -r -p "Paste your InterviewStack MCP key (isk_...): " KEY
fi
[ -n "$KEY" ] || die "No MCP key provided."
printf 'INTERVIEWSTACK_MCP_KEY=%s\n' "$KEY" > "$CONF_DIR/env"
chmod 600 "$CONF_DIR/env"
say "Stored key in $CONF_DIR/env (chmod 600)."

# ── 6. jittered schedule ────────────────────────────────────────────────────
span=$(( WINDOW_END - WINDOW_START + 1 ))
[ "$span" -ge 1 ] || die "WINDOW_END must be >= WINDOW_START"
HOUR=$(( WINDOW_START + RANDOM % span ))
MIN=$(( RANDOM % 60 ))
PY_BIN="$(command -v python3)"

if [ "$(uname -s)" = "Darwin" ]; then
  PLIST="$HOME/Library/LaunchAgents/io.interviewstack.digest.plist"
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>io.interviewstack.digest</string>
  <key>ProgramArguments</key>
  <array><string>$PY_BIN</string><string>$CONF_DIR/digest.py</string></array>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>$HOUR</integer><key>Minute</key><integer>$MIN</integer></dict>
  <key>StandardOutPath</key><string>$CONF_DIR/run.log</string>
  <key>StandardErrorPath</key><string>$CONF_DIR/run.log</string>
</dict></plist>
PLISTEOF
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
  say "launchd job installed: io.interviewstack.digest"
else
  LINE="$MIN $HOUR * * * $PY_BIN $CONF_DIR/digest.py >> $CONF_DIR/run.log 2>&1"
  ( crontab -l 2>/dev/null | grep -v 'interviewstack-digest' || true; \
    echo "# interviewstack-digest"; echo "$LINE" ) | crontab -
  say "cron entry installed."
fi

printf '\nDaily digest scheduled at %02d:%02d (random within %02d:00-%02d:00).\n' "$HOUR" "$MIN" "$WINDOW_START" "$WINDOW_END"
echo "Next: edit $CONF_DIR/config.json (profile + criteria), then test now with:"
echo "    $PY_BIN $CONF_DIR/digest.py --dry-run"
echo "Logs: $CONF_DIR/run.log   Digests: ~/job-digests/"
