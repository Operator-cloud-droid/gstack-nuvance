> Produced with Hinokane v0.2.0 on 2026-05-13.

# gstack-nuvance — security audit (malicious-code / supply-chain vetting)

**Target:** `garrytan/gstack` working copy at `/mnt/c/Users/selli/Downloads/Tools/G-stack/gstack-nuvance/`, `main` branch, VERSION `1.33.2.0`.
**Operator:** Nuvance (`operations@nuvance-ait.co.za`).
**Scope:** Vet for malicious code, backdoors, and supply-chain compromise prior to forking. Not a standard web-app pentest.
**Methodology version:** Hinokane v0.2.0, narrowed per `references/judgment.md` ("When to skip a vulnerability class").

---

## Executive verdict

**Safe to fork.** No malicious code, no supply-chain compromise, no live secrets, no covert egress. The codebase shows deliberate security engineering — defenses-in-depth around SSRF, prompt injection, shell-arg handling, and the pair-agent tunnel boundary — and the package surface is small, mainstream, and lockfile-pinned.

There are zero security findings against the codebase itself. There are three **adoption-discipline notes** for Nuvance to handle when forking (telemetry endpoint, team-mode trust root, lockfile-fallback hardening) — none of these are vulnerabilities; they are governance choices a fork-owner should make consciously.

| Risk class | Result | Action |
|---|---|---|
| Supply chain (deps, lockfile, install hooks) | Clean | None — see Note 3 for an optional hardening |
| Malicious-code patterns (obfuscation, droppers, beacons, exfil) | Clean | None |
| Hardcoded secrets / credentials | Clean — only documented public anon key | Repoint at your own Supabase or strip telemetry (Note 1) |
| Network egress | Clean — matches documented set | None |
| Shell / command injection in CLI | Clean — all `Bun.spawn` array form | None |
| Web surfaces (pair-agent, Chrome extension) | Hardened — dual-listener, escapeHtml, 127.0.0.1-only host_permissions | None |
| CI / git hooks | Clean — no third-party-action drift; hooks are `.sample` defaults | None |
| Tracked binaries | None present in working copy | None |
| Auto-update trust root (team mode) | Opt-in, but real trust implication | Disable team mode in your fork or repoint remote (Note 2) |

---

## Scope discipline

The user's question — "ensure that this is not hiding any nasty bugs or viruses" — maps onto a malicious-code / supply-chain vet, not the full 16-class web-app sweep. Skipped classes (XSS, CSRF, SSRF, IDOR, authn, authz, tenant isolation, business logic, race, file upload, API rate-limit, IaC) do not apply because the target is a single-user developer CLI + Markdown skill toolkit, not a deployed multi-tenant web app. The two surfaces that ARE web-shaped — the pair-agent HTTP daemon and the Chrome extension — got a focused single-surface pass instead of class-by-class, and they hold up.

This narrowing is documented per the Hinokane "When to skip a vulnerability class" rule. If Nuvance later deploys a hosted version of any of these surfaces, re-run with the full methodology against that deployment.

---

## What the codebase is

`gstack` is Garry Tan's personal Claude Code toolkit. The working copy contains:

- ~50 Markdown skill templates (`ship/`, `review/`, `office-hours/`, `plan-ceo-review/`, …) — these are prompts, not code, but they are read by Claude Code at invocation time and instruct it on workflow behavior.
- `browse/` — a Bun-compiled TypeScript CLI wrapping Playwright (`browse`, `find-browse`). Largest single subsystem (~30 MB tree). Includes a persistent Chromium daemon (`browse/src/server.ts`), a dual-listener architecture for the optional ngrok tunnel, and an in-process prompt-injection classifier ensemble.
- `design/`, `make-pdf/` — additional Bun-compiled CLIs for image generation and PDF export.
- `extension/` — Chrome MV3 extension; sidepanel + content-script + background-worker. Manifest scopes network to `127.0.0.1` only.
- `pair-agent/` — Markdown skill that drives the tunnel feature in `browse/src/server.ts`. No code of its own.
- `supabase/migrations/` — schema for an opt-in telemetry project.
- `bin/`, `scripts/` — bash + TS utilities for setup, sync, upgrade, host adapters.
- `.github/workflows/`, `.gitlab-ci.yml` — CI for evals, version-gate, doc generation.

Dependency surface: 7 production deps (`@huggingface/transformers`, `@ngrok/ngrok`, `diff`, `marked`, `playwright`, `puppeteer-core`, `socks`), 4 dev deps (Anthropic SDKs + xterm). All mainstream, lockfile-pinned (`bun.lock`, 297 unique packages total). No custom registries, no `git+ssh://` sources, no transitive postinstall hooks.

---

## Findings

**There are none.** No security finding rises to the bar for the main findings list.

The detailed per-class evidence lives in `.hinokane/findings/`:

- `supply-chain-summary.md` — no postinstall, no typosquats, no remote-fetch install hooks
- `network-egress-summary.md` — every destination matches the documented set
- `secrets-summary.md` — public Supabase anon key only; no live credentials
- `malicious-code-summary.md` — no obfuscation, droppers, beacons, exfil, or anti-analysis
- `pre-recon.md` — target shape, stack, dependency manifest

---

## Adoption notes (Nuvance fork governance)

These are not vulnerabilities. They are three things a fork-owner should decide deliberately at fork time.

### Note 1 — Telemetry endpoint

`supabase/config.sh:7-8` ships the upstream gstack project's Supabase URL and public anon key. When you fork, **decide one of**:

