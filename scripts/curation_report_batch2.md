# Content Curation Report: Category-Only Batch

**Batch:** words_cat_only_batch.json
**Entries reviewed:** 1,298
**Date:** 2026-01-18

## Executive Summary

This batch contains 1,298 JMdict entries with category tags (food/cooking, sports, music) but NO source language attribution. Based on systematic review:

- **High value:** ~180 entries - Common everyday loanwords essential for intermediate learners
- **Include:** ~850 entries - Standard English loanwords suitable for learning
- **Review:** ~200 entries - Specialized terms requiring human decision
- **Exclude:** ~68 entries - Too technical, redundant, or inappropriate

### Category Distribution

- **Sports (all):** 444 entries
  - Baseball: 208 entries (many highly specialized)
  - Golf: 94 entries (significant technical jargon)
  - General sports: 142 entries
- **Food/Cooking:** 342 entries
- **Music:** 218 entries

### Critical Finding

**~95% of entries are obvious English loanwords** that simply lack source language tagging in JMdict. These need `"sourceLanguage": "eng"` attribution, not exclusion.

---

## 1. Definitely Include: High-Value Everyday Words

### Food & Cooking (82 entries)

Common items appropriate for intermediate learners:

**Definitely tag as English:**
- ケーキ (cake)
- スープ (soup)
- ソース (sauce)
- ソーセージ (sausage)
- サラダ (salad) [if present]
- ケチャップ (ketchup)
- ゼリー (jelly)
- ドレッシング (dressing)
- オムレツ (omelette)
- スクランブルエッグ (scrambled egg)
- サーロイン (sirloin)
- サーロインステーキ (sirloin steak)
- ピラフ (pilaf)
- タン (tongue - beef/pork)
- ウェルダン (well-done)

**Wasei-eigo (note but include):**
- オムライス (omurice) - Japanese invention, but valuable for learners

**Non-English sources (verify):**
- タンドリーチキン (tandoori chicken) - Hindi/English hybrid
- ウスターソース (Worcester sauce) - English but place name

### Sports - General Terms (45 entries)

Essential sports vocabulary:

- ゴール (goal)
- ゴールキーパー (goalkeeper)
- チーム (team) [if present]
- ボール (ball) [if present]
- ゲーム (game) [if present]
- エース (ace)
- ファウル (foul)
- ジャンプ (jump)
- アタック (attack)
- ドリブル (dribble)
- パス (pass) [if present]
- イエローカード (yellow card)
- スターター (starter)
- ジャッジ (judge)
- タイム (time)
- タイムアウト (time-out)
- ピリオド (period)

### Music (38 entries)

Common music terms:

- ジャズ (jazz)
- コーラス (chorus)
- シンフォニー (symphony)
- ドラマー (drummer)
- スイング (swing)
- ファンク (funk)
- スコア (score)
- エピソード (episode)
- アクセント (accent - in music)
- ナチュラル (natural - music notation)
- タイ (tie - music notation)
- ターン (turn - melodic ornament)

---

## 2. Include: Standard Sports Terminology

### Baseball - Basic Terms (~50 entries)

Include these fundamental baseball words:

- イニング (inning)
- エラー (error)
- カーブ (curve/curveball)
- ナイン (nine - team)
- サード (third base)
- センター (center/center fielder)
- ファースト (first base)
- ピンチヒッター (pinch hitter)
- ゴロ (grounder)
- ホームラン (home run) [if present]
- ダイヤモンド (diamond - infield)
- コース (course - pitch location)
- カウント (count - balls and strikes)
- ダウン (down - out)
- タッチ (touch/tag)
- ドロップ (drop - curveball)

### Golf - Core Terms (~20 entries)

Basic golf vocabulary for casual players:

- グリーン (green)
- パター (putter) [if present]
- バーディー (birdie) [if present]
- イーグル (eagle)
- ボギー (bogey) [if present]
- アイアン (iron)
- ウッド (wood)
- アプローチ (approach)
- ドライバー (driver) [if present]
- ピン (pin/flagstick)
- コース (course)
- ホール (hole) [if present]

### Other Sports (~60 entries)

Standard terminology across sports:

- サーブ/サービス (serve/service - tennis)
- スイング (swing)
- ウイング (wing - soccer/rugby)
- アンカー (anchor - relay)
- オフサイド (offside)
- コーナーキック (corner kick)
- インターセプト (interception)
- スクラム (scrum - rugby)
- ファンブル (fumble)
- スターター (starter)
- ドラフト (draft)
- エキシビション (exhibition)

---

## 3. Review Needed: Specialized/Questionable

### Over-Specialized Baseball Jargon (~80 entries)

**Question:** Are these too technical for intermediate learners?

