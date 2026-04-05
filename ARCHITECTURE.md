<!--
GUARDRAILS FOR THIS DOCUMENT:
- No specific counts or statistics (e.g., "2,493 words", "37,184 entries").
- No progress checkmarks or completion markers.
- No session outputs or historical reports.
- Forward-looking roadmap only – remove completed items, don't check them off.
See CLAUDE.md > Documentation Boundaries for full policy.
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
| Orientation | Portrait and landscape |
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
├── IHeartKatakana/             # App source (see CLAUDE.md for structure conventions)
├── IHeartKatakanaTests/
├── IHeartKatakanaUITests/
├── data/
│   ├── words.json              # Curated word database (UI label: "Word")
│   ├── kana.json               # Katakana character reference (UI label: "Kana")
│   └── fonts.json              # Font display tuning and ordering (runtime config)
├── scripts/                    # Font processing and content curation
│   ├── subset_fonts.py         # Subset standard Unicode fonts
│   ├── remap_maniackers.py     # Remap + subset Maniackers 1-byte fonts
│   ├── convert_suitcases.py    # Convert legacy .suit fonts via FontForge
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
- Bundled JSON loading.
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
  "parentCategory": "Everyday Life",
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
| `categories` | string[] | Fine-grained semantic categories from JMdict. |
| `parentCategory` | string | Broad category for UI filtering (Food, Brands, Wasei-eigo, Onomatopoeia, Everyday Life, Sports & Recreation, Arts & Entertainment, Health & Medicine, Technology, Academic & Humanities, Business & Finance, Science & Nature, Military & Aviation). |
| `patterns` | string[] | All phonetic patterns present in the word. Array because most words mix patterns (e.g., "ジュース" contains gojūon, dakuon, and yōon). |
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
| `gojuon` | Gojūon – basic 46 katakana | ア イ ウ エ オ, カ キ ク ケ コ |
| `dakuon` | Dakuon – voiced consonants (゛) | ガ ギ グ ゲ ゴ, ザ ジ ズ ゼ ゾ |
| `handakuon` | Handakuon – P-sounds (゜) | パ ピ プ ペ ポ |
| `youon` | Yōon – combination sounds (small ャュョ) | キャ, シュ, チョ |
| `extended` | Extended – modern additions for foreign sounds | ティ, ファ, ヴァ |

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

### Font Processing

Two separate pipelines process fonts for the app. Both output to `IHeartKatakana/Resources/Fonts/` (`.gitignored`; run locally).

**Unicode range:** U+30A0-30FF (full katakana block, 96 codepoints). Includes all standard katakana, small kana, dakuon, handakuon, ヴ, ヵ, ヶ, long vowel mark ー, and nakaguro ・. The full block is used rather than only the characters currently in the word database, to support future content additions with negligible size overhead.

**Subsetting flags (shared by both pipelines):**
- `--layout-features='*'` – Preserve all OpenType layout features
- `--no-hinting` – Strip hinting (not needed at 72pt+ display)
- `--desubroutinize` – Simplify glyph outlines for smaller output

#### Pipeline 1: Standard Unicode fonts

For fonts with proper Unicode katakana mappings (Noto Sans CJK, Cherry Bomb One, etc.).

```
python scripts/subset_fonts.py FontName.ttf
```

Subsets to katakana-only glyphs.

#### Pipeline 2: Maniackers 1-byte fonts

Maniackers Design katakana fonts are single-byte fonts that store katakana glyphs at ASCII codepoints based on the JIS kana keyboard layout (JIS X 6002). They need remapping before subsetting.

```
python scripts/remap_maniackers.py FontName.otf
```

Remaps ASCII→katakana codepoints using the Maniackers Set 1 mapping table (source: martijnkoch.com/katakanaconverter.php), then subsets. One step, no intermediate files.

**Note:** Per Maniackers README, character layout may vary slightly between fonts. The script reports any unmapped glyphs for manual review.

**Adding a new font (either pipeline):**
1. Drop the font in `i-heart-katakana-assets/fonts/`
2. Run the appropriate script with the filename
3. Register in `PracticeFont.swift`, `data/fonts.json`, `Info.plist`

