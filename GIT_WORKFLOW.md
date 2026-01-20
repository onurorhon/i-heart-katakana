# Git Workflow

Instructions for Claude Code to execute git operations via natural language.

---

## Save My Work

When user says: "save my work", "commit this", "save current state"

```bash
git add .
git commit -m "<description based on what changed>"
```

---

## Save Before Experimenting

When user says: "save before I try something", "create a save point", "backup before experimenting"

```bash
git add .
git commit -m "Save point: <current state description>"
```

---

## Undo Recent Changes

When user says: "undo my changes", "go back to last save", "discard what I just did"

```bash
git checkout .
```

Confirm with user first – this discards all uncommitted work.

---

## Show Recent History

When user says: "show me recent commits", "what did I do recently", "show history"

```bash
git log --oneline -10
```

---

## Go Back to Previous State

When user says: "go back to [description]", "restore to earlier today", "undo everything since [description]"

1. Show recent commits: `git log --oneline -10`
2. Confirm which commit with user.
3. Execute: `git reset --hard <commit>`

Warn user this is destructive.

---

## Push to GitHub

When user says: "push to github", "back up to remote", "sync to github"

```bash
git push origin main
```

---

## Commit Message Guidelines

- Be descriptive: "Add practice view with word display" not "update."
- Reference what changed: "Fix TTS not playing on reveal."
- No AI disclaimers: Never include "Generated with Claude" or similar.
