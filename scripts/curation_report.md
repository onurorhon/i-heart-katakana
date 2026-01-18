# Content Curation Report

**Batch:** words_gold.json
**Entries reviewed:** 1,124
**Date:** 2026-01-18

## Executive Summary

The gold set contains 1,124 katakana entries with JMdict field categories and source language attribution. The dataset shows a strong **sports/baseball bias** (particularly baseball with 83 entries) and **specialized academic terminology** that may not be appropriate for intermediate learners. There is a notable **absence of everyday vocabulary** in categories like food, household items, and basic technology.

### Summary Statistics
- High value (everyday, common): ~150-200 entries (estimated)
- Include (standard, suitable): ~700-800 entries
- Review (needs human decision): ~150-200 entries
- Exclude (inappropriate/too specialized): ~50-100 entries

---

## 1. Category Balance Analysis

### Major Category Distribution

Based on grep analysis of the dataset:

| Category | Count | Assessment |
|----------|-------|------------|
| Music | 228 | **OVERREPRESENTED** - Large number of technical music terms |
| Baseball | 83 | **OVERREPRESENTED** - Highly specialized baseball jargon |
| Sports (general) | 80 | Reasonable, but check for overlap with baseball |
| German (source) | 98 | Good diversity of source languages |
| Portuguese (source) | 33 | Includes religious/historical terms |
| English (source) | 393 | Majority source - **check for wasei-eigo** |
| Philosophy | ~40 | **TOO SPECIALIZED** - Not suitable for intermediate learners |
| Christianity | ~15 | Specialized religious terminology |
| Buddhism | ~8 | Specialized religious terminology |
| Greek mythology | ~35 | Cultural value but specialized |
| Anatomy | ~3 | Includes potentially sensitive terms |
| Food and drink | 0* | **CRITICAL GAP** - No dedicated food category found |
| Clothing | 13 | **UNDERPRESENTED** - Need more everyday clothing terms |
| Business | 9 | **UNDERPRESENTED** - Need more workplace vocabulary |
| Computer/Internet | ~30 | Some modern tech terms but could expand |

*Note: "food and drink" as a category tag was not found, though food-related words may exist under other categorizations.

### Critical Gaps Identified

1. **Everyday Food & Drink** - The dataset appears to lack a dedicated food category. For intermediate learners, common food vocabulary (レストラン, メニュー, コーヒー, etc.) is essential.

2. **Household Items** - Only 8 entries found for "furniture/tool/household" combined. Missing common items like テーブル, カーテン, ソファ.

3. **Transportation** - Only 1 entry found. Missing common terms like バス, タクシー, エレベーター.

4. **Animals/Nature** - Only 5 entries found. Missing common animals, plants, and nature vocabulary.

5. **Everyday Technology** - While there are ~30 computer/Internet terms, basic technology vocabulary for intermediate learners may be missing.

### Overrepresented Categories

1. **Baseball Terminology** - 83 entries of highly specialized baseball jargon:
   - アウトカウント (out count)
   - インコース (inside pitch)
   - エンタイトルツーベース (ground-rule double)
   - **Recommendation:** Retain only the 10-15 most common baseball terms that general learners would encounter.

2. **Music Theory** - 228 music entries, many highly technical:
   - ノントロッポ (non troppo)
   - コーダ (coda)
   - **Recommendation:** Keep common instruments and basic music terms, flag advanced music theory for review.

3. **Philosophy** - ~40 entries of advanced philosophical terms:
   - アウフヘーベン (Aufheben/sublation)
   - アプリオリ (a priori)
   - アナムネーシス (anamnesis)
   - ヌーメノン (noumenon)
   - **Recommendation:** EXCLUDE most philosophy terms. These are graduate-level academic vocabulary, not suitable for intermediate language learners.

---

## 2. Entries Requiring Review

### A. Potentially Offensive/Vulgar Content

#### スベタ (ID: 1006220)
- **Issue:** First meaning listed as "bitch"
- **Context:** Portuguese "espada" (sword), hanafuda card game term
- **Question:** Is the offensive meaning primary or secondary? Should this be flagged with context?
- **Recommendation:** If retained, reorder meanings to put card game definition first, add cultural context note.

#### ヴァギナ (ID: 1098230)
- **Issue:** Anatomical term "vagina"
- **Context:** Latin, anatomy category
- **Question:** Is anatomical vocabulary appropriate for a general language learning app?
- **Recommendation:** Review based on app audience age and context. If retained, ensure it's marked as medical/anatomical terminology.

