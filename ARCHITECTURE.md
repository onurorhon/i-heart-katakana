<!--
GUARDRAILS FOR THIS DOCUMENT:
- No specific counts or statistics (e.g., "2,493 words", "37,184 entries").
- No progress checkmarks or completion markers.
- No session outputs or historical reports.
- Forward-looking roadmap only – remove completed items, don't check them off.
- Script details go in scripts/README.md, not here.
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

## Data Schema

Two JSON files for content:

### words.json

Curated katakana words extracted from JMdict with wasei-eigo detection.

```json
{
  "id": "1049180",
  "reading": "コーヒー",
  "meanings": ["coffee"],
  "sourceLanguage": "eng",
  "sourceWord": "coffee",
  "categories": ["food"],
  "patterns": ["gojuon"]
}
```

**Example with wasei-eigo flag:**
```json
{
  "id": "1014740",
  "reading": "アウトコース",
  "meanings": ["outside track", "outside pitch"],
  "sourceLanguage": "eng",
  "sourceWord": "out course",
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
| `reading` | string | Katakana word. |
| `meanings` | string[] | English translations. |
| `sourceLanguage` | string | Origin language code (eng, por, deu, fra, etc.). |
| `sourceWord` | string | Original foreign word. |
| `categories` | string[] | Semantic categories (food, technology, places, etc.). |
| `patterns` | string[] | All phonetic patterns present in the word. Array because most words mix patterns (e.g., "ジュース" contains gojuon, dakuon, and youon). |
| `wasei_eigo` | boolean | **Optional.** True if this is a confirmed wasei-eigo (和製英語) - Japanese-coined pseudo-English that differs from actual English. |
| `wasei_info` | object | **Optional.** Present when `wasei_eigo: true`. Contains `english_equivalent` (what English speakers actually say), `wasei_meaning` (the Japanese construction), and `notes` (explanation). |
| `wasei_candidate` | boolean | **Optional.** True if this word is flagged as a potential wasei-eigo that needs human verification. |
| `wasei_flags` | array | **Optional.** Present when `wasei_candidate: true`. List of detection flags explaining why it was flagged. |

### katakana.json

Reference data for individual katakana characters.

```json
{
  "character": "カ",
  "romaji": "ka",
  "pattern": "gojuon"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `character` | string | Single katakana character. |
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
    ├── words_excluded.json
    └── wasei_candidates_for_review.json
```

### Wasei-Eigo Detection

**What is wasei-eigo?** Wasei-eigo (和製英語) means "Japanese-made English" - words that appear to be English loanwords but are actually Japanese coinages. They either don't exist in English, have different meanings, or use non-standard constructions.

**Why flag it?** Learners need to know when a katakana word won't be understood by English speakers, despite being written in katakana.

**Detection Strategy:**

1. **Tier 1: Known Database** (100% accuracy)
   - `scripts/wasei_eigo_database.json` - Curated list of confirmed wasei-eigo
   - Auto-flags words like アメリカンドッグ (corn dog), バージョンアップ (update)

2. **Tier 2: Heuristic Detection** (70-80% accuracy)
   - Pattern matching (e.g., "X-up/down" constructions)
   - English phrase validation
   - Flags candidates for human review

3. **Tier 3: Human Review**
   - Candidates exported to `wasei_candidates_for_review.json`
   - Human reviewers verify and update database
   - Continuous improvement of detection rules

**Key Files (in `i-heart-katakana-data` repo):**

| File | Purpose |
|------|---------|
| `scripts/wasei_eigo_database.json` | Permanent confirmed wasei-eigo database |
| `scripts/detect_wasei_eigo.py` | Detection module (3-tier system) |
| `scripts/curate_words.py` | Main curation script with wasei detection |
| `data/wasei_candidates_for_review.json` | Temporary review queue (gitignored) |

**Example Confirmed Wasei-Eigo:**

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
    let reading: String
    let meanings: [String]
    let sourceLanguage: String?
    let sourceWord: String?
    let categories: [String]
    let patterns: [String]

    // Wasei-eigo detection (optional fields)
    let waseiEigo: Bool?
    let waseiInfo: WaseiInfo?
    let waseiCandidate: Bool?
    let waseiFlags: [WaseiFlag]?
}

struct WaseiInfo: Codable {
    let englishEquivalent: String
    let waseiMeaning: String
    let notes: String
}

struct WaseiFlag: Codable {
    let type: String
    let detail: String
}

// Katakana character (from katakana.json)
struct Katakana: Codable, Identifiable {
    var id: String { character }
    let character: String
    let romaji: String
    let pattern: String
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

### Next: Phase 1 Build

Build functional prototype with SwiftUI defaults:
- Data models (Word, Theme, AppFont).
- Remote JSON fetching with bundled fallback.
- Basic quiz view (display word, reveal answer).
- Likes (SwiftData + iCloud sync).
- Categories and filtering.
- Theme/font switching (architecture only, placeholder values).
- TTS playback.
- TelemetryDeck integration.

### Then: Content Finalization

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

Public GitHub repo: `i-heart-katakana-data`

Purpose: Anything updatable without an App Store release.
- `words.json` – Word database
- `fonts.json` – Font metadata (future)
- `themes.json` – Theme definitions (future)
- `config.json` – Feature flags (future)
