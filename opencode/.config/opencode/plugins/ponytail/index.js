import { createRequire } from "node:module"
import { readFileSync, writeFileSync } from "node:fs"

const require = createRequire(import.meta.url)
const root = "/home/jacocanete/.claude/plugins/marketplaces/ponytail"
const { getPonytailInstructions } = require(`${root}/hooks/ponytail-instructions.js`)
const { getDefaultMode, normalizePersistedMode } = require(`${root}/hooks/ponytail-config.js`)
const state = "/home/jacocanete/.config/opencode/.ponytail-active"

function activeMode() {
  try {
    return normalizePersistedMode(readFileSync(state, "utf8").trim()) || getDefaultMode()
  } catch {
    return getDefaultMode()
  }
}

export default {
  id: "ponytail",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      const mode = activeMode()
      if (mode !== "off") {
        event.system.push({ type: "text", text: getPonytailInstructions(mode) })
      }
    })

    await ctx.command.transform((editor) => {
      editor.add({
        name: "ponytail",
        description: "Switch Ponytail mode (lite, full, ultra, review, off)",
        execute: async ({ sessionID, prompt, delivery }) => {
          const requested = prompt.text?.trim() || getDefaultMode()
          const mode = normalizePersistedMode(requested)
          if (!mode) {
            await ctx.session.prompt({
              sessionID,
              text: "Invalid Ponytail mode. Choose lite, full, ultra, review, or off.",
              delivery,
            })
            return
          }
          writeFileSync(state, mode)
          await ctx.session.prompt({ sessionID, text: `Ponytail mode set to ${mode}.`, delivery })
        },
      })
    })
  },
}
