---
name: ocr-simplify
description: Simplification review of changed code through OpenCodeReview, then apply the confirmed cleanups. Use for a simplify pass, cleanup review, over-engineering review, or "what can we delete" on an increment, commit, or range.
---

# OCR simplify

OCR runs the review with `simplify-rule.json` from this skill's folder, which replaces OCR's bug-hunting rules with cleanup tags (`reuse`, `stdlib`, `native`, `yagni`, `delete`, `shrink`, `perf`, `altitude`). You triage the findings, apply the confirmed ones, and verify. Correctness bugs stay with the normal OCR review.

## 1. Run the review

Choose the scope and background with the OCR rules in `AGENTS.md`, then run:

```bash
ocr review --audience agent --format json \
  --rule ~/.claude/skills/ocr-simplify/simplify-rule.json [scope args]
```

Allow a 10-minute timeout. Markdown is skipped as `unsupported_ext`, so a docs-only diff has nothing to review: report that and stop.

**Done when:** the JSON has `status` and `comments`, and you have noted `summary.files_reviewed`.

## 2. Triage

For every comment, read the cited lines and their callers, then keep it only if all of these hold:

- The replacement preserves what existing callers observe: outputs, errors, validation, and evaluation order.
- The fix stays inside the reviewed diff or its immediate neighbours.
- A `reuse:` finding names a helper whose contract actually fits (input types, edge cases, side effects).
- It does not delete a smoke test or `assert` self-check.

Merge comments that point at the same line or mechanism. Record each dropped comment with a one-line reason.

**Done when:** every comment is kept, merged, or dropped with a reason.

## 3. Apply and verify

Apply each kept finding, matching the surrounding code. Then run the typecheck, test, and lint commands the project defines. A fix that breaks a check is reverted and reported as skipped.

**Done when:** every kept finding is applied or reverted, and the checks pass.

## 4. Repeat

OCR recall varies run to run, so one review misses findings another catches. Rerun step 1 with the same command and scope, then triage and apply again. A finding is new only when it points at code the current files still contain and was not dropped in an earlier round; with a commit or range scope, OCR sees the original code, so already-fixed findings come back and are skipped.

**Done when:** a round keeps no new findings, or three rounds have run.

## 5. Report

Report the kept findings in the OCR format from `AGENTS.md`, each with its verdict and round. Close with the scope, `files_reviewed`, the rounds run and why they stopped, the dropped count, and `net: -N lines` from `git diff --stat` over your fixes. With nothing kept, say the code is already lean.
