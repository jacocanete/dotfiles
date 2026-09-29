import assert from "node:assert/strict"
import { mkdtempSync, readFileSync, writeFileSync, chmodSync, rmSync, unlinkSync, existsSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { registerHooks } from "node:module"
import { test } from "node:test"

test("Zellij follows only the visible OpenCode session", async () => {
  const dir = mkdtempSync(join(tmpdir(), "zellij-tab-"))
  const bin = join(dir, "zellij-tab-state")
  writeFileSync(bin, '#!/bin/sh\n[ -z "$TAB_TEST_DELAY" ] || sleep "$TAB_TEST_DELAY"\nprintf "%s\\n" "$1" >> "$TAB_TEST_LOG"\n')
  chmodSync(bin, 0o755)
  const env = { ...process.env }
  Object.assign(process.env, { PATH: `${dir}:${process.env.PATH}`, TAB_TEST_LOG: join(dir, "states"), ZELLIJ: "0", ZELLIJ_PANE_ID: "999" })
  let effect, listen, route = { type: "home" }
  const status = { first: "idle", background: "idle" }
  const permissions = { first: [], background: [] }, forms = { first: [], background: [] }
  const oldEffect = globalThis.__tabEffect
  globalThis.__tabEffect = (fn) => { effect = fn; fn() }
  const hook = registerHooks({
    resolve(specifier, context, next) {
      if (specifier === "@opencode/plugin/tui") return { url: "data:text/javascript,export const Plugin={define:x=>x}", shortCircuit: true }
      if (specifier === "solid-js") return { url: "data:text/javascript,export const createEffect=globalThis.__tabEffect", shortCircuit: true }
      return next(specifier, context)
    },
  })
  let activeCleanup
  try {
    const { default: plugin } = await import("./tui.js")
    const context = {
      ui: { router: { current: () => route }, slot: ({ render }) => { render(); return () => {} } },
      data: { session: {
        status: (id) => status[id],
        permission: { list: (id) => permissions[id], sync: async () => {} },
        form: { list: (id) => forms[id], sync: async () => {} },
      }, listen: (fn) => { listen = fn; return () => { if (listen === fn) listen = undefined } } },
    }
    let count = 0
    const tick = async () => {
      const expected = ++count
      for (let attempt = 0; attempt < 100; attempt++) {
        if (existsSync(process.env.TAB_TEST_LOG) && readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length >= expected) return
        await new Promise((resolve) => setTimeout(resolve, 10))
      }
      assert.fail(`Zellij helper did not write state ${expected}`)
    }
    const cleanup = activeCleanup = plugin.setup(context)
    const emit = (type, data) => listen?.({ details: { type, data } })
    await tick()
    route = { type: "session", sessionID: "first" }; effect()
    await tick()
    status.first = "running"; effect()
    await tick()
    emit("session.execution.started", { sessionID: "first" })
    await tick()
    emit("form.created", { form: { id: "initial", sessionID: "first" } })
    await tick()
    route = { type: "home" }; effect()
    await tick()
    route = { type: "session", sessionID: "first" }; effect()
    await tick()
    emit("form.replied", { id: "initial", sessionID: "first" })
    await tick()
    emit("session.execution.succeeded", { sessionID: "first" })
    await tick()
    emit("session.execution.failed", { sessionID: "background" })
    permissions.background = [{ id: "remote" }]
    emit("permission.asked", { id: "remote", sessionID: "background" })
    await new Promise((resolve) => setTimeout(resolve, 20))
    assert.equal(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length, count)
    permissions.background = []
    emit("permission.replied", { requestID: "remote", sessionID: "background" })
    route = { type: "session", sessionID: "background" }; effect()
    await tick()
    route = { type: "session", sessionID: "first" }; effect()
    await tick()
    await cleanup()
    activeCleanup = undefined
    assert.deepEqual(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n"),
      ["clear", "clear", "working", "working", "needs", "clear", "needs", "working", "done", "error", "done", "clear"])

    count = readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length
    route = { type: "session", sessionID: "first" }
    permissions.first = [{ id: "one" }, { id: "two" }]
    forms.first = [{ id: "form" }]
    const attached = activeCleanup = plugin.setup(context)
    await tick()
    permissions.first = [{ id: "two" }]
    effect()
    emit("permission.replied", { sessionID: "first", requestID: "one" })
    await tick()
    permissions.first = []
    effect()
    emit("permission.replied", { sessionID: "first", requestID: "two" })
    await tick()
    forms.first = []
    emit("form.cancelled", { sessionID: "first", id: "form" })
    await tick()
    emit("session.execution.failed", { sessionID: "first" })
    await tick()
    emit("permission.replied", { sessionID: "first", requestID: "late" })
    await tick()
    forms.first = [{ id: "late" }]
    emit("form.created", { form: { id: "late", sessionID: "first" } })
    await tick()
    forms.first = []
    emit("form.replied", { sessionID: "first", id: "late" })
    await tick()
    await attached()
    activeCleanup = undefined
    assert.deepEqual(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").slice(-9),
      ["needs", "needs", "needs", "working", "error", "error", "needs", "error", "clear"])
    const stoppedCount = readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length
    emit("session.execution.started", { sessionID: "first" })
    await new Promise((resolve) => setTimeout(resolve, 20))
    assert.equal(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length, stoppedCount)

    count = readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").length
    status.first = "idle"
    context.data.session.form.sync = async () => {
      await new Promise((resolve) => setTimeout(resolve, 20))
      forms.first = [{ id: "late" }]
      effect()
    }
    const hydrated = activeCleanup = plugin.setup(context)
    await tick()
    await tick()
    await hydrated()
    activeCleanup = undefined
    assert.deepEqual(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n").slice(-3), ["clear", "needs", "clear"])

    unlinkSync(process.env.TAB_TEST_LOG)
    context.data.session.form.sync = async () => {}
    forms.first = []
    status.first = "running"
    process.env.TAB_TEST_DELAY = "0.1"
    route = { type: "session", sessionID: "first" }
    const delayed = activeCleanup = plugin.setup(context)
    emit("form.created", { form: { id: "delayed", sessionID: "first" } })
    route = { type: "home" }; effect()
    emit("session.execution.failed", { sessionID: "background" })
    route = { type: "session", sessionID: "background" }; effect()
    await delayed()
    activeCleanup = undefined
    assert.deepEqual(readFileSync(process.env.TAB_TEST_LOG, "utf8").trim().split("\n"), ["working", "clear"])
  } finally {
    try {
      await activeCleanup?.()
    } finally {
      hook.deregister()
      if (oldEffect === undefined) delete globalThis.__tabEffect
      else globalThis.__tabEffect = oldEffect
      for (const key of ["PATH", "TAB_TEST_LOG", "TAB_TEST_DELAY", "ZELLIJ", "ZELLIJ_PANE_ID"]) {
        if (env[key] === undefined) delete process.env[key]
        else process.env[key] = env[key]
      }
      rmSync(dir, { recursive: true, force: true })
    }
  }
})