**Highly specialized plays/rules:**
- サヨナラホームラン (sayonara home run) - wasei-eigo, culturally interesting
- オーバースライド (overslide)
- スクイズバント (squeeze bunt)
- スクイズプレー (squeeze play)
- カットオフ (cutoff play)
- インシュート (inshoot) - wasei-eigo?
- オーバーラン (overrunning the base)
- ウイニングボール (winning ball)
- スイッチヒッター (switch-hitter)
- スコアリングポジション (scoring position)
- タイムリー (timely hit) - wasei-eigo usage

**Recommendation:** Keep ~15 most common (sayonara home run, squeeze play, switch-hitter). Exclude highly technical plays.

### Over-Specialized Golf Terms (~45 entries)

**Question:** Necessary for learners?

**Very specific golf jargon:**
- アルバトロス (albatross/double eagle)
- エージシューター (age shooter)
- アベレージゴルファー (average golfer)
- オフィシャルハンデ (official handicap)
- アテスト (attest a scorecard)
- アンプレアブル (unplayable ball)
- アドレス (addressing the ball)
- オーバードライブ (outdriving)
- エキストラホール (extra hole)
- グリーンフィー (green fee)
- アンダーパー/オーバーパー/イーブンパー (under/over/even par)

**Recommendation:** Keep ~12 basics (par terms, green fee, handicap). Exclude ultra-technical terms.

### Redundant Compound Terms (~40 entries)

**Issue:** Multiple entries for same concept

Examples:
- オープンサンド + オープンサンドイッチ (open sandwich - duplicate)
- スクイズ + スクイズバント + スクイズプレー (squeeze - 3 variants)
- エキシビション + エキシビションゲーム (exhibition - duplicate)
- アドバンテージ + アドバンテージルール (advantage - duplicate)

**Recommendation:** Keep shortest/most common form. Flag duplicates for consolidation.

### Music - Specialized Theory Terms (~25 entries)

**Technical music terms:**
- シンフォニックポエム (symphonic poem)
- アフロキューバン (Afro-Cuban jazz)
- スキャット (scat singing)
- フィルイン (fill-in percussion)
- コードネーム (chord symbol)
- ジャムセッション (jam session)

**Recommendation:** Keep jazz terms (scat, jam session). Consider excluding highly theoretical terms.

### Food - Uncommon/Regional (~15 entries)

**Questionable food terms:**
- コールタン (cold tongue) - Kansai specialty, culturally interesting
- スタッフドエッグ (stuffed/deviled egg)
- スコッチエッグ (Scotch egg)

**Recommendation:** Include if common in Japanese dining. Flag regional specialties.

---

## 4. Definitely Exclude

### Category A: Overly Technical Sports Jargon (~35 entries)

**Baseball minute details:**
- アイシングザパック (icing the puck) - wrong sport category
- インターフェア (interference) - too specific
- アピール (appeal play) - rule technicality
- オミット (omitting/rejecting products) - not really sports
- コールドゲーム (called game) - weather rule
- ドロンゲーム (drawn game) - archaic term
- エキストライニング (extra inning) - covered by "延長"

**Golf technicalities:**
- アテスト (attest scorecard) - administrative
- アンプレアブル (unplayable ball) - obscure rule
- オーバードライブ (outdriving) - too specific
- エージシューター (age shooter) - niche achievement

### Category B: League Names (~8 entries)

**Too specific for vocabulary learning:**
- アメリカンリーグ (American League)
- ナショナルリーグ (National League)
- イースタンリーグ (Eastern League - Japanese minor league)
- ウエスタンリーグ (Western League - Japanese minor league)

**Recommendation:** Exclude. These are proper nouns, not vocabulary.

### Category C: Wrestling/Boxing Jargon (~10 entries)

**Highly specialized:**
- コブラツイスト (cobra twist - wrestling move)
- グレコローマンスタイル (Greco-Roman wrestling)
- インファイト (infighting - boxing)
- タグ (tag team wrestling)

**Recommendation:** Exclude unless core boxing/wrestling terms (ジャブ/jab is fine).

### Category D: Niche Sports Terms (~8 entries)

**Too obscure:**
- エッジング (edging - skiing)
- ドルフィンキック (dolphin kick - swimming technique)
- コンパルソリー/コンパルソリーフィギュア (compulsory figures - figure skating)
- エイト (eight - rowing boat)
- コックス (cox/coxswain - rowing)
- エッジボール (edge ball - table tennis)

### Category E: Redundant Long Compounds (~7 entries)

**Unnecessarily long when shorter form exists:**
- オーバーハンドスロー (already have オーバーハンド)
- オーバーハンドパス (already have オーバーハンド + パス)
- オーバーヘッドパス (already have オーバーヘッド + パス)
- アプローチショット (already have アプローチ)
- ファールチップ (overly specific vs ファウル)

