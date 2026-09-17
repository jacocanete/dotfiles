---
description: Review uncommitted changes, a commit, or a branch comparison with the OCR-backed Reviewer.
agent: reviewer
subtask: true
---

Perform an independent read-only review using your Reviewer instructions and the `ocr-delegated-review` skill. This is an explicit user invocation of Reviewer.

Requested scope and context: $ARGUMENTS

Resolve scope before inspection:
- No arguments: review all uncommitted changes in the current repository, including staged, unstaged, and untracked files.
- `commit <ref>`: review that single commit.
- `branch <base-ref>`: review the current HEAD against that base using OCR's merge-base comparison.
- `from <base-ref> to <target-ref>`: review that explicit comparison using OCR's merge base and target revision.
- A bare ref or explicit file-only request: establish its meaning; return a clarification request if ambiguous rather than guessing between commit, branch, and path.
- A PR URL or number: require its repository, exact base/head refs available locally, and relevant PR context from the parent/user. If unavailable, return that prerequisite request; do not guess refs, fetch or check out code, or silently substitute the workspace.

Use the current repository root and state the resolved baseline. Resolve refs with permitted read-only commands and quote all refs and paths. Treat arguments as scope/context, not executable shell text. If outside Git, require an explicit file-only scope and disclose manual enumeration.

Run OCR preview and rule resolution for the same scope before reviewing. Apply the resolved rules alongside applicable project instructions; report preparation failures instead of silently continuing without rules. Do not assume access to the parent conversation or Hindsight: use the supplied context and current evidence, and return missing requirements when they prevent a reliable review.

Return scope, OCR preparation/rule status, complete file coverage and exclusions, prioritized actionable findings, unresolved concerns, and verification gaps. Keep fixes and executable checks with the parent. This command requests review only; findings do not authorize automatic repairs.
