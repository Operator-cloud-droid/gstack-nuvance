> Produced with Hinokane v0.2.0 on 2026-05-13.

# Secrets — summary

## Verdict

**Clean.** No live secrets in source or recent history. Two known checked-in values are documented public keys.

## Live secrets

None.

## Public values intentionally committed

`supabase/config.sh:7-8`:

```
GSTACK_SUPABASE_URL="https://frugpmstpnojnhfyimgv.supabase.co"
GSTACK_SUPABASE_ANON_KEY="sb_publishable_tR4i6...K"   (redacted)
```

This is a Supabase **publishable / anon** key — by design, public-side. The file header documents this. RLS policies in `supabase/migrations/*.sql` deny all anonymous reads/writes; ingest happens through edge functions that use the **service-role** key server-side (never in this tree). `supabase/verify-rls.sh:14-17` is a smoke test that confirms the anon key cannot read/update directly. Equivalent in shape to a Firebase Web API key — safe to commit, **but** when forking, point this at your own Supabase project unless you want telemetry to land in upstream Garry's project.

## Placeholders

`.env.example:5`:

```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Obvious placeholder, no live key.

## Test fixtures (fake keys for scanner validation)

`test/brain-sync.test.ts:288-295` contains intentionally-fake AWS / GitHub / OpenAI / JWT shapes (`AKIAABCDEFGHIJKLMNOP`, `ghp_abcdefghij...`) — low-entropy alphabetical sequences that would never be valid live keys. Test code only.

## Git history sample

Spot-checked recent commits with `git log -p` filtered to env / secret / credential paths. No removed-after-commit secrets observed.

## Operator note for forking

1. Replace `GSTACK_SUPABASE_URL` + `GSTACK_SUPABASE_ANON_KEY` in `supabase/config.sh` (and the migrations folder if you want to redeploy schema) with your own project's values, or strip telemetry entirely if you don't need it.
2. Keep `.env.example` as-is; populate `.env` locally and never commit it.
3. Consider running `git-secrets` or `trufflehog` on the full upstream history if you plan to mirror the whole git history into a public Nuvance repo. Spot-check did not show issues, but a full sweep is cheap and definitive.