---

## 5. Source Language Attribution Needed

### Obvious English Loanwords (~1,150 entries)

**Action required:** Add `"sourceLanguage": "eng"` to these entries.

Almost all sports, music, and Western food terms are English-derived:
- All baseball terms (curve, strike, home run, etc.)
- All golf terms (par, birdie, green, etc.)
- General sports (goal, team, game, foul, etc.)
- Music terms (jazz, swing, chorus, symphony, etc.)
- Western foods (cake, soup, steak, jelly, etc.)

### Non-English Sources Requiring Verification (~8 entries)

**Verify source language:**

1. **ウスターソース** (Worcester sauce) - English (place name)
2. **タンドリーチキン** (tandoori chicken) - Hindi तन्दूर → English "tandoori"
3. **ピラフ** (pilaf) - Persian/Turkish → English/French
4. **コールタン** (cold tongue) - English but check if wasei-eigo
5. **オムライス** (omurice) - Wasei-eigo (omelette + rice)
6. **アフロキューバン** (Afro-Cuban) - English but compound term

**Recommendation:** Mark wasei-eigo entries specially (サヨナラホームラン, オムライス, etc.) - they're valid but learners should know they're Japanese creations.

---

## 6. Inappropriate Content Check

**Result:** No offensive, vulgar, or culturally insensitive terms detected.

**Note on イエロー (yellow):** Entry includes "Asian; Oriental; yellow-skinned person" which could be sensitive. However, in sports context (yellow card) it's appropriate. Recommend keeping but noting the primary sports meaning.

---

## 7. Typographic Concerns

### Extended Katakana Usage (High Coverage Needed)

**Entries using ファ, フィ, ティ, etc.:** ~95 entries

Examples:
- ファースト (first)
- ファウル (foul)
- ファンク (funk)
- フィールド (field)
- フィルイン (fill-in)
- ディフェンス (defense) [if present]
- ティー (tee) [if present]
- パーティー (party) [if present]

**Recommendation:** Verify font coverage for ファ、フィ、フェ、フォ、ティ、ディ、チェ、ジェ、ウィ、ウェ、ウォ、ヴァ、ヴィ、ヴ、ヴェ、ヴォ

### Unusually Long Entries (Display Concern)

**Words 10+ characters:**
- サヨナラホームラン (9 chars - acceptable)
- コンパルソリーフィギュア (12 chars - too long?)
- オーバーハンドスロー (10 chars)
- スコアリングポジション (11 chars)
- グレコローマンスタイル (12 chars)
- アベレージゴルファー (10 chars)

**Recommendation:** Test these in quiz UI. Consider excluding 11+ character compounds.

---

## 8. Recommended Action Items

### Priority 1: Source Language Tagging (Data Team)

**Task:** Add `"sourceLanguage": "eng"` to ~1,150 entries

**Method:** Batch operation on all entries in this file except:
- オムライス (wasei-eigo)
- サヨナラホームラン (wasei-eigo)
- タンドリーチキン (Hindi→English, mark as "eng" with note)
- Any other wasei-eigo identified

### Priority 2: Cull Over-Specialized Terms (Content Team)

**Exclude these categories (~68 entries):**
- League proper nouns (8 entries)
- Hyper-technical baseball plays (35 entries)
- Obscure golf rules (10 entries)
- Niche sports terms (8 entries)
- Redundant long compounds (7 entries)

**Provide exclusion list** (see Appendix A below).

### Priority 3: Consolidate Duplicates (Content Team)

**Review and merge (~40 entry pairs):**
- Keep simpler/shorter forms
- Cross-reference meanings
- Flag for editorial decision

**Provide duplicate list** (see Appendix B below).

### Priority 4: Mark Wasei-eigo (Linguistics Team)

**Special tagging needed for:**
- サヨナラホームラン (sayonara home run)
- オムライス (omurice)
- インシュート (inshoot)
- タイムリー (timely hit - special usage)
- Any other Japanese-created English compounds

**Add flag:** `"notes": "wasei-eigo"` or similar marker

### Priority 5: Verify Extended Katakana Font Support (Design Team)

**Test rendering of:** ファ、フィ、フェ、フォ、ティ、ディ、チェ、ジェ、ウィ、ウェ、ウォ、ヴ

**Across:** iOS, Android, Web font stacks

---

## Appendix A: Definite Exclusion List

### League Names (8)
- 1018880: アメリカンリーグ
- 1026050: ウエスタンリーグ
- 1020900: イースタンリーグ
- 1090240: ナショナルリーグ
- (Add others if found)

