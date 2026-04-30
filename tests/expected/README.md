# Expected behavior per fixture

A human-readable spec for what each fixture *should* produce when graded by `vibe-review`. Treat this as a calibration anchor, not a strict assertion. Severity may shift one notch in either direction — that's normal LLM noise. A grade two letters off, or a missing must-catch finding, is a real regression worth investigating.

---

## `python_slop.py` — dense vibe-coding signatures

**Expected overall grade:** D+ to C-

**Must catch (any tier):**
- Hardcoded API key / credential at top of file
- Dead `from typing import ...` line — only `List` (or nothing) is used
- Ceremony docstring on `add_numbers(a, b)` — three-bullet Args/Returns block on a trivial function
- `format_user_id` flagged as single-caller helper
- `get_user(..., mode='default', strategy=None, options=None)` — future-extensibility params with no callers
- AI-task reference comment (`# Added for the user-onboarding flow` or similar)
- `except Exception` re-raised as generic `RuntimeError`
- Stale `# TODO: implement this` next to a function that's already implemented
- Restating comment (`i += 1  # increment i` or similar)
- Dead/unused imports (`os`, `sys`, `json` if not used)

**Must NOT flag:**
- The variable name `i` as a loop counter (low-confidence territory; over-flagging here means calibration is too aggressive)

**Banner:** the security pass may surface the hardcoded credential as CRITICAL → merge-block banner expected.

---

## `python_security.py` — security-only fixture

**Expected overall grade:** F to D- (Correctness dimension dominates)

**Banner:** **YES — merge-block banner MUST fire** with multiple Security CRITICAL findings.

**Must catch (Security CRITICAL):**
- `pickle.loads(blob)` on user-controllable bytes — RCE-class deserialization
- `subprocess.run(cmd, shell=True)` with user-controlled `cmd` — command injection
- Hardcoded `DB_PASSWORD` and `JWT_SIGNING_SECRET` at module level
- `password == stored_hash` — timing-attack on password compare (use `hmac.compare_digest`)
- `query = f"SELECT * FROM users WHERE id = {user_id}"` — SQL injection via f-string
- `requests.get(user_url)` — SSRF (no allowlist, no internal-IP filter)

**Must catch (Security HIGH):**
- `hashlib.md5` for password hashing — broken cryptographic choice

**Phase 2 behavior:** if the user approves Phase 2, the fixer must list every Security CRITICAL under "Left for human review" and apply ZERO edits to this file. If any Security CRITICAL gets auto-edited, that's a CRITICAL bug in the fixer.

---

## `python_clean.py` — false-positive guard

**Expected overall grade:** A− to A+

**Acceptable findings (≤2 total):**
- LOW-severity style nits at most (e.g. minor naming preference)

**Must NOT flag:**
- The frozen `@dataclass` (it's clean Python, not "AI slop")
- The `__post_init__` validation (it's not "validation theater" — it actually rejects)
- The `if not items: raise` early return as "missing case" — it IS the case
- The set comprehension `{m.currency for m in items}` as "non-idiomatic"

**Phase 2 recommendation:** "Phase 2 not recommended — no HIGH or CRITICAL findings."

If this fixture grades below B or produces more than 2 findings, the skill is over-flagging clean code. That's a worse regression than missing a real issue, because false positives erode user trust.

---

## `name_lies.py` — intent-vs-implementation

**Expected overall grade:** D+ to C

**Must catch (one finding per function, all HIGH or MEDIUM, dimension Style/Correctness):**
- `get_user` flagged for name-vs-behavior mismatch (gets implies query, body inserts)
- `validate_email` flagged as validation theater (body cannot return False)
- `is_valid_password` flagged as validation theater (logs but always returns True)
- `cleanup_resources` flagged for name-vs-behavior mismatch (cleanup implies release, body allocates)
- `find_active_users` flagged for name-vs-behavior mismatch (find implies query, body mutates `last_seen`)
- `UserCache.__repr__` flagged for side effects in `__repr__`

If 4+ of these 6 are caught, calibration is good. Less than 4 means the AI-slop bullets we added need strengthening.

---

## `unit_confusion.py` — unit mismatches

**Expected overall grade:** C to D

**Must catch (HIGH, dimension Correctness):**
- `time.sleep(timeout_ms=5)` — `time.sleep` takes seconds; `timeout_ms` name is wrong, value will sleep 5 seconds not 5 ms
- `latency_seconds > MAX_LATENCY_SECONDS` where `MAX_LATENCY_SECONDS = 500` — 500s is 8 minutes; combined with the constant being suspicious, name suggests this comparison is in mixed units
- `schedule_retry(delay_minutes)` calling `time.sleep(delay_minutes)` — sleep takes seconds, name implies minutes
- `file_age_days` returning `time.time() - getmtime` — that's seconds, not days

**Should catch (MEDIUM):**
- `DEFAULT_TIMEOUT_MS = 30` — 30ms is suspiciously short for a timeout; combined with how it's used (or unused), suggests confusion
- `truncate(text, size_bytes)` — slicing a string with `size_bytes` actually slices by chars, not bytes (UTF-8 mismatch)

If 3+ of the HIGH-tier items are caught, the new AI-slop bullets are working as intended.
