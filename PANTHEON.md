# The Omoikane Pantheon

Naming scheme for Nuvance's fork of gstack. Tools with distinct character get
their own kami name; generic utilities live under the `omoikane-` umbrella prefix.

## The umbrella

**Omoikane** (思兼) — kami of wisdom and deliberation. Born from the foreheads
of the high deities to ponder problems too hard for any single mind. The umbrella
brand for the Nuvance AI engineering toolkit.

> "When the gods could not agree, they called Omoikane to think it through."

`Omoikane` covers the project as a whole. Anything that's a generic utility under
the umbrella keeps the `omoikane-` prefix (e.g. `omoikane-config`, `omoikane-upgrade`,
`omoikane-slug`). Only specialized tools with their own distinct purpose graduate
to their own kami name.

## Named kami (one per specialized tool)

| Kami | Domain | Replaces | What it does |
|---|---|---|---|
| **Hinokane** 火兼 | Fire / inspection / purification | (existing) `cso` / `hinokane` skill | Security audit. Five-phase white-box methodology over 16 vulnerability classes. The artifacts of an audit live in `.hinokane/`. |
| **Yatagarasu** 八咫烏 | The three-legged guide crow | `gbrain` (external CLI + wrappers) | Semantic search / persistent memory for AI agents. Yatagarasu was the divine crow that guided Emperor Jimmu through unknown territory; the brain guides agents through unknown code and past decisions. |

## How to choose a kami name for a new tool

1. Ask: does this tool have a single, distinct purpose that a single image captures?
   If yes, give it a kami. If it's just an admin utility, prefix it `omoikane-`.
2. Pick a kami whose domain semantically matches the tool's purpose. Avoid
   forcing fits — `omoikane-foo` is fine if no kami clicks.
3. One kami per tool. No reusing names across different tools.
4. Keep names pronounceable. Three or four syllables, no diacritics.

## Open positions

These tools have distinct character but haven't earned a kami yet. They may stay
under the `omoikane-` umbrella indefinitely, or receive a kami name if/when one
fits clearly:

- The `browse` headless-browser CLI — candidate kami: **Sarutahiko** (猿田彦),
  kami of crossroads and guidance. Browsing is crossroads work. Deferred until
  someone is in love with the pairing.
- The `pair-agent` tunnel — candidate kami: also Sarutahiko, since it bridges
  agents at a crossroads. Same deferral.
- The `design` GPT-image CLI — candidate kami: **Ame-no-Uzume** (天宇受売), goddess
  of dawn, dance, and revelry. She drew Amaterasu out of the cave with her dance —
  fitting for "drawing forth a design that didn't exist." Deferred.

When a Nuvance team member feels strongly about one of these, propose it in a PR
and update this doc.

## Why this scheme

- **Discoverability:** `omoikane-*` for utilities means `omoikane <tab>` in a shell
  completes a coherent toolset. Kami-named tools have distinct character and are
  worth remembering separately.
- **Identity:** Hinokane already lives in this repo (`.hinokane/` audit
  artifacts). The pattern is "kami name for tools with distinct purpose" — we
  formalize it rather than invent something new.
- **No artificial uniformity:** Renaming every skill to a kami name would obscure
  what each one does. `ship`, `qa`, `review`, `investigate` are good names. They
  stay.
