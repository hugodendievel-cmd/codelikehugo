---
description: "Show sprint progress at a glance. Use when user says 'status', 'show progress', 'sprint status', 'where are we', or 'what's done'. Args: [optional epic number]"
---

## Context
- Current branch: !`git branch --show-current`

# Status

Display the current sprint progress in a clear, visual format.

Filter: $ARGUMENTS

## Step 1: Detect Artifacts

Check which format is present:

**BMAD format** — if `_bmad-output/` exists:
- Read `_bmad-output/implementation-artifacts/sprint-status.yaml`
- Stories dir: `_bmad-output/implementation-artifacts/stories/`

**codelikehugo format** — if `specs/` exists:
- Read `specs/sprint-status.yaml`
- Stories dir: `specs/stories/`

If neither exists: "No sprint status found. Run `/init` then `/plan` first."

## Step 2: Parse & Display

Read the sprint status file. If an epic number was given, filter to that epic only.

Display:

```
## Sprint Status

Project: {name}
Updated: {date}

### Epic 1: {Name} — {status_emoji} {status}
  {status_emoji} 1-1 {title}           {status}
  {status_emoji} 1-2 {title}           {status}
  {status_emoji} 1-3 {title}           {status}

### Epic 2: {Name} — {status_emoji} {status}
  {status_emoji} 2-1 {title}           {status}
  ...

---
Progress: {done_count}/{total_count} stories done ({percentage}%)
In flight: {in_progress_count} in-progress, {review_count} in review
Remaining: {backlog_count} backlog, {ready_count} ready
```

Status indicators:
- `done` → [x]
- `review` → [~]
- `in-progress` → [>]
- `ready` / `ready-for-dev` → [.]
- `backlog` → [ ]

## Step 3: Surface Issues (if any)

Check for potential problems and mention them:
- Stories stuck in `in-progress` with no recent git activity
- Stories in `review` that might have stale branches
- Epics marked `in-progress` where all stories are actually `done`
- Stories out of order (later story done but earlier one isn't)

Only mention issues if found — don't report "no issues" if everything looks clean.
