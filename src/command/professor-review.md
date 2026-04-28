---
description: Grade a file or codebase like a university professor. Produces a letter-graded report card with findings, AI-slop signatures, and an opt-in fix phase.
argument-hint: "[path] [--fast] [--fix]"
---

Invoke the `professor-review` skill on `$ARGUMENTS`.

Parse the arguments:
- First non-flag token is the **target path**. If absent, default to `.` (current working directory).
- `--fast` flag → single-file fast mode: skip the Design pass, only run Quality + AI-slop in parallel. Use this when the user wants a quick read on one file.
- `--fix` flag → after Phase 1 produces the report card, automatically launch Phase 2 (the `professor-fixer` agent) if the overall grade is below B. Without this flag, ask the user before starting Phase 2.

Then follow the dispatch protocol in the `professor-review` skill:

1. Launch the parallel Explore agents for Phase 1 (Quality + Design + AI-slop, or Quality + AI-slop in fast mode).
2. Aggregate findings into the rubric, compute letter grades per dimension, and emit the report card in the format defined by the skill.
3. Stop and wait for user input — unless `--fix` was passed and the overall grade < B, in which case proceed directly to Phase 2.
4. On Phase 2 approval, dispatch the `professor-fixer` agent with the report card and target path.

Do not add commentary outside what the skill prescribes. The report card is the output.
