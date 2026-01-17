# Critical Rules for Claude Code

- Never hardcode design values (colors, fonts, spacing) during Phase 1. Use placeholder tokens or system defaults.
- Never edit bundled JSON directly for content changes. Update the source in `i-heart-katakana-data` repo.
- Never commit API keys or sensitive credentials. Use environment variables.
