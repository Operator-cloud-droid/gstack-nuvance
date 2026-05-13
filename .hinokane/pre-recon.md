> Produced with Hinokane v0.2.0 on 2026-05-13.

# Pre-recon — gstack-nuvance

## What this codebase is

`gstack` is a personal-developer toolkit for Claude Code authored by Garry Tan (upstream `garrytan/gstack`). The working copy is on the `main` branch at version `1.33.2.0`. License is MIT.

It packages four distinct things into one repo:

1. **Skill templates** — ~50+ directories at the root each named for a skill (`ship/`, `review/`, `office-hours/`, `plan-ceo-review/`, etc.). Each contains a `SKILL.md` (generated) and a `SKILL.md.tmpl` (source). These are Markdown prompts read by Claude Code at invocation time.
2. **A Bun-compiled CLI surface** — `browse/` (~30 MB tree, the largest single subsystem; headless-browser CLI built on Playwright), `design/` (image-gen CLI), `make-pdf/`, plus utilities under `bin/` and `scripts/`. All TypeScript, compiled to native binaries via `bun build --compile`. The compiled artifacts ship under `*/dist/` and are gitignored in this working copy.
3. **A Chrome extension** — `extension/`. Side-panel, content-script, background-worker, manifest. Runs in the user's browser when installed.
4. **An HTTP daemon with optional ngrok tunnel** — `pair-agent/`. Local HTTP server that can be exposed via ngrok for "pair programming with someone using your terminal." Dual-listener architecture per `CLAUDE.md`: local listener has full surface, tunnel listener has a 26-command allowlist.

Supporting:

- **`supabase/migrations/`** — telemetry / installation tracking tables for the upstream gstack project.
- **`.github/workflows/`** — 9 GitHub Actions workflows, mostly evals + version-gate.
- **`.gitlab-ci.yml`** — GitLab parity for version-gate / PR-title checks.
- **`browser-skills/`** — small browser-eval skills bundle.
- **`hosts/`** — adapter configs for non-Claude AI hosts (Codex, Cursor, Kiro, OpenClaw, etc.).
- **`docs/`** — design docs and architecture notes.

## Stack & runtime

| Surface | Runtime | Language |
|---|---|---|
| Skill templates | Claude Code (Markdown + bash blocks) | Markdown |
| CLIs (`browse`, `design`, `make-pdf`) | Bun 1.0+ | TypeScript |
| Chrome extension | Browser (Manifest V3) | JS / CSS / HTML |
| Pair-agent daemon | Bun + native HTTP | TypeScript |
| CI | GitHub Actions / GitLab CI | YAML + bash |

`engines.bun >= 1.0.0` (`package.json`). Designed to run on macOS, Linux, and Windows (with WSL2 for some surfaces).

## Dependencies (top-level)

Production (7):
- `@huggingface/transformers ^4.1.0` — ONNX runtime for in-browser injection-detection classifier (testsavant, optional deberta).
- `@ngrok/ngrok ^1.7.0` — official ngrok SDK for the pair-agent tunnel.
- `diff ^7.0.0` — diffing.
- `marked ^18.0.2` — markdown rendering.
- `playwright ^1.58.2` — browser automation (the `browse` CLI engine).
- `puppeteer-core ^24.40.0` — secondary browser automation path.
- `socks ^2.8.8` — SOCKS proxy client.

Dev (4):
- `@anthropic-ai/claude-agent-sdk 0.2.117` — used by E2E tests.
- `@anthropic-ai/sdk ^0.78.0` — used by LLM-judge tests.
- `xterm 5` + `xterm-addon-fit ^0.8.0` — vendored into the Chrome extension's terminal pane.

All are mainstream, named verbatim, and easily verifiable on npm. None have suspicious typosquat-shape names. Lockfile (`bun.lock`) and per-dep audit happen in finding-stage.

## Tracked binaries

