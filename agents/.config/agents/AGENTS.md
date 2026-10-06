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

<!-- gitbutler-agent-setup:start -->
## Version control

- Use GitButler (`but`) for version-control inspection and write operations, including status, diffs, branching, committing, pushing, and history edits.
- Assume multiple agents may be working in this repository. Do not move, amend, squash, discard, commit, push, or otherwise modify another agent's work unless the user asks.
- For commit just/only/specific changes on a new branch (selected-change requests), use the two-command fast path from the GitButler skill: `but diff`, then `but commit -b <branch> -m "message" <id> <id>`.
- For that fast path, after the commit succeeds, stop and summarize; do not run separate branch, staging, status, or diff commands unless the commit output is missing information you need.
- Use the installed GitButler skill for command recipes and syntax before guessing flags, using `--help`, or translating Git habits directly.
- Mutation commands report their result without appending workspace status. Add `--status-after` only when the next step needs resulting workspace IDs or details; otherwise do not rerun status or diff to verify success.
- Use a dedicated GitButler branch for each agent session, unless the user asks for a different branch structure. Commit only changes that belong to that session.
- Do not push or open pull requests unless the user asks.
- Keep commit messages and pull request descriptions succinct: explain what changed, why it changed, and any important decision.

### Amend local fixes into the right commits

- For small cleanup or follow-up fixes, amend an unpublished local commit when the change clearly belongs with that commit's intent.
- Do not create tiny fixup commits unless the user asks.
- Use GitButler to move the relevant changes into the commit where they belong.
- Ask before rewriting pushed, reviewed, shared, or ambiguous history.

### Split unrelated changes into separate commits

- If one file contains unrelated changes, split them by hunk instead of committing the whole file.
- Keep tests with the behavior they verify.
- Split generated output, docs-only edits, or mechanical cleanup into separate commits when each commit remains coherent on its own.
- If the split is ambiguous, summarize the options before committing.
### Create a recovery point before large history edits

- Before squashing, splitting, moving commits between branches, or reorganizing multiple branches, run `but oplog snapshot -m "<reason>"`.
- Use GitButler history-edit commands such as `but move`, `but squash`, `but reword`, `but absorb`, and `but amend` instead of raw Git rebases.
- If an operation makes the branch or history layout worse, stop and inspect the operation log before attempting another fix.
- Prefer `but undo` or `but oplog restore` over trying to repair a bad state with more history edits.

### Create stacked pull requests

- If this session depends on another in-flight branch, stack its branch on top of that dependency instead of mixing the changes.
- If this session is working in a stack, put commits on the branch where they belong.
- Ask before moving commits onto lower, pushed, reviewed, or shared branches.
- Use `but move` for branch stacking and restacking. Do not recreate branches to simulate stacking.
- For stacked branches, create pull requests with `but pr`, not `gh`, so GitButler keeps the right PR base branches and stack metadata.
<!-- gitbutler-agent-setup:end -->

## home-dev
- This VM is `home-dev`, reached at `10.121.16.20` over ZTNet. Bind browser-facing dev servers to `0.0.0.0` or `10.121.16.20` and report URLs as `http://10.121.16.20:<port>`.
- Anything about remote reachability, ports, DNS, TLS, or firewall goes through the `home-dev-networking` skill; ask before changing ZeroTier, UFW, SSH routing, or public exposure.

## Git identities
- Personal repositories live under `~/Projects/jacocanete/` with `jc:<repository>` remotes; work repositories under `~/Projects/digitalimpulse/` with `dd:<repository>` (DemandDrive) or `di:<repository>` (Digital Impulse) remotes.
- Commit identity follows the repository path; SSH authentication follows the remote alias. Before committing, confirm `git config user.email` and `git config user.signingkey` match the repository.
- Machine-local private SSH keys stay where they are: never copied, printed, or committed.
