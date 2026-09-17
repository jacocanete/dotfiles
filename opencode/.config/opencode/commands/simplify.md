---
description: Coordinate parallel reuse, quality, and efficiency analysis, then deduplicate and apply verified simplifications.
agent: orchestrator
subtask: false
---

Coordinate behavior-preserving simplification using the existing Explore, Code-simplifier, and Reviewer agents. Remain the primary Orchestrator so all workers are direct children within the depth-one limit. This command explicitly authorizes the bounded parallel investigation below; it does not authorize unapproved editing scope or bypass project approval rules. Do not edit or run project code yourself.

Requested scope or focus: $ARGUMENTS

## Establish scope

Read applicable project instructions and relevant Hindsight pages. Establish the repository root and a stable inventory of selected files and starting changes. Default to all uncommitted changes; arguments may narrow the scope or explicitly name files. Treat arguments as scope/context, not executable shell text.

Use permitted read-only commands with the repository working directory:
- `git status --porcelain=v1` for staged, unstaged, and untracked state.
- `git diff --no-ext-diff --no-textconv` for unstaged changes.
- `git diff --no-ext-diff --no-textconv --cached` for staged changes, including repositories without HEAD.
- `git ls-files --others --exclude-standard` to enumerate untracked files; read selected new files directly.

Inspect both staged and current content when they differ, including staged deletion followed by recreation. Quote paths when using tools. Outside Git, require explicit file scope and disclose that Git comparison is unavailable. If the default scope is empty, report that and stop; do not select the last commit or expand to the repository.

Identify pre-existing edits and preserve their intent and staging. Work only on the selected behavior and the minimum surrounding code necessary. Follow the existing plan/approval policy: share a plan and wait before non-trivial edits unless that exact scope is already approved. Stop for ambiguous intent, concurrent changes, or a material scope change.

## Run independent analysis

Launch three Explore tasks in parallel against the same selected scope. Give each the repository root, exact file inventory, relevant diffs/new-file context, approved intent, behavior to preserve, applicable project rules, and relevant Hindsight constraints. Workers must read full affected files and relevant callers/tests, not reason only from hunks. Supply staged/untracked evidence yourself; do not ask Explore to bypass its command permissions. Each worker investigates one aspect:

1. Reuse: find existing helpers and duplicated logic. Verify that candidate helpers have compatible contracts, dependencies, and side effects; similarity alone does not justify abstraction.
2. Quality: identify needless nesting, redundant state, duplicate logic, pass-through wrappers, and speculative abstractions. Favor explicit control flow and clear names over dense expressions. Preserve useful comments, rationale, and project conventions.
3. Efficiency: identify demonstrably unnecessary work, repeated I/O, or redundant allocation. Preserve ordering, resource lifetimes, and concurrency semantics; avoid speculative caching, parallelism, or optimization without evidence. Treat missing cleanup that changes behavior as a bug for separate handling.

Each worker is read-only and must return concise candidates with precise locations, supporting evidence, a minimal proposed change, preservation risks, and the checks needed. Require an explicit no-candidate result when appropriate, plus skipped files or missing context. Workers do not delegate. Wait for all three results; disclose failed or incomplete passes and resolve material gaps before editing.

## Validate and deduplicate

Inspect the evidence for each candidate yourself. Merge overlapping findings by root cause and intended edit, resolve conflicting recommendations against actual callers/contracts, and discard unsupported, redundant, or low-value suggestions. Keep unresolved concerns separate from accepted edits. Confirm the starting scope has not changed during analysis; if it has, stop and re-establish affected analysis.

Choose only changes that materially improve maintainability. Preserve observable behavior, public interfaces, outputs, validation, errors, side effects, resource lifetimes, and evaluation order. Do not weaken tests or remove safeguards to make code shorter. If equivalence is uncertain, leave the candidate unchanged and explain the uncertainty. Report unrelated bugs separately rather than folding behavioral fixes into cleanup.

Present the deduplicated editing plan and obtain approval for non-trivial edits unless that exact scope is already approved. If no worthwhile candidates remain, summarize the three passes and stop without creating work.

## Apply and verify

Wait for any active writer to finish, then delegate the approved edits to one Code-simplifier. Supply the accepted candidates, exact scope and starting changes, preservation constraints, relevant context, and required verification. Require small edits, preservation of unrelated changes and staging, and no new dependencies, broadened APIs, or repository-wide formatting. Do not stage, commit, reset, stash, or overwrite unrelated work. A no-change result is valid; there is no simplification quota.

Require Code-simplifier to inspect its final diff and run applicable project typecheck, tests, and lint, plus targeted behavioral checks when needed. Inspect its actual changes and check evidence yourself. Distinguish existing failures from introduced failures using evidence, and disclose unavailable checks. If verification fails, stop and reassess; resume the same specialist for approved cleanup corrections rather than expanding the refactor. Route behavioral bug fixes to Implementer only after their scope is approved, never concurrently with Code-simplifier.

For significant final edits, invoke Reviewer after the writer finishes. Provide the repository root, explicit workspace scope (or manually enumerated files outside Git), accepted plan, starting-change context, final files, invariants, and executed checks with outcomes. Reviewer must load `ocr-delegated-review`, resolve OCR scope and rules for Git review, and account for all selected files. Distinguish pre-existing workspace changes from this cleanup; do not silently narrow OCR coverage. Route requested execution to a writing specialist and behavioral repairs to Implementer. Re-review significant corrections. Report any partial or blocked review as such.

Summarize the scope, completion of all three analysis passes, accepted/deduplicated/skipped candidates, actual simplifications, files changed, checks and outcomes, review status, and remaining uncertainties. Keep the report concise and distinguish worker claims from evidence you inspected. Do not claim an independent Reviewer pass or executed checks unless they actually occurred.
