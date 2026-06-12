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

## Quick start - two copy-pastes, then just talk

1. **Get a key** (free) - sign in at [app.interviewstack.io/sidenav/job-search-mcp](https://app.interviewstack.io/sidenav/job-search-mcp), name your key (e.g. "work-laptop") and click Create. That page fills your key into the commands below automatically. One active key at a time - delete it from the same page if you need a fresh one.
2. **Paste one line in your Terminal** (saves the key permanently):
   ```bash
   echo 'export INTERVIEWSTACK_MCP_KEY="isk_your_key_here"' >> ~/.zshrc && source ~/.zshrc
   ```
   (Linux/bash: use `~/.bashrc`.)
3. **Paste two lines in Claude Code** (other tools: [Step 2](#step-2---connect-your-tool)):
   ```
   /plugin marketplace add interviewstackio/interviewstack-jobs
   /plugin install interviewstack-jobs@interviewstack-jobs
   ```
4. **That's the whole setup. Now just ask:**
   > "Find new jobs that match my resume and save the best ones for me every morning."

   Your assistant takes it from there: asks for your resume, sets up the morning
   schedule itself (jittered, on your machine), and from then on the best new
   matches land in [your application tracker](https://app.interviewstack.io/sidenav/my-applications)
   with a note on why each one fits. You review and apply. Jobs you remove are
   never re-saved. More ideas: [starter prompts](#starter-prompts---what-to-ask-it).

Prefer to script the schedule yourself instead of asking in chat? See
[Step 3](#step-3---daily-digest-on-autopilot).

---

## Step 1 - Get your API key (all tools)

Sign in at **[app.interviewstack.io/sidenav/job-search-mcp](https://app.interviewstack.io/sidenav/job-search-mcp)**,
name your key (e.g. `work-laptop`) and click **Create key**. Copy the key
(`isk_…`) - it's shown once. One active key at a time: delete it from the same
page if you need a fresh one (anything still using the old key stops working).

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

Once connected, grab a prompt from [Starter prompts](#starter-prompts---what-to-ask-it) below.

---

## Step 3 - Daily digest on autopilot

This is the step that makes the whole thing passive: a scheduled run finds what's
**new** for you each morning, **auto-saves the strongest matches** (each with a
one-line "why it fits" note) into your
[application tracker](https://app.interviewstack.io/sidenav/my-applications), and
writes a compact digest to a log. You review and apply from the tracker - jobs you
remove are never re-saved.

```bash
# Picks a RANDOM time inside your window (see note below) and installs a cron entry.
WINDOW_START=6 WINDOW_END=9 ./examples/cron/setup-daily-digest.sh
```

**Put your criteria in the prompt.** Each headless run starts fresh, so tell it what
you want explicitly:

```bash
DIGEST_PROMPT="Run my daily job digest: new senior ML engineer roles, remote, US, \
posted today. Top 6, save the best 2-3 to my tracker with concrete fit reasons." \
WINDOW_START=6 WINDOW_END=9 ./examples/cron/setup-daily-digest.sh
```

> **⏰ Always jitter the schedule.** Don't run it at 09:00 sharp. If everyone runs
> on the hour, the shared job database takes a synchronized hit and gets slow for
> everyone. The setup script randomizes the time for you; if you schedule manually,
> pick a random minute (e.g. `07:23`, not `08:00`). The digest isn't time-critical.

The cron template runs Claude Code headlessly; on another tool, schedule that tool's
equivalent headless/agent command with the same jittered timing.

---

## Starter prompts - what to ask it

Copy-paste any of these into your connected AI tool. They're ordered roughly by
where you are in a job search.

**Explore what the board covers**
> "What job search tools do you have from InterviewStack, and what roles does the
> board support for someone with my background? Here's my resume: [paste]"

**Find roles that actually fit you (not keyword soup)**
> "Here's my resume: [paste]. Find roles on the InterviewStack board that genuinely
> fit my background - rank by real fit, be honest about stretches, and show salary
> where listed."

**Targeted search with hard constraints**
> "Find senior backend engineer roles, remote, US, posted this week, paying
> $180k+. I need visa sponsorship. Top 10, newest first."

**Build a shortlist and save it for later**
> "Search for staff product manager roles in fintech, hybrid or remote in NYC.
> Save the 3 best fits to my InterviewStack tracker with a concrete reason for
> each, and give me the link to review them."

**Tailor applications to the best matches**
> "Here's my resume: [paste]. Find the 2 best-fitting senior data scientist roles
> posted this week and draft tailored resume bullets, a short cover note, and the
> apply link for each. Save both to my tracker."

**Polish your resume against real demand**
> "Pull 8-10 real senior DevOps postings from the InterviewStack board, tell me
> which skills and phrasings keep recurring, and rewrite my resume toward that
> demand. Here's the current version: [paste]"

**Scope a career pivot with real data**
> "I'm a data analyst who wants to move toward ML engineering. Using the
> InterviewStack board: which adjacent roles exist, what do their postings ask for
> that I don't have yet, and which current openings would accept my profile today?"

**Market recon**
> "What are the highest-paying remote machine learning roles on the board right
> now? Which companies show up most in those results?"

**Set up the recurring digest (interactive alternative to Step 3)**
> "Set up a daily job digest for me: new senior frontend roles, remote, EU,
> every morning at a randomized time between 7 and 9. Each run, save the best 2-3
> new matches to my tracker with fit reasons and keep the digest to 6 lines."

A few habits that get better results: paste your **real resume** (fit ranking is
only as good as what the agent knows about you), state **hard constraints**
explicitly (visa, salary floor, location), and ask it to be **honest about
stretches** - the board's curated taxonomy means "no good matches" is a real,
useful answer.

---

## Use a local, open model (free and private)

Prefer to run the AI on your own machine? Point a local open-source model at the same
MCP server. Two real wins:

- **Free.** No API keys, no per-token bills. The model runs on your hardware; your only
  cost is your own compute.
- **Private.** Your model and your **resume stay on your machine**. (Job search still
  calls our hosted MCP, so the job data comes from InterviewStack.io, but your resume
  and the model never leave your computer.)

**What you need**

1. A local runtime. [Ollama](https://ollama.com) is the simplest.
2. A model that is good at **tool calling** - this workflow is multi-step (the agent
   calls `find_roles`, then `search_jobs`, then `get_job`), so an agentic/coding model
   is the right pick. A strong, ~30B example is **`qwen3-coder:30b`** (tuned for tool
   use; budget roughly 24 GB+ of RAM/VRAM at a 4-bit quant). Smaller 7-14B models work
   but are less reliable at the multi-tool flow. (If you specifically want a ~27B model,
   Google's `gemma3:27b` is another option, but pick one trained for tool calling.)
3. An MCP-capable agent client that supports local models, such as
   [Cline](https://cline.bot) for VS Code.

**Recipe: Cline + Ollama + Qwen3-Coder**

```bash
# 1. Pull the model (see ollama.com/library for current tags)
ollama pull qwen3-coder:30b
```

```json
// 2. In Cline, add the MCP server (MCP Servers -> Configure), remote HTTP:
{
  "mcpServers": {
    "interviewstack-jobs": {
      "type": "streamableHttp",
      "url": "https://mcp-job-search.interviewstack-io.workers.dev/mcp",
      "headers": { "Authorization": "Bearer YOUR_KEY" }
    }
  }
}
```

3. In Cline, choose **Ollama** as the API provider and `qwen3-coder:30b` as the model.
4. Drop [`AGENTS.md`](./AGENTS.md) into your workspace so the model follows the
   curated-filters-first workflow, then ask it to find roles and tailor to your resume.

> **Honest note:** local models are less reliable at multi-step tool orchestration than
> frontier hosted models, so expect to guide them a bit more. The curated-filters-first
> design (resolve the role with `find_roles`, then a structured `search_jobs`) keeps each
> step simple, which helps smaller models stay on track. If your client can't reach the
> remote server directly, bridge it with `mcp-remote` (see "Any other MCP client" above).

---

## What you get

### Tools (via the MCP server)
- **search_jobs** - live search with the board's curated classification (role,
  level, skills, location, work mode, salary, benefits, company size, …).
- **get_job** - full job detail + the apply link.
- **save_job** - save a well-matched job (with a fit note) to your InterviewStack
  application tracker - review and apply later at
  [app.interviewstack.io/sidenav/my-applications](https://app.interviewstack.io/sidenav/my-applications).
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
  criteria, on your own scheduler - it auto-saves the strongest matches to your
  application tracker so they're waiting for you. *"Send me new ML engineer jobs
  every morning."*

> **On other tools:** add the MCP server (Step 2) and drop [`AGENTS.md`](./AGENTS.md)
> in your project - that gives the agent the same curated-filters-first workflow the
> Claude skills encode. Individual skill files are also in [`skills/`](./skills) if
> you'd rather copy one into your tool's rules.

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

## License and scope

The contents of this repository (skills, plugin manifests, docs, and example scripts)
are released under the **MIT License** - see [LICENSE](./LICENSE). Use them freely.

This open license covers the **client-side assets only**. The InterviewStack.io
job-search **service, API, and job data are proprietary** and operated by
InterviewStack.io; access is via an API key and subject to its terms and rate limits.
In other words: the client is open, the service is hosted.

**Trademark:** "InterviewStack" and "InterviewStack.io" are trademarks of
InterviewStack.io. The MIT license covers the code, not the marks. Please do not use the
name or logo in a way that implies endorsement of a fork or derivative.

## Contributing

Issues (bugs, ideas, questions) are welcome. Pull requests are maintainer-led; small
fixes are welcome, and for larger changes please open an issue first. See
[CONTRIBUTING.md](./CONTRIBUTING.md) and [SECURITY.md](./SECURITY.md).
