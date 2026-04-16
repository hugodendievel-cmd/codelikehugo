<p align="center">
  <strong>codelikehugo</strong><br>
  <em>Spec-driven development for Claude Code — from idea to PRs, without the ceremony.</em>
</p>

<p align="center">
  <a href="#getting-started">Getting Started</a> &middot;
  <a href="#commands">Commands</a> &middot;
  <a href="#the-team">The Team</a> &middot;
  <a href="#how-build-works">How /build Works</a> &middot;
  <a href="#installation">Installation</a>
</p>

---

## Why

Most spec-driven frameworks are heavy: dozens of agents, XML workflow engines, multi-step activation rituals. The actual value is in the pipeline — going from idea to PRD to architecture to stories to code in a disciplined way.

This plugin gives you that pipeline in a few simple commands.

```
/init  ───>  /plan  ───>  /build epic 1
 analyze      backlog      Florent → Romain → Victor
                           (write)   (dev)     (review)
                              ↓        ↓         ↓
                           story     code       PR
```

---

## Getting Started

Pick the guide that matches your situation:

### New project (greenfield)

You have an idea but no code yet.

```
/init new              # 1. Describe your idea — produces project-context, architecture, PRD
/plan                  # 2. Break the PRD into epics and stories
/build epic 1          # 3. Automated pipeline: write stories → dev → review → PRs
```

`/init new` starts a conversation: what are you building, for whom, what's the scope? After 2-3 rounds of questions it launches parallel agents to generate your project context, architecture, and PRD. Then `/plan` turns that into a backlog, and `/build` executes it.

### Existing project (brownfield, no framework)

You have a codebase but no specs, PRD, or stories.

```
/init                  # 1. Scans your codebase with 3 parallel agents
                       #    Produces project-context + architecture
/plan                  # 2. Turns your described work into epics and stories
/build epic 1          # 3. Automated pipeline: write stories → dev → review → PRs
```

`/init` detects existing code automatically. It launches 3 instances of **Chloe** (Analyst) in parallel — structure & stack, architecture & patterns, features & domain — and synthesizes the findings into `project-context.md` and `architecture.md`. No PRD is created unless you describe new work.

### Coming from BMAD

You already have BMAD artifacts (`_bmad-output/`). You don't need to redo any analysis — codelikehugo picks up where BMAD left off.

```
/build epic 15         # Reads your existing BMAD artifacts and runs the pipeline
```

That's it. codelikehugo auto-detects `_bmad-output/` and reads:

| Artifact | BMAD path |
|----------|-----------|
| PRD & architecture | `_bmad-output/planning-artifacts/` |
| Project context | `_bmad-output/project-context.md` |
| Sprint status | `_bmad-output/implementation-artifacts/sprint-status.yaml` |
| Story files | `_bmad-output/implementation-artifacts/stories/` |

It understands BMAD's flat `development_status:` sprint-status format natively.

Want to add new epics beyond what BMAD generated?

```
/plan                  # Reads your existing BMAD PRD + architecture, adds new epics
/build epic 16         # Executes the new epic
```

### Ongoing development

Once specs exist (from any path above), day-to-day work is:

```
/build epic N              # Full pipeline for an epic (auto mode)
/build epic N interactive  # Same, but pause between stages for approval
/build 3-2                 # Pipeline for a single story
```

Or go manual for more control:

```
/story 3.2   →   /dev 3.2   →   /review 3.2
 prepare          implement       verify + PR
```

Specs changed? Keep things up to date:

```
/update                # Surgically edit PRD/architecture with impact analysis
/distill all           # Compress verbose specs to save tokens (lossless, 2-5x)
/status                # See sprint progress at a glance
```

---

## Commands

### Core Pipeline

| Command | What it does | Output |
|:--------|:------------|:-------|
| `/init` | Auto-detect brownfield/greenfield, launch parallel agents, produce specs | `project-context.md`, `architecture.md`, `prd.md` |
| `/plan` | Break PRD + architecture into epics with BDD stories | `epics.md`, `sprint-status.yaml` |
| `/build` | Execute an epic end-to-end: Florent → Romain → Victor per story | Code + PRs |
| `/update` | Surgically update specs with impact analysis and cascade | Updated spec files |
| `/distill` | Lossless compression — strip prose, keep every fact | Compressed spec files |
| `/status` | Sprint progress at a glance | Visual status report |

### Building Blocks

Run individual steps when you need fine-grained control:

| Command | What it does |
|:--------|:------------|
| `/map` | Scan an existing codebase and document it (brownfield) |
| `/discover` | Collaborative product discovery and PRD creation (greenfield) |
| `/architect` | Create architecture decisions from a PRD |
| `/story` | Create a single implementation-ready story file |
| `/dev` | Implement a single story with TDD, create branch and push |
| `/review` | Code review a single story, create PR |

---

## The Team

