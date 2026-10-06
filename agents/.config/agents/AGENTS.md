## Working style
- Plan non-trivial work first; share the plan and wait for go-ahead.
- Deliver in small, reviewable increments.
- When something goes sideways, stop and re-plan. After a failed tool call, read the error and retry only with a concrete change; otherwise report the blocker.
- Change only what the task needs; flag unrelated issues in your report.
- Ask when a requirement is ambiguous.
- When a step needs the user's hands (a command you cannot run, a dashboard, a key), hand it over as a `wizard` script, not a list of commands.

## Tools earn their call
The tools below are defaults, not rituals. Use one when it answers faster or better than the alternative; when you skip a default, say so in one line with the reason.

### Code review: OpenCodeReview
- OCR is the reviewer: `ocr_review` in OpenCode, the `open-code-review:review` skill in Claude Code. Use it in place of built-in review commands.
- Review each finished increment before reporting it done or committing it. Skip trivial diffs (docs-only, config values, renames, a few mechanical lines) and report `review skipped: trivial`.
- Scope every review to exactly the work under review, and state the scope in the report:
  - Uncommitted work, and the workspace holds nothing else → workspace mode (no scope arguments).
  - One commit → `--commit <sha>` (reviewed against its parent).
  - A run of commits, such as a feature or a re-review after fixes → `--from <commit before the work began> --to <head>`. Use the branch base only when reviewing the whole branch.
  - Workspace mixed with unrelated changes, or the right base unclear → ask before reviewing.
  - Before a large review, confirm the file list with `--preview`.
- Pass the approved goal as `--background` when the review should check the change against its requirements.
- Treat findings as candidates: drop low-confidence ones (likely false positives, nitpicks, missing context), check the rest against the code, and fix the confirmed ones. Re-review only after significant fixes, scoped to the fix commits.
- Large increment or finished feature, in Claude Code: once review fixes are committed, run the `ocr-simplify` skill over the work plus its fix commits, commit, then review only the simplify commits unless they are trivial. Simplify comes after review because bug fixes change behaviour and would undo earlier cleanups, while simplify must keep behaviour.
- Report every kept finding verbatim, exactly as OCR returned it: `content`, `path`, `start_line`, `end_line`, `existing_code`, and `suggestion_code` when present. Follow each with your verdict (fixed, or dismissed with a one-line reason). Close with the scope, coverage, and a count of dropped findings.

### Memory: Hindsight
- Hindsight injects relevant memory into each prompt and records sessions automatically; retrieval beyond that is on demand.
- Read a knowledge page before substantial work in an area you have not touched this session; reflect only when you need the *why* behind existing behaviour. Skip explicit retrieval for small, self-contained tasks.
- Memory is history: current instructions set the goal, and current code and runtime evidence decide what exists.
- Capture an initiative only after the user approves a new capability, and file a correction only for memory you verified is stale.

### Docs and web: Firecrawl
- Firecrawl is the first choice for anything outside the repository; the built-in web tools and Context7 are fallbacks for when it errors, runs out of credits, or has nothing useful.
- Library, API, and error questions → `firecrawl-developer-index` (primary-source passages from docs, READMEs, issues, and merged PRs). Context7 fills in when the answer needs one library version's reference.
- Web research → `firecrawl-search`; a known page → `firecrawl-scrape`; a site's structure or a local copy → `firecrawl-map` or `firecrawl-download`.

## Code
- Match the patterns already in the file or module.
- Use small, focused functions with early returns.
- Names and structure carry the *what*. Comments carry only the *why*: the constraint, decision, or gotcha behind the code.

## Safety and verification
- Ask before committing to Git or adding a dependency.
- Before reporting completion, run the typecheck, test, and lint commands the project defines.

## Commits
- Commits are authored by the user alone: no `Co-Authored-By` trailer or other agent attribution, even when a tool suggests one.
- The subject line carries the change. Add a body only when it earns its place: two or three lines on *why* (the constraint, decision, or gotcha), never a recap of the diff.

## home-dev
- This VM is `home-dev`, reached at `10.121.16.20` over ZTNet. Bind browser-facing dev servers to `0.0.0.0` or `10.121.16.20` and report URLs as `http://10.121.16.20:<port>`.
- Anything about remote reachability, ports, DNS, TLS, or firewall goes through the `home-dev-networking` skill; ask before changing ZeroTier, UFW, SSH routing, or public exposure.

## Git identities
- Personal repositories live under `~/Projects/jacocanete/` with `jc:<repository>` remotes; work repositories under `~/Projects/digitalimpulse/` with `dd:<repository>` (DemandDrive) or `di:<repository>` (Digital Impulse) remotes.
- Commit identity follows the repository path; SSH authentication follows the remote alias. Before committing, confirm `git config user.email` and `git config user.signingkey` match the repository.
- Machine-local private SSH keys stay where they are: never copied, printed, or committed.
