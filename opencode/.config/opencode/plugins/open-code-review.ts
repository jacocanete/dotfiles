// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 alibaba/open-code-review Contributors

import { spawn } from "node:child_process"
import { join } from "node:path"
import type { Plugin as PluginV2 } from "@opencode/plugin"

interface ReviewInput {
  commit?: string
  from?: string
  to?: string
  resume?: string
  background?: string
  backgroundFile?: string
  exclude?: string
  model?: string
  concurrency?: number
  timeoutMinutes?: number
  overallTimeoutMinutes?: number
  maxTools?: number
  maxGitProcesses?: number
  preview?: boolean
}

interface OcrInvocation {
  command: string
  prefixArgs: string[]
}

interface RunOptions {
  cwd: string
  timeoutMs?: number | null
  maxOutputBytes?: number
  invocation?: OcrInvocation
  signal?: AbortSignal
}

interface RunResult {
  stdout: string
  stderr: string
  exitCode: number
}

class OcrExecutionError extends Error {
  readonly exitCode: number | null
  readonly signal: NodeJS.Signals | null
  readonly stderr: string
  readonly stdout: string

  constructor(message: string, result: {
    exitCode: number | null
    signal?: NodeJS.Signals | null
    stderr?: string
    stdout?: string
  }) {
    super(message)
    this.name = "OcrExecutionError"
    this.exitCode = result.exitCode
    this.signal = result.signal ?? null
    this.stderr = result.stderr ?? ""
    this.stdout = result.stdout ?? ""
  }
}

function pushValue(args: string[], flag: string, value: string | number | undefined): void {
  if (value !== undefined && value !== "") {
    args.push(flag, String(value))
  }
}

export function buildReviewArgs(input: ReviewInput, repo: string): string[] {
  const from = input.from?.trim() ? input.from : undefined
  const to = input.to?.trim() ? input.to : undefined
  const hasRange = from !== undefined || to !== undefined
  if (hasRange && (!from || !to)) {
    throw new Error("Both 'from' and 'to' are required for a branch comparison.")
  }
  if (input.commit && hasRange) {
    throw new Error("Use either 'commit' or a 'from'/'to' range, not both.")
  }
  if (input.resume && (input.commit || hasRange)) {
    throw new Error("'resume' cannot be combined with 'commit' or a 'from'/'to' range.")
  }
  if (input.preview && input.resume) {
    throw new Error("'preview' and 'resume' cannot be used together.")
  }
  // OCR warns on stderr and lets the file win, but formatReviewResult drops
  // stderr on exit 0, so the caller would never see it.
  if (input.background && input.backgroundFile) {
    throw new Error("Use either 'background' or 'backgroundFile', not both.")
  }

  const args = ["review", "--audience", "agent"]
  if (!input.preview) {
    args.push("--format", "json")
  }
  args.push("--repo", repo)

  pushValue(args, "--commit", input.commit)
  pushValue(args, "--from", from)
  pushValue(args, "--to", to)
  pushValue(args, "--resume", input.resume)
  pushValue(args, "--background", input.background)
  pushValue(args, "--background-file", input.backgroundFile)
  pushValue(args, "--exclude", input.exclude)
  pushValue(args, "--model", input.model)
  pushValue(args, "--concurrency", input.concurrency)
  pushValue(args, "--timeout", input.timeoutMinutes)
  pushValue(args, "--max-tools", input.maxTools)
  pushValue(args, "--max-git-procs", input.maxGitProcesses)

  if (input.preview) {
    args.push("--preview")
  }
  return args
}

function appendChunk(
  chunks: Uint8Array[],
  currentBytes: number,
  chunk: Uint8Array,
  maxBytes: number,
): number {
  const nextBytes = currentBytes + chunk.byteLength
  if (nextBytes > maxBytes) {
    throw new Error(`OCR output exceeded the ${maxBytes}-byte safety limit.`)
  }
  chunks.push(chunk)
  return nextBytes
}

