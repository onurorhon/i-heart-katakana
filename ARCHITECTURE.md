# Architecture & Technical Decisions

## Tech Stack

- **SwiftUI** – Native iOS framework
- **SwiftData** – User data persistence with iCloud sync
- **AVSpeechSynthesizer** – On-device TTS for pronunciation
- **TelemetryDeck** – Privacy-focused analytics

## Technical Decisions

| Area | Decision |
|------|----------|
| Framework | SwiftUI (native) |
| Minimum iOS | iOS 18 |
| Content storage | Remote JSON (public GitHub repo: `i-heart-katakana-data`) with bundled fallback |
| Content source | JMdict (open-source), extracted and curated |
| User data storage | SwiftData with iCloud sync |
| Audio | On-device TTS (AVSpeechSynthesizer) |
| Analytics | TelemetryDeck (free tier) |
| Accessibility | SwiftUI defaults + light intentional pass |
| Development environment | Cursor + Claude Code + Xcode |

## Development Approach

### Phase 1: Functional Prototype (~80%)

Build core functionality using SwiftUI defaults. No custom styling – generic iOS appearance. Focus on architecture and behavior.

**In scope:**
- Core quiz flow (display word, reveal answer, navigate).
- Likes (save, filter, iCloud sync).
- Theme system architecture (switching, persistence) – placeholder values.
- Font system architecture (loading, switching) – system font initially.
- Categories and filtering.
- TTS playback.
- Remote JSON fetching with bundled fallback.
- Analytics integration (TelemetryDeck).

**Approach:**
- Vibe code with Claude Code in Cursor.
- Iterate using Xcode Previews and on-device testing.
- Commit frequently via Git.

### Phase 2: Design Application (~20%)

Layer design on top of the working prototype.

**In scope:**
- Final UI design (layout, spacing, visual hierarchy).
- Actual theme values (colors, backgrounds).
- Actual font selection and pairing.
- Polish, animations, micro-interactions.
- Figma integration via MCP if needed.

**Approach:**
- Design tokens for colors, spacing, typography.
- Custom ViewModifiers for consistent styling.
- Swap placeholder values for final design values.

## Data Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Remote (GitHub)                      │
│                  i-heart-katakana-data                  │
│                      words.json                         │
└─────────────────────┬───────────────────────────────────┘
                      │ fetch on launch
                      ▼
┌─────────────────────────────────────────────────────────┐
│                      App                                │
│  ┌───────────────┐    ┌───────────────┐                │
│  │ Bundled JSON  │◄───│ Fallback if   │                │
│  │ (fallback)    │    │ fetch fails   │                │
│  └───────────────┘    └───────────────┘                │
│           │                                             │
│           ▼                                             │
│  ┌───────────────────────────────────────┐             │
│  │         In-Memory Word List           │             │
│  └───────────────────────────────────────┘             │
│           │                                             │
│           ▼                                             │
│  ┌───────────────────────────────────────┐             │
│  │            Quiz View                  │             │
│  │   (displays words, themes, fonts)     │             │
│  └───────────────────────────────────────┘             │
│                                                         │
│  ┌───────────────────────────────────────┐             │
│  │     SwiftData (User Data)             │             │
│  │     - Liked words                     │             │
│  │     - Preferences                     │             │
│  │         ▲                             │             │
│  │         │ iCloud Sync                 │             │
│  └─────────┴─────────────────────────────┘             │
└─────────────────────────────────────────────────────────┘
```

## Component Architecture

*This section will expand as components are built during Phase 1.*

### Data Models

```swift
// Content (from remote JSON)
struct Word: Codable, Identifiable {
    let id: String
    let reading: String           // Katakana word
    let meanings: [String]        // English definitions
    let sourceLanguage: String?   // Origin language code
    let sourceWord: String?       // Original word
    let frequency: String?        // common, uncommon, etc.
    let categories: [String]      // food, technology, etc.
    let phoneticPattern: String?  // gojuon, dakuon, etc.
}

// Theme (architecture only – values TBD in Phase 2)
struct Theme: Identifiable {
    let id: String
    let name: String
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
}

// Font (architecture only – values TBD in Phase 2)
struct AppFont: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let fileName: String?  // nil for system font
}
```

### User Data (SwiftData)

```swift
@Model
class LikedWord {
    var wordId: String
    var likedAt: Date
}

@Model
class UserPreferences {
    var selectedThemeId: String
    var selectedFontId: String
}
```

## Analytics

TelemetryDeck integration for privacy-focused usage tracking.

- **App ID:** `80F89D4F-DD50-4D9D-98B2-DE9298E16F71`
- **Org namespace:** `com.onurorhon`

Events to track (TBD during implementation):
- Category viewed
- Word liked/unliked
- Theme changed
- Font changed
- TTS played

## Roadmap

### Immediate: Content Pipeline

1. Define JSON schema for `words.json`.
2. Write script to extract katakana entries from JMdict.
3. Review output and define categorization.

### Then: Project Setup

1. Create Xcode project.
2. Create `i-heart-katakana-data` public GitHub repo.
3. Set up folder structure and initial files.

### Then: Phase 1 Build

Build functional prototype with SwiftUI defaults:
- Data models (Word, Theme, AppFont).
- Remote JSON fetching with bundled fallback.
- Basic quiz view (display word, reveal answer).
- Likes (SwiftData + iCloud sync).
- Categories and filtering.
- Theme/font switching (architecture only, placeholder values).
- TTS playback.
- TelemetryDeck integration.

### Then: Phase 2 Design

- Final UI design in Figma.
- Design tokens (colors, spacing, typography).
- Custom ViewModifiers for styling.
- Actual theme and font values.
- Polish, animations, micro-interactions.

### Then: Launch

- App Store metadata and screenshots.
- Submit for review.
- Create `i-heart-katakana-data` content if not already done.

---

## Remote Content

Public GitHub repo: `i-heart-katakana-data`

Purpose: Anything updatable without an App Store release.
- `words.json` – Word database
- `fonts.json` – Font metadata (future)
- `themes.json` – Theme definitions (future)
- `config.json` – Feature flags (future)
