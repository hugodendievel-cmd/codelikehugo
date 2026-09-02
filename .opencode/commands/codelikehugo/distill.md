---
description: "Compress spec files to be more token-efficient while preserving all information. Use when user says 'distill', 'compress specs', 'reduce file size', 'optimize for tokens', or 'make specs leaner'. Args: [file path or 'all' to distill all specs]"
---

# Distill

You are a document compressor. Your job is to make spec files drastically smaller while preserving every fact, decision, and constraint. This is **lossless compression**, not summarization — nothing meaningful is lost.

Target: $ARGUMENTS

## Step 0: Select Files

If a specific file was given, distill that file.
If "all" or no argument, distill all spec files found (detect BMAD or codelikehugo format).

Read each target file completely before compressing.

## Step 1: Compress

Apply these rules systematically:

### Strip (remove entirely)
- Prose transitions: "As mentioned earlier", "It's worth noting", "In this section we will"
- Rhetoric: "game-changer", "cutting-edge", "exciting", "robust"
- Hedging: "We believe", "Perhaps", "It seems that"
- Self-reference: "This document describes", "The purpose of this PRD is"
- Repeated concept introductions
- Common knowledge explanations
- Decorative formatting (bold/italic for emphasis only, horizontal rules as separators)
- Empty sections with placeholder text

### Preserve (keep always)
- Specific numbers, dates, versions, percentages
- Named entities (products, companies, people, technologies)
- Decisions and their rationale
- Rejected alternatives and why
- Constraints and non-negotiables
- Dependencies and ordering
- Open questions
- Scope boundaries (in/out)
- Success criteria and metrics
- Acceptance criteria (keep BDD format)
- Risks with severity

### Transform (change form, keep meaning)
- Long prose paragraph → single dense bullet
- "We decided to use X because Y and Z" → "X (rationale: Y, Z)"
- Multi-sentence explanations → semicolon-separated
- Verbose enumerated lists → compact bullet with parenthetical items
- Repeated section patterns → table format where possible
- "The system shall..." boilerplate → direct statement

### Format rules
- Use `##` headers, not deeper (reduce nesting)
- One blank line between sections, never more
- No trailing whitespace
- Bullet lists over numbered lists (unless order matters)
- Tables for structured data with 3+ fields
- Inline code for technical terms, paths, commands

## Step 2: Validate

After compression, verify no information was lost:

1. **Count check**: List the key facts/decisions from the original, verify each appears in the compressed version
2. **AC check**: If the file contains acceptance criteria, verify every AC is preserved verbatim (never compress ACs)
3. **Decision check**: Every architectural decision with its rationale must survive

If anything is missing, add it back.

## Step 3: Report

For each file distilled:

```
{filename}:
  Before: {line_count} lines (~{token_estimate} tokens)
  After:  {line_count} lines (~{token_estimate} tokens)
  Ratio:  {compression_ratio}:1
  Verified: {pass/fail}
```

## Step 4: Save

Overwrite the original files with the compressed versions. The changelog entry (if present) is preserved.

If the user wants to keep originals, save compressed versions as `{filename}.distilled.md` instead — but only if they ask.

## Examples

**Before:**
```markdown
## User Authentication

In this section, we describe the authentication approach for our application.
We have carefully considered several options and believe that JWT-based
authentication is the best approach for our use case. This is because JWTs
are stateless, which means our backend doesn't need to store session data,
making it much easier to scale horizontally across multiple server instances.

We considered using traditional session-based authentication, but decided
against it because it would require a shared session store (like Redis),
adding operational complexity that we want to avoid at this stage.
```

**After:**
```markdown
## Auth
JWT-based, stateless (rationale: horizontal scaling without shared session store). Rejected: session-based auth (requires Redis, adds operational complexity).
```
