## Working style
- Plan before non-trivial work; share the plan and wait for go-ahead
- Work in small, reviewable increments, not the whole task in one shot
- When something goes sideways, stop and re-plan; do not keep pushing
- Stay scoped: only change what the task needs; flag unrelated issues instead of fixing them inline
- If a requirement is ambiguous, ask rather than assume

## Code
- Keep it simple; no over-engineering or speculative abstraction
- Match existing patterns in the file or module before introducing new ones
- Prefer editing existing files over creating new ones
- Use small, focused functions and early returns over nested conditionals
- Avoid unnecessary comments and docstrings

## Safety and verification
- Ask before committing to Git
- Do not add dependencies without asking
- After a task, run typecheck, tests, and lint before reporting completion

## Development VM networking
- Use `10.121.16.20` as the stable SSH and browser address for `home-dev`; ZTNet provides the same address at home and away
- Bind browser-facing development servers to `0.0.0.0` or `10.121.16.20`, not only to `localhost`
- Report browser URLs as `http://10.121.16.20:<port>` unless a project defines a hostname
- Make browser-side frontend requests relative, such as `/api`, or proxy them through the frontend dev server; browser-side `localhost` refers to the client machine, not the VM
- Keep backend services on VM-local addresses when only the frontend proxy needs them
- Check for an available port with `ss -lnt` before starting a service
- WordPress Studio sites listen on localhost by default; use a Studio custom domain and map it to `10.121.16.20` on approved clients before claiming that a site is remotely reachable
- Use `studio start --skip-browser` in the headless VM
- Do not change ZeroTier, UFW, SSH routing, or public exposure without asking first

## Git identities
- Put personal repositories under `~/Projects/jacocanete/` and use `jc:<repository>` remotes
- Put work repositories under `~/Projects/digitalimpulse/` and use `dd:<repository>` for DemandDrive or `di:<repository>` for Digital Impulse
- Git commit identity is selected by repository path, while SSH authentication is selected by the remote alias
- Before committing, verify `git config user.email` and `git config user.signingkey` match the repository identity
- Do not copy, replace, print, or commit machine-local private SSH keys
