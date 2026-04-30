# vibe-review

**Fixes vibe coding.**

A Claude Code skill that grades AI-generated code like a strict university professor and cleans up the slop. Five-dimension rubric, letter grades A–F, dedicated security pass, opt-in fix phase that won't replace AI slop with more AI slop.

The goal: turn vibe-coded slop into code a new developer joining the team can actually read.

## What "vibe coding" means here

Code written by an LLM in one shot that *feels* organized but is actually full of:

- Over-defensive try/except wrapping code that can't fail
- Multi-line docstrings explaining what `def add(a, b)` does
- Helper functions with exactly one caller
- `from typing import Any, Optional, Union, List, Dict, Tuple, Callable` — only `List` is used
- "Future extensibility" parameters no caller passes
- `# Added for the user-onboarding flow` AI-task references
- `subprocess.run(cmd, shell=True)` with user input
- `pickle.loads()` on data from the network
- Comments using "robust", "comprehensive", "leverages", "seamlessly"

This skill detects those signatures and fixes them.

## How it works

**Phase 1 — Vibe check (grade)**

Uses a cheap-executor / expensive-advisor pattern (inspired by Anthropic's [advisor tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool)). The skill body and parallel review passes run on Sonnet; an Opus-pinned advisor agent is consulted twice — once before dispatch to plan focus areas, once after aggregation to sanity-check grades. Most of the quality of an all-Opus review at much lower cost.

Dispatches four review passes in parallel:

1. **Quality** — bugs, performance, naming, error handling, language idioms
2. **Design** — cohesion, coupling, SRP, file size, cross-file duplication
3. **AI-slop signatures** — over-abstraction, dead scaffolding, ceremony docstrings, "for future use" parameters with no callers, AI-task references, decorative em-dashes
4. **Security** — dedicated threat-modeling pass: OWASP Top 10, injection, broken authn/authz, weak crypto, insecure deserialization, SSRF, secrets, language-specific footguns. CRITICAL security findings produce a merge-block banner and are never auto-fixed.

Findings get bucketed into a five-dimension rubric. Each dimension gets a letter grade A–F. You get a weighted overall grade and a prioritized findings list.

**Phase 2 — Fix (opt-in)**

If you approve, a separate fixer agent applies fixes for HIGH and CRITICAL findings only (MEDIUM and LOW are left alone — those are style preferences). Every comment and docstring it touches gets humanized: AI-tell phrases stripped, ceremony preambles removed, restating comments deleted.

The fixer follows five non-negotiable rules:

1. **Don't change the program's purpose**
2. **Don't break the program** — syntax check + fast tests after every file; revert on fail
3. **Don't put the code in a worse state** — net issue count cannot rise
4. **Don't duplicate code** — grep for existing equivalents before creating any new helper
5. **Don't replace AI slop with AI slop** — mandatory self-review of own diff

**Security CRITICALs are never auto-fixed.** They're surfaced under "Left for human review" in the post-fix report so you can patch them yourself with full context.

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
/vibe-review                       # vibe check the current directory
/vibe-review src/                  # vibe check a folder
/vibe-review src/auth/login.py     # vibe check one file
/vibe-review --fast file.py        # fast mode: skip Design pass
/vibe-review --fix src/            # auto-apply fixes if grade < B
```

You can also just say it in plain language: "vibe check this file", "is this vibe coded?", "fix the vibes", "grade this code".

## Example output

```
# Code Review: src/auth/

> ## SECURITY BLOCK — 1 CRITICAL findings
>
> The Security pass found exploitable issues. Phase 2 will not auto-fix
> CRITICAL security findings — they require human review.
>
> - [auth/session.py:45] pickle.loads on user-controlled bytes (RCE)
>
> Fix these manually before shipping. Re-run /vibe-review after fixing.

**Overall: C+ (74/100)** — Works but a new developer would struggle.

## Dimension Grades
| Dimension      | Grade | Score | Top Issue                              |
|----------------|-------|-------|----------------------------------------|
| Completeness   | B     | 85    | One TODO with no owner in login.py:45  |
| Correctness    | C     | 72    | RCE-class deserialization in session   |
| Language use   | A−    | 90    | Mostly idiomatic Python                |
| Style          | C     | 73    | 12 ceremony docstrings on trivial fns  |
| Design         | D+    | 65    | god-class AuthService (520 lines)      |

## AI-Slop Signatures Detected
- [auth/utils.py:1-15] 15-line docstring for a 3-line function
- [auth/service.py:200] # Added for the user-onboarding flow
- [auth/utils.py:5] from typing import Any, Optional, Union, List, Dict, Tuple — only List is used

## Phase 2 Recommendation
Auto-fix would address: 0 CRITICAL, 4 HIGH (~6 file edits estimated).
**Note: 1 CRITICAL findings from the Security pass will NOT be auto-fixed — they require human review.**
Reply "fix it" or run /vibe-review --fix src/auth/ to launch Phase 2.
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
| `src/command/vibe-review.md` | `~/.claude/commands/vibe-review.md` |
| `src/agent/professor-advisor.md` | `~/.claude/agents/professor-advisor.md` |
| `src/agent/professor-reviewer.md` | `~/.claude/agents/professor-reviewer.md` |
| `src/agent/professor-security.md` | `~/.claude/agents/professor-security.md` |
| `src/agent/professor-fixer.md` | `~/.claude/agents/professor-fixer.md` |

The skill name stays `professor-review` internally — that's the skill's identity. The user-facing command is `/vibe-review`.

The installer warns rather than overwrites. Delete the existing files first if you want to reinstall.

## Requirements

Claude Code. That's it. The skill is fully self-contained — no plugins, no other agents, no external skills required.

## Models

The skill uses the `sonnet` and `opus` aliases everywhere, so it always runs on the latest versions of each model that your Claude Code install knows about. No manual upgrades when new models ship — the aliases auto-resolve.

- `professor-reviewer` agent (Quality / Design / AI-slop passes) → latest Sonnet
- `professor-security` agent (dedicated security pass) → latest Sonnet
- `professor-advisor` agent (planning + sanity check) → latest Opus
- `professor-fixer` agent (Phase 2 edits) → latest Sonnet

## Uninstall

```bash
rm ~/.claude/skills/professor-review/SKILL.md
rm ~/.claude/commands/vibe-review.md
rm ~/.claude/agents/professor-advisor.md
rm ~/.claude/agents/professor-reviewer.md
rm ~/.claude/agents/professor-security.md
rm ~/.claude/agents/professor-fixer.md
rmdir ~/.claude/skills/professor-review
```

## Testing the skill itself

The repo ships a fixture suite under `tests/fixtures/` for regression-checking the skill after edits. It's not a pass/fail unit-test suite (the skill is LLM-driven and inherently noisy) — it's a calibration anchor you eyeball.

```
/vibe-review tests/fixtures/
```

Then compare the output against `tests/expected/README.md`, which documents per-fixture: expected grade range, must-catch findings, must-not-flag patterns. See [tests/README.md](tests/README.md) for details.

If you edit the rubric, the AI-slop checklist, or any agent prompt, run the fixtures first and check that the report doesn't drift in unexpected ways.

## License

MIT — see [LICENSE](LICENSE).
