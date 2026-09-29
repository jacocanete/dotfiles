@~/.config/agents/AGENTS.md

## Headroom
- Call `headroom_retrieve` in a turn of its own, never in parallel with other tools. The Headroom proxy resolves it server-side only when it is the sole tool call; mixed with another tool, it passes to Claude Code, which has no tool by that bare name.
