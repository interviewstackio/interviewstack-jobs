# Security Policy

## Reporting a vulnerability

If you find a security issue in this repository or in the InterviewStack.io job-search
MCP service, please report it privately. Do not open a public issue for security
problems.

- Preferred: open a private security advisory via the GitHub "Security" tab
  ("Report a vulnerability").
- Or email security@interviewstack.io.

Please include steps to reproduce and the impact you observed. We will acknowledge your
report and keep you updated on the fix.

## API keys

Keys issued for the MCP service (`isk_...`) are read-only, rate-limited, and revocable.
If a key is exposed, regenerate it from your account page
(app.interviewstack.io/sidenav/job-search-mcp) to immediately revoke the old one. Never
commit a key to source control.

## Scope

This repository contains client-side assets (skills, plugin manifests, docs, and
example scripts). The MCP service, API, and job data are operated separately by
InterviewStack.io.
