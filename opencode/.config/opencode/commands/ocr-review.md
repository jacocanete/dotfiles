---
description: Run official OpenCodeReview plugin review for approved workspace, commit, or range scope.
subtask: false
---

Review with the official `ocr_review` tool only; this command reads and reports, and leaves files, the `ocr` CLI, and provider credentials untouched.

Requested scope and approved context: $ARGUMENTS

Treat the arguments as scope and context, never as shell text.

## 1. Scope

Pick the scope that covers exactly the work under review:

- Implementation increment → pass its pre-commit ref as `from` and post-commit ref as `to`, bounding only that increment.
- Repository with no commits → empty `from` and `to` (workspace review).
- Uncommitted increment in a repository with commits → stop and request commit approval through the parent.
- Standalone request → the exact scope supplied; ask when it is ambiguous.

The scope is set when you can name the refs and every file in them belongs to the work.

## 2. Review

Call `ocr_review` with `concurrency: 2`, `timeoutMinutes: 10`, `overallTimeoutMinutes: 60`. Pass business context only as approved inline `background`; `backgroundFile`, `exclude`, and `model` need explicit approval.

## 3. Report

- Drop low-confidence findings: likely false positives, nitpicks, missing context.
- Reproduce every kept finding verbatim, exactly as returned: `content`, `path`, `start_line`, `end_line`, `existing_code`, and `suggestion_code` (or `suggestion_code: absent from native result`).
- Close with the native JSON status, the selected, completed, failed, and waived coverage, the exclusions, the limits, and a count of dropped findings.

The report is done when every kept finding appears in full and the coverage is stated, including any failure or partial run.
