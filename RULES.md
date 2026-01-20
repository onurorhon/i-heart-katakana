# Project Rules & Conventions

## Never

- **Never hardcode design values in Phase 1** – Use system defaults or placeholder tokens
- **Never commit credentials** – API keys, tokens go in environment variables
- **Never edit bundled JSON for content updates** – Update source repo instead
- **Never skip Xcode Preview testing** – Verify changes render correctly
- **Never include "Generated with Claude Code" or similar AI disclaimers** – Keep commit messages clean. No 🤖 Generated with messages.

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
- Script usage instructions (those go in the `i-heart-katakana-data` repo).

**General principle:** Documentation describes *what the system is*, not *how we got here*.

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
