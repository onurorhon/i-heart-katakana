<!--
GUARDRAILS FOR THIS DOCUMENT:
- No specific counts or statistics (e.g., "2,493 words", "37,184 entries").
- No progress checkmarks or completion markers.
- No session outputs or historical reports.
- Forward-looking roadmap only – remove completed items, don't check them off.
See RULES.md > Documentation Boundaries for full policy.
-->

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
| Platforms | iPhone and iPad |
| Orientation | Portrait only (landscape TBD) |
| Minimum iOS | iOS 18 |
| Content storage | Bundled JSON (`data/`) with optional remote fallback |
| Content source | JMdict (open-source), extracted and curated |
| User data storage | SwiftData with iCloud sync |
| Audio | On-device TTS (AVSpeechSynthesizer) |
| Analytics | TelemetryDeck (free tier) |
| Accessibility | SwiftUI defaults + light intentional pass |
| Development environment | Cursor + Claude Code + Xcode |

## Repository Structure

The project spans two repositories:

| Repository | Visibility | Purpose |
|------------|------------|---------|
| `i-heart-katakana` (this repo) | Public | iOS app, data, scripts, documentation |
| `i-heart-katakana-assets` | Private | Fonts, design files |

**This repository:**
```
i-heart-katakana/
├── IHeartKatakana.xcodeproj    # Xcode project
├── IHeartKatakana/             # App source (see RULES.md for structure conventions)
├── IHeartKatakanaTests/
├── IHeartKatakanaUITests/
├── data/
│   ├── words.json              # Curated word database (UI label: "Word")
│   └── kana.json                 # Katakana character reference (UI label: "Kana")
├── scripts/                    # Python curation pipeline
│   ├── extract_katakana.py
│   ├── curate_words.py
│   └── wasei_eigo_database.json
├── .claude/                    # Claude Code agent configs
└── *.md                        # Project documentation
```

**Assets repository:**
```
i-heart-katakana-assets/
└── Fonts/                      # Licensed fonts (not redistributable)
```

## Development Approach

### Phase 1: Functional Prototype (~80%)

Build core functionality using SwiftUI defaults. No custom styling – generic iOS appearance. Focus on architecture and behavior.

**In scope:**
- Core practice flow (display word, reveal answer, navigate).
- Likes (save, filter, iCloud sync).
- ColorTheme system architecture (switching, persistence) – placeholder values.
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
│                      App                                │
│  ┌───────────────────────────────────────┐             │
│  │         Bundled JSON                  │             │
│  │         (data/words.json)             │             │
│  └───────────────────────────────────────┘             │
│           │                                             │
│           ▼                                             │
│  ┌───────────────────────────────────────┐             │
│  │         In-Memory Word List           │             │
│  └───────────────────────────────────────┘             │
│           │                                             │
│           ▼                                             │
│  ┌───────────────────────────────────────┐             │
│  │            Practice View                  │             │
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

## Data Schema

Two JSON files for content:

### words.json

Curated katakana words extracted from JMdict with wasei-eigo detection.

```json
{
  "id": "1049180",
  "word": "コーヒー",
  "romaji": "koohii",
  "originalWord": "coffee",
  "originalWordInferred": null,
  "originLanguage": "eng",
  "meanings": ["coffee"],
  "categories": ["food"],
  "patterns": ["gojuon"]
}
```

**Example with inferred original word:**
```json
{
  "id": "1013950",
  "word": "アイシング",
  "romaji": "aishingu",
  "originalWord": null,
  "originalWordInferred": "icing",
  "originLanguage": "eng",
  "meanings": ["icing", "frosting"],
  "categories": ["food, cooking", "sports"],
  "patterns": ["dakuon", "gojuon"]
}
```

