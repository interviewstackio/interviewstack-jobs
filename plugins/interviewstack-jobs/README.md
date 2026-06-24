# interviewstack-jobs (plugin)

Connects the InterviewStack.io job-search MCP server and installs the job-search
skills. Part of the [`interviewstack-jobs` marketplace](../../README.md).

## Install

```
/plugin marketplace add interviewstackio/interviewstack-jobs
/plugin install interviewstack-jobs@interviewstack-jobs
```

## Requires

An API key in the `INTERVIEWSTACK_MCP_KEY` environment variable. Generate one at
[app.interviewstack.io/sidenav/job-search-mcp](https://app.interviewstack.io/sidenav/job-search-mcp),
then:

```bash
export INTERVIEWSTACK_MCP_KEY="isk_your_key_here"
```

If the key is missing, the MCP server won't authenticate (you'll see a 401 / the
tools will fail). Set the variable and restart Claude Code.

## Provides

| Type | Name | What it does |
|------|------|--------------|
| MCP server | `interviewstack-jobs` | search_jobs, get_job, find_roles, find_skills, find_locations, find_companies, list_filter_options, save_job, list_saved_jobs |
| Skill | `tailor-application` | Find fitting roles → draft tailored applications |
| Skill | `resume-polish` | Sharpen a resume, optionally targeted at real postings |
| Skill | `daily-job-digest` | Recurring low-noise digest of new matching roles |

See the [repo README](../../README.md) for full setup, the daily-digest cron, and
non-Claude-Code clients.
