# Nuvance — gstack digestion TODO

Working doc for turning the upstream `garrytan/gstack` fork into Nuvance-specific itemized tools.
Audit deliverable lives at `.hinokane/report.md`; per-class evidence under `.hinokane/findings/`.

---

## 1. Security audit summary

**Audit date:** 2026-05-13 · **Target version:** `1.33.2.0` · **Verdict:** safe to fork.

No malicious code, no supply-chain compromise, no live secrets, no covert network egress.
Eight passes ran; all clean.

| Pass | Result |
|---|---|
| Supply chain (deps, lockfile, install hooks) | Clean. 11 top-level deps, 297 transitive, no postinstall, no typosquats, no custom registries. |
| Malicious-code patterns | Clean. No obfuscation, droppers, beacons, exfil, anti-analysis. |
| Secrets / credentials | Clean. Only the documented public Supabase anon key. No live keys. |
| Network egress | Clean. All destinations match the documented set (Anthropic, OpenAI, supabase, ngrok, HuggingFace, GitHub, Google). |
| Shell / command injection | Clean. All `Bun.spawn` array-form; one `execSync` with template uses a hardcoded list. |
| Web surfaces (pair-agent, extension) | Hardened. Dual-listener tunnel, `escapeHtml()`, extension locked to `127.0.0.1`. |
| CI workflows + git hooks | Clean. Vanilla GitHub Actions; secrets via context; hooks are `.sample` defaults. |
| Tracked binaries | None present in working copy (gitignored). |

Positive signals worth preserving: SSRF metadata-endpoint blocklist, prompt-injection classifier ensemble, surface-based command allowlist on the tunnel listener, `shellEscape()` at the one dynamic command site.

---

## 2. Fork-governance items (from audit — must decide)

These are not vulns; they are conscious fork-owner choices.

- [ ] **Telemetry endpoint.** `supabase/config.sh:7-8` points at upstream gstack's Supabase. Pick one:
  - [ ] **Recommended for Nuvance internal tool:** strip telemetry. Empty URL+key, delete `supabase/migrations/` and `supabase/functions/`, remove telemetry call sites.
  - [ ] OR repoint at a Nuvance-owned Supabase project, redeploy migrations from `supabase/migrations/*.sql`.
  - [ ] OR (not recommended) leave upstream-pointed — usage data flows to Garry.
- [ ] **Team-mode auto-update trust root.** `./setup --team` registers a SessionStart hook that `git pull && setup` every Claude Code session. For Nuvance:
  - [ ] If keeping auto-update: point `git remote origin` at a Nuvance-controlled repo, treat write access as privileged, enable branch protection.
  - [ ] If not: just don't pass `--team`. Default install doesn't register the hook.
- [ ] **Lockfile-fallback hardening (optional).** Drop the `|| bun install` fallback at `setup:239` so a corrupt lockfile fails loudly instead of silently re-resolving. One-line edit.

---

## 3. Digestion plan — turning gstack into Nuvance tools

The repo has four kinds of surface. Decide what each becomes for Nuvance.

### Skills (`*/SKILL.md` and `SKILL.md.tmpl`)

There are ~50 skill dirs at repo root. Quick inventory:

- **Workflow:** `ship`, `review`, `land-and-deploy`, `qa`, `qa-only`, `investigate`, `retro`, `document-release`
- **Planning:** `plan-ceo-review`, `plan-design-review`, `plan-eng-review`, `plan-devex-review`, `plan-tune`, `autoplan`
- **Design:** `design-consultation`, `design-shotgun`, `design-review`, `design-html`
- **Codex / multi-AI:** `codex`, `office-hours`, `careful`, `freeze`, `unfreeze`
- **Browser / extension:** `browse`, `extension`, `open-gstack-browser`, `connect-chrome`, `pair-agent`, `setup-browser-cookies`, `scrape`
- **CSO / security:** `cso`, `health`, `guard`, `canary`, `benchmark`
- **Infra / setup:** `setup-deploy`, `setup-gbrain`, `sync-gbrain`, `gstack-upgrade`, `learn`, `skillify`
- **Misc:** `agents`, `claude`, `context-save`, `context-restore`, `landing-report`, `model-overlays`

Per skill: **keep / fork-and-rebrand / strip**.