**Example with wasei-eigo flag:**
```json
{
  "id": "1014740",
  "word": "アウトコース",
  "romaji": "autokoosu",
  "originalWord": "out course",
  "originalWordInferred": null,
  "originLanguage": "eng",
  "meanings": ["outside track", "outside pitch"],
  "categories": ["baseball"],
  "patterns": ["gojuon"],
  "wasei_eigo": true,
  "wasei_info": {
    "english_equivalent": "outside pitch (baseball), outer lane (racing)",
    "wasei_meaning": "out course",
    "notes": "In baseball English: 'outside pitch' or 'away'. In racing: 'outer lane'"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | JMdict entry ID (ent_seq). |
| `word` | string | Katakana word. |
| `romaji` | string | Romanized pronunciation (generated from katakana). |
| `originalWord` | string? | Original foreign word from JMdict (authoritative). |
| `originalWordInferred` | string? | Inferred original word (cleaned first meaning). Present when `originalWord` is null. |
| `originLanguage` | string | Origin language code (eng, por, deu, fra, etc.). |
| `meanings` | string[] | English translations. |
| `categories` | string[] | Semantic categories (food, technology, places, etc.). |
| `patterns` | string[] | All phonetic patterns present in the word. Array because most words mix patterns (e.g., "ジュース" contains gojuon, dakuon, and youon). |
| `wasei_eigo` | boolean | **Optional.** True if this is a confirmed wasei-eigo (和製英語) - Japanese-coined pseudo-English that differs from actual English. |
| `wasei_info` | object | **Optional.** Present when `wasei_eigo: true`. Contains `english_equivalent` (what English speakers actually say), `wasei_meaning` (the Japanese construction), and `notes` (explanation). |

### kana.json

Reference data for individual katakana characters.

```json
{
  "kana": "カ",
  "romaji": "ka",
  "pattern": "gojuon"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `kana` | string | Single katakana character. |
| `romaji` | string | Romanized pronunciation. |
| `pattern` | string | Phonetic pattern classification. |

### Phonetic Patterns

| Pattern | Description | Examples |
|---------|-------------|----------|
| `gojuon` | Basic 46 katakana | ア イ ウ エ オ, カ キ ク ケ コ |
| `dakuon` | Voiced consonants (゛) | ガ ギ グ ゲ ゴ, ザ ジ ズ ゼ ゾ |
| `handakuon` | P-sounds (゜) | パ ピ プ ペ ポ |
| `youon` | Combination sounds (small ャュョ) | キャ, シュ, チョ |
| `extended` | Modern additions for foreign sounds | ティ, ファ, ヴァ |

### Filtering Logic

User selects which patterns to practice (e.g., `[gojuon, youon]`).

For words: Show words where `patterns` is a **subset** of user's selection. A word with `["gojuon", "dakuon"]` would not match `[gojuon, youon]` because it contains dakuon.

For characters: Show characters matching user's selection directly.

---

## Content Curation Pipeline

The word database is extracted and curated from JMdict using Python scripts in the `scripts/` directory.

### Pipeline Overview

```
JMdict XML
    ↓
extract_katakana.py → words_raw.json
    ↓
curate_words.py → words.json
    └── words_excluded.json
```

**Processing steps:**
1. Extract katakana-only entries from JMdict
2. Filter by categories and apply exclusions
3. Infer origin language for entries missing it
4. Generate romaji from katakana
5. Auto-backfill `originalWord` for high-confidence English entries
6. Flag confirmed wasei-eigo from curated database

### Wasei-Eigo Detection

**What is wasei-eigo?** Wasei-eigo (和製英語) means "Japanese-made English" - words that appear to be English loanwords but are actually Japanese coinages. They either don't exist in English, have different meanings, or use non-standard constructions.

**Why flag it?** Learners need to know when a katakana word won't be understood by English speakers, despite being written in katakana.

**Detection approach:** Database lookup only (no heuristics). The `scripts/wasei_eigo_database.json` file contains a curated list of confirmed wasei-eigo terms. Words are only flagged if they appear in this database, ensuring high accuracy.

**Key files:**

| File | Purpose |
|------|---------|
| `scripts/wasei_eigo_database.json` | Curated database of confirmed wasei-eigo |
| `scripts/detect_wasei_eigo.py` | Simple database lookup module |

**Example confirmed wasei-eigo:**

- **アメリカンドッグ** (American dog) → corn dog
- **バージョンアップ** (version up) → update/upgrade
- **サインペン** (sign pen) → felt-tip pen
- **ナイター** (nighter) → night game
- **アウトコース** (out course) → outside pitch

---

## Component Architecture

*This section will expand as components are built during Phase 1.*

### Data Models

```swift
// Word (from words.json)
struct Word: Codable, Identifiable {
    let id: String
    let word: String
    let romaji: String
    let originalWord: String?           // From JMdict (authoritative)
    let originalWordInferred: String?   // Cleaned first meaning when JMdict lacks source
    let originLanguage: String?
    let meanings: [String]
    let categories: [String]
    let patterns: [String]

    // Wasei-eigo (optional, from curated database)
    let waseiEigo: Bool?
    let waseiInfo: WaseiInfo?
}

struct WaseiInfo: Codable {
    let englishEquivalent: String
    let waseiMeaning: String
    let notes: String
}

// Katakana character (from kana.json)
struct Kana: Codable, Identifiable {
    var id: String { kana }
    let kana: String
    let romaji: String
    let pattern: String
}

// ColorTheme (architecture only – values TBD in Phase 2)
// Each theme defines both light and dark mode colors
struct ColorTheme: Identifiable {
    let id: String
    let name: String
    let backgroundColorLight: Color
    let textColorLight: Color
    let accentColorLight: Color
    let backgroundColorDark: Color
    let textColorDark: Color
    let accentColorDark: Color
}

// Font (architecture only – values TBD in Phase 2)
struct PracticeFont: Identifiable {
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
    var selectedColorThemeId: String
    var selectedPracticeFontId: String
}
```

## Analytics

TelemetryDeck integration for privacy-focused usage tracking.

- **App ID:** Configure in `Secrets.swift` (see `Secrets.example.swift`)
- **Org namespace:** `com.onurorhon`

Events to track (TBD during implementation):
- Category viewed
- Word liked/unliked
- ColorTheme changed
- Font changed
- TTS played

## Roadmap

### Next: Phase 1 Build

Build functional prototype with SwiftUI defaults:
- Data models (Word, ColorTheme, PracticeFont).
- Bundled JSON loading.
- Basic practice view (display word, reveal answer).
- Likes (SwiftData + iCloud sync).
- Categories and filtering.
- ColorTheme/font switching (architecture only, placeholder values).
- TTS playback.
- TelemetryDeck integration.

### Then: Content Finalization

- Remote JSON fetching with bundled fallback.
- Streamline JSON fields based on what the app actually uses.
- Fix inconsistencies discovered during development.
- Expand categories (technology, places, everyday objects).
- Review wasei-eigo candidates.

### Then: Phase 2 Design

- Final UI design in Figma.
- Design tokens (colors, spacing, typography).
- Custom ViewModifiers for styling.
- Actual theme and font values.
- Polish, animations, micro-interactions.

### Then: Launch

- App Store metadata and screenshots.
- Submit for review.
- Publish `i-heart-katakana-data` content.

### Post-Launch

- Evaluate git branching strategy (main + develop) if needed for safer releases.

---

## Remote Content

Content is bundled with the app as fallback. Remote fetching (added in Content Finalization phase) enables content updates without App Store releases:
- Word database updates
- Font metadata
- ColorTheme definitions
- Feature flags