async function runOcr(args: string[], options: RunOptions): Promise<RunResult> {
  const invocation = options.invocation ?? { command: "ocr", prefixArgs: [] }
  const timeoutMs = options.timeoutMs === undefined ? 15 * 60 * 1000 : options.timeoutMs
  const maxOutputBytes = options.maxOutputBytes ?? 10 * 1024 * 1024

  return await new Promise<RunResult>((resolve, reject) => {
    const child = spawn(
      invocation.command,
      [...invocation.prefixArgs, ...args],
      {
        cwd: options.cwd,
        env: process.env,
        shell: false,
        detached: true,
      },
    )
    child.stdin.end()

    const stdoutChunks: Uint8Array[] = []
    const stderrChunks: Uint8Array[] = []
    let outputBytes = 0
    let settled = false
    let closed = false
    let timer: ReturnType<typeof setTimeout> | undefined
    let forceKillTimer: ReturnType<typeof setTimeout> | undefined
    let abort: (() => void) | undefined

    const finish = (callback: () => void): void => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      if (abort) {
        options.signal?.removeEventListener("abort", abort)
      }
      callback()
    }

    const killProcessGroup = (signal: NodeJS.Signals): void => {
      if (closed || child.pid === undefined) return
      if (process.platform === "win32") {
        spawn("taskkill", ["/pid", String(child.pid), "/T", "/F"], { stdio: "ignore" })
        return
      }
      try {
        process.kill(-child.pid, signal)
      } catch {
        child.kill(signal)
      }
    }

    const terminateChild = (): void => {
      if (closed) return
      killProcessGroup("SIGTERM")
      forceKillTimer ??= setTimeout(() => {
        if (!closed) {
          killProcessGroup("SIGKILL")
        }
      }, 3_000)
    }

    const failForOutputLimit = (error: Error): void => {
      terminateChild()
      finish(() => reject(error))
    }

    child.stdout.on("data", (chunk: Buffer) => {
      try {
        outputBytes = appendChunk(stdoutChunks, outputBytes, chunk, maxOutputBytes)
      } catch (error) {
        failForOutputLimit(error as Error)
      }
    })
    child.stderr.on("data", (chunk: Buffer) => {
      try {
        outputBytes = appendChunk(stderrChunks, outputBytes, chunk, maxOutputBytes)
      } catch (error) {
        failForOutputLimit(error as Error)
      }
    })

    child.on("error", (error) => {
      const message = error.message.includes("ENOENT")
        ? "OpenCodeReview is not installed or 'ocr' is not on PATH. Install it with: npm install -g @alibaba-group/open-code-review"
        : `Failed to start OpenCodeReview: ${error.message}`
      finish(() => reject(new OcrExecutionError(message, { exitCode: null })))
    })

    child.on("close", (exitCode, signal) => {
      closed = true
      clearTimeout(forceKillTimer)
      finish(() => {
        const stdout = Buffer.concat(stdoutChunks).toString("utf8").trim()
        const stderr = Buffer.concat(stderrChunks).toString("utf8").trim()
        if (exitCode === 0) {
          resolve({ stdout, stderr, exitCode })
          return
        }
        // A signal kill reports a null exit code. Naming the signal keeps it
        // distinguishable from a genuine exit 1 when OCR wrote no output.
        // `?? 1` keeps the message numeric: close always reports one of the
        // two, but neither is typed as non-null.
        const cause = signal
          ? `was terminated by signal ${signal}`
          : `exited with code ${exitCode ?? 1}`
        reject(new OcrExecutionError(
          stderr || stdout || `OpenCodeReview ${cause}.`,
          { exitCode, signal, stdout, stderr },
        ))
      })
    })

    abort = (): void => {
      terminateChild()
      finish(() => reject(new OcrExecutionError(
        "OpenCodeReview was cancelled by OpenCode.",
        {
          exitCode: null,
          stdout: Buffer.concat(stdoutChunks).toString("utf8"),
          stderr: Buffer.concat(stderrChunks).toString("utf8"),
        },
      )))
    }
    options.signal?.addEventListener("abort", abort, { once: true })

    if (timeoutMs !== null) {
      timer = setTimeout(() => {
        terminateChild()
        finish(() => reject(new OcrExecutionError(
          `OpenCodeReview timed out after ${Math.round(timeoutMs / 1000)} seconds.`,
          {
            exitCode: null,
            stdout: Buffer.concat(stdoutChunks).toString("utf8"),
            stderr: Buffer.concat(stderrChunks).toString("utf8"),
          },
        )))
      }, timeoutMs)
    }

    if (options.signal?.aborted) {
      abort()
    }
  })
}

function formatReviewResult(result: RunResult, preview: boolean): string {
  if (preview) {
    return result.stdout || "No files changed."
  }
  if (result.stdout === "") {
    return "No changes detected; OCR produced no output."
  }
  try {
    JSON.parse(result.stdout)
    return result.stdout
  } catch {
    throw new OcrExecutionError("OpenCodeReview returned invalid JSON.", result)
  }
}

// Tool execution uses the session directory; timeouts also stop reviews if
// the client disconnects without cancelling the tool.

const OCR_REVIEW_DESCRIPTION =
  "Run OpenCodeReview on workspace changes, one commit, or a ref range. " +
  "Returns structured line-level findings as JSON. Use preview=true to inspect scope without LLM usage."

const OCR_HEALTH_DESCRIPTION =
  "Check the installed OpenCodeReview version and verify its configured LLM connection."

const OCR_REVIEW_COMMAND_TEMPLATE =
  "Use the ocr_review tool to review the requested target. " +
  "Treat the following text as review intent, target details, and business context:"

const OCR_REVIEW_COMMAND_SUFFIX =
  ". If no target is specified, review the current workspace changes. " +
  "Report findings by severity with exact file and line references."

const OCR_HEALTH_COMMAND_TEMPLATE =
  "Use the ocr_health tool and explain any configuration problem concisely."

