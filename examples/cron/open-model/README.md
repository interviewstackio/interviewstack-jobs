# Daily job digest on a local open model (free + private)

This runs your daily InterviewStack.io job digest using a **local open model**
(via [Ollama](https://ollama.com)) for the ranking. The InterviewStack MCP server
provides the job **data**; your local model decides what actually fits you.

**Why this and not `claude -p`?**
- **Free** - no hosted-AI API key, no per-token bills. The recurring run uses no AI vendor at all.
- **Private** - your resume/profile and the model run entirely on your machine.
- **Client-neutral** - once set up, the morning run is just `python3 digest.py`. Your AI assistant (Claude, Codex, Copilot, Cline, ...) is only needed for the one-time setup.

(Prefer to spend a hosted-AI call each morning instead? Use `../setup-daily-digest.sh` - the `claude -p` variant.)

## Quick start (your AI assistant can do all of this for you)

```bash
# from this folder, with your key from app.interviewstack.io/sidenav/job-search-mcp
INTERVIEWSTACK_MCP_KEY=isk_... ./setup.sh
```

`setup.sh` will:
1. check `python3`, install **Ollama** if missing (with your OK), and pull the model (`qwen3:8b` by default),
2. scaffold `~/.config/interviewstack-digest/` from `config.example.json`,
3. store your key in `~/.config/interviewstack-digest/env` (`chmod 600`, never committed),
4. install a **jittered** daily schedule (launchd on macOS, cron on Linux).

Then edit `~/.config/interviewstack-digest/config.json` - set `candidateProfile`
and your `search` criteria - and test immediately:

```bash
python3 ~/.config/interviewstack-digest/digest.py --dry-run
```

`--dry-run` ranks and writes the digest but saves nothing and doesn't advance the
de-dupe state, so you can run it as many times as you like while tuning.

## Files

| File | Purpose |
|------|---------|
| `digest.py` | The digest: MCP client for data + Ollama for ranking. No secrets, no personal data. |
| `config.example.json` | Copy to `~/.config/interviewstack-digest/config.json`. Profile, criteria, model, thresholds. |
| `env.example` | Copy to `~/.config/interviewstack-digest/env` (`chmod 600`). Holds only `INTERVIEWSTACK_MCP_KEY`. |
| `setup.sh` | One-time installer (Ollama + model + config + jittered schedule). |

## Choosing a model

Default is `qwen3:8b` (~5 GB, a good balance on a typical laptop). Any Ollama
model that follows JSON instructions works - set `MODEL=...` for `setup.sh` or edit
`ollamaModel` in `config.json`:

- `qwen3:8b` (default) - solid ranking, runs on 16 GB RAM.
- `llama3.1:8b` - lighter alternative.
- larger models (e.g. `qwen3:14b`) - better judgment, need more RAM/VRAM.

The model never talks to the internet for ranking; it only sees the job summaries,
descriptions, and the profile you put in `config.json`.

## How a run works

1. `search_jobs` with your stored criteria (recently posted, your roles/levels/locations).
2. De-dupe against `seen.json` (jobs reported in prior runs) - "nothing new" is a valid result.
3. **Pass 1**: the local model ranks the new jobs on the search summary to shortlist.
4. **Pass 2**: `get_job` pulls the full description for the top few; the model re-scores on the real posting text (catches "the tags lied"). Pass-2 scores win.
5. `save_job` the genuine fits (score >= `saveThreshold`, capped at `maxSavesPerRun`), each with a concrete `fitReason` from the description.
6. Write `~/job-digests/YYYY-MM-DD.md` and a desktop notification.

Saved jobs land in your tracker: **https://app.interviewstack.io/sidenav/my-applications**

## Tuning

| Setting | Effect |
|---------|--------|
| `candidateProfile` | The single biggest lever. Be specific, especially the `Not a fit:` clause. |
| `search` | Canonical filters (use `find_roles`/`list_filter_options` via the MCP to get valid values). |
| `saveThreshold` (default 9) | Lower to save more borderline matches; raise to save only near-perfect fits. |
| `maxSavesPerRun` (default 5) | Hard cap on auto-saves per day. |
| `datePosted` | `"3days"` for daily, `"week"` for a weekly digest. |

## Notes

- Respects the per-key daily caps (search + save). If throttled (HTTP 429), the run stops gracefully and still writes the digest.
- Keep the schedule **jittered** - never on-the-hour. `setup.sh` does this for you.
- Source: InterviewStack.io (the `.io` job board, https://interviewstack.io/job-board).
