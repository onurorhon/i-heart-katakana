# Known Issues

Technical quirks and limitations to be aware of during development.

---

## LLDB Debugger Causes Unresponsiveness

**Symptom:** App takes ~1 minute to become responsive on physical devices when launched from Xcode.

**Cause:** LLDB debugger attachment has severe performance overhead with this project's SwiftData + SwiftUI stack.

**Workaround:** "Debug executable" is disabled in the Xcode scheme (Product → Scheme → Edit Scheme → Run → Info).

**Development approach:**
- Use `print()` statements and Xcode Previews for debugging.
- If breakpoints are needed, temporarily re-enable "Debug executable" and wait for the app to become responsive.

---

## unsafeForcedSync Warning

**Symptom:** Xcode console shows "Potential Structural Swift Concurrency Issue: unsafeForcedSync called from Swift Concurrent context" when using the app or switching to app switcher.

**Cause:** Interaction between `@Observable` and SwiftUI's lifecycle. This is a known friction point in Apple's frameworks.

**Impact:** None. The warning is informational - the app works correctly.

**Action:** Ignore it. No fix needed unless Apple provides guidance in future SwiftUI updates.

---

## PracticeView Scroll Stutter

**Symptom:** Occasional scroll stutter (30-40% of swipes) when navigating between cards in PracticeView. This can be tested with a screen recording of the wipes on the iphone, then watching in quicktime frame by frame.

**Cause:** ForEach re-evaluates `itemForPage()` for all visible cards when navigation state (`history`, `pendingNextIndex`) changes. Theme color functions also access settings state.

**Mitigation applied:** Refactored to overlay architecture (Jan 2025) - current-page-specific UI (peek hint, answer reveal) moved to single-instance overlays instead of per-card rendering. This reduced but didn't eliminate the stutter.

**Future fix:** Pre-compute and cache card data and theme colors into stable arrays that don't change during scroll. Revisit during Phase 2 when adding 20 themes and fonts.

