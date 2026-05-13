> Produced with Hinokane v0.2.0 on 2026-05-13.

# Network egress — summary

## Verdict

**Clean — all outbound destinations match the documented set.**

## Destinations enumerated

| Destination | Purpose | Sample citation |
|---|---|---|
| `api.anthropic.com` | Claude API (core feature) | sdk default — implicit via `@anthropic-ai/sdk` |
| `api.openai.com` | OpenAI image-gen + Codex | `design/src/check.ts:25` |
| `generativelanguage.googleapis.com` | Gemini | gemini skill |
| `huggingface.co` / `cdn-lfs.huggingface.co` | ONNX model fetch (testsavant/deberta) | `browse/src/security-classifier.ts` |
| `frugpmstpnojnhfyimgv.supabase.co` | **Opt-in telemetry** | `supabase/config.sh:7` |
| `*.ngrok.{com,app,-free.app}` | Pair-agent tunnel (opt-in) | `pair-agent/SKILL.md` |
| `api.github.com` / `github.com` | gh CLI | `bin/gstack-global-discover.ts` |
| `esm.sh` | supabase Edge Function modules | `supabase/functions/.../index.ts:5` |
| `bun.sh` | Install-time only | `.gitlab-ci.yml` |
| `playwright.azureedge.net` (transitive) | Chromium download at install time | playwright dep default |
| `127.0.0.1` / `localhost` | Pair-agent + extension | many |

## Hardcoded IPs

Two IP literals in production code (`browse/src/url-validation.ts`, `browse/src/meta-commands.ts:949`): `169.254.169.254` and `::ffff:169.254.169.254`. These are the AWS/GCP/Azure instance-metadata endpoints, used here as a **blocklist** in URL validation (defense against SSRF attempting to read cloud metadata from a hosted browse instance). Not a call destination. Safe.

## Telemetry is opt-in

Per `README.md` Privacy & Telemetry section and `supabase/verify-rls.sh`:
- Default state: off.
- User is prompted on first run.
- Public anon key is committed (correct shape for a Supabase project — equivalent to a Firebase public key).
- RLS policies enforce that direct-anon-key access cannot read or insert outside the documented ingest function.
- Payload is documented: skill name, duration, version, OS. No code, prompts, or paths.

When forking for Nuvance, you can either keep this telemetry pointed at the upstream supabase (which gives Garry usage data on your fork — probably not what you want), or repoint it at your own supabase project, or strip it out entirely. Three lines of change in `supabase/config.sh`.

## Operator note for forking

1. Replace the supabase URL + anon key in `supabase/config.sh:7` if you want telemetry to land in YOUR project, not upstream. (Or set it to empty to disable.)
2. The `frugpmstpnojnhfyimgv.supabase.co` URL is the upstream gstack project. There's nothing wrong with it being committed — the anon key is the public component, and RLS protects the data — but it's a data-residency choice you should make consciously.
