---
description: Run the vibe-review calibration test suite. Grades every fixture in tests/fixtures/, compares each report against tests/expected/README.md, and produces a pass/fail-style summary so you can see at a glance whether the skill still behaves correctly after edits.
argument-hint: "[fixtures-dir] (default: tests/fixtures/)"
---

You are running the calibration test suite for the `vibe-review` skill.

## Inputs

- `$ARGUMENTS` — optional path to the fixtures directory. If empty, default to `tests/fixtures/`.
- The expected-behavior spec lives at `tests/expected/README.md` (read it before running).

## What to do

### Step 1 — Locate fixtures and expectations

1. Resolve the fixtures directory (`$ARGUMENTS` or `tests/fixtures/`).
2. List every file in that directory using `Glob`. Each is a fixture.
3. Read `tests/expected/README.md`. Parse it section by section — each fixture has a heading like `## python_slop.py` followed by **Expected overall grade**, **Must catch**, **Must NOT flag**, and (sometimes) **Banner** clauses.
4. If a fixture exists with no matching section in the expectations doc, flag it in the final report under "Fixtures with no expectations" — do not run it.

### Step 2 — Grade each fixture sequentially

For each fixture file, invoke the `professor-review` skill (the skill backing `/vibe-review`) in `--fast` mode. `--fast` keeps the cost down — it skips the Design pass and the Opus pre-flight advisor on small files, but still runs Quality + AI-slop + Security in parallel and the post-aggregation sanity check.

Capture the resulting report card from each run. Do not stop and ask the user to approve Phase 2 — this is a calibration run, not an editing run. Phase 2 must NOT fire on any fixture.

### Step 3 — Compare each report against the expectations

For each fixture, evaluate four checks:

1. **Grade in range?** Did the overall grade fall within the documented range? (Allow ±1 letter-grade slip — e.g. expected B-range and got A− is a PASS, got C is a FAIL.)
2. **Must-catch hit rate?** Of the documented must-catch findings, count how many appear in the report (match by file:line and topic, not exact wording). Hit rate ≥75% is PASS; 50–74% is WARN; <50% is FAIL.
3. **No must-not-flag matches?** Did any of the documented must-not-flag patterns appear in the findings? Any match is FAIL.
4. **Banner expectations?** If the expectations doc says the merge-block banner should fire, confirm it did. If it says no banner expected, confirm none fired.

A fixture passes if all four checks pass. Any FAIL on any check is a fixture-level FAIL. WARN on must-catch and PASS elsewhere is a fixture-level WARN.

### Step 4 — Produce the summary

Output exactly this shape — no preamble, no postscript:

```markdown
# vibe-review calibration test results

**Verdict: <HEALTHY | DRIFT | REGRESSION>**

| Fixture | Expected grade | Actual | Must-catch | False positives | Banner | Status |
|---|---|---|---|---|---|---|
| python_slop.py | D+ to C- | C- | 9/10 | none | n/a | PASS |
| python_security.py | F to D- | D- | 6/6 | none | fired (expected) | PASS |
| python_clean.py | A range | A− | n/a | none | none (expected) | PASS |
| name_lies.py | D+ to C | D | 5/6 | none | n/a | PASS |
| unit_confusion.py | C to D | C− | 4/4 | none | n/a | PASS |

## Per-fixture detail

### python_slop.py — PASS
- Grade: C- (within D+ to C- range) ✓
- Must-catch hits: 9 of 10 (90%) ✓
- False positives: none ✓
- Missed: <list any must-catch findings the skill did not produce>

### python_security.py — PASS
...

(repeat per fixture)

## Verdict reasoning

<one short paragraph>:
- HEALTHY = all fixtures PASS, no calibration concerns
- DRIFT = at least one fixture WARN; calibration is shifting but no hard regressions yet
- REGRESSION = at least one fixture FAIL; the skill's behavior has changed in a way that breaks expected calibration. Investigate the most recent edits to SKILL.md, the AI-slop checklist, or the agent prompts.

## Recommended action

If REGRESSION: <name the specific fixture that failed, what it expected, what it got, and the likely cause based on which checklist or rubric edits would produce that pattern>
If DRIFT: <name the WARN fixtures and which check is sliding>
If HEALTHY: "No action needed."
```

## Hard rules

- **Do NOT run Phase 2 on any fixture.** This is a read-only calibration run. The fixer must never fire from inside `/vibe-test`.
- **Do NOT modify any file** in `tests/fixtures/` or `tests/expected/`. Read-only.
- **Do NOT skip fixtures to save tokens.** Every fixture in the directory must be graded, or the verdict is meaningless. If you cannot run a fixture for some reason, mark it ERROR in the table with a one-line reason.
- **Do NOT deviate from the output format.** This output is meant to be scannable in seconds.
- **Do NOT ask the user questions.** Just run and report. The user invoked this to get an answer, not to be interviewed.

## When to use this

- After editing `SKILL.md`, the rubric, the AI-slop checklist, or any agent prompt
- After upgrading the host Claude Code's Sonnet/Opus version
- Before publishing a release tag
- When `/vibe-review` reports start "feeling off" on real codebases
