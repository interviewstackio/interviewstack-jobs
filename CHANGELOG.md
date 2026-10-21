# Changelog

## v0.2.0 (2026-10-20)

- **Free vs Pro results.** Free accounts now get teaser results: `search_jobs` and
  `get_job` keep role, level, location, work mode, salary, skills, job type and
  posting age, but each job has `company: ""` and `locked: true`, the company name is
  removed from the title, and `get_job` has no `description`, `applyUrl` or
  `companyWebsite`. Locked responses carry `locked: true`, an `upgradeUrl` and a
  `note`. The `companies` filter is ignored, `find_companies` returns an empty locked
  list, and `save_job` returns the new outcome `pro_required` (a normal result, never
  retry it). Pro accounts are unchanged.
- Skills and `AGENTS.md`: handle locked results (tell the user, share the upgrade
  link once, rank on the visible fields, never guess the company, skip `get_job` and
  `save_job` on locked results) and treat `pro_required` as final.
- `examples/cron/open-model/digest.py`: runs a teaser digest on free accounts (no
  `get_job`/`save_job` calls, upgrade link at the top), stops saving on
  `pro_required`, and now handles HTTP errors such as the 429 daily limit as a
  graceful skip instead of crashing.
- Roles are active-only: `find_roles` returns `supported: false` for roles the board
  no longer covers, and `search_jobs` ignores those role names with a `note`.
- New tool **`list_saved_jobs`**: read the user's own application tracker back from
  any connected device/surface (save on a laptop, review on a phone), newest-first
  with status + saved note, optional `status` filter, cursor-paged. Documented in
  `AGENTS.md` (tools list + "Review saved jobs" workflow) and the READMEs.

## v0.1.0

Initial public release.

- Claude Code plugin that connects the InterviewStack.io job-search MCP server and
  installs the skills in one step.
- Skills: `tailor-application`, `resume-polish`, `daily-job-digest`.
- Portable `AGENTS.md` for Codex, Cursor, Copilot, Windsurf, and other MCP clients.
- Per-tool connect docs (Claude Code, Cursor, VS Code + Copilot, Codex, Windsurf) and a
  free local-model path (Ollama + Qwen3-Coder + Cline).
- Jittered daily-digest cron template.