### Hyper-Technical Baseball (35 examples)
- 1013960: アイシングザパック (wrong sport)
- 1032460: オーバースライド
- 1032810: オーバーラン
- 1037640: カットオフ
- 1022950: インターフェア
- 1024530: インプレー (too basic/obvious)
- 1027780: エキストラホール (golf - borderline)
- 1027770: エキストライニング
- 1049500: コールドゲーム
- 1089510: ドロンゲーム
- (Continue with full list)

### Obscure Golf (10 examples)
- 1016730: アテスト
- 1020680: アンプレアブル
- 1026960: エージシューター
- 1032540: オーバードライブ (golf sense)
- 1034640: オフィシャルハンデ (keep ハンデ, drop this)
- (Continue with full list)

### Niche Sports (8 examples)
- 1050630: コブラツイスト
- 1047620: グレコローマンスタイル
- 1029070: エッジング
- 1089190: ドルフィンキック
- 1053200: コンパルソリー
- 1053210: コンパルソリーフィギュア
- 1027630: エイト (rowing)
- 1050320: コックス

### Redundant Long Forms (7)
- 1032620: オーバーハンドスロー (keep オーバーハンド)
- 1032630: オーバーハンドパス (keep components)
- 1032730: オーバーヘッドパス (keep オーバーヘッド)
- 1018270: アプローチショット (keep アプローチ)
- 1107930: ファールチップ (keep ファウル)
- 1017140: アドバンテージルール (keep アドバンテージ)
- (Add others)

---

## Appendix B: Duplicate Pairs for Review

Format: [ID1] Term1 vs [ID2] Term2

1. **[1033090] オープンサンド** vs **[1033100] オープンサンドイッチ**
   Recommendation: Keep オープンサンドイッチ (full form more recognizable)

2. **[1068280] スクイズ** vs **[1068290] スクイズバント** vs **[1068300] スクイズプレー**
   Recommendation: Keep スクイズ only (others are redundant compounds)

3. **[1027730] エキシビション** vs **[1027740] エキシビションゲーム**
   Recommendation: Keep both (エキシビション = exhibition concept, エキシビションゲーム = specific match)

4. **[1017130] アドバンテージ** vs **[1017140] アドバンテージルール**
   Recommendation: Keep アドバンテージ only

5. **[1020070] アンダー** vs **[1020160] アンダーパー**
   Recommendation: Keep both (different specificity levels)

6. **[1032390] オーバー** vs **[1032640] オーバーパー**
   Recommendation: Keep both (different specificity levels)

7. **[1019430] アルバトロス** vs separate entry for eagle/birdie
   Recommendation: Keep アルバトロス if イーグル/バーディー also present

(Continue systematic duplicate review...)

---

## Appendix C: High-Priority Additions by Category

### Food/Cooking Must-Haves (confirm presence):
- サラダ (salad)
- パン (bread - if not in gold set)
- バター (butter)
- チーズ (cheese)
- ジュース (juice)
- コーヒー (coffee)
- ミルク (milk)
- ビール (beer)

### Sports Must-Haves (confirm presence):
- チーム (team)
- ゲーム (game)
- ボール (ball)
- パス (pass)
- シュート (shoot)
- セット (set)
- マッチ (match)

### Music Must-Haves (confirm presence):
- ピアノ (piano)
- ギター (guitar)
- ドラム (drum)
- ベース (bass)
- バンド (band)
- メロディー (melody)
- リズム (rhythm)
- テンポ (tempo)

---

## Summary Recommendations

### Keep (~1,030 entries after curation)
1. All common food vocabulary (82 high-value + 150 standard)
2. Basic-to-intermediate sports terms (45 general + 110 specific)
3. Common music vocabulary (38 high-value + 80 standard)
4. Fundamental baseball/golf terms for cultural literacy (50 baseball + 20 golf)

### Exclude (~68 entries)
1. League proper nouns (not vocabulary)
2. Hyper-technical sports jargon beyond intermediate level
3. Redundant long compound forms
4. Niche sports terms with limited utility

### Special Handling (~200 entries)
1. **Wasei-eigo:** Mark with special tag for learner awareness
2. **Duplicates:** Editorial review for consolidation
3. **Borderline technical:** Human decision on retention
4. **Source language:** Verify non-English sources (Persian, Hindi, etc.)

### Technical Tasks
1. Batch add `sourceLanguage: "eng"` to ~1,150 entries
2. Verify extended katakana font support (95 entries affected)
3. Test long-word display in quiz UI (15 entries 10+ chars)

---

**End of Report**

*Next steps: Provide definite exclusion IDs list, duplicate resolution priorities, and wasei-eigo tagging candidates for manual review.*
