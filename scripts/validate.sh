#!/usr/bin/env bash
#
# Validate the marketplace + plugin manifests and skills. Runs in CI and locally.
# A broken manifest means /plugin install fails for every user — so we gate it.

set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
err() { echo "  ✗ $1"; fail=1; }
ok()  { echo "  ✓ $1"; }

jq_get() { jq -er "$2" "$1" 2>/dev/null; }

echo "== marketplace manifest =="
MK=.claude-plugin/marketplace.json
if [ ! -f "$MK" ]; then err "missing $MK"; else
  jq -e . "$MK" >/dev/null 2>&1 && ok "valid JSON" || err "invalid JSON in $MK"
  jq_get "$MK" '.name' >/dev/null && ok "has name" || err "missing .name"
  jq_get "$MK" '.owner.name' >/dev/null && ok "has owner.name" || err "missing .owner.name"
  jq_get "$MK" '.plugins[0].source' >/dev/null && ok "has plugins[].source" || err "missing plugins[].source"
fi

echo "== plugin manifests =="
# every plugin source referenced by the marketplace must exist + have plugin.json
for src in $(jq -r '.plugins[].source' "$MK" 2>/dev/null); do
  dir="${src#./}"
  PJ="$dir/.claude-plugin/plugin.json"
  if [ ! -f "$PJ" ]; then err "missing $PJ (referenced by marketplace)"; continue; fi
  jq -e . "$PJ" >/dev/null 2>&1 && ok "$PJ valid JSON" || err "$PJ invalid JSON"
  jq_get "$PJ" '.name' >/dev/null && ok "$dir: has name" || err "$dir: missing .name"
  jq_get "$PJ" '.version' >/dev/null && ok "$dir: has version" || err "$dir: missing .version"
  # MCP server (inline) — if present, must be type http with a url
  if jq -e '.mcpServers' "$PJ" >/dev/null 2>&1; then
    jq -e '.mcpServers | to_entries[] | select(.value.type=="http" and (.value.url|type=="string"))' "$PJ" >/dev/null 2>&1 \
      && ok "$dir: mcpServers http config present" || err "$dir: mcpServers present but malformed"
    # the auth header must reference an env var, never a hard-coded key
    if jq -r '.mcpServers[].headers.Authorization // ""' "$PJ" | grep -qE 'Bearer isk_'; then
      err "$dir: HARD-CODED key in Authorization header — must use \${INTERVIEWSTACK_MCP_KEY}"
    else
      ok "$dir: no hard-coded key in headers"
    fi
  fi
done

echo "== skills =="
# every SKILL.md must have frontmatter with a description
shopt -s nullglob
found_skill=0
for sk in skills/*/SKILL.md plugins/*/skills/*/SKILL.md; do
  found_skill=1
  head -1 "$sk" | grep -q '^---' && grep -q '^description:\|^description: >' "$sk" \
    && ok "$sk has frontmatter description" || err "$sk missing frontmatter description"
done
[ "$found_skill" = 1 ] || err "no SKILL.md files found"

echo
if [ "$fail" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "VALIDATION FAILED"; exit 1; fi
