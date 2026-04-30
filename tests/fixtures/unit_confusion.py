"""Fixture: unit confusion in identifiers.

Variable names declare a unit; values or comparisons use a different one.
The AI-slop pass should catch each mismatch.
"""

import time

DEFAULT_TIMEOUT_MS = 30
MAX_LATENCY_SECONDS = 500


def wait_for_response(timeout_ms=5):
    time.sleep(timeout_ms)
    return True


def is_slow(latency_seconds):
    return latency_seconds > MAX_LATENCY_SECONDS


def truncate(text, size_bytes):
    return text[:size_bytes]


def schedule_retry(delay_minutes):
    time.sleep(delay_minutes)


def file_age_days(path):
    import os
    return time.time() - os.path.getmtime(path)
