# Glossary – Japanese Linguistic Terms

Terminology used throughout this project, organized for developers and users.

---

## Writing Systems

| Term | Japanese | Definition |
|------|----------|------------|
| **katakana** | 片仮名 (カタカナ) | Angular syllabary used for foreign loanwords, onomatopoeia, emphasis, and technical terms. The focus of this app. |
| **hiragana** | 平仮名 (ひらがな) | Cursive syllabary for native Japanese words, particles, and verb endings. |
| **kana** | 仮名 (かな) | Collective term for both hiragana and katakana syllabaries. |
| **romaji** | ローマ字 (ろーまじ) | Romanization of Japanese using Latin alphabet. Used for pronunciation guidance. |

---

## Phonetic Patterns

These are the pattern classifications used in `data/kana.json` and `data/words.json`.

*Note: Documentation uses macrons for long vowels (ō, ū). Code/data uses ASCII (`ou`, `uu`) for compatibility.*

| Term | Code | Japanese | Description | Examples |
|------|------|----------|-------------|----------|
| **gojūon** | `gojuon` | 五十音 (ごじゅうおん) | "Fifty sounds" – the basic 46 katakana characters organized in a grid by consonant and vowel. | ア イ ウ エ オ, カ キ ク ケ コ |
| **dakuon** | `dakuon` | 濁音 (だくおん) | "Voiced sounds" – consonants marked with dakuten (゛) that voice unvoiced consonants. | ガ ギ グ ゲ ゴ, ザ ジ ズ ゼ ゾ |
| **handakuon** | `handakuon` | 半濁音 (はんだくおん) | "Half-voiced sounds" – P-column marked with handakuten (゜). | パ ピ プ ペ ポ |
| **yōon** | `youon` | 拗音 (ようおん) | "Contracted sounds" – combinations using small ャ, ュ, or ョ for palatalized consonants. | キャ, シュ, チョ, ギャ |
| **extended** | `extended` | 拡張音 (かくちょうおん) | Modern additions for foreign sounds not in traditional Japanese phonology. | ティ, ディ, ファ, ヴァ, シェ |

### Related Sound Features

| Term | Japanese | Description | Examples |
|------|----------|-------------|----------|
| **sokuon** | 促音 (そくおん) | Small ッ creating consonant doubling or glottal stop. Common in loanwords. | サッカー (sakkā), ベッド (beddo) |
| **chōon** | 長音 (ちょうおん) | Vowel lengthening indicated by ー (chōonfu). Critical for meaning. | コーヒー (kōhī), ケーキ (kēki) |

### Diacritic Marks

| Term | Japanese | Description |
|------|----------|-------------|
| **dakuten** | 濁点 (だくてん) | The two-dot mark (゛) that voices consonants. |
| **handakuten** | 半濁点 (はんだくてん) | The circle mark (゜) that creates P-sounds. |
| **chōonfu** | 長音符 (ちょうおんふ) | The horizontal bar (ー) indicating vowel lengthening. |

---

## Loanword Categories

| Term | Japanese | Definition |
|------|----------|------------|
| **gairaigo** | 外来語 (がいらいご) | "Words from outside" – loanwords borrowed from foreign languages, typically written in katakana. The core content of this app. |
| **wasei-eigo** | 和製英語 (わせいえいご) | "Japanese-made English" – words that sound English but aren't used (or mean something different) in actual English. See [Wasei-Eigo](#wasei-eigo-examples) below. |
| **katakana eigo** | カタカナ英語 | English words written in katakana following Japanese phonetic constraints. Broader than wasei-eigo; includes correctly borrowed terms. |

### Wasei-Eigo Examples

These words appear to be English but won't be understood by English speakers:

| Katakana | Literal | Actual English |
|----------|---------|----------------|
| サラリーマン | "salary man" | office worker |
| ノートパソコン | "note personal computer" | laptop |
| アウトコース | "out course" | outside pitch (baseball) |
| バージョンアップ | "version up" | update, upgrade |

---

## Onomatopoeia

Japanese has an unusually rich system of mimetic words, often written in katakana for emphasis.

| Term | Japanese | Definition | Examples |
|------|----------|------------|----------|
| **gionogo** | 擬音語 (ぎおんご) | Words imitating actual sounds. | ワンワン (dog bark), ガタガタ (rattle) |
| **gitaigo** | 擬態語 (ぎたいご) | Words describing states/conditions without sound. | キラキラ (sparkling), フワフワ (fluffy) |
| **giseigo** | 擬声語 (ぎせいご) | Subset of gionogo for human/animal voices. | ニャーニャー (meow), ワハハ (laughter) |

The collective term **onomatope** (オノマトペ, from French) covers all these categories.

---

## Language Origins

Common source languages for katakana loanwords:

| Language | Japanese | Historical Context | Examples |
|----------|----------|-------------------|----------|
| English | 英語 (えいご) | Modern era – majority of loanwords | コンピューター, テレビ |
| Portuguese | ポルトガル語 | 16th-century trade | パン (bread), タバコ (tobacco) |
| Dutch | オランダ語 | Edo-period science/medicine | ランドセル (school bag), メス (scalpel) |
| German | ドイツ語 | Medical, philosophical, musical terms | カルテ (chart), アルバイト (part-time job) |
| French | フランス語 | Cuisine, fashion, art | アンケート (questionnaire), アトリエ (studio) |

---

## Data & Curation Terms

Terms used in the curation pipeline and data schema:

| Term | Definition |
|------|------------|
| **JMdict** | Open-source Japanese-English dictionary. Source for word extraction. |
| **ent_seq** | JMdict entry sequence number. Used as word ID. |
| **originLanguage** | ISO language code for the source language (eng, por, deu, etc.). |
| **originalWord** | The foreign word before Japanese adaptation, from JMdict. |
| **originalWordInferred** | Cleaned first meaning when JMdict lacks explicit source word. |
| **parentCategory** | Broad category for UI filtering (Food, Technology, etc.). |
| **patterns** | Array of phonetic patterns present in a word. |

---

## See Also

- `ARCHITECTURE.md` – Data schema and technical patterns
- `OVERVIEW.md` – Product requirements and content scope
- `scripts/wasei_eigo_database.json` – Curated wasei-eigo database
