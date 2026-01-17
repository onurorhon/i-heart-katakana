# Project Rules & Conventions

## Never

- **Never hardcode design values in Phase 1** – Use system defaults or placeholder tokens
- **Never commit credentials** – API keys, tokens go in environment variables
- **Never edit bundled JSON for content updates** – Update source repo instead
- **Never skip Xcode Preview testing** – Verify changes render correctly
- **Never add co-authored-by messages** – Keep commit messages clean

## Always

- **Always use SwiftUI standard components** – Until Phase 2 design application
- **Always test on simulator and device** – Check both before committing
- **Always commit with descriptive messages** – No "fix" or "update" without context
- **Always update ARCHITECTURE.md** – When patterns or components change

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

- Views: `[Name]View.swift` (e.g., `QuizView.swift`)
- Models: `[Name].swift` (e.g., `Word.swift`)
- Services: `[Name]Service.swift` (e.g., `ContentService.swift`)
