# Contributing

Thanks for your interest in the InterviewStack.io job-search tools.

## How this project is maintained

- **Issues are welcome** - bug reports, ideas, and questions. Please open an issue.
- **Pull requests are maintainer-led.** The InterviewStack.io team ships the code.
  Small, focused fixes (typos, doc corrections, a broken config) are welcome as PRs.
  For anything larger, please open an issue first so we can align before you invest
  time.

## What is in here

Client-side assets only:

- `plugins/interviewstack-jobs/` - the Claude Code plugin (MCP server config + skills)
- `skills/` - portable copies of the skills for non-plugin clients
- `AGENTS.md` - tool-agnostic workflow guidance
- `examples/` - helper scripts (for example, the jittered daily-digest cron)

The MCP server, API, and job data live elsewhere and are operated by InterviewStack.io.

## Before you open a PR

Run the validator (it also runs in CI):

```bash
bash scripts/validate.sh
```

It checks the marketplace and plugin manifests, the skills frontmatter, and that no API
key is ever hard-coded in a config. Keep changes consistent with the existing style.

## Reporting security issues

See [SECURITY.md](./SECURITY.md). Do not file security problems as public issues.
