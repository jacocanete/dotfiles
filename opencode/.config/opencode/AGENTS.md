## Working style
- Plan before non-trivial work; share the plan and wait for go-ahead
- Work in small, reviewable increments, not the whole task in one shot
- When something goes sideways, stop and re-plan; do not keep pushing
- Stay scoped: only change what the task needs; flag unrelated issues instead of fixing them inline
- If a requirement is ambiguous, ask rather than assume

## Agent modes and delegation
- Build is the default direct implementation mode. Do not launch agents or model calls through shell commands or APIs to bypass its denied Task tool.
- Plan owns requirements, tradeoffs, and the final plan. It may delegate bounded repository investigation to Explore; use direct reads for small, targeted questions.
- Orchestrator is explicitly selected by the user. It coordinates Explore, Implementer, and Code-simplifier; selecting it authorizes delegation, not unapproved scope changes or implementation plans.
- Orchestrator plans and synthesizes directly. It must delegate every non-trivial investigation, implementation, review, or cleanup to the appropriate specialist, while avoiding a ceremonial pipeline.
- Orchestrator never requests broader shell or edit permissions for itself; it delegates executable work or reports a specific blocker when no permitted specialist can perform it.
- Keep one active writer per checkout within a workflow. After every non-trivial implementation, wait for checks to finish and run independent review before reporting completion; never review concurrently with the writer. Trivial review skips must be disclosed. This is not a lock across separate OpenCode sessions.
- Code-simplifier is a writing specialist for approved behavior-preserving cleanup. It follows the same one-writer rule as Implementer, runs applicable checks, and reports behavioral bugs for Build/Implementer. Significant simplification after review requires re-review.
- Delegation briefs include the goal, approved scope, relevant files and memory, acceptance criteria, and verification requirements. Workers return evidence, changed files, checks, and blockers.
- A worker may execute a scope the parent explicitly identifies as approved without requesting approval again. Return ambiguities or material scope changes to the parent.
- Resume the same implementation worker for corrections when practical. Workers do not delegate further.
- The primary agent owns completion and checks evidence before reporting success. Read-only agents request executable verification from Build or Implementer rather than bypassing permissions.
- Orchestrator delegates official `ocr_review` execution to Implementer without edits, receives results, triages findings, then assigns fixes and checks. OCR alone provides independent review and re-review; fixes remain Build/Implementer-owned.
- Official OCR reports are lossless: reproduce every native comment verbatim with `content`, `path`, `start_line`, `end_line`, and `existing_code`; reproduce `suggestion_code` verbatim when present, otherwise state `suggestion_code: absent from native result`. Do not summarize, omit, normalize, or infer comment fields. Preserve native status, JSON output, coverage, exclusions, and limits exactly as returned.

## Repository search

Use Lumen semantic search first when the location or symbol is unknown and the
question is conceptual. Restrict every Lumen search to the active repository;
never search `/home/jacocanete` as a project root.

Examples:
- “Where is authentication handled?” → Lumen
- “What validates checkout totals?” → Lumen
- “Find the retry and backoff logic.” → Lumen
- “Where is `validateToken` defined?” → Grep
- “Find every use of `LUMEN_BACKEND`.” → Grep
- Known file or confirmed result → read that file directly

Use built-in Grep for exact symbols, strings, regexes and file filters; verify relevant Lumen results with Grep and current file contents before drawing conclusions. Use `glob` only for filename discovery. Use shell `rg` only for match counts or options unsupported by Grep, when shell permissions allow.

## Hindsight memory
- Build, Plan, and Orchestrator own explicit Hindsight retrieval, approved initiative capture, and verified corrections. Specialists use the relevant knowledge supplied in their brief and return missing-context questions to the parent.
- Before substantial repository work, consult relevant knowledge pages and existing initiatives. Use reflection for historical rationale when pages are insufficient; avoid elaborate retrieval for trivial requests.
- Current instructions define the goal, AGENTS.md and skills define working rules, and current code/runtime evidence establishes what exists. Treat memory as historical context, not unquestionable truth.
- Capture initiatives after approval, update materially changed scope, and correct verified stale knowledge. Do not record tentative proposals or unverified worker findings as established decisions.
- Let automatic ingestion retain ordinary conversations. The installed Hindsight plugin also processes child sessions; denying specialist tools does not disable automatic injection or capture.
- Specialists must not bypass denied Hindsight tools through shell commands or APIs, and should clearly label hypotheses and unverified findings in their reports.

## Skills
- Before answering or using other tools, load every available skill whose description matches the user's intent
- Match skills by the requested outcome, not only by literal technology names; treat description examples as non-exhaustive
- If a task spans multiple skills, load each relevant skill and follow the most specialized guidance for each part

## Code
- Keep it simple; no over-engineering or speculative abstraction
- Match existing patterns in the file or module before introducing new ones
- Prefer editing existing files over creating new ones
- Use small, focused functions and early returns over nested conditionals
- Avoid unnecessary comments and docstrings

## Safety and verification
- Ask before committing to Git
- Do not add dependencies without asking
- After a task, run typecheck, tests, and lint before reporting completion

## Development VM networking
- Use `10.121.16.20` as the stable SSH and browser address for `home-dev`; ZTNet provides the same address at home and away
- OpenCode Web runs as a systemd user service at `http://10.121.16.20:4096` and relies on ZTNet and UFW rather than HTTP Basic Auth
- The phone at `10.121.16.132` can reach only OpenCode Web on TCP port 4096; do not broaden that rule for ordinary development servers
- Bind browser-facing development servers to `0.0.0.0` or `10.121.16.20`, not only to `localhost`
- Report browser URLs as `http://10.121.16.20:<port>` unless a project defines a hostname
- Make browser-side frontend requests relative, such as `/api`, or proxy them through the frontend dev server; browser-side `localhost` refers to the client machine, not the VM
- Keep backend services on VM-local addresses when only the frontend proxy needs them
- Check for an available port with `ss -lnt` before starting a service
- WordPress Studio sites listen on localhost by default; use a Studio custom domain and map it to `10.121.16.20` on approved clients before claiming that a site is remotely reachable
- Use `studio start --skip-browser` in the headless VM
- Do not change ZeroTier, UFW, SSH routing, or public exposure without asking first

## Git identities
- Put personal repositories under `~/Projects/jacocanete/` and use `jc:<repository>` remotes
- Put work repositories under `~/Projects/digitalimpulse/` and use `dd:<repository>` for DemandDrive or `di:<repository>` for Digital Impulse
- Git commit identity is selected by repository path, while SSH authentication is selected by the remote alias
- Before committing, verify `git config user.email` and `git config user.signingkey` match the repository identity
- Do not copy, replace, print, or commit machine-local private SSH keys
