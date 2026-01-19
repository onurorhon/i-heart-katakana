# Critical Rules for Claude Code

- Never hardcode design values (colors, fonts, spacing) during Phase 1. Use placeholder tokens or system defaults.
- For content changes, update `data/words.json` via the curation scripts in `scripts/`.
- Never commit API keys or sensitive credentials. Use environment variables.
