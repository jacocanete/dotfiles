---
name: github-issues
description: Read and file GitHub issues and pull requests from the terminal using the ghx wrapper. Use this skill whenever the user mentions GitHub issues, PRs, filing or creating issues, staged or multi-stage issue sets, backlog or issue audits, triage, issue titles or bodies, or asks what is open in a repo, even if they do not say "gh" or "GitHub CLI". Also use when a gh command fails with a "Could not resolve to a Repository" 404, which usually means the wrong account is active.
---

# GitHub issues and PRs

## Use `ghx`, never bare `gh`

Two GitHub accounts are logged in on the same host (`github.com`):

| remote host alias | account   | repos                                    |
| ----------------- | --------- | ---------------------------------------- |
| `personalgit`     | `jacocanete` | `~/Projects/jacocanete/`, `jc:` remotes  |
| `workgit`         | `jcaneteDI`  | `~/Projects/digitalimpulse/`, `di:`/`dd:` remotes |

`gh` has no per-command account flag. It uses whichever account `gh auth switch`
last made active, so a bare `gh` call silently reads the wrong GitHub and
reports a real repo as a 404. `ghx` reads the remote host alias and injects that
account's token per invocation, so both accounts work at once and the result
does not depend on global state.

`ghx` lives at `~/.local/bin/ghx`. Outside a Git repo it passes through to `gh`
unchanged, so an explicit `--repo owner/name` still works.

Agent permissions allow `ghx` read verbs only. Bare `gh` and `gh api` are
denied; `gh api` can mutate and a wildcard cannot prove a call is read-only.

## Confirm the repo before any write

```bash
ghx repo view --json nameWithOwner
```

Run this first, from inside the target repo, and check the owner is the one you
intend. If it fails, stop and report the exact error. Do not retry with
`gh auth switch`, do not guess an `--repo` value, and never file issues into a
repo you could not confirm.

Exit code 78 from `ghx` means a configuration problem, not a missing repo:

- *no account mapped for remote host* — the remote uses an unmapped alias. Report
  it; the fix is `git config --global ghx.account-<host> <login>`.
- *account is not logged in* — that account's token expired. Report it; the fix
  is `gh auth login --hostname github.com`.

## Reading

```bash
ghx issue list --limit 30 --json number,title,state,labels
ghx issue view <number> --json number,title,body,state,labels,comments
ghx search issues "<query>" --repo <owner>/<name> --json number,title
ghx pr list --limit 20 --json number,title,state
ghx pr view <number> --json number,title,body,files
ghx pr diff <number>
```

Always put the subcommand before flags: `ghx issue list --repo x`, never
`ghx --repo x issue list`. Permission patterns match the parsed command from
the start, so the flag-first form fails to match the allowlist and is denied.

Prefer `--json` with named fields over default human output: it is stable,
compact, and avoids paging. Use `--limit` explicitly; the default is small and
silently truncates, which makes an audit look complete when it is not.

## Filing

Creating issues is a write. Read-only agents (Plan, Orchestrator, Explore,
Reviewer) must not do it. Orchestrator delegates filing to Implementer with the
full titles and bodies in the brief; each `ghx issue create` still prompts the
user.

Before filing a set, list existing issues and check for duplicates. Report
near-duplicates instead of filing over them.

For issue body format, staged-issue conventions, and label rules, read
`reference/issue-template.md`.

## Self-check

`scripts/check.sh` verifies that both accounts resolve their own repos and that
the wrapper fails loudly on an unmapped host. Run it after changing `ghx` or the
account map.