`CLAUDE.md` warns about `browse/dist/` and `design/dist/` being historically tracked. **In this working copy, neither directory exists** — `find . -path "*/dist/*"` returns nothing under `browse/`, `design/`, or `make-pdf/`. The `.gitignore` excludes all `*/dist/` paths. `./setup` builds them locally from source. Conclusion: no smuggled-binary risk in this working copy. Phase-3 binary-inspection becomes trivial (no artifact to inspect).

## Install hooks

`package.json` has no `preinstall` / `postinstall` / `prepare` lifecycle script. The only "install"-related entry is the `slop` script invoking `npx slop-scan` on demand, which is a developer command, not an install hook.

## Auth model

The toolkit itself has no user-account model. It's a single-user developer tool. Three places have auth-shaped state:

1. **`pair-agent/`** — token-gated HTTP listener. Two listeners: local (`127.0.0.1`, full command surface) and tunnel (locked allowlist + scoped token + 30-minute SSE cookie). Tunnel-binding only happens when the user starts ngrok.
2. **`extension/`** — Chrome extension reads a `gstack_pty` cookie / `Sec-WebSocket-Protocol` token to authenticate against the pair-agent daemon running locally.
3. **`supabase/migrations/*.sql`** — telemetry tables with RLS policies. Inserts only; the user is anonymous. Not exposed in this working copy beyond the schema.

## Network egress (preliminary inventory — to be confirmed in phase 3)

Expected outbound destinations:
- npm registry (build time, via `bun install`).
- GitHub (`api.github.com`, `github.com`) — via `gh` CLI in skill scripts and CI.
- supabase project (telemetry POSTs).
- Anthropic API (`api.anthropic.com`) — when LLM-judge or agent-SDK code runs.
- OpenAI API (`api.openai.com`) — codex skill calls the OpenAI Codex CLI; image-gen via `gpt-image-1`.
- HuggingFace (`huggingface.co`) — first-run model fetch for testsavant / deberta classifiers.
- ngrok (`ngrok.com`, `ngrok.app`) — when pair-agent starts a tunnel.
- Google APIs (`generativelanguage.googleapis.com`) — gemini skill.
- `playwright.download.prss.microsoft.com` — Chromium download for Playwright.

Phase 3 confirms each, plus catches anything not in this list.

## Directory shape

```
~ 30 MB browse/        — TypeScript CLI: headless browser, content snapshot, security classifier
~ 2.9 MB test/         — TS tests + fixtures
~ 1.7 MB scripts/      — build/CI scripts
~ 0.6 MB docs/         — design docs
~ 0.5 MB bin/          — shell + TS CLI utilities

~50 *-named skill dirs (autoplan, benchmark, canary, codex, design-*, plan-*, ship, review, etc.)
hosts/        — host-adapter configs (claude, codex, cursor, kiro, opencode, slate, openclaw, ...)
extension/    — Chrome MV3 extension
pair-agent/   — local HTTP daemon
supabase/     — telemetry migrations
```

## What I will not look at

- Optional compliance frameworks. Operator did not ask.
- Live telemetry endpoint behavior. No live target to probe.
- Full `node_modules/` audit. Out of scope by user time-budget — supply-chain pass instead checks lockfile + manifests + transitive surface for known-bad shapes.
- Languages other than TS / JS / bash / Markdown / SQL / YAML. The tree contains nothing else.

## Confidence

- Stack identification: high — every claim above is grounded in `package.json`, `.gitignore`, top-level directory layout, and `CLAUDE.md` self-documentation.
- Functionality claims (what pair-agent does, what extension does): medium — based on `CLAUDE.md` and quick directory inspection. Will tighten in phase 2 when the relevant files are read for the web-surface audit.
- Upstream-vs-fork claim: medium-high — the working copy clones `garrytan/gstack` per `gstack/llms.txt` and the commit log; the operator has not yet made Nuvance-specific changes.
