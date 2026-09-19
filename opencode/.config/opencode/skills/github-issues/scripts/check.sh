#!/usr/bin/env bash
# Self-check for the ghx wrapper and its account map. Read-only: no issues are
# created. Exits non-zero on the first failure.
set -uo pipefail

ghx=$(dirname "$0")/ghx
fail=0

check() {
  local label=$1 expected=$2 dir=$3
  local got
  if [ ! -d "$dir" ]; then
    echo "SKIP $label (no $dir)"
    return
  fi
  got=$(cd "$dir" && "$ghx" repo view --json nameWithOwner --jq .nameWithOwner 2>&1)
  if [ "$got" = "$expected" ]; then
    echo "ok   $label -> $got"
  else
    echo "FAIL $label: expected $expected, got: $got"
    fail=1
  fi
}

# Both accounts must resolve at the same time, regardless of which one
# `gh auth switch` last made active. This is the property bare gh lacks.
check work     demanddrive/wp-theme-charter "$HOME/Projects/digitalimpulse/wp-theme-charter"
check personal jacocanete/loadout           "$HOME/Projects/jacocanete/loadout"

# An unmapped remote host must fail loudly rather than falling back to whichever
# account happens to be active.
tmp=$(mktemp -d)
git -C "$tmp" init -q
git -C "$tmp" remote add origin git@unmapped-host:someone/repo
out=$(cd "$tmp" && "$ghx" repo view 2>&1)
code=$?
rm -rf "$tmp"
if [ "$code" -eq 78 ] && printf '%s' "$out" | grep -q "no account mapped"; then
  echo "ok   unmapped host rejected (exit 78)"
else
  echo "FAIL unmapped host: exit $code, output: $out"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "all checks passed"
exit "$fail"