- [ ] Walk the list. For each skill, decide one of the three. Default to **strip** unless there's a clear Nuvance use case — fewer skills = less surface to maintain.
- [ ] For each "fork-and-rebrand" skill: rewrite the `SKILL.md.tmpl`, run `bun run gen:skill-docs`, replace Garry-voice content (CHANGELOG examples, ETHOS.md references, "Garry's stack" branding).
- [ ] Audit `ETHOS.md` — this is Garry's personal builder philosophy and is gated in `CLAUDE.md` against external edits. Either delete it or replace with Nuvance's own ethos doc.

### CLIs (`browse/`, `design/`, `make-pdf/`)

- [ ] **`browse/`** — headless-browser CLI. Largest subsystem (~30 MB). Keep if Nuvance tools need browser automation; strip otherwise. The dual-listener pair-agent + prompt-injection classifier ensemble are real engineering value if kept.
- [ ] **`design/`** — GPT Image API CLI. Keep if doing image gen; strip otherwise.
- [ ] **`make-pdf/`** — PDF export. Keep if relevant.
- [ ] If you keep all three, `package.json` is fine as-is. If you strip any, also remove their `dist/` references in `package.json`'s `bin` and `build` scripts.

### Chrome extension (`extension/`)

- [ ] Decide if Nuvance needs an in-browser sidebar. If no, delete `extension/` and remove related code paths in `browse/src/server.ts`.
- [ ] If yes: rebrand `manifest.json` name + description + icons, audit `popup.html` / `sidepanel.html` for upstream branding.

### Documentation (`README.md`, `CHANGELOG.md`, `ARCHITECTURE.md`, `CLAUDE.md`)

- [ ] Rewrite `README.md` — currently markets upstream gstack to YC founders.
- [ ] `CHANGELOG.md` is 578KB of upstream history. Decide: truncate to "Nuvance fork starts here," keep for reference, or archive separately.
- [ ] `CLAUDE.md` is heavily upstream-specific (CHANGELOG style guide for Garry's release voice, community PR guardrails referencing Garry, etc.). Rewrite the Nuvance-relevant parts; delete the rest.
- [ ] `ARCHITECTURE.md`, `BROWSER.md`, `ETHOS.md`, `CONTRIBUTING.md` — same audit.

### CI / build

- [ ] `.github/workflows/` — currently runs paid Anthropic + OpenAI + Gemini evals on every PR. For a small Nuvance fork these are likely overkill. Strip what doesn't apply; keep `version-gate.yml` and `actionlint.yml` as cheap correctness gates.
- [ ] `.gitlab-ci.yml` — only matters if Nuvance mirrors to GitLab.
- [ ] `gstack-upgrade/migrations/` — these are upstream version-state migrations. Probably safe to delete after forking; if you renumber Nuvance versions from 1.0.0.0, the migrations become inert.

---

## 4. Suggested execution order

1. [ ] **Lock the fork.** `git remote set-url origin <nuvance-repo>` so accidental pushes can't go upstream.
2. [ ] **Handle the three governance items** in §2 (telemetry, team-mode, lockfile).
3. [ ] **Skill triage.** Walk the ~50 skills, mark each keep/rebrand/strip. Delete the strip-list dirs first — fastest reduction in surface.
4. [ ] **CLI triage.** Decide browse / design / make-pdf. Strip what you don't need.
5. [ ] **Extension decision.** Keep or delete `extension/`.
6. [ ] **Rebrand pass.** README, CHANGELOG, CLAUDE.md, ETHOS.md, manifest.json, package.json name + description.
7. [ ] **Regen + test.** `bun install && bun run build && bun test`. Confirm the trimmed tree still passes free tests.
8. [ ] **Re-audit.** Re-run a quick Hinokane pass against the Nuvance fork once the changes settle, focused on (a) anything Nuvance added, (b) any net-new network destinations, (c) any new secrets handling. The upstream baseline is clean; only your additions need fresh eyes.
9. [ ] **Delete `.hinokane/`** if you don't want the audit artifacts in your fork's history. (Or keep — they're a useful baseline.)

---

## 5. Quick reference

- Audit report: `.hinokane/report.md`
- Per-class findings: `.hinokane/findings/`
- Pre-recon (what this codebase is): `.hinokane/pre-recon.md`
- Intake (scope statement): `.hinokane/intake.md`
