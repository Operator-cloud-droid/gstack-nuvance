# Changelog

All notable Nuvance-side changes to Omoikane will be documented in this file.

The upstream `gstack` release history (versions 0.x through 1.33.2.0) is
preserved in [`CHANGELOG-upstream-gstack.md`](CHANGELOG-upstream-gstack.md) for
reference. Entries below cover only changes made after the fork.

The format roughly follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
with the upstream's four-segment version scheme (`MAJOR.MINOR.PATCH.MICRO`).

---

## [1.0.0.0] — 2026-05-13

**Forked from `garrytan/gstack` at v1.33.2.0 as Omoikane, Nuvance's internal AI
engineering toolkit.**

The Nuvance fork takes the upstream technical engineering verbatim — every
skill, every CLI, the Chrome extension, the security classifier ensemble, the
dual-listener pair-agent architecture — and rebrands it as Omoikane under a
kami-name-per-tool scheme. No skill behavior changes. No new features. No
removals. The cut between upstream gstack v1.33.2.0 and Omoikane v1.0.0.0 is
identity, not capability.

### Brand changes

- **Project renamed** `gstack` → `omoikane`. `package.json` name, description,
  and keywords updated. VERSION reset to 1.0.0.0 to mark the fork boundary.
- **Naming scheme established** in `PANTHEON.md`: Omoikane (思兼, wisdom) as the
  umbrella; Hinokane (火兼, fire) for security audit (existing); Yatagarasu (八咫烏,
  guide crow) for the gbrain replacement (planned). Workflow skills with neutral
  names (`/ship`, `/qa`, `/review`, etc.) keep their names.
- **Skill rename** `open-gstack-browser` → `open-omoikane-browser`, with 26
  reference updates across templates, code, and docs.
- **README.md** rewritten from upstream's YC-founder pitch (~40 KB) to a clean
  Nuvance fork README (~5 KB) cataloging what's in the toolkit and how to install.
- **ETHOS.md** replaced. The upstream doc captured Garry Tan's personal builder
  philosophy and was gated against external edits per upstream's own CLAUDE.md.
  Nuvance starter ethos carries forward the universally-true AI-assisted
  engineering principles (boil the lake, search before building, root cause,
  reversible defaults, honesty over performance) and flags itself as scaffolding
  to be replaced as Nuvance's voice forms.
- **TODOS.md** replaced. Upstream was ~107 KB of personal roadmap; Nuvance
  version is a blank slate tracking only fork-relevant work.
- **CHANGELOG.md** reset. Upstream history archived to
  `CHANGELOG-upstream-gstack.md`.

### Governance hardening

Per `.hinokane/report.md` adoption notes:

- **Telemetry stripped.** `supabase/config.sh` URL and anon key emptied; the
  four `bin/gstack-*` telemetry scripts short-circuit at their existing
  "no Supabase URL configured" guard. `supabase/migrations/`,
  `supabase/functions/`, and `supabase/verify-rls.sh` deleted as deploy-time
  artifacts with no runtime references.
- **Update-check repointed.** `bin/gstack-update-check` now polls VERSION from
  `Operator-cloud-droid/gstack-nuvance` instead of `garrytan/gstack`. Prevents
  spurious upgrade prompts for upstream releases that don't apply.
- **Lockfile fallback removed.** `setup` no longer falls back to plain
  `bun install` when `--frozen-lockfile` fails. Corrupt lockfiles error loudly.

### Deferred to follow-up work

- `bin/gstack-*` → `bin/omoikane-*` mass rename (~4600 references across 125
  files). Deferred until the local environment has `bun` installed and the test
  suite can validate the rename.
- `gstack/` and `gstack-upgrade/` directory renames. Same reason.
- `setup-gbrain` and `sync-gbrain` skill renames to `setup-yatagarasu` and
  `sync-yatagarasu`. Same reason.
- External workstream: fork `github.com/garrytan/gbrain` into a Nuvance-owned
  **Yatagarasu** CLI with rebranded binary name, command surface, env vars,
  and MCP server name. The in-repo wrappers continue to invoke the upstream
  `gbrain` binary until the external fork lands.

### Audit baseline

The upstream codebase was security-audited prior to the fork (5-phase white-box
sweep over the malicious-code / supply-chain vetting subset of Hinokane v0.2.0).
Verdict: safe to fork. No vulnerabilities, no covert egress, no live secrets.
Three governance items (above) handled. Full report at `.hinokane/report.md`.

---

*Upstream release history is in [`CHANGELOG-upstream-gstack.md`](CHANGELOG-upstream-gstack.md).*
