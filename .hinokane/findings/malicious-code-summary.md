> Produced with Hinokane v0.2.0 on 2026-05-13.

# Malicious code pattern scan — summary

## Verdict

**Clean.** No evidence of backdoor, dropper, beacon, or obfuscated payload.

## Per-class results

| Class | Result |
|---|---|
| Obfuscation / encoded payloads | None. One vendored minified file at `design/design-html/vendor/pretext.js` — a documented third-party library, not source. |
| Dynamic execution (eval / new Function / vm.run / dynamic import) | All `import()` calls use compile-time constant paths (e.g., `scripts/gen-llms-txt.ts:99`). No eval-of-network-data. |
| Droppers / persistence | No `chmod +x` followed by exec of a fetched binary. No launchd/systemd/cron/autostart writes. No `~/.bashrc` / `~/.zshrc` / `~/.profile` modification outside the user-consented `./setup` flow. |
| Network beacons | All outbound destinations match the documented set (Anthropic, OpenAI, supabase telemetry, ngrok, HuggingFace, GitHub, Google generativelanguage). No suspicious TLDs (`.tk`, `.xyz`, etc.). No hardcoded non-localhost IPs in production code. |
| Credential exfiltration | No code reads `~/.ssh/`, `~/.aws/`, `~/.config/gcloud/`, system keychains. References to those paths are blocklist entries in URL validation or test fixtures. |
| Anti-analysis / sandbox detection | None. |
| Foreign binaries in tree | None (ELF / Mach-O / PE). `*/dist/` directories are gitignored and absent in this working copy. |

## Defensive code observed (positive signals)

The codebase shows deliberate security engineering, not just absence of malice:
- `browse/src/url-validation.ts` — blocklist for cloud metadata IP (`169.254.169.254`) as an SSRF defense.
- `browse/src/security-classifier.ts` — TestSavantAI ONNX + Claude Haiku transcript classifier ensemble for prompt-injection detection.
- `browse/src/server.ts` — documented dual-listener tunnel architecture with surface-based command allowlisting.
- `scripts/host-config-export.ts:73` — `shellEscape()` used at the one site where a dynamic command name is interpolated.
- Extension manifest `host_permissions` locked to `127.0.0.1` only — the extension cannot phone home anywhere else.
- `extension/sidepanel.js:232` — `escapeHtml()` explicitly escapes `&<>"'` with a code comment explaining why DOM text-node serialization isn't sufficient.

## Operator note for forking

No remediation required. When auditing your Nuvance-specific additions, re-run the same passes — the upstream codebase establishes a clean baseline that your fork should preserve.
