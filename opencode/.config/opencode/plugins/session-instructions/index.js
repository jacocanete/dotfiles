import { readFileSync } from "node:fs"

const sharedRules = "/home/jacocanete/.config/agents/AGENTS.md"
const cavemanLite = "/home/jacocanete/.claude/output-styles/caveman-lite.md"

const instructions = [sharedRules, cavemanLite].map((path) =>
  readFileSync(path, "utf8").replace(/^---\s*\n[\s\S]*?\n---\s*\n/, ""),
)

export default {
  id: "shared-session-instructions",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      for (const text of instructions) event.system.push({ type: "text", text })
    })
  },
}
