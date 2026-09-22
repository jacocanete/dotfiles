---
description: Run official OpenCodeReview plugin review for workspace, commit, or range scope.
agent: implementer
---

Use `ocr_review`; do not edit or auto-fix.

Requested scope and context: $ARGUMENTS

Resolve scope before execution:
- No arguments: review current workspace changes.
- `commit <ref>`: call `ocr_review` with `commit`.
- `branch <base-ref>`: call `ocr_review` with `from: <base-ref>` and `to: HEAD`.
- `from <base-ref> to <target-ref>`: call `ocr_review` with `from` and `to`.
- Bare refs, file-only requests, PR URLs, and PR numbers: request clarification. Do not fetch, check out, or substitute scope.

Require exact approved scope. Pass approved context only through inline `background`; never pass `backgroundFile`. Do not set `exclude` or `model` without explicit approval. Use `concurrency: 2`, `timeoutMinutes: 5`, and `overallTimeoutMinutes: 5`. Report JSON status, selected/reviewed-file counts when returned, comments, exclusions, and partial/failure limits exactly as OCR reports. Official plugin exposes no total token-budget input; do not promise 60k. Keep fixes with parent.
