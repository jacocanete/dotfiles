# Issue body templates

Read this file only when filing or auditing issue bodies.

## Staged work issue

Used when one approved plan is split into sequential stages. Each stage is a
separate issue so it can be closed independently.

```markdown
## Goal

One sentence describing the observable outcome of this stage.

## Scope

- Files or modules this stage may touch
- Explicitly out of scope: ...

## Acceptance criteria

- [ ] Behavioral criterion, not an implementation step
- [ ] ...

## Verification

Exact commands a reviewer can run, e.g. `npm run typecheck`, `npm test -- foo`.

## Depends on

#<issue-number> (omit this section for the first stage)
```

Rules for staged sets:

- Title format: `Stage <n>/<total>: <imperative summary>`.
- File in dependency order so earlier issue numbers can be referenced by later ones.
- Put the dependency link in the body, not only in the title.
- Do not invent labels or milestones. Check what already exists first:
  `ghx label list --limit 100` and `ghx issue list --limit 30 --json labels`.
  If no suitable label exists, file without one and say so.

## Writing bodies safely

Pass bodies via a file, never a long inline `--body` string:

```bash
ghx issue create --repo <owner>/<name> --title "..." --body-file /tmp/opencode/issue-1.md
```

This avoids shell quoting and newline mangling, and leaves the exact text on
disk for review before the issue is created.
