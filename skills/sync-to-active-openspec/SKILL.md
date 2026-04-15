---
name: sync-to-active-openspec
description: Sync code changes back to the active openspec. Detects code diffs since the spec was last written, then updates proposal/design/specs/tasks accordingly. Use when implementation has progressed beyond what the spec currently describes.
---

# Sync to Active OpenSpec

Sync code changes back into the active openspec (proposal, design, specs, tasks).

## STEPS

### 1. Find Active OpenSpec
- `git branch --show-current` → fuzzy-match to `ls openspec/changes/`
- No match or multiple → **ask user**. Do NOT guess.
- Announce: **"Your Openspec Changes Module Name Is: `<active>`"**

### 2. Load OpenSpec Instructions
Before modifying ANY file, fetch format instructions per artifact:
```bash
openspec instructions <artifact> --change <active>
# <artifact>: proposal | design | specs | tasks
```
Follow instructions output — it overrides this skill on conflicts.

### 3. Compute Baseline & Diff
```bash
# Earliest per-file commit across all openspec files
for f in openspec/changes/<active>/**/*.md; do
  git log -1 --format='%at %H' -- "$f"
done | sort -n | head -1 | cut -d' ' -f2
# Fallback (untracked): git merge-base HEAD main

# Diff: source changes since baseline, excluding openspec/
git diff <baseline> -- . ':!openspec/'
```
Empty diff → "spec is up to date" → stop.

### 4. Staleness Scan (before adding anything)
Scan every existing openspec file for **stale identifiers** (variables, functions, constants, types, fields, enums). Cross-reference against the diff:
- **Renamed** → update all spec references (e.g. `bDelete` → `eEventType`)
- **Deleted** → remove or rewrite the spec section
- **Replaced** (e.g. magic numbers → enum) → rewrite to reflect new approach
- **Design decisions** → verify mechanism still matches code; modify/remove if not

### 5. Analyze & Sync
Read diff + ALL existing openspec files. Update each:

| File | What to update |
|------|---------------|
| `proposal.md` | Architecture changes, impact/risk, cross-repo deps |
| `design.md` | New/changed design decisions, divergences, risks |
| `specs/*/spec.md` | New/modified/removed requirements (delta format: ADDED/MODIFIED/REMOVED) |
| `tasks.md` | `- [ ]` → `- [x]`, new tasks, validation updates |

### 6. Report
```
## OpenSpec Synced: <change-name>
**Baseline**: <hash> (<date>) | **Diff**: <N> files, +<add>/-<del>
### Updated: proposal.md / design.md / specs/ / tasks.md
- <what changed per file>
```

## MUST DO

- **Read before write** — always read existing openspec files + diff before any edits
- **Add** what diff introduces that spec doesn't cover
- **Remove** spec content that no longer matches code
- **Modify** spec content whose behavior changed
- **Staleness scan** before adding new content — catch renamed/deleted/replaced identifiers
- Only diff-justified updates — every update traceable to a specific change
- Match existing language/style (zh-TW / English). Ambiguous → TODO or ask user
- **Idempotent** — running twice with no new changes produces no additional edits

## MUST NOT DO

- NEVER modify `openspec/specs/` (main specs) — delta changes only under `openspec/changes/<active>/`
- NEVER run `openspec archive` or move/delete/rename change files
- NEVER fabricate changes not supported by the diff
- NEVER guess the active change — ask user if ambiguous
- NEVER skip the staleness scan