```
               Hugo (Lead)
            ┌─────┼─────┐
         /init         /build
        ┌──┴──┐      ┌──┼──┐
     Chloe  Julie  Florent Romain  Victor
     scan   PRD    story   dev     review
```

| Agent | Role | Model | Used by |
|:------|:-----|:------|:--------|
| **Hugo** | Lead Orchestrator | Sonnet | `/init`, `/build` — coordinates the team |
| **Chloe** | Analyst | Sonnet | `/init`, `/map` — scans codebases |
| **Julie** | Product Manager | Sonnet | `/init`, `/discover`, `/update` — requirements |
| **Vincent** | Architect | Sonnet | `/init`, `/architect` — technical decisions |
| **Florent** | Planner & Story Writer | Sonnet | `/plan`, `/build`, `/story` — epics and stories |
| **Romain** | Developer | Opus | `/build`, `/dev` — TDD implementation |
| **Victor** | Reviewer | Opus | `/build`, `/review` — adversarial review, PRs |

Analysis agents run on **Sonnet** (fast, cheap). Implementation agents run on **Opus** (best reasoning for code).

---

## How /build Works

Hugo orchestrates a **3-agent pipeline per story**:

```
┌──────────────────────────────────────────────────────────┐
│  For each story in the epic:                             │
│                                                          │
│  ┌─────────┐     ┌─────────┐     ┌─────────┐             │
│  │ Florent │ ──> │ Romain  │ ──> │ Victor  │             │
│  │ (write) │     │  (dev)  │     │(review) │             │
│  └────┬────┘     └────┬────┘     └────┬────┘             │
│       │               │               │                  │
│   story file      code + tests    PR created             │
│                   branch pushed   issues fixed           │
└──────────────────────────────────────────────────────────┘
```

Stories execute sequentially with **branch stacking**:

```
main ← PR #1 (story 2.1) ← PR #2 (story 2.2) ← PR #3 (story 2.3)
```

Merge PRs in order after review.

**Modes:**
- `auto` (default) — no pauses, auto-fix review issues, run all stories
- `interactive` — pause between stages for approval

**Resume:** If the pipeline is interrupted, re-run the same `/build` command. It detects in-progress stories and picks up where it left off.

### Running /build with fewer interruptions

`/build` spawns three (or four) agents sequentially per story — across
a full epic that means a lot of permission prompts. If you're on
Claude Code Max, start your session in **auto mode** so routine
actions (file edits, test runs, git branching) proceed without
prompting while risky actions (force-push, production access,
cross-repo writes) still gate:

```bash
claude --permission-mode auto
/build epic 1
```

Pair this with `protected:` paths in `.codelikehugo/repos.yaml` to
stop agents from wandering into code they shouldn't touch even when
permission prompts are relaxed.

---

## Artifacts

```
specs/
├── project-context.md      # Tech stack, conventions, patterns
├── prd.md                  # Product requirements
├── architecture.md         # Technical decisions and component design
├── epics.md                # All epics and stories
├── sprint-status.yaml      # Sprint tracking
└── stories/
    ├── 1-1-user-auth.md    # Implementation-ready story files
    ├── 1-2-session-mgmt.md
    └── 2-1-dashboard.md
```

---

## Configuration (optional)

Out of the box, codelikehugo assumes a single-repo project and no
protected paths. For multi-repo setups (e.g. specs in one repo, code
in a sibling repo) or to mark submodules/vendored code as read-only,
copy `repos.yaml.example` from this plugin into your project:

```bash
mkdir -p .codelikehugo
cp path/to/plugin/repos.yaml.example .codelikehugo/repos.yaml
```

Then uncomment the sections you need. Common cases:

- **Multi-repo** — set `code.root: ../my-app` so Romain commits and
  Victor opens PRs in a sibling repository while artifacts stay local.
- **Protected paths** — list submodules or vendored directories under
  `protected:`. Agents HALT and report rather than editing them.

See `repos.yaml.example` for the full schema.

---

## Installation

Add this repo as a Claude Code marketplace, then install the plugin:

```bash
claude plugin marketplace add hugodendievel-cmd/codelikehugo
claude plugin install codelikehugo@codelikehugo
```

Scope the install with `--scope user|project|local` as needed
(default: `user`). Run `claude plugin update codelikehugo` later to
pull new commits.

---

## Design Principles

| Principle | What it means |
|:----------|:-------------|
| **Two commands for the common case** | `/init` then `/build` gets you from zero to PRs |
| **Parallel agents for speed** | Init launches 3 agents simultaneously for analysis |
| **Conversational, not procedural** | Commands ask smart questions instead of rigid checklists |
| **Lean artifacts** | Every line answers: "Does a developer need this to build correctly?" |
| **Self-contained stories** | A story file has everything — no hunting through 5 documents |
| **TDD by default** | Tests first, implementation second |
| **Adversarial reviews** | Find real issues, not style preferences |
| **BMAD compatible** | Drop in alongside existing BMAD artifacts — no migration needed |

---

## License

MIT