#### エロス (ID: 1030730)
- **Issue:** Includes "sexual desire" among meanings
- **Context:** Greek mythology, also philosophical term
- **Question:** Cultural/mythological term with sexual connotations
- **Recommendation:** INCLUDE - This is a legitimate cultural/philosophical term. The sexual meaning is one of several, including mythology and Platonic philosophy.

### B. Highly Technical/Specialized Terms

#### Philosophy Category (~40 entries) - **RECOMMEND EXCLUDE ENTIRE CATEGORY**

Examples requiring exclusion:
- アウフヘーベン (Aufheben/sublation) - ID: 1014920
- アポステリオリ (a posteriori) - ID: 1018480
- アンチノミー (antinomy) - ID: 1020310
- ジンテーゼ (Synthese/synthesis) - ID: 1066650
- デュナミス (dynamis) - ID: 2515450
- エネルゲイア (energeia) - ID: 2515460
- ノマドロジー (nomadology) - ID: 2857098

**Rationale:** These are graduate-level philosophical terminology requiring extensive background knowledge. Not appropriate for intermediate language learners whose goal is practical communication.

#### Religious Terminology - **RECOMMEND SELECTIVE INCLUSION**

Christianity/Buddhism terms to review:
- アガペー (agape) - ID: 1015040 - **INCLUDE** (culturally significant)
- アグヌスデイ (Agnus Dei) - ID: 2476250 - **EXCLUDE** (too specialized)
- パードレ (padre) - ID: 1100870 - **INCLUDE** (appears in common usage)
- サタン (Satan) - ID: 1056690 - **INCLUDE** (culturally common)
- アヒンサー (ahimsa) - ID: 2199170 - **REVIEW** (specialized but culturally valuable)
- マントラ (mantra) - ID: 2832350 - **INCLUDE** (entered common usage)

**Rationale:** Keep religiously-derived terms that have entered general cultural vocabulary; exclude liturgical/specialized theological terms.

#### Advanced Music Theory - **RECOMMEND SELECTIVE EXCLUSION**

Many of the 228 music entries are Italian tempo/expression markings suitable only for music students:
- ノントロッポ (non troppo) - ID: 1094310 - **EXCLUDE**
- コーダ (coda) - ID: 1048900 - **REVIEW** (somewhat common in general usage)

**Recommendation:** Retain common instruments, music genres, basic terms. Exclude advanced music theory and Italian performance directions.

#### Baseball Jargon - **RECOMMEND AGGRESSIVE CULLING**

83 baseball entries include extremely specialized terms:
- エンタイトルツーベース (ground-rule double) - ID: 1926110 - **EXCLUDE**
- アウトカウント (out count) - ID: 1014730 - **EXCLUDE**
- インハイ (high and inside pitch) - ID: 1023950 - **EXCLUDE**

**Recommendation:** Retain only 10-15 most basic baseball terms (ホームラン, ストライク, etc.). The current set is too specialized for intermediate general learners.

### C. Very Long Words (Display Concerns)

Words over 12 characters may have display/quiz interface issues:

| Reading | Length | Meaning | Recommendation |
|---------|--------|---------|----------------|
| スムージングオペレーション | 14 | smoothing operation | EXCLUDE - Too specialized (finance) |
| フランクフルトソーセージ | 13 | Frankfurt sausage | INCLUDE - Common food item |
| インターネットプロバイダ | 13 | Internet provider | INCLUDE - Common tech term |
| マイナーバージョンアップ | 13 | minor version up | REVIEW - Tech jargon, possibly wasei-eigo |
| メジャーバージョンアップ | 13 | major version up | REVIEW - Tech jargon, possibly wasei-eigo |
| アプリケーションフォーマット | 14 | application format | EXCLUDE - Too technical |
| ダウンロードオンリーメンバー | 14 | download-only member | EXCLUDE - Too specialized |
| ネクストバッターズサークル | 13 | next batter's circle | EXCLUDE - Specialized baseball |
| ロコモティブシンドローム | 13 | locomotive syndrome | EXCLUDE - Medical terminology |
| アプフェルシュトルーデル | 13 | Apfelstrudel | INCLUDE - Common food item |
| カスケードスタイルシート | 13 | cascading style sheets | EXCLUDE - Technical web development |
| ルンペンプロレタリアート | 13 | lumpenproletariat | EXCLUDE - Specialized political science |
| コミュニケーションコスト | 13 | communication cost | REVIEW - Business jargon |

**Display Recommendation:** Test these in the quiz interface. If they don't fit well, consider excluding the most specialized ones.

---

## 3. Extended Katakana Usage

Extended katakana characters (ティ, ディ, ファ, etc.) appear in **126 entries**. This is a good phonetic coverage but requires font verification.

