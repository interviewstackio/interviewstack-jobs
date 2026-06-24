# Changelog

## Unreleased

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
