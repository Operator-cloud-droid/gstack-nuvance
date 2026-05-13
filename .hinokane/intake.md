> Produced with Hinokane v0.2.0 on 2026-05-13.

# Intake — gstack-nuvance malicious-code / supply-chain vetting

## Operator

- **Operator:** Garry / Nuvance (operations@nuvance-ait.co.za)
- **Authorization:** Operator owns the working copy at `/mnt/c/Users/selli/Downloads/Tools/G-stack/gstack-nuvance/`. The target is a downloaded folder the operator intends to fork and adapt to "Nuvance-specific itemized tools." Code-reading scope only — no live PoCs that mutate operator systems beyond the working copy.

## Target

- **Name:** gstack (upstream: garrytan/gstack — see `gstack/llms.txt`, `package.json`, etc.)
- **Working copy version:** 1.33.2.0 (`VERSION` at repo root).
- **Shape:** A multi-skill toolkit for Claude Code — primarily Markdown skill templates (`*/SKILL.md`), a Bun-compiled CLI (`browse/`, `design/`), a Chrome extension (`extension/`), an HTTP daemon with optional ngrok tunnel (`pair-agent/`), supabase migrations (`supabase/`), and contributor scripts (`scripts/`, `bin/`).
- **Stated upstream architecture:** Single-user developer tool. No multi-tenancy, no production user data. Telemetry to a supabase project (per `supabase/migrations/`).

## Scope of engagement

Scope here is **vetting for malicious code, backdoors, and supply-chain compromise** before the operator adapts the codebase. This is NOT a standard web-app pentest — there is no deployed Nuvance target yet.

### In scope

1. **Supply chain** — `package.json`, `bun.lock`, postinstall hooks, anything that fetches code at install/run time.
2. **Malicious-code patterns** — obfuscation, base64 droppers, eval-of-network-data, beacon callouts, encoded payloads.
3. **Hardcoded secrets** — credentials, API keys, private keys in tracked files. Brief `.git` history sample.
4. **Network egress** — every outbound network destination this code can reach, with judgement on whether each is benign.
5. **Shell-injection** — `bin/` scripts, `child_process.exec` / `spawn` patterns with potentially-tainted inputs.
6. **Web surfaces** — `pair-agent/` HTTP daemon (tunneled via ngrok), `extension/` Chrome extension. These are real attack surfaces.
7. **CI & git hooks** — `.github/workflows/`, `.gitlab-ci.yml`, `.git/hooks/`, any pre-commit config.
8. **Tracked binaries** — `browse/dist/`, `design/dist/`. Confirm they are what they claim to be.

### Out of scope (default-skip per `references/judgment.md`)

- XSS / CSRF / SSRF / IDOR / authn / authz / tenant-isolation / business-logic / race / file-upload / API rate-limit / IaC. Reason: no deployed multi-tenant web application in this engagement. The pair-agent and extension get a focused single-author web-surface pass (see scope item 6) rather than the full class sweep.
- Optional compliance regimes (SOC 2, ISO, HIPAA, PCI). Not requested.

### Exploitation discipline

- No live PoCs against any third-party. No outbound network calls from PoC code.
- Witness-form only: where a payload demonstrates a flaw, the payload is shown, not executed.
- The single exception is: running the supplied binaries' `--version` / `--help` is permitted to confirm they are not droppers.

## Pushback

None on scope as stated. The user's framing ("hiding nasty bugs or viruses") maps cleanly onto the in-scope list. I am narrowing the 16-class methodology because the conventional web classes don't fit a CLI/skill toolkit, and the user gets more value from a deep malware-vetting pass than a watery 16-class report. This narrowing is documented per `references/judgment.md` "When to skip a vulnerability class."