Common extended katakana found:
- ティ/ディ (ti/di sounds)
- ファ/フィ/フェ/フォ (fa/fi/fe/fo sounds)
- ヴ (v sound)
- ウィ/ウェ/ウォ (wi/we/wo sounds)

**Recommendation:**
- Ensure app font properly displays all extended katakana
- Consider creating a dedicated practice set for extended katakana
- These are valuable for intermediate learners as they represent modern loanword phonetics

---

## 4. Wasei-Eigo Analysis

The dataset contains 393 English-source words. Many require review for wasei-eigo (Japanese-coined pseudo-English):

### Confirmed/Likely Wasei-Eigo Candidates

Based on pattern analysis (compound patterns, meanings that don't match standard English):

1. **サインペン** (sign pen) - ID: 1926480
   - Marked as "trademark" category
   - Actually a brand name (Pentel Sign Pen), now genericized in Japanese
   - **Recommendation:** INCLUDE with wasei-eigo flag - common and useful

2. **インハイ** (in-high) - ID: 1023950
   - "high and inside pitch" - baseball jargon
   - This is Japanese baseball terminology, not standard English
   - **Recommendation:** EXCLUDE (too specialized) or FLAG as wasei-eigo

3. **ゲッツー** (get two) - ID: 1048590
   - "double play" in baseball
   - Wasei-eigo abbreviation
   - **Recommendation:** If retained, FLAG as wasei-eigo

4. **ノータイム** (no time) - ID: 1093420
   - Means "making a move immediately" in shogi/go
   - Meaning doesn't match English "no time"
   - **Recommendation:** FLAG as wasei-eigo if retained

5. **マーケットイン** (market-in) - ID: 1925080
   - "market orientation" - Japanese business jargon
   - Not standard English usage
   - **Recommendation:** FLAG as wasei-eigo or EXCLUDE (too specialized)

**Need for Systematic Wasei-Eigo Review:**

The dataset lacks wasei-eigo tagging. Recommend human review of all English-source words to identify:
- Common wasei-eigo that learners should know (ノートパソコン, サラリーマン, etc.)
- Whether common wasei-eigo are even present in this dataset
- Specialized wasei-eigo that should be excluded

**Critical Gap:** The dataset appears to lack many common everyday wasei-eigo terms. Did not find in sampling:
- サラリーマン (salary man)
- オーエル (OL/office lady)
- バイキング (Viking/buffet)
- マンション (mansion/apartment)

These are essential for intermediate learners.

---

## 5. Source Language Distribution Analysis

| Language | Count | Notes |
|----------|-------|-------|
| English | 393 | Majority source; review for wasei-eigo |
| German | 98 | Good representation; includes philosophy terms |
| Italian | ~50+ | Mostly music terms |
| French | ~40+ | Mix of categories |
| Portuguese | 33 | Includes Christian terminology and hanafuda |
| Greek (grc) | ~30+ | Mythology and philosophy |
| Latin | ~15+ | Religious and academic |
| Sanskrit | ~8 | Buddhist terminology |
| Other | ~20+ | Various languages |

**Assessment:** Good linguistic diversity overall, but Portuguese entries skew toward specialized religious/historical content. Greek/Latin entries are heavily philosophical/mythological.

**Recommendation:** The multi-language sourcing is a strength. Consider highlighting language diversity as a learning feature.

---

## 6. Duplicate Analysis

Based on the data structure, exact duplicate readings were not found in the sample review. However, **semantic near-duplicates** likely exist (e.g., multiple baseball terms for similar concepts).

**Recommendation:** Conduct systematic duplicate check focusing on:
- Same reading with multiple entries
- Very similar meanings in same category (especially baseball, music)
- Synonymous terms from different source languages

---

## 7. Overall Assessment by Category

### Categories to EXPAND (Critical Gaps)

1. **Food & Drink** - Currently absent or severely underrepresented
   - Add: レストラン, メニュー, コーヒー, サラダ, デザート, ジュース, ビール, ワイン, etc.
   - Target: 50-80 entries

2. **Everyday Objects** - Currently ~8 entries
   - Add: テーブル, チェア, ベッド, カーテン, タオル, etc.
   - Target: 30-40 entries

3. **Transportation** - Currently ~1 entry
   - Add: バス, タクシー, エレベーター, エスカレーター, etc.
   - Target: 20-30 entries

4. **Animals/Nature** - Currently ~5 entries
   - Add: ライオン, ゴリラ, ペンギン, パンダ, etc.
   - Target: 30-40 entries

5. **Basic Technology** - Underdeveloped
   - Add: パソコン, スマホ, カメラ, テレビ, ラジオ, etc.
   - Target: 40-50 entries

### Categories to REDUCE (Overrepresented/Too Specialized)

1. **Philosophy** - Current ~40 entries
   - Target: 0-5 entries (only culturally common terms)
   - Remove: ~35 entries

2. **Baseball Jargon** - Current 83 entries
   - Target: 10-15 entries (only basic terms)
   - Remove: ~70 entries

3. **Advanced Music Theory** - Current ~50-80 of 228 music entries
   - Target: Keep instruments and common terms
   - Remove: Italian tempo markings, advanced theory

4. **Religious Specialized Terms** - Current ~25 entries
   - Target: 10-15 entries (culturally common only)
   - Remove: Liturgical and specialized theological terms

### Categories to MAINTAIN

1. **Sports (general)** - 80 entries - Good coverage
2. **Music (basic)** - Keep instruments, genres, common terms
3. **Mythology** - 35 entries - Cultural value, appropriate level
4. **Computer/Internet** - ~30 entries - Relevant and useful

---

## 8. Recommendations Summary

### Immediate Actions

1. **EXCLUDE entirely:**
   - Philosophy category (~35-40 entries)
   - Specialized baseball jargon (retain only 10-15 most common, remove ~70)
   - Advanced music theory (remove ~50 entries)
   - Specialized religious terms (remove ~10-15)
   - Medical/anatomical terms (remove ~3)
   - Highly technical computer jargon (remove ~10)
   - **Total to exclude: ~180-200 entries**

2. **FLAG for review:**
   - All potentially offensive terms (reorder meanings or add context) - ~5 entries
   - All very long words (12+ chars) for display testing - ~15 entries
   - Borderline technical terms in each category - ~50 entries

3. **WASEI-EIGO tagging project:**
   - Systematically review all 393 English-source entries
   - Add wasei-eigo flag to appropriate entries
   - Consider adding missing common wasei-eigo

### Content Development Priorities

To balance the dataset for intermediate learners, prioritize adding:

1. **Food & Drink** - 50-80 new entries (CRITICAL)
2. **Everyday Objects** - 30-40 new entries (HIGH)
3. **Transportation** - 20-30 new entries (HIGH)
4. **Animals/Nature** - 30-40 new entries (MEDIUM)
5. **Basic Technology** - 20-30 new entries (MEDIUM)
6. **Common Wasei-Eigo** - 20-30 entries (MEDIUM)

**Target final dataset:** ~900-950 entries after exclusions, then expand to 1,200+ with new everyday vocabulary.

### Quality Assurance

1. **Human review required for:**
   - All flagged offensive/sensitive content
   - All philosophy entries (confirm exclusion)
   - All borderline technical terms
   - Wasei-eigo identification and tagging

2. **Technical testing required for:**
   - Extended katakana font rendering
   - Long word display in quiz interface
   - Mobile display of 12+ character words

3. **Pedagogical review:**
   - Confirm difficulty level appropriate for intermediate learners
   - Ensure cultural context provided where needed
   - Verify learning value vs. specialized knowledge

---

## 9. Category Balance Scorecard

| Aspect | Current State | Target State | Priority |
|--------|--------------|--------------|----------|
| Sports/Baseball ratio | 83:80 (51% baseball) | 15:80 (16% baseball) | HIGH |
| Everyday vs. Specialized | ~30:70 | ~70:30 | CRITICAL |
| Food vocabulary | ~0 entries | 50-80 entries | CRITICAL |
| Philosophy content | ~40 entries | 0-5 entries | HIGH |
| Wasei-eigo tagging | Not tagged | All tagged | HIGH |
| Extended katakana | 126 entries (good) | Maintain | LOW |
| Source diversity | Good mix | Maintain | LOW |
| Long words (12+ chars) | ~15 entries | Test/review | MEDIUM |

---

## Appendix: Sample Excellent Entries

These entries represent the quality and appropriateness we should aim for:

1. **ゲノム** (genome) - ID: 1048610
   - Modern scientific term, culturally relevant, appropriate level
   - German source shows linguistic diversity

2. **フランクフルトソーセージ** (Frankfurt sausage)
   - Common food item, good length for practice
   - Cultural context valuable

3. **サタン** (Satan) - ID: 1056690
   - Culturally common religious term
   - Appropriate for general learners

4. **マントラ** (mantra) - ID: 2832350
   - Religious origin but entered common usage
   - Good example of cross-cultural vocabulary

---

## Files Referenced

- Source data: `/Users/onurorhon/_git/i-heart-katakana/scripts/words_gold.json`
- Analysis script: `/Users/onurorhon/_git/i-heart-katakana/scripts/analyze_gold_set.py`
- This report: `/Users/onurorhon/_git/i-heart-katakana/scripts/curation_report.md`
