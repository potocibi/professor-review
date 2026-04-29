---
description: Vibe check your code. Grades a file or codebase like a strict professor — five-dimension rubric, AI-slop detection, dedicated security pass, opt-in fix phase.
argument-hint: "[path] [--fast] [--fix]"
---

Invoke the `professor-review` skill on `$ARGUMENTS`.

Parse the arguments:
- First non-flag token is the **target path**. If absent, default to `.` (current working directory).
- `--fast` flag → single-file fast mode: skip the Design pass; run Quality + AI-slop + Security in parallel. Use this for a quick read on one file.
- `--fix` flag → after Phase 1 produces the report card, automatically launch Phase 2 (the `professor-fixer` agent) if the overall grade is below B. Without this flag, ask the user before starting Phase 2.

Then follow the dispatch protocol in the `professor-review` skill:

1. Run the pre-flight advisor consultation (Step 0 in the skill) unless the target is a single tiny file.
2. Launch the parallel Phase 1 agents — Quality + Design + AI-slop + Security (or Quality + AI-slop + Security in `--fast` mode).
3. Run the post-aggregation advisor sanity check.
4. Aggregate findings, compute letter grades per dimension, and emit the report card with the merge-block banner if any Security CRITICALs fired.
5. Stop and wait for user input — unless `--fix` was passed and the overall grade < B, in which case proceed directly to Phase 2.
6. On Phase 2 approval, dispatch the `professor-fixer` agent with the report card and target path.

Do not add commentary outside what the skill prescribes. The report card is the output.
