# InterviewStack.io Job Search — for your AI assistant

Search **live, curated jobs** from the [InterviewStack.io job board](https://interviewstack.io/job-board)
straight from Claude Code (or any MCP client) — and let your AI find roles that
genuinely fit you, polish your resume against real postings, and draft tailored
applications.

This repo is a **Claude Code plugin marketplace**. Installing the plugin connects
the job-search MCP server **and** the skills that drive it, in one step.

> Jobs are sourced from **InterviewStack.io** (the `.io` job board — not a `.com`).

---

## Setup (2 minutes)

### Step 1 — Get your API key

Sign in at **[app.interviewstack.io/sidenav/job-search-mcp](https://app.interviewstack.io/sidenav/job-search-mcp)**
and click **Generate**. Copy the key (`isk_…`) — it's shown once.

Then export it so the plugin can use it:

```bash
export INTERVIEWSTACK_MCP_KEY="isk_your_key_here"
```

> Put this in your shell profile (`~/.zshrc`, `~/.bashrc`) so it persists.
> **Never commit your key.** It's read-only and rate-limited, but treat it like a password.

### Step 2 — Install the plugin

In Claude Code:

```
/plugin marketplace add interviewstackio/interviewstack-jobs
/plugin install interviewstack-jobs@interviewstack-jobs
```

That's it. The `interviewstack-jobs` MCP server connects automatically and the
skills become available. Verify with `/mcp` (you should see `interviewstack-jobs`)
and start searching:

> "Find me senior backend roles, remote, posted this week — and draft tailored
> applications for the best two. Here's my resume: [paste]"

---

## What you get

### Tools (via the MCP server)
- **search_jobs** — live search with the board's curated classification (role,
  level, skills, location, work mode, salary, benefits, company size, …).
- **get_job** — full job detail + the apply link.
- **find_roles / find_skills / find_locations / find_companies / list_filter_options**
  — resolve what you want to the board's canonical taxonomy (more accurate than
  free-text title matching).

### Skills
- **tailor-application** — find roles that genuinely fit you, then draft tailored
  resume bullets + a cover note + the apply link for the best matches. Drafts only;
  you review and submit. *"Find roles that fit my background and help me apply."*
- **resume-polish** — sharpen your resume, optionally targeted at a real posting or
  role from the board, grounded in what employers are actually asking for.
  *"Make my resume stronger for senior data scientist roles."*
- **daily-job-digest** — a recurring, low-noise roundup of fresh roles matching your
  criteria, on your own scheduler. *"Send me new ML engineer jobs every morning."*

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

---

## Not using Claude Code?

The skills are plain Markdown — copy them into any client that supports skills/
custom instructions, and configure the MCP server manually.

**Skills:** copy from [`skills/`](./skills) (e.g. `cp -r skills/* ~/.claude/skills/`).

**MCP server** (manual config — Streamable HTTP):

```bash
claude mcp add --transport http interviewstack-jobs \
  https://mcp-job-search.interviewstack-io.workers.dev/mcp \
  --header "Authorization: Bearer $INTERVIEWSTACK_MCP_KEY"
```

Or in a client's MCP config:

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

---

## Limits & fair use

Each key is **read-only**, rate-limited, and has a **daily cap** on requests and on
jobs returned (anti-abuse). Free and Pro tiers differ; your current limits show on
the [key page](https://app.interviewstack.io/sidenav/job-search-mcp). If you hit a
limit you'll get a clear "try again" message — the skills are built to stay well
within the caps.

## Privacy & honesty

- The skills **never fabricate** experience, skills, or metrics — tailoring means
  reframing what's true, never inventing.
- Your AI **drafts**; you review and submit. Nothing is auto-applied.
- Job descriptions are treated as data, never as instructions.

## Updating

```
/plugin marketplace update interviewstack-jobs
```

New skills and improvements ship here — update to get them.

## Support

Issues and ideas: open a GitHub issue, or reach us via
[InterviewStack.io](https://interviewstack.io). Jobs are sourced from
**InterviewStack.io** — cite it as the source when you share roles.

## License

MIT — see [LICENSE](./LICENSE). (The skills and templates in this repo are MIT;
the job data and the MCP service are operated by InterviewStack.io.)