#### Shared workflow

Source fonts live in the private `i-heart-katakana-assets` repo (never modified by scripts). Subsetted fonts are `.gitignored` (`**/fonts/`); each developer runs the scripts locally.

**Variable fonts:** Skip variable fonts. Use static weight versions instead (e.g., NotoSansJP-Regular.ttf not NotoSansJP-VariableFont_wght.ttf).

---

## Component Architecture

### Menu System

Menus use a **floating card pattern** inspired by Apple TV. Each control group is a separate card with `.regularMaterial` background, stacked vertically with gaps between them so the practice content remains visible behind. This avoids a heavy modal feel.

**Components:**
- `FloatingCard` – Wraps content with padding, material background, and rounded corners
- `FloatingCloseButton` / `FloatingBackButton` – Circular material buttons for navigation
- `ActionsMenu` – Left menu with Word/Kana toggle, Level filters, Category submenu
- `HamburgerMenu` – Right menu with Pull to Peek submenu, Font, Colors, About

**Submenu pattern:** Menus with submenus (Category, Pull to Peek) use internal `@State` to swap between main menu and submenu views, keeping both within the same floating card container.

### Practice Flow

Cards use a **shuffle-without-repeat** pattern for item presentation:

- Items are shown in random order without repeats until all have been seen
- A shuffled deck of indices is created on session start
- User can swipe back through history indefinitely
- When deck is exhausted, an **end card** appears with two options:
  - **Restart** (↺) – Repeats the same shuffled order from card 1
  - **Shuffle** (⤮) – Creates a new random order and starts from card 1

**Progress indicator:** Shows current position as "X of Y", fades out on end card.

**Session persistence:** Practice session state (history, shuffled deck, position, current page) is saved to UserDefaults as JSON. On app launch, the saved session is restored if filter criteria (content type, patterns, category) still matches. If settings changed, a fresh session starts.

**Card layout:** Full-screen cards using `ScrollView` with `.scrollTargetBehavior(.paging)` and `ScrollViewReader` for programmatic scrolling on orientation change.

**Safe area handling:** Capture insets from outer `GeometryReader` BEFORE calling `.ignoresSafeArea()`, then apply as manual padding (20px base + insets). This ensures content clears Dynamic Island while cards remain edge-to-edge.

### Content Loading

`ContentService` uses `@MainActor` and `@Observable`. Load via `.task` (not `.onAppear`) to avoid Swift concurrency warnings about `unsafeForcedSync`.

### DEBUG Test Data

Typography edge cases are tested via `TypographyTestData.swift`:
- `#if DEBUG` conditional compilation
- Test words injected into `ContentService.words` at load time
- "Typography Test" category appears at top of category list in DEBUG builds only
- Never included in release builds

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
    let parentCategory: String          // Broad category for UI filtering
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

// Font
struct PracticeFont: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let postScriptName: String?  // iOS font reference; nil for system
    let fileName: String?        // Bundle filename; nil for system font
    var tracking: CGFloat        // Letter spacing (overridden by fonts.json)
    var maxSize: CGFloat         // Max display size in points (overridden by fonts.json)
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

**iCloud sync:** Deferred. Likes are local-only (on-device SwiftData) until the Apple Developer Program ($99/year) is active. Once enrolled, adding iCloud sync is a one-line change (`cloudKitDatabase: .automatic` in `ModelConfiguration` + CloudKit capability in Xcode). The data model requires no changes.

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

### Next: Phase 1 Remaining

- TelemetryDeck integration.
- Enroll in Apple Developer Program ($99/year).
- iCloud sync for likes (requires paid account).

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

- Enroll in Apple Developer Program ($99/year).
- Enable iCloud sync for likes (one-line config change + CloudKit capability).
- App Store metadata and screenshots.
- Submit for review.

### Post-Launch

- Evaluate git branching strategy (main + develop) if needed for safer releases.

---

## Remote Content

Content is bundled with the app as fallback. Remote fetching (added in Content Finalization phase) enables content updates without App Store releases:
- Word database updates
- Font metadata
- ColorTheme definitions
- Feature flags
