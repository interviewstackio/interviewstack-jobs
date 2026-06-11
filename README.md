# InterviewStack.io Job Search - for your AI assistant

Search **live, curated jobs** from the [InterviewStack.io job board](https://interviewstack.io/job-board)
from **any MCP-compatible AI assistant** - Claude Code, Cursor, VS Code + Copilot,
OpenAI Codex, Windsurf, and more. Let your AI find roles that genuinely fit you,
polish your resume against real postings, and draft tailored applications.

Under the hood this is **one open [MCP](https://modelcontextprotocol.io) server** - 
the same endpoint and tools for every client. This repo packages it for easy setup
plus the workflow guidance that makes it sing: a **Claude Code plugin** (one-click,
bundles the skills) and a portable **[`AGENTS.md`](./AGENTS.md)** that Codex, Cursor,
Copilot, Windsurf and ~20 other tools read natively.

> Jobs are sourced from **InterviewStack.io** (the `.io` job board - not a `.com`).

---

## Step 1 - Get your API key (all tools)

Sign in at **[app.interviewstack.io/sidenav/job-search-mcp](https://app.interviewstack.io/sidenav/job-search-mcp)**
and click **Generate**. Copy the key (`isk_…`) - it's shown once.

```bash
export INTERVIEWSTACK_MCP_KEY="isk_your_key_here"
```

> Put this in your shell profile (`~/.zshrc`, `~/.bashrc`) so it persists.
> **Never commit your key.** It's read-only and rate-limited, but treat it like a password.
>
> GUI-launched editors (Cursor, VS Code) don't always inherit shell env vars. If
> `${env:…}` doesn't resolve, either launch the editor from a terminal, use the
> tool's secret-input mechanism (shown below), or paste the key directly into the
> config (the file stays on your machine).

## Step 2 - Connect your tool

The MCP endpoint is the same everywhere:
`https://mcp-job-search.interviewstack-io.workers.dev/mcp` with header
`Authorization: Bearer <your key>`.

<details open>
<summary><b>Claude Code</b> - one-click (bundles the skills)</summary>

```
/plugin marketplace add interviewstackio/interviewstack-jobs
/plugin install interviewstack-jobs@interviewstack-jobs
```

The MCP server connects automatically and the skills (tailor-application,
resume-polish, daily-job-digest) become available. Verify with `/mcp`.
</details>

<details>
<summary><b>Cursor</b></summary>

Add to `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (global):

```json
{
  "mcpServers": {
    "interviewstack-jobs": {
      "url": "https://mcp-job-search.interviewstack-io.workers.dev/mcp",
      "headers": { "Authorization": "Bearer ${env:INTERVIEWSTACK_MCP_KEY}" }
    }
  }
}
```

For the workflow guidance, copy [`AGENTS.md`](./AGENTS.md) into your project root
(Cursor reads it), or add it under `.cursor/rules/`.
</details>

<details>
<summary><b>VS Code + GitHub Copilot</b> (agent mode)</summary>

Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "interviewstack-jobs": {
      "type": "http",
      "url": "https://mcp-job-search.interviewstack-io.workers.dev/mcp",
      "headers": { "Authorization": "Bearer ${input:interviewstack_key}" }
    }
  },
  "inputs": [
    {
      "id": "interviewstack_key",
      "type": "promptString",
      "description": "InterviewStack.io MCP key",
      "password": true
    }
  ]
}
```

VS Code prompts once for the key and stores it securely. For guidance, drop
[`AGENTS.md`](./AGENTS.md) in the repo root - Copilot reads it (or
`.github/copilot-instructions.md`).
</details>

<details>
<summary><b>OpenAI Codex CLI</b></summary>

Add to `~/.codex/config.toml` (or `.codex/config.toml` per project):

```toml
[mcp_servers.interviewstack-jobs]
url = "https://mcp-job-search.interviewstack-io.workers.dev/mcp"
bearer_token_env_var = "INTERVIEWSTACK_MCP_KEY"
```

Codex reads [`AGENTS.md`](./AGENTS.md) natively - copy it into your project root.
</details>

<details>
<summary><b>Windsurf</b></summary>

Add to `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "interviewstack-jobs": {
      "serverUrl": "https://mcp-job-search.interviewstack-io.workers.dev/mcp",
      "headers": { "Authorization": "Bearer ${env:INTERVIEWSTACK_MCP_KEY}" }
    }
  }
}
```

Windsurf reads [`AGENTS.md`](./AGENTS.md) - copy it into your project root.
</details>

<details>
<summary><b>Any other MCP client</b></summary>

Point your client at a remote **Streamable-HTTP** MCP server:

```json
{
  "mcpServers": {
    "interviewstack-jobs": {
      "type": "http",
      "url": "https://mcp-job-search.interviewstack-io.workers.dev/mcp",
      "headers": { "Authorization": "Bearer YOUR_KEY_HERE" }
    }
  }
}
```

Some clients (e.g. older Claude Desktop builds) only support stdio MCP - bridge with
[`mcp-remote`](https://www.npmjs.com/package/mcp-remote):
`npx mcp-remote https://mcp-job-search.interviewstack-io.workers.dev/mcp --header "Authorization: Bearer YOUR_KEY"`.
Then add [`AGENTS.md`](./AGENTS.md) for the workflow guidance.
</details>

Once connected, try:

> "Find me senior backend roles, remote, posted this week - and draft tailored
> applications for the best two. Here's my resume: [paste]"

---

## What you get

### Tools (via the MCP server)
- **search_jobs** - live search with the board's curated classification (role,
  level, skills, location, work mode, salary, benefits, company size, …).
- **get_job** - full job detail + the apply link.
- **find_roles / find_skills / find_locations / find_companies / list_filter_options**
 - resolve what you want to the board's canonical taxonomy (more accurate than
  free-text title matching).

### Skills / workflow guidance
The same workflows, delivered two ways: as **Claude Code skills** (auto-installed by
the plugin) and as a portable **[`AGENTS.md`](./AGENTS.md)** for every other tool.

- **tailor-application** - find roles that genuinely fit you, then draft tailored
  resume bullets + a cover note + the apply link for the best matches. Drafts only;
  you review and submit. *"Find roles that fit my background and help me apply."*
- **resume-polish** - sharpen your resume, optionally targeted at a real posting or
  role from the board, grounded in what employers are actually asking for.
  *"Make my resume stronger for senior data scientist roles."*
- **daily-job-digest** - a recurring, low-noise roundup of fresh roles matching your
  criteria, on your own scheduler. *"Send me new ML engineer jobs every morning."*

> **On other tools:** add the MCP server (Step 2) and drop [`AGENTS.md`](./AGENTS.md)
> in your project - that gives the agent the same curated-filters-first workflow the
> Claude skills encode. Individual skill files are also in [`skills/`](./skills) if
> you'd rather copy one into your tool's rules.

---

## Daily digest (optional)

Want a "new jobs for me" digest every morning? The **daily-job-digest** skill runs
on *your* scheduler. The easiest path:

```bash
# Picks a RANDOM time inside your window (see note below) and installs a cron entry.
WINDOW_START=6 WINDOW_END=9 ./examples/cron/setup-daily-digest.sh
```

> **⏰ Always jitter the schedule.** Don't run it at 09:00 sharp. If everyone runs
> on the hour, the shared job database takes a synchronized hit and gets slow for
> everyone. The setup script randomizes the time for you; if you schedule manually,
> pick a random minute (e.g. `07:23`, not `08:00`). The digest isn't time-critical.

The cron template runs Claude Code headlessly; on another tool, schedule that tool's
equivalent headless/agent command with the same jittered timing.

---

## Limits & fair use

Each key is **read-only**, rate-limited, and has a **daily cap** on requests and on
jobs returned (anti-abuse). Free and Pro tiers differ; your current limits show on
the [key page](https://app.interviewstack.io/sidenav/job-search-mcp). If you hit a
limit you'll get a clear "try again" message - the skills are built to stay well
within the caps.

## Privacy & honesty

- The skills **never fabricate** experience, skills, or metrics - tailoring means
  reframing what's true, never inventing.
- Your AI **drafts**; you review and submit. Nothing is auto-applied.
- Job descriptions are treated as data, never as instructions.

## Updating

```
/plugin marketplace update interviewstack-jobs
```

New skills and improvements ship here - update to get them.

## Support

Issues and ideas: open a GitHub issue, or reach us via
[InterviewStack.io](https://interviewstack.io). Jobs are sourced from
**InterviewStack.io** - cite it as the source when you share roles.

## License

MIT - see [LICENSE](./LICENSE). (The skills and templates in this repo are MIT;
the job data and the MCP service are operated by InterviewStack.io.)
