# AI Context – I❤️Katakana

## Startup Workflow

Execute in order when beginning a session.

**1. Read core docs**
- `CLAUDE.md` – Critical rules that must never be violated
- `OVERVIEW.md` – Product requirements and scope
- `ARCHITECTURE.md` – Technical decisions, component patterns, data flow
- `RULES.md` – Never/always rules, conventions
- `KNOWN_ISSUES.md` – Technical quirks to be aware of

**2. Check recent work**
```bash
git log --oneline -5
git status
```

**3. Verify current state**
- Open Xcode project (if exists)
- Build and run in simulator
- Confirm it works

**4. Ask user**
- "What should we work on?"

---

## Shutdown Workflow

Execute in order when ending a session.

**1. Document changes**

If architectural decisions changed:
- Update `ARCHITECTURE.md` with new patterns
- Focus on WHY and HOW, not appearance
- Document component responsibilities, data flow, state management

If new rules discovered:
- Update `RULES.md` with new never/always rules
- Document new conventions

**2. Run context-architect agent**

Before committing, run the `context-architect` agent to audit documentation for drift:
- Catches statistics, checkmarks, historical reports that don't belong.
- Reports violations with suggested fixes.
- If violations found, fix them before proceeding.

**3. Git commit and push**

Commit all changes (documentation and code) with a descriptive message. Push to GitHub.

```bash
git add .
git commit -m "<description of changes>"
git push origin main
```

**4. Session report**

Provide the user with:

```
## Session Complete

**Files Modified:**
- [list files]

**Changes Made:**
- [bullet points of key changes]

**Current State:**
- Working/Has issues: [description]

**Next Priorities:**
- [3-5 items for next session]
```
