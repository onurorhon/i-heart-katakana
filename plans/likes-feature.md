# Likes Feature Implementation

## Context

Users need to like/unlike words and filter to show only liked words. Likes are local-only (SwiftData) for now. iCloud sync deferred until Apple Developer Program enrollment ($99/year) at launch time — one-line config change when ready.

## Plan

- [x] **Step 1: Update ModelContainer schema**
  **File: `IHeartKatakana/IHeartKatakanaApp.swift`**
  - Replace `Item.self` with `LikedWord.self` in the schema
  - Local-only SwiftData (no CloudKit for now)
  - Delete `IHeartKatakana/Item.swift` (unused Xcode template)

- [x] **Step 2: iCloud sync — DEFERRED**
  - Requires Apple Developer Program ($99/year)
  - Will add at launch: `cloudKitDatabase: .automatic` + CloudKit capability in Xcode

- [x] **Step 3: Create LikeService**
  **New file: `IHeartKatakana/Services/LikeService.swift`**
  - `@MainActor @Observable` class (matches ContentService/TTSService pattern)
  - Takes `ModelContext` in init
  - Maintains `likedWordIds: Set<String>` cache for O(1) lookups
  - Methods: `isLiked(_:)`, `toggleLike(wordId:)`, `loadLikedIds()`
  - CRUD via SwiftData `ModelContext`

- [x] **Step 4: Wire LikeService into ContentView**
  **File: `IHeartKatakana/ContentView.swift`**
  - Get `modelContext` from `@Environment(\.modelContext)`
  - Create `LikeService` in `.task` (same place `contentService.load()` is called)
  - Pass `likeService` to `PracticeView` and `ActionsMenu`

- [x] **Step 5: Implement heart button in PracticeView**
  **File: `IHeartKatakana/Views/PracticeView.swift`**
  - Add `likeService: LikeService?` property
  - Replace TODO stub at line 664 with `likeService.toggleLike(wordId:)`
  - Toggle icon between `heart` and `heart.fill` based on `likeService.isLiked(_:)`
  - Hide the heart button entirely in kana mode (only visible when `activeContentType == .word`)

- [x] **Step 6: Add "Liked" filter to ActionsMenu**
  **File: `IHeartKatakana/Views/ActionsMenu.swift`**
  - Add `likeService: LikeService?` property
  - Insert "Liked" row after "All" in category submenu (only visible when liked words exist)
  - Uses `settings.selectedCategory = "Liked"` as sentinel value

- [x] **Step 7: Handle "Liked" filter in PracticeView**
  **File: `IHeartKatakana/Views/PracticeView.swift`**
  - In `rebuildFilteredCache()` (line 556): when `activeSelectedCategory == "Liked"`, filter words by `likeService.isLiked(word.id)` instead of `parentCategory`

- [x] **Step 8: iCloud sync refresh**
  **File: `IHeartKatakana/ContentView.swift`**
  - On `willEnterForegroundNotification`, call `likeService.loadLikedIds()` to pick up changes synced while backgrounded

## Files modified
| File | Change |
|------|--------|
| `IHeartKatakanaApp.swift` | Schema: `LikedWord.self`, CloudKit config |
| `Item.swift` | Delete |
| **New:** `Services/LikeService.swift` | SwiftData CRUD + in-memory cache |
| `ContentView.swift` | Create & pass LikeService, foreground refresh |
| `Views/PracticeView.swift` | Heart button, "Liked" filter in cache rebuild |
| `Views/ActionsMenu.swift` | "Liked" category row |

## Verification
1. [x] Build and run on device
2. [x] Tap heart on a word card — icon fills
3. [x] Liked category filter works
4. [ ] Kill and relaunch app — likes persist
5. [ ] Unlike all words while in "Liked" filter — empty state

## Status: COMPLETE (tested on device)
