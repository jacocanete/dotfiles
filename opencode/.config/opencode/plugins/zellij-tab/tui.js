import { spawn } from "node:child_process"
import { Plugin } from "@opencode/plugin/tui"
import { createEffect } from "solid-js"

export default Plugin.define({
  id: "zellij-tab",
  setup(ctx) {
    if (!process.env.ZELLIJ || !process.env.ZELLIJ_PANE_ID) return

    const states = new Map()
    const requests = new Map()
    let pending, running
    const send = (state) => {
      pending = state
      if (running) return running
      running = (async () => {
        while (pending) {
          const next = pending
          pending = undefined
          await new Promise((resolve) => {
            const child = spawn("zellij-tab-state", [next], { stdio: "ignore", timeout: 3000 })
            child.once("error", resolve)
            child.once("close", resolve)
          })
        }
        running = undefined
      })()
      return running
    }
    const active = () => {
      const route = ctx.ui.router.current()
      return route.type === "session" ? route.sessionID : undefined
    }
    const stateFor = (sessionID) => {
      if (!sessionID) return "clear"
      const permissions = ctx.data.session.permission.list(sessionID)?.length
      const forms = ctx.data.session.form.list(sessionID, ctx.location)?.length
      if (requests.get(sessionID)?.size || permissions || forms) return "needs"
      const cached = states.get(sessionID)
      if (cached && cached !== "working") return cached
      return ctx.data.session.status(sessionID) === "running" ? "working" : cached ?? "clear"
    }

    const stopSlot = ctx.ui.slot({
      append: "app",
      render: () => {
        let previous = Symbol("uninitialized")
        let previousState
        createEffect(() => {
          const sessionID = active()
          if (sessionID && sessionID !== previous) {
            void Promise.allSettled([
              ctx.data.session.permission.sync(sessionID),
              ctx.data.session.form.sync(sessionID, ctx.location),
            ])
          }
          const state = stateFor(sessionID)
          if (sessionID === previous && state === previousState) return
          previous = sessionID
          previousState = state
          send(state)
        })
        return null
      },
    })

    const stopEvents = ctx.data.listen(({ details }) => {
      const { type, data } = details
      const sessionID = type === "form.created" ? data.form.sessionID : data?.sessionID
      if (!sessionID) return

      const request = type === "permission.asked" ? `permission:${data.id}`
        : type === "form.created" ? `form:${data.form.id}` : undefined
      const resolved = type === "permission.replied" ? `permission:${data.requestID}`
        : type === "form.replied" || type === "form.cancelled" ? `form:${data.id}` : undefined
      if (request) {
        const pending = requests.get(sessionID) ?? new Set()
        pending.add(request)
        requests.set(sessionID, pending)
      }
      if (resolved) requests.get(sessionID)?.delete(resolved)
      const state = {
        "session.execution.started": "working",
        "session.execution.succeeded": "done",
        "session.execution.failed": "error",
        "session.execution.interrupted": "done",
      }[type]
      if (!state && !request && !resolved) return
      if (state) states.set(sessionID, state)
      if (sessionID === active()) send(stateFor(sessionID))
    })

    return async () => {
      stopEvents()
      stopSlot()
      await send("clear")
    }
  },
})
