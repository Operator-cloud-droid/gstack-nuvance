# TODOS

Roadmap and tracked work for Omoikane (Nuvance's fork of gstack).

> *Nuvance fork note: the upstream gstack TODOS was ~107 KB of Garry Tan's
> personal roadmap. That has been archived (see git history for the pre-fork
> contents). This file is Nuvance's blank slate.*

---

## In progress

- **Omoikane rebrand pass** — see `OMOIKANE-TRIAGE.md` for the full execution
  plan and `PANTHEON.md` for the kami naming scheme.

## Deferred (need bun + test suite)

- `bin/gstack-*` → `bin/omoikane-*` mass rename (~4600 references across 125 files).
- `gstack-upgrade/` → `omoikane-upgrade/` directory rename (89 reference files).
- `gstack/` → `omoikane/` directory rename (3 actual repo refs; rest are
  `~/.gstack` runtime home-dir references that need a separate migration).
- `setup-gbrain/` + `sync-gbrain/` → `setup-yatagarasu/` + `sync-yatagarasu/`
  in-repo wrapper rename.

## External workstreams

- Fork `github.com/garrytan/gbrain` → Nuvance-owned **Yatagarasu** CLI. Rebrand
  binary name, command surface, env vars (`GBRAIN_*` → `YATAGARASU_*`), MCP
  server name. Then update Omoikane's in-repo wrapper skills to invoke the new
  CLI. See `PANTHEON.md` for the rationale.

## Backlog

(Empty. Add items as they come up.)
