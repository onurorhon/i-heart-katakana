# Development Log

Case-study-worthy moments from building I♥︎Katakana.

---

## 2026-01-26 — Store the Hard Part

**The problem:** Romaji hints needed dashes between syllables for learners (e.g., `ka-ta-ka-na` instead of `katakana`).

**The wrong instinct:** Parse plain romaji into syllables at display time.

**The insight:** "Removing dashes is trivial. Parsing romaji into syllables is tricky. Segmented storage preserves information that's annoying to reconstruct."

This is a general principle worth remembering: when choosing canonical data formats, store the version that's hardest to derive. You can always strip structure away; recreating it requires either complex parsing logic or domain knowledge that may be lossy.

The words database now stores `romaji: "ka-ta-ka-na"` as canonical. Deriving `katakana` is a one-liner: `romaji.replacingOccurrences(of: "-", with: "")`.

**Validation:** The content curator agent confirmed this supports *mora awareness* — a key concept for Japanese learners where each syllable (mora) gets equal timing. Dashed romaji makes mora boundaries explicit.

---

