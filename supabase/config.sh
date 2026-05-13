#!/usr/bin/env bash
# Telemetry endpoint config.
#
# Nuvance fork (Omoikane) ships with telemetry stripped. The URL and key are
# intentionally blank so `bin/gstack-telemetry-sync` and the dashboard scripts
# exit silently (they short-circuit when SUPABASE_URL is empty).
#
# To re-enable analytics, point these at a Nuvance-owned Supabase project and
# redeploy schema from a fresh `supabase/migrations/` (the upstream migrations
# were removed when telemetry was stripped — see git history if you want them
# back).

GSTACK_SUPABASE_URL=""
GSTACK_SUPABASE_ANON_KEY=""
