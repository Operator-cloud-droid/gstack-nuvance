# Omoikane — fork decisions (resolved)

Working doc for the Nuvance fork of gstack. All triage decisions made on
2026-05-13 are captured below.

**Naming scheme:** see `PANTHEON.md`.
**Audit baseline:** see `.hinokane/report.md`.

---

## Decisions

### Skills, CLIs, extension — KEEP ALL

The default "strip unused surface" approach was rejected. Nuvance handles
maintenance via scheduled routines, so unused-but-present surface is cheap.
All ~50 upstream skills, all 3 CLIs (`browse`, `design`, `make-pdf`), the
Chrome extension, and all supporting subdirs (`agents/`, `contrib/`, `docs/`,
`openclaw/`, `browser-skills/`, `hosts/`, `lib/`, `bin/`, `scripts/`, `test/`)
all survive into the Omoikane fork.

Future per-skill cleanup happens via routines, not a manual triage pass.

### Naming — kami-name-per-tool

See `PANTHEON.md`. Summary:

- **Omoikane** is the umbrella brand. Generic utilities live under `omoikane-*`.
- **Hinokane** is the security audit (existing, unchanged).
- **Yatagarasu** is the gbrain replacement (semantic search / agent memory).
- Workflow skills with neutral names (`ship`, `qa`, `review`, `investigate`,
  `retro`, `plan-*`, `design-*`, etc.) keep their names — no forced rebrand.

### gbrain — fork as Yatagarasu (separate workstream)

Nuvance will fork the external `gbrain` CLI (`github.com/garrytan/gbrain`)
into its own Nuvance-owned repo, rebrand the binary + commands + env vars as
**Yatagarasu**, and publish under the `Operator-cloud-droid` org.

Until the external CLI fork lands, the in-repo wrappers (`setup-yatagarasu`,
`sync-yatagarasu`) will continue invoking the upstream `gbrain` binary. The
in-repo skill rename can happen now; the external CLI work is a parallel
workstream tracked separately.

### Governance hardening — DONE

Per `.hinokane/report.md` Notes 1–3:

| Note | Action | Status |
|---|---|---|
| 1. Telemetry endpoint | Stripped. `supabase/config.sh` URL+key emptied; migrations/functions/verify-rls deleted. | ✅ commit `9e95736` |
| 2. Team-mode auto-update | Repointed `bin/gstack-update-check` to Nuvance repo. Default install still doesn't register the SessionStart hook. | ✅ commit `9e95736` |
| 3. Lockfile fallback | Removed. `setup` now fails loudly on corrupt lockfile. | ✅ commit `9e95736` |

### Branded content — replace, don't strip

Files that are content (not tools) get Nuvance equivalents rather than deletion:

- `ETHOS.md` — replaced with Nuvance ethos or an empty placeholder. The upstream
  doc is gated against external edits per upstream CLAUDE.md.
- `TODOS.md` — cleared or replaced with a Nuvance roadmap stub. 107KB of upstream
  roadmap items is noise for Nuvance.
- `README.md` — rewritten. Currently markets upstream gstack to YC founders.
- `CHANGELOG.md` — fresh entry "v1.0.0.0 — Forked from gstack 1.33.2.0".
  Upstream history archived to `CHANGELOG-upstream.md`.
- `CLAUDE.md` — rewritten. Strip Garry-voice CHANGELOG style guide and
  community-PR guardrails referencing Garry. Keep Nuvance-relevant pieces.
- `ARCHITECTURE.md`, `BROWSER.md`, `CONTRIBUTING.md`, `AGENTS.md`, `DESIGN.md`,
  `USING_GBRAIN_WITH_GSTACK.md` — voice-rebrand pass.

---

## Execution order (resolved)

Tracked in the live task list. Commits land in order, each one is independently
revertable, none of them touch the workflow skills' actual behavior:

1. ✅ `omoikane: governance hardening` — telemetry, update-check, lockfile (commit `9e95736`)
2. Planning artifacts: `OMOIKANE-TRIAGE.md`, `PANTHEON.md`
3. `package.json` + `VERSION` rebrand
4. `bin/gstack-*` → `bin/omoikane-*` rename
5. `gstack/` dir → `omoikane/` dir; `open-gstack-browser` → `open-omoikane-browser`;
   `gstack-upgrade` skill → `omoikane-upgrade`
6. `setup-gbrain` → `setup-yatagarasu`; `sync-gbrain` → `sync-yatagarasu`;
   `USING_GBRAIN_*` → `USING_YATAGARASU_*`. In-repo wrapper only.
7. Branded content swap (`ETHOS.md`, `TODOS.md`)
8. `README.md` rewrite
9. `CHANGELOG.md` reset + upstream archive
10. `CLAUDE.md` rewrite
11. Extension manifest + branding
12. `ARCHITECTURE.md` + technical docs voice pass
13. Regen + test
14. Re-audit Nuvance-specific changes

---

## Out-of-scope (deferred)

- The external `gbrain` CLI fork → Yatagarasu CLI. Lives in a separate Nuvance-owned
  repo, not this one. Tracked as task #16.
- Routine maintenance configuration. User said: "the maintenance is something
  I will automatically set up via routines, don't worry about it."
