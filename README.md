# professor-review

A Claude Code skill that grades any code you point it at, like a university professor marking a CS assignment. Five dimensions, letter grades, prioritized findings, AI-slop detection, and an opt-in fix phase that humanizes the prose so the comments stop sounding AI-generated.

The goal: turn AI-generated slop into code a new developer joining the team can actually read.

## What it does

**Phase 1 — Grade**

The skill uses a **cheap-executor / expensive-advisor** pattern (inspired by Anthropic's [advisor tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool)). The skill body and parallel review passes run on a fast model; an Opus-pinned advisor agent is consulted twice — once before dispatch to plan focus areas, once after aggregation to sanity-check grades. You get most of the quality of an all-Opus review at much lower cost.

Dispatches three review passes in parallel:

1. **Quality** — security holes, bugs, performance, naming, error handling, language idioms
2. **Design** — cohesion, coupling, SRP, file size, cross-file duplication
3. **AI-slop signatures** — over-abstraction, dead scaffolding, ceremony docstrings, "for future use" parameters with no callers, AI-task references in comments, decorative em-dashes

Findings get bucketed into a five-dimension rubric, each dimension gets a letter grade A–F, and you get a weighted overall grade.

**Phase 2 — Fix (opt-in)**

If you approve, a separate fixer agent applies fixes for HIGH and CRITICAL findings only (MEDIUM and LOW are left alone — they're style preferences). Every comment and docstring it touches gets humanized: AI-tell phrases stripped, ceremony preambles removed, restating comments deleted.

## Install

```bash
git clone https://github.com/potocibi/professor-review
cd professor-review

# Mac / Linux / Git Bash
./install.sh

# Windows PowerShell
.\install.ps1
```

Then restart Claude Code (or run `/reload`).

## Use

```
/professor-review                       # grade the current directory
/professor-review src/                  # grade a folder
/professor-review src/auth/login.py     # grade one file
/professor-review --fast file.py        # fast mode: skip Design pass
/professor-review --fix src/            # auto-apply fixes if grade < B
```

You can also just say it in plain language: "professor review this file", "grade this code", "is this Google-quality".

## Example output

```
# Code Review: src/auth/
**Overall: C+ (74/100)** — Works but a new developer would struggle.

## Dimension Grades
| Dimension      | Grade | Score | Top Issue                              |
|----------------|-------|-------|----------------------------------------|
| Completeness   | B     | 85    | One TODO with no owner in login.py:45  |
| Correctness    | B+    | 87    | Race condition on session cache        |
| Language use   | A−    | 90    | Mostly idiomatic Python                |
| Style          | C     | 73    | 12 ceremony docstrings on trivial fns  |
| Design         | D+    | 65    | god-class AuthService (520 lines)      |

## Findings
### CRITICAL (1)
- [auth/session.py:120] Race condition on self._cache (Correctness)

### HIGH (4)
- [auth/service.py:1] AuthService is 520 lines, handles login + tokens + audit (Design)
- [auth/utils.py:30] Helper format_user_id has only one caller (Design)
...

## AI-Slop Signatures Detected
- [auth/utils.py:1-15] 15-line docstring for a 3-line function
- [auth/service.py:200] # Added for the user-onboarding flow
- [auth/utils.py:5] from typing import Any, Optional, Union, List, Dict, Tuple — only List is used

## Phase 2 Recommendation
Auto-fix would address: 1 CRITICAL, 4 HIGH (~8 file edits estimated).
Reply "fix it" or run /professor-review --fix src/auth/ to launch Phase 2.
```

## How the grading works

Each dimension starts at 100 points. Each finding subtracts:

| Severity | Penalty |
|----------|---------|
| CRITICAL | −15     |
| HIGH     | −7      |
| MEDIUM   | −3      |
| LOW      | −1      |

Dimension weights for the overall:

| Dimension     | Weight |
|---------------|--------|
| Completeness  | 15%    |
| Correctness   | 30%    |
| Language use  | 15%    |
| Style         | 15%    |
| Design        | 25%    |

## What gets installed

| File | Goes to |
|------|---------|
| `src/skill/SKILL.md` | `~/.claude/skills/professor-review/SKILL.md` |
| `src/command/professor-review.md` | `~/.claude/commands/professor-review.md` |
| `src/agent/professor-advisor.md` | `~/.claude/agents/professor-advisor.md` |
| `src/agent/professor-reviewer.md` | `~/.claude/agents/professor-reviewer.md` |
| `src/agent/professor-fixer.md` | `~/.claude/agents/professor-fixer.md` |

The installer warns rather than overwrites. Delete the existing files first if you want to reinstall.

## Requirements

Claude Code. That's it. The skill is fully self-contained — no plugins, no other agents, no external skills required.

## Models

The skill uses the `sonnet` and `opus` aliases everywhere, so it always runs on the latest versions of each model that your Claude Code install knows about. No manual upgrades when new models ship — the aliases auto-resolve.

- `professor-reviewer` agent (parallel review passes) → latest Sonnet
- `professor-advisor` agent (planning + sanity check) → latest Opus
- `professor-fixer` agent (Phase 2 edits) → latest Sonnet

## Uninstall

```bash
rm ~/.claude/skills/professor-review/SKILL.md
rm ~/.claude/commands/professor-review.md
rm ~/.claude/agents/professor-advisor.md
rm ~/.claude/agents/professor-reviewer.md
rm ~/.claude/agents/professor-fixer.md
rmdir ~/.claude/skills/professor-review
```

## License

MIT — see [LICENSE](LICENSE).
