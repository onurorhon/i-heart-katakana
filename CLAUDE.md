# Critical Rules for Claude Code

- Never hardcode design values (colors, fonts, spacing) during Phase 1. Use placeholder tokens or system defaults.
- For content changes, update `data/words.json` via the curation scripts in `scripts/`.
- Never commit API keys or sensitive credentials. Use environment variables.

<!-- CODESTORY-START -->
## CodeStory: Auto-Tracking & Trigger

### Live Session Tracking

While working on this project, automatically log notable moments to `.social-draft-Onur.md`:

**What to capture:**
- Technical wins (clever solutions, performance improvements, clean refactors)
- Progress milestones (features completed, bugs squashed, tests passing)
- Lessons learned (debugging adventures, "aha" moments, things that surprised you)
- Interesting decisions (architecture choices, tradeoffs you made, why you picked one approach over another)
- Frustrations turned victories (that bug that took forever, the docs that were wrong)

**Log format:**
```
## Session: {DATE}

{TIME} - Brief note about what just happened
- Include relevant code snippets or commands when they add context
- Keep it casual and authentic
- Write like you are telling a friend about your day
```

**Example entry:**
```
## Session: 2024-01-15

2:34 PM - Finally figured out why the auth was failing. Turns out the token was being URL-encoded twice. Classic.

3:15 PM - Refactored the entire validation layer. Went from 400 lines to 120. Sometimes less really is more.

4:02 PM - Added rate limiting. Used a sliding window approach instead of fixed buckets. Feels cleaner.
```

### Trigger Word

When the user says "CodeStory" in conversation (e.g., "run CodeStory", "let's do CodeStory", "time for CodeStory"), run the `/CodeStory` skill to generate social media content.
<!-- CODESTORY-END -->
