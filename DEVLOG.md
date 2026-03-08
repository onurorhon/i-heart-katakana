# Development Log

Case-study-worthy moments from building I♥︎Katakana.

---

## 2026-01-26

### Store the Hard Part
**Tags:** #technical #domain

**Context:** Romaji hints needed dashes between syllables for learners (`ka-ta-ka-na`). Initial instinct was to parse plain romaji into syllables at display time in Swift.

**Insight:** "Removing dashes is trivial. Parsing romaji into syllables is tricky." Store the version that's hardest to derive. Segmented romaji is now canonical; plain form is a one-liner to derive.

**Why it matters:** Pedagogy shaped data structure. Content curator confirmed dashed romaji supports *mora awareness* — each Japanese syllable gets equal timing. Domain expertise drove a technical decision.

---

## 2026-03-08

### Maniackers Fonts Require a Full Cmap Remapping Pipeline
**Tags:** #technical #domain

**Context:** Several high-quality artisanal Japanese font families (Maniackers Design KtA/KT series) were candidates for the font picker. Loading them in-app rendered nothing — glyphs were invisible despite the fonts containing katakana artwork.

**Insight:** Maniackers fonts predate Unicode. They store katakana glyphs at ASCII codepoints matching the JIS kana keyboard layout (e.g., 'a' → チ, 't' → カ). Any Unicode-aware renderer requests U+30A0–30FF and finds nothing. The solution required a dedicated pipeline: `remap_maniackers.py` reads each font's ASCII cmap, rewrites it to Unicode katakana codepoints via a hand-verified 85-entry translation table, then passes the result to the standard subsetting step. Legacy .suit suitcase files needed a further conversion stage via FontForge (`convert_suitcases.py`), plus a post-conversion fix for a FontForge bug that maps hyphen to U+00AD instead of U+002D. The translation table itself required 11 corrections discovered through iterative testing — the handakuon block was shifted by one position, and entries for ベ, ボ, ヱ, ヮ were missing entirely.

**Why it matters:** A whole class of fonts was effectively invisible to the app's rendering stack for a non-obvious reason rooted in pre-Unicode Japanese computing history. The pipeline built here is the unlock. Without it, any future font from this foundry would silently fail.

---

