---
document: Project Overview
project: I❤️Katakana
version: 1.0
status: Draft
last_updated: 2025-01-17
author: Onur
decision_maker: Onur (sole designer and developer)
---

# I❤️Katakana – Project Overview

## 1. Project Context

This is an independent learning project with multiple objectives in addition to shipping a useful language app.

### Learning Objectives

- Improve skills for coding with AI, using both vibe-coding and structured, spec-based approaches.
- Sharpen knowledge of native iOS development and SwiftUI.
- Gain hands-on experience with MCP, AI agent workflows, Cursor, and Claude Code.
- Explore design-to-development workflows using AI tools.

### Career Objectives

- Build a portfolio case study demonstrating AI-assisted development.
- Create content for professional networking (LinkedIn, case study write-ups).
- Strengthen positioning for principal/lead designer and design systems roles.

### Personal Objectives

- Scratch a long-standing itch: a clean, focused katakana practice tool.
- Support the Japanese language learning community with a free resource.

### Project Approach

**AI-first development:** All documentation is structured to be consumable by both humans and AI coding agents. Clear, modular files with explicit context.

**Dual methodology:** The project alternates between vibe-coding (exploratory, conversational) and spec-based coding (structured implementation). Part of the learning is understanding when each approach works best.

**Development environment:**
- Cursor as the primary IDE.
- Claude Code for agentic, multi-file edits.
- Xcode for previews, simulator, and builds.
- Git for version control.

**Constraints:**
- Solo designer/developer.
- Minimal budget (free/open-source resources only).
- One-month target timeline.
- iOS only.

### Strategic Partnerships

**Maniackers Design:** Japanese font maker. Permission secured for font usage. Representative Masayuki Sato expressed interest in broader design collaboration beyond licensing.

---

## 2. Purpose

Many apps help learners memorise katakana characters. Far fewer help them practice reading real katakana words as they appear in everyday Japanese – across different typefaces, visual styles, and phonetic patterns.

I❤️Katakana fills that gap: a focused, distraction-free environment for practicing katakana recognition with curated content and visual variety.

This is a free, non-profit iOS app developed independently.

## 3. Target Users

**Primary:** Intermediate learners who know katakana characters and want reading fluency with real words.

**Secondary:** Beginners reinforcing character recognition through word context.

### User Needs

- Practice reading katakana words and isolated characters.
- Exposure to varied typefaces reflecting real-world usage.
- Clean experience without gamification pressure.

## 4. Core Functionality

### 4.1 Practice Experience

Self-assessment quiz for recognising katakana characters and words. Users see content, attempt to read it, reveal the answer, and optionally mark their response.

### 4.2 Likes

Users can like words. Liked words appear as a filterable category alongside semantic and phonetic categories. Likes sync across user's devices via iCloud.

### 4.3 Content Scope

**Target:** 1,000+ curated items spanning:

- **Semantic categories:** food, places, technology, everyday objects, loanword origins.
- **Phonetic patterns:** gojūon, dakuon, handakuon, yōon.
- **Modern extended katakana:** including less common contemporary variations.

See `GLOSSARY.md` for term definitions.

**Data source:** JMdict (open-source Japanese-English dictionary). Katakana entries extracted and curated.

### 4.4 Customisation

Users adjust practice via settings: font, theme, character type, word category, difficulty, content type. Details in design specifications.

### 4.5 Visual Variety

~20 fonts and ~20 themes reflecting varied Japanese typographic styles.

### 4.6 Audio

Audio pronunciation via on-device TTS (AVSpeechSynthesizer). Uses iOS's built-in Japanese voices. No network required.

### 4.7 Reference

Katakana character table. Additional reference content TBD.

## 5. Design Principles

- **Focused:** No distractions, no gamification.
- **Typographically rich:** Fonts are a core feature.
- **Visually varied:** Themes keep sessions fresh.
- **Honest:** No dark patterns, no hidden data collection.

## 6. Content & Licensing

| Asset | Source | Status |
|-------|--------|--------|
| Word database | JMdict (open-source) | Available. Extraction and curation needed. |
| Fonts | Free/open-source (~20) | In progress. Must permit free distribution. |
| Audio | On-device TTS (AVSpeechSynthesizer) | Built-in. No licensing needed. |

## 7. Technical Constraints

- iOS only (iPhone).
- SwiftUI (native framework).
- Minimum iOS 18.
- Free, no in-app purchases.
- Privacy-focused.

### 7.1 Data Architecture

| Data Type | Storage | Sync |
|-----------|---------|------|
| Katakana content | Remote JSON with bundled fallback | You push updates; users pull on launch. |
| User data (likes, future features) | SwiftData with iCloud | Apple handles sync via user's iCloud account. |

**Remote content hosting:** Public GitHub repo (`i-heart-katakana-data`). App fetches raw file URLs. This repo holds anything that should be updatable without an App Store release:

- Word database (`words.json`).
- Font metadata (`fonts.json`) – names, display order, groupings.
- Theme definitions (`themes.json`) – colors, background styles.
- App announcements (`announcements.json`) – in-app messages, tips.
- Feature flags (`config.json`) – toggle features remotely.

Not all of these are needed for v1, but the repo provides a place for them.

### 7.2 Analytics

TelemetryDeck (privacy-focused, no personal data collected).

- App ID: `80F89D4F-DD50-4D9D-98B2-DE9298E16F71`
- Org namespace: `com.onurorhon`

### 7.3 Accessibility

SwiftUI defaults plus a light intentional pass before launch. Use standard components, add meaningful VoiceOver labels where needed, test briefly with VoiceOver. Support Dynamic Type where feasible with custom fonts.

## 8. Out of Scope

- In-app purchases.
- Advertising.

## 9. Risks

| Risk | Mitigation |
|------|------------|
| JMdict extraction yields insufficient quality content. | Manual curation pass; supplement with additional sources. |
| Insufficient free fonts meeting quality bar. | Expand search to additional foundries; reduce v1 font count if needed. |
| Audio adds complexity without clear solution. | Treat as enhancement; launch without if necessary. |

## 10. Success Criteria

- Launch with 500+ items across all phonetic categories.
- All core functionality working and stable.
- At least 10 fonts and 10 themes available.

## 11. Timeline

Target release: one month from project start.

## 12. App Store Metadata

| Field | Status |
|-------|--------|
| App name | I❤️Katakana |
| Tagline | TBD |
| Description | TBD |
| Keywords | TBD |
| Category | Education |

## 13. Future Considerations

See `PARKING-LOT.md`.

## 14. Related Documents

- `ARCHITECTURE.md` – Technical decisions and roadmap.
- `RULES.md` – Conventions and standards.
- `PARKING-LOT.md` – Deferred features.
- `GLOSSARY.md` – Terminology (TBD).
