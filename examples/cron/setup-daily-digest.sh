#!/usr/bin/env bash
#
# Set up a JITTERED daily job-digest cron for the InterviewStack.io MCP.
#
# WHY JITTER MATTERS: a daily digest is the classic "thundering herd" risk. If
# every user schedules 09:00 sharp, thousands of requests hit the shared job
# database in one synchronized burst - spiking latency and failing requests for
# everyone. This script picks a RANDOM minute (and a random hour inside your
# window) so load spreads out. The digest is not time-critical; a few minutes of
# jitter costs you nothing and keeps the service fast for all users.
#
# This installs a cron entry that runs Claude Code headlessly with the
# daily-job-digest skill. Adjust WINDOW_START/WINDOW_END to taste.
#
# Requirements: claude CLI on PATH, the interviewstack-jobs MCP connected
# (INTERVIEWSTACK_MCP_KEY set), bash, crontab.

set -euo pipefail

# ── Your preferred window (24h clock). The run lands at a random time inside it. ─
WINDOW_START="${WINDOW_START:-6}"   # earliest hour (inclusive)
WINDOW_END="${WINDOW_END:-9}"       # latest hour (inclusive)

# What the digest should look for. Edit freely - the skill resolves these to the
# board's canonical taxonomy at run time.
DIGEST_PROMPT="${DIGEST_PROMPT:-Run my daily job digest: new roles matching my saved criteria, top 6, deduped against the last run.}"

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH." >&2
  exit 1
fi
if [ -z "${INTERVIEWSTACK_MCP_KEY:-}" ]; then
  echo "error: INTERVIEWSTACK_MCP_KEY is not set. Get a key at" >&2
  echo "       https://app.interviewstack.io/sidenav/job-search-mcp and export it." >&2
  exit 1
fi

# ── Pick a random hour in [START, END] and a random minute in [0, 59]. ──────────
span=$(( WINDOW_END - WINDOW_START + 1 ))
if [ "$span" -lt 1 ]; then echo "error: WINDOW_END must be >= WINDOW_START" >&2; exit 1; fi
HOUR=$(( WINDOW_START + RANDOM % span ))
MIN=$(( RANDOM % 60 ))

LOG="$HOME/.interviewstack-digest.log"
# Pass the key through to the cron environment; -p runs Claude headlessly.
CMD="INTERVIEWSTACK_MCP_KEY='${INTERVIEWSTACK_MCP_KEY}' claude -p \"${DIGEST_PROMPT}\" >> '${LOG}' 2>&1"
CRON_LINE="${MIN} ${HOUR} * * * ${CMD}"

# Install it (idempotent: replace any prior interviewstack-digest line).
( crontab -l 2>/dev/null | grep -v 'interviewstack-digest\|INTERVIEWSTACK_MCP_KEY' || true; \
  echo "# interviewstack-digest"; echo "${CRON_LINE}" ) | crontab -

printf 'Daily digest scheduled at %02d:%02d (randomized within %02d:00-%02d:00).\n' "$HOUR" "$MIN" "$WINDOW_START" "$WINDOW_END"
echo "Logs: ${LOG}"
echo "Re-run this script any time to re-roll the time. Remove with: crontab -e (delete the interviewstack-digest lines)."
