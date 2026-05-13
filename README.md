# Omoikane

> *Omoikane* (思兼) — the kami of wisdom and deliberation. Born from the foreheads
> of the high deities to ponder problems too hard for any single mind.

Nuvance's AI engineering toolkit. Claude Code skills, a fast headless browser,
image generation, and a PDF tool — installed by one command.

Forked from [`garrytan/gstack`](https://github.com/garrytan/gstack) at v1.33.2.0
and rebranded for Nuvance internal use. See `PANTHEON.md` for the kami naming
scheme, and `.hinokane/report.md` for the upstream security audit baseline.

---

## What's in it

**Workflow skills.** Slash commands that turn Claude Code into a multi-perspective
engineering team:

| Skill | What it does |
|---|---|
| `/ship` | Detect base branch → test → review diff → bump VERSION → update CHANGELOG → commit → push → PR |
| `/review` | Pre-landing PR review (SQL safety, LLM trust boundaries, side effects) |
| `/qa` and `/qa-only` | Systematically QA-test a web app via the headless browser; fix bugs found (or report-only) |
| `/investigate` | Four-phase root-cause debugging. No fixes without a root cause |
| `/retro` | Weekly retrospective from commit history |
| `/learn` | Manage learnings across sessions (search, prune, export) |
| `/document-release` | Post-ship doc updates across README / ARCHITECTURE / CLAUDE.md |
| `/health` | Code-quality dashboard (type/lint/test/dead-code → 0–10 score) |
| `/context-save` and `/context-restore` | Persist and resume working context across sessions |

**Plan reviews.** Multi-perspective critique before you build:

| Skill | Perspective |
|---|---|
| `/plan-ceo-review` | Founder mode: rethink the problem, expand scope, aim for the 10-star product |
| `/plan-eng-review` | Eng manager mode: architecture, data flow, edge cases, performance |
| `/plan-design-review` | Designer's eye: 0–10 per dimension, fixes the plan |
| `/office-hours` | YC office-hours forcing questions + builder brainstorm |

**Design tools.** `/design-consultation`, `/design-shotgun`, `/design-review`,
`/design-html`. Build a design system, explore variants, audit visual quality,
generate production-quality HTML/CSS.

**Multi-AI consultation.** `/codex` (OpenAI Codex CLI wrapper) and `/claude`
(for non-Claude hosts). Adversarial reviews, second opinions, three modes each
(review, challenge, consult).

**Safety.** `/careful` (warns before destructive ops), `/freeze` (lock edits to
one directory), `/guard` (both), `/unfreeze`.

**Security.** `/cso` (aka Hinokane) — five-phase white-box security audit over
16 vulnerability classes. Artifacts land in `.hinokane/`.

**Standalone CLIs**:

- **`browse/`** — headless browser CLI (Playwright wrapper, persistent daemon,
  dual-listener tunnel architecture for pair-agent, in-process prompt-injection
  classifier ensemble). Used by `/qa`, `/scrape`, `/canary`, `/benchmark`, and
  the open-omoikane-browser launcher.
- **`design/`** — GPT Image API CLI for image generation.
- **`make-pdf/`** — markdown → publication-quality PDF.

**Chrome extension.** Side-panel UI with a live terminal (Claude PTY), activity
feed, and CSS inspector. Launched via `/open-omoikane-browser`.

---

## Install

```bash
git clone https://github.com/Operator-cloud-droid/gstack-nuvance.git
cd gstack-nuvance
./setup
```

The setup script builds the CLI binaries from source, symlinks skills into your
Claude Code config, and walks you through any one-time configuration.

**Team mode** (auto-update on session start) is opt-in:

```bash
./setup --team
```

Be aware that team mode treats your `git remote origin` as a trust root — whoever
has write access to that repo can ship code to every Omoikane developer's machine
on the next Claude Code session. See `.hinokane/report.md` Note 2 for the full
discussion.

---

## Architecture

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — system overview
- [`BROWSER.md`](BROWSER.md) — headless browser internals
- [`PANTHEON.md`](PANTHEON.md) — kami naming scheme
- [`docs/designs/`](docs/designs/) — design documents
- [`.hinokane/report.md`](.hinokane/report.md) — upstream security audit baseline

---

## Contributing

Internal contributors: see [`CONTRIBUTING.md`](CONTRIBUTING.md).

This is a Nuvance internal fork. External PRs aren't accepted here — upstream
the change to `garrytan/gstack` instead if it's broadly useful, or fork further.

---

## License

MIT, carried forward from upstream. See [`LICENSE`](LICENSE).

---

## Acknowledgements

Forked from `garrytan/gstack` by Garry Tan and contributors. Omoikane preserves
the upstream technical engineering and replaces the upstream branding, voice,
and personal philosophy with Nuvance's own. The kami naming scheme (Hinokane,
Yatagarasu, etc.) is Nuvance-specific; the rest of the architecture is upstream's
work.
