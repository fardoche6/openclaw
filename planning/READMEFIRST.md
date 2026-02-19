# READ THIS FIRST

> **For any AI assistant (Claude, Gemini, ChatGPT, local LLMs, Copilot, Cursor, etc.)**
> Read this file at the start of every session. It tells you how this directory works,
> what rules to follow, and how to contribute your own knowledge.

---

## What Is This Directory?

`planning/` is the **shared brain** for this project. It is version-controlled and synced
across multiple machines and AI assistants via git. Every computer and every AI tool
reads from and writes to these same files so that **everyone has the same knowledge**.

---

## Files In This Directory

| File | Purpose | Read? | Write? |
|------|---------|-------|--------|
| `READMEFIRST.md` | You are here. How this system works. | Always | Rarely (structure changes only) |
| `RULES.md` | Project rules, conventions, do/don'ts | Always | When rules change |
| `MEMORY.md` | Shared knowledge base (architecture, patterns, decisions) | Always | When you learn something new |
| `AUDIT.md` | Full project audit (features, performance, suggestions) | As needed | When audit findings change |
| `plans/` | Implementation plans (one file per task) | As needed | When planning a task |

---

## Your Obligations As An AI Assistant

### At Session Start

1. **Read `READMEFIRST.md`** (this file) to understand the system.
2. **Read `RULES.md`** to know what you can and cannot do.
3. **Read `MEMORY.md`** to load shared project knowledge.
4. Skim `AUDIT.md` if the task involves architecture, performance, or broad changes.

### During Work

5. **Follow `RULES.md`** — no exceptions. It contains coding conventions, git safety
   rules, and workflow requirements.
6. **When you discover something important** (a pattern, a gotcha, a decision, a fix
   for a recurring problem), **add it to `MEMORY.md`** in the appropriate section.
7. **When planning a non-trivial task**, create a plan file in `plans/` using the
   naming convention: `YYYY-MM-DD-<short-topic>.md`.

### After Any Change To `planning/`

8. **Always commit and push immediately:**
   ```bash
   git add planning/
   git commit -m "planning: <short description of what changed>"
   git push
   ```
   This is **mandatory**. Other machines and AI assistants rely on pulling the latest
   version. If you don't push, knowledge is lost.

---

## How To Add Knowledge To `MEMORY.md`

When you learn something worth sharing (a pattern, a decision, a debugging insight),
add it to the appropriate section in `MEMORY.md`.

**Rules for entries:**
- Keep entries **concise and factual** — no speculation, no "I think".
- Use the **Patterns & Decisions Log** table at the bottom for timestamped notes.
- Only add information you have **verified** against the actual codebase.
- If an existing entry is **wrong or outdated**, update or remove it.
- Do NOT duplicate information that's already in `RULES.md` or `AGENTS.md`.

**Example entry for the log:**
```markdown
| 2026-02-20 | SQLite WAL mode enabled in memory backend; improved concurrent read performance |
```

---

## How To Add A Plan

When working on a non-trivial feature or change:

1. Create `plans/YYYY-MM-DD-<topic>.md` (e.g., `plans/2026-02-20-async-sqlite.md`).
2. Include:
   - **Context**: Why this change is needed.
   - **Approach**: What will be done and which files are affected.
   - **Tradeoffs**: What alternatives were considered and why this was chosen.
   - **Verification**: How to test that it works.
3. Commit and push the plan before starting implementation.
4. After implementation, update the plan with the outcome (completed, modified, abandoned).

---

## What NOT To Do

- **Do NOT delete or overwrite other AI's entries** unless they are factually wrong.
- **Do NOT add speculative or unverified information** to `MEMORY.md`.
- **Do NOT skip the commit + push** after editing files in `planning/`.
- **Do NOT put AI-specific syntax** in these files (no Claude XML tags, no GPT system
  prompts, no tool-specific markup). Plain Markdown only.
- **Do NOT put secrets, tokens, or credentials** in any file in this directory.
- **Do NOT ignore `RULES.md`** — it is the source of truth for project conventions.

---

## Engineering Preferences (From The Project Owner)

These apply to all code reviews and implementation decisions:

1. **DRY** — flag repetition aggressively.
2. **Well-tested** — non-negotiable. Rather too many tests than too few.
3. **"Engineered enough"** — not hacky, not over-abstracted. Find the middle.
4. **Edge cases** — handle more, not fewer. Thoughtfulness over speed.
5. **Explicit over clever** — readable code wins over clever code.
6. **Feature first** — ship working features, then refine.

### Review Process For Code Changes

Before making code changes, review the plan with the project owner:
- For every issue: explain tradeoffs, give an opinionated recommendation, and **ask
  before assuming a direction**.
- Number issues (1, 2, 3…), letter options (A, B, C…).
- Present recommended option first.
- Do not assume priorities on timeline or scale.

---

## Quick Reference: Dev Commands

```bash
pnpm install          # install dependencies
pnpm test             # run tests (vitest)
pnpm build            # type-check + build
pnpm tsgo             # TypeScript check only
pnpm check            # lint + format check
pnpm format:fix       # auto-fix formatting
pnpm openclaw ...     # run CLI in dev mode
```

---

## Quick Reference: Git Workflow

```bash
# Normal code changes — only commit when the user asks
git add <specific-files>
git commit -m "descriptive message"
# Push only when asked

# Planning files — ALWAYS commit + push immediately
git add planning/
git commit -m "planning: <description>"
git push
```

**Never** force-push to `main`. **Never** run destructive git ops without explicit
user confirmation. See `RULES.md` for the full list.
