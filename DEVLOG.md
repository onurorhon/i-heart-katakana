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

