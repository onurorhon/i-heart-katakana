# Project Rules & Conventions

## Never

- **Never hardcode design values in Phase 1** – Use system defaults or placeholder tokens
- **Never include AI disclaimers in commits** – No "Co-Authored-By: Claude", "Generated with Claude Code", or 🤖 messages
- **Never commit credentials** – API keys, tokens go in environment variables
- **Never edit bundled JSON for content updates** – Update source repo instead
- **Never skip Xcode Preview testing** – Verify changes render correctly

## Always

- **Always use SwiftUI standard components** – Until Phase 2 design application
- **Always test on simulator and device** – Check both before committing
- **Always commit with descriptive messages** – No "fix" or "update" without context
- **Always update ARCHITECTURE.md** – When patterns or components change

## Documentation Boundaries

**ARCHITECTURE.md** contains:
- Technical decisions and rationale.
- Data schemas and structures.
- Component patterns and data flow.
- Forward-looking roadmap (what's next).

**ARCHITECTURE.md must NOT contain:**
- Specific counts or statistics from script runs.
- Progress checkmarks or completion status.
- Session outputs or historical reports.

**OVERVIEW.md** may contain:
- Aspirational targets (e.g., "1,000+ items", "~20 fonts").
- Scope estimates (e.g., "Phase 1 (~80%)").
- Success criteria with specific goals.

These are product requirements, not statistics from actual runs.

**General principle:** Documentation describes *what the system is* and *what we're building toward*, not *how we got here*.

## Responsive Layout

- Design for portrait orientation first.
- Constrain content to readable width on larger screens (don't stretch edge-to-edge).
- Use SwiftUI's adaptive layout (`.frame(maxWidth:)`, `ViewThatFits`, etc.).
- Test on both iPhone and iPad simulators.

## Conventions

*This section will expand as patterns emerge during development.*

### File Organization

```
IHeartKatakana/
├── App/
│   └── IHeartKatakanaApp.swift
├── Models/
│   ├── Word.swift
│   ├── Theme.swift
│   └── AppFont.swift
├── Views/
│   └── [views as created]
├── Services/
│   ├── ContentService.swift
│   └── TTSService.swift
└── Resources/
    └── words.json (bundled fallback)
```

### Naming

- Views: `[Name]View.swift` (e.g., `PracticeView.swift`)
- Models: `[Name].swift` (e.g., `Word.swift`)
- Services: `[Name]Service.swift` (e.g., `ContentService.swift`)