const reviewInputSchema = {
  type: "object",
  properties: {
    commit: { type: "string", description: "Review one commit against its parent." },
    from: { type: "string", description: "Base ref for a branch/range comparison. Must be paired with 'to'." },
    to: { type: "string", description: "Target ref for a branch/range comparison. Must be paired with 'from'." },
    resume: { type: "string", description: "Resume a previous OCR review session by ID." },
    background: { type: "string", description: "Business or requirement context that the implementation should satisfy." },
    backgroundFile: { type: "string", description: "Path to a Markdown file holding the review background, for context too long to pass inline. A relative path resolves against the repository root; an absolute path is used as given. Cannot be combined with 'background'." },
    exclude: { type: "string", description: "Comma-separated gitignore-style exclusion patterns." },
    model: { type: "string", description: "Override the model configured in OpenCodeReview." },
    concurrency: { type: "integer", minimum: 1, description: "Maximum concurrent file reviews." },
    timeoutMinutes: { type: "integer", minimum: 1, description: "Per-file OCR timeout in minutes." },
    overallTimeoutMinutes: { type: "integer", minimum: 1, description: "Optional wall-clock timeout for the complete OCR process in minutes." },
    maxTools: { type: "integer", minimum: 1, description: "Maximum tool-call rounds per subtask; OCR enforces a minimum of 50." },
    maxGitProcesses: { type: "integer", minimum: 1, description: "Maximum concurrent Git subprocesses." },
    preview: { type: "boolean", description: "List the files that would be reviewed without calling an LLM." },
  },
  required: [],
  additionalProperties: false,
}

async function resolveSessionCwd(ctx: PluginV2.Context, sessionID: string): Promise<string> {
  try {
    const session = await ctx.session.get({ sessionID })
    const directory = session.location.directory
    const subpath = session.subpath
    return subpath === undefined || subpath === "" ? directory : join(directory, subpath)
  } catch {
    return ctx.location.directory
  }
}

async function setupV2(ctx: PluginV2.Context): Promise<void> {
  await ctx.shell.hook("create.before", (event) => {
    event.env.AGENT_BROWSER_CA_CERT = "/home/jacocanete/.local/share/mkcert/rootCA.pem"
  })
  await ctx.tool.transform((editor) => {
    editor.add({
      name: "ocr_review",
      description: OCR_REVIEW_DESCRIPTION,
      input: reviewInputSchema,
      execute: async (input, toolCtx) => {
        const review = input as ReviewInput
        const cwd = await resolveSessionCwd(ctx, toolCtx.sessionID)
        const result = await runOcr(buildReviewArgs(review, cwd), {
          cwd,
          signal: toolCtx.signal,
          timeoutMs: review.overallTimeoutMinutes !== undefined
            ? review.overallTimeoutMinutes * 60 * 1000
            : 30 * 60 * 1000,
        })
        return { content: formatReviewResult(result, review.preview === true) }
      },
    })
    editor.add({
      name: "ocr_health",
      description: OCR_HEALTH_DESCRIPTION,
      input: { type: "object", properties: {}, additionalProperties: false },
      execute: async (_input, toolCtx) => {
        const cwd = await resolveSessionCwd(ctx, toolCtx.sessionID)
        const [version, llm] = await Promise.allSettled([
          runOcr(["version"], { cwd, timeoutMs: 30_000, signal: toolCtx.signal }),
          runOcr(["llm", "test"], { cwd, timeoutMs: 60_000, signal: toolCtx.signal }),
        ])
        toolCtx.signal?.throwIfAborted()
        const parts: string[] = []
        if (version.status === "fulfilled") {
          parts.push(version.value.stdout)
        } else {
          parts.push(`Version check failed: ${version.reason?.message ?? "unknown error"}`)
        }
        if (llm.status === "fulfilled") {
          parts.push(llm.value.stdout, llm.value.stderr)
        } else {
          parts.push(`LLM connection check failed: ${llm.reason?.message ?? "unknown error"}`)
        }
        return { content: parts.filter(Boolean).join("\n") }
      },
    })
  })

  // Like the V1 `??=` guards above, never override commands the user
  // already defined under the same names.
  const registeredCommands = await ctx.command.list()
  const commandNames = new Set(registeredCommands.data.map((command) => command.name))

  await ctx.command.transform((editor) => {
    // Text-only prompts, matching the V1 $ARGUMENTS templates: spreading the
    // incoming prompt attachments would violate exactOptionalPropertyTypes
    // and risk stale attachment offsets after the text rewrite.
    if (!commandNames.has("ocr-review")) {
      editor.add({
        name: "ocr-review",
        description: "Review code changes with OpenCodeReview",
        execute: async ({ sessionID, prompt, delivery }) => {
          await ctx.session.prompt({
            sessionID,
            text: `${OCR_REVIEW_COMMAND_TEMPLATE}${prompt.text ?? ""}${OCR_REVIEW_COMMAND_SUFFIX}`,
            delivery,
          })
        },
      })
    }
    if (!commandNames.has("ocr-health")) {
      editor.add({
        name: "ocr-health",
        description: "Check OpenCodeReview and its LLM connection",
        execute: async ({ sessionID, delivery }) => {
          await ctx.session.prompt({
            sessionID,
            text: OCR_HEALTH_COMMAND_TEMPLATE,
            delivery,
          })
        },
      })
    }
  })
}

export default {
  id: "open-code-review",
  setup: setupV2,
}
