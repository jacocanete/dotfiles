---
name: code-simplify
description: Use when the user requests behavior-preserving code simplification, cleanup, deduplication, or a maintainability pass on specific files or current changes.
---

# Code simplification

Work in Build on the requested scope. If the scope is not explicit, default to the current uncommitted changes; inspect staged, unstaged, and untracked files before planning. If there are no changes, ask for a file scope rather than expanding to the repository.

Read the full affected files and relevant callers and tests. Look for needless nesting, duplicate logic, redundant state, and wrappers that obscure behavior. Reuse existing helpers only when their contracts and side effects fit. Keep public interfaces, outputs, validation, errors, evaluation order, resource lifetimes, and concurrency behavior intact. Prefer clear code over fewer lines; do not introduce speculative abstractions or optimizations.

Share a scoped plan and wait for approval before non-trivial edits. Apply small changes directly in Build, preserving unrelated changes and staging. If behavior preservation is uncertain, leave that candidate unchanged and explain why. Report unrelated bugs separately.

Inspect the resulting diff and run relevant typecheck, tests, and lint. Report the files changed, the simplifications made, the checks and outcomes, and any skipped candidates or unresolved risks. A no-change result is valid.
