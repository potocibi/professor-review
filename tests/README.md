# tests/

Regression-sanity fixtures for `vibe-review`. Not a pass/fail test suite — the skill is LLM-driven and inherently noisy. These fixtures exist so a human (you, or a contributor) can eyeball whether the skill still behaves correctly after editing `SKILL.md`, the agents, or the rubric.

## Why fixtures, not unit tests

Traditional unit tests don't fit:

- Same input → potentially different output (LLM variability)
- "Correct" output is fuzzy — the same finding can be phrased ten ways
- Model upgrades (Sonnet 4.6 → 4.7) shift calibration without any code change

So instead of pass/fail assertions, we have **fixtures with documented expectations**. Run the skill, eyeball the report against `tests/expected/README.md`, and decide if calibration is still in range.

## How to run

After installing the skill (`./install.sh` or `.\install.ps1`) and reloading Claude Code:

```
/vibe-review --fast tests/fixtures/python_slop.py
/vibe-review --fast tests/fixtures/python_security.py
/vibe-review --fast tests/fixtures/python_clean.py
/vibe-review --fast tests/fixtures/name_lies.py
/vibe-review --fast tests/fixtures/unit_confusion.py
```

`--fast` mode keeps each run cheap (skips the Design pass, skips the pre-flight advisor on tiny files).

For a full-skill exercise (all 4 passes + advisor), drop the flag and run on the whole `tests/fixtures/` directory:

```
/vibe-review tests/fixtures/
```

## What to check

For each fixture, open `tests/expected/README.md` and confirm:

1. **Overall grade** lands in the documented range
2. **Must-catch findings** are all present (severity tier may shift one notch — that's fine)
3. **Must-not-flag patterns** are absent (those are the false-positive guards)
4. For `python_security.py`: the merge-block banner fires
5. For `python_clean.py`: very few or no findings, no banner

If a fixture's report drifts significantly from the expected shape after you edited the skill, that's the regression. Either fix the skill or update the expectations — but pause and decide which one.

## Fixtures

| File | Purpose |
|---|---|
| `python_slop.py` | Dense vibe-coding signatures (dead imports, ceremony docstring, single-caller helper, AI-task comment, future-extensibility params, marketing tone, generic names, hardcoded secret) |
| `python_security.py` | Triggers the security pass and merge-block banner (pickle.loads, shell=True, hardcoded creds, MD5, `==` password compare, SQL injection, SSRF) |
| `python_clean.py` | Well-written reference code. Should grade A and produce minimal findings. False-positive guard. |
| `name_lies.py` | Intent-vs-implementation mismatches (the new AI-slop bullets): name says X, body does Y |
| `unit_confusion.py` | Identifiers declaring one unit, values using another (timeout_ms storing seconds, etc.) |
