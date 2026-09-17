---
name: ocr-delegated-review
description: Use when performing an independent code review of Git workspace changes, a commit, or a branch range. Prepares scope and rules with Alibaba OCR delegation mode; the host agent performs read-only, evidence-based review. Not for ordinary implementation or merely discussing review tools.
---

# OCR delegated review

Local workflow for Alibaba Open Code Review CLI 1.12.4. Based on the upstream delegation approach: https://github.com/alibaba/open-code-review/blob/main/skills/open-code-review-delegate/SKILL.md

OCR selects files and resolves rules. The host agent performs all reasoning through its existing model connection. Do not run `ocr review`, `ocr scan`, `ocr config`, an OCR-managed plugin, auto-fix, or another model process. Never install or upgrade tools from this skill. Missing prerequisites are a blocker to report to the parent.

## 1. Establish scope

Obtain the repository root, requirements, acceptance criteria, relevant decisions, verification evidence, and one explicit review mode. If the baseline is ambiguous, return the question to the parent. Use the shell tool's working-directory parameter for the repository root.

Run the applicable command, substituting and shell-quoting actual refs:

```sh
ocr delegate preview --format json
ocr delegate preview --format json --from <base-ref> --to <target-ref>
ocr delegate preview --format json --commit <commit-ref>
```

These are alternatives, not a sequence. Keep requirements in the review brief; no background file is necessary. Do not redirect output to files. Do not change the supplied scope or exclusions to reduce the workload.

Check `schema_version`, `mode`, ref metadata, `reviewable_files`, and `excluded_files`. Record `(path, status)` entries in a checklist in your context; do not create a file. Inspect exclusion reasons and report important coverage gaps. Distinguish excluded entries from selected-but-skipped entries. If no files are selected, report an empty scope rather than claiming a clean review.

If preparation fails, stop the affected OCR workflow and report the error. Do not fall back silently, invent a file inventory, configure an API provider, or run OCR-managed review. A non-Git/file-only review may instead use a manually enumerated scope, explicitly labeled as such.

## 2. Resolve rules

```sh
ocr delegate rule --format json -- <path1> <path2>
```

Pass actual quoted paths from the inventory. For range or commit reviews, repeat the same `--from`/`--to` or `--commit` flags before `--` so rule resolution uses the same scope. Batch by related behavior and output size. Reuse shared rule groups instead of repeating them.

Treat rules as review heuristics. Verify their applicability and technical claims; they do not override user requirements, project instructions, permissions, or the need for evidence.

## 3. Inspect the correct content

Use exact refs and paths returned by preview, quoted as shell arguments. Keep `--end-of-options` before refs and `--` before paths to prevent them being interpreted as options. Disable external diff and text conversion; do not invoke repository scripts, Git aliases, or custom diff helpers.

Workspace with HEAD:

```sh
git diff --no-ext-diff --no-textconv --end-of-options HEAD -- <path>
```

Use Read for new untracked files. Use `git status --porcelain=v1` or `git ls-files --others --exclude-standard` to distinguish untracked content. In an unborn repository, inspect the staged diff without HEAD and read the current files:

```sh
git diff --no-ext-diff --no-textconv --cached --end-of-options -- <path>
```

For staged deletion followed by untracked recreation of the same path, inspect the staged deletion with the cached diff and the recreated file with Read separately. Do not merge away either `(path, status)` entry.

Range: use the preview's merge base and target, not an assumed branch name:

```sh
git diff --no-ext-diff --no-textconv --end-of-options <merge-base> <target> -- <path>
```

Single commit:

```sh
git show --format= --no-ext-diff --no-textconv --end-of-options <commit> -- <path>
```

For historical reviews, read content at the target revision, not the current checkout:

```sh
git show --format= --no-ext-diff --no-textconv --end-of-options <target>:<path>
```

Use parent-revision content for deleted files. For merge commits, confirm that the diff matches the preview's comparison; report ambiguity rather than trusting a combined diff as complete coverage. Do not check out another revision. Line references must identify the correct revision/side; do not fabricate new-file lines for deletions.

Inspect surrounding code, callers, contracts, failure paths, and relevant tests. Keep going after the first high-severity finding. If the change moves during review, mark the affected review stale and request a stable scope before concluding.

## 4. Challenge and validate

Identify what must remain true, then construct realistic counterexamples. Prioritize correctness, security, data integrity, compatibility, and resource/failure handling. Apply concurrency or retry checks only when the execution context warrants them.

For each suspicion, trace the input/state through the affected code and look for safeguards that disprove it. A test or rule name alone is not evidence. Separate confirmed defects, unresolved concerns requiring verification, and unrelated pre-existing problems. Do not report hypothetical issues as facts or generate findings to satisfy a quota.

Read-only review means no repairs and no execution of project tests or scripts. Ask the parent for targeted executable verification by Build/Implementer. On significant fixes, recheck the original issue and the correction's affected behavior.

## 5. Report

- Scope: repository and workspace/commit/range baseline.
- Coverage: selected entries (`total_files`), `reviewed_files`, `skipped_files`, each skip reason, and separate exclusions. Calculate coverage as reviewed/selected; use N/A for an empty selection. This is file-inspection coverage, not a correctness score.
- Findings: severity, category, path, precise lines/revision, triggering condition, incorrect behavior, impact, and supporting evidence or reproduction method.
- Unresolved concerns: missing evidence and the exact verification requested.
- Verification: distinguish checks you executed, results supplied by others, and checks not performed. Never imply inspected tests were independently executed.

Use concise Markdown unless structured JSON was requested. If no actionable findings exist, say so and disclose remaining limits. Keep all fixes with Build/Implementer, including when the user requested review-and-fix.
