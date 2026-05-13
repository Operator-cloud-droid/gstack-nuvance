> Produced with Hinokane v0.2.0 on 2026-05-13.

# Supply chain — summary

## Verdict

**Clean.** No supply-chain compromise indicators.

## Evidence

- `package.json` has **no** `preinstall` / `postinstall` / `prepare` lifecycle script.
- No `.npmrc` / `.bun` / custom-registry config files in the tree.
- All 11 top-level deps match exact official package names, official scopes, version pinned. No typosquat shapes.
- 297 unique packages in `bun.lock`; no `git+ssh://`, `file://`, `http://` sources; no postinstall declarations in transitive deps; no suspicious generic names (`install`, `fetch`, `loader`, etc.).
- Platform-specific binaries (`@ngrok/ngrok-*`, `@anthropic-ai/claude-agent-sdk-*`) all from official org scopes with SHA-512 integrity.
- `./setup` uses `bun install --frozen-lockfile` (rejects lockfile drift). Falls back to plain `bun install` only when frozen install fails — that fallback is the only point where lockfile drift would proceed silently, but it requires the lockfile to be unparseable, which is not a typical attack vector.
- No `curl | bash`, `wget | sh`, `bash <(curl ...)` patterns anywhere.
- No `sudo` in setup. No writes to system directories (`/usr/`, `/etc/`, `/opt/`). All state lives under `$HOME`.

## Operator note for forking

Conservative tightening to consider after forking:
1. Replace the `|| bun install` fallback at `setup:239` with a hard fail-on-frozen-lockfile-error. The current fallback is fine in practice but slightly weakens lockfile integrity if the lockfile is ever corrupted.
2. After your first `bun install`, commit `node_modules` to a private artifact registry or pin every dep to a hash via overrides. Optional, not required for the threat model the user described.

(Both are hardening, not vulnerability fixes. The current state is clean.)