a. Strip telemetry entirely — empty the URL + key, delete `supabase/migrations/` and `supabase/functions/`, remove any telemetry calls. Cleanest for a Nuvance internal tool.
b. Point at your own Supabase project — replace URL + anon key, redeploy the migrations from `supabase/migrations/*.sql`. Use this if you want usage analytics for the Nuvance team.
c. Keep upstream pointed — telemetry continues to flow to Garry's Supabase. Probably not what you want for a forked, branded tool.

Default: do (a) unless you have a specific reason to keep telemetry. The anon key is safe to commit (it's a publishable key, RLS-locked), but the data residency is a governance choice, not a security one.

### Note 2 — Team-mode auto-update is a trust root

`./setup --team` registers a SessionStart hook (`bin/gstack-session-update`) that runs `git pull --ff-only && ./setup -q` at the start of every Claude Code session. Code at `bin/gstack-session-update:78-114`.

**Implication.** In team mode, whoever controls the `git remote origin` for your installed copy of gstack can ship arbitrary code to every Nuvance developer's machine the next time they open Claude Code. Upstream, that's Garry. For a Nuvance fork:

- If you DO want auto-update behavior for Nuvance developers, point `origin` at a Nuvance-controlled repo and treat write access to that repo as a privileged role (mandatory review, branch protection, etc.).
- If you DON'T want it, just don't pass `--team` when running `./setup`. Auto-update is opt-in; the default install does not register the hook.

This is not a vulnerability — it's a documented, opt-in feature with an explicit user prompt. But it IS a real trust assumption you should make consciously.

### Note 3 — Lockfile-fallback hardening (optional)

`setup:239` runs `bun install --frozen-lockfile 2>/dev/null || bun install`. The fallback to plain `bun install` only triggers when frozen-install fails (typically: corrupt or missing lockfile), but in principle it permits lockfile drift on edge cases. After forking, you can tighten this to `bun install --frozen-lockfile` with no fallback — a one-line change. Optional, not required. The risk profile of the fallback is low because the failure case is unusual.

---

## Positive signals worth recording

The codebase shows deliberate security engineering, not just absence of malice. Things Nuvance should preserve when forking:

- `browse/src/url-validation.ts` — blocks `169.254.169.254` (and IPv4-mapped IPv6 form) as SSRF defense against cloud-metadata exfil.
- `browse/src/server.ts` — dual-listener tunnel architecture (local listener has full surface, tunnel listener has a 26-command allowlist + scoped tokens). Documented in `ARCHITECTURE.md`.
- `browse/src/security-classifier.ts` — TestSavantAI ONNX classifier + Claude Haiku transcript classifier ensemble for prompt-injection detection. Multiple thresholds, kill-switch via `GSTACK_SECURITY_OFF=1`.
- `extension/sidepanel.js:232` — `escapeHtml()` with explicit `"`/`'` escaping and a code comment explaining why DOM text-node serialization alone is insufficient.
- `extension/manifest.json:7` — `host_permissions` locked to `http://127.0.0.1:*/` and `ws://127.0.0.1:*/`. The extension structurally cannot phone home anywhere else.
- `scripts/host-config-export.ts:73` — `shellEscape()` at the only call site where a command name interpolates a variable.
- All `child_process.spawn` / `Bun.spawn` use the array form (shell-bypass-safe). The one `execSync` with template interpolation (`browse/src/meta-commands.ts:787`) iterates a hardcoded constant list, not user input.

---

## Coverage statement

This audit ran:

- ✅ Supply chain (deps, lockfile, postinstall, dynamic-fetch, setup script)
- ✅ Malicious-code patterns (obfuscation, dynamic exec, droppers, beacons, exfil, anti-analysis, foreign binaries)
- ✅ Secrets / credentials (live keys, public keys, placeholders, git-history sample)
- ✅ Network egress (every outbound destination, hardcoded IPs)
- ✅ Shell / command injection (every exec/spawn call, shell:true sweep)
- ✅ Web surfaces — pair-agent dual-listener architecture, Chrome extension manifest + DOM-injection paths
- ✅ Build artifacts — confirmed `*/dist/` absent in this working copy (gitignored)
- ✅ CI workflows + git hooks + migrations

This audit did NOT run (out of scope per intake):

- The 16-class web-app sweep (XSS / CSRF / SSRF / IDOR / authn / authz / tenant / business-logic / race / file-upload / API / IaC). Re-run if Nuvance deploys a hosted multi-tenant version.
- Full `node_modules/` deep audit (only manifest + lockfile reviewed at the dep-shape level).
- Full git-history sweep for past committed-then-removed secrets. Spot-check only — clean. If Nuvance plans to mirror the full upstream history into a public repo, run `git-secrets` or `trufflehog` on the whole `--all` history as a one-time pre-publish gate.
- Side-channel analysis of the compiled binaries (they're not present in this working copy and are gitignored).

## Cleanup

This engagement made no changes to operator systems beyond writing this audit's artifacts under `.hinokane/`. No PoCs were run, no test accounts created, no live calls to any third-party service. To remove all audit artifacts:

```bash
rm -rf /mnt/c/Users/selli/Downloads/Tools/G-stack/gstack-nuvance/.hinokane
```

---

## One-line takeaway

The upstream gstack codebase is clean and well-engineered. When you fork it for Nuvance, the only governance decisions to make are (1) where telemetry should point, (2) whether to enable team-mode auto-update against a Nuvance-controlled remote, and (3) optional tightening of the lockfile-fallback in `setup`. No remediation work is required against the codebase itself.
