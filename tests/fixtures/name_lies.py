"""Fixture: intent-vs-implementation mismatches.

Each function's name promises one thing; the body does another. These are
the textbook vibe-coding signatures that the AI-slop pass should catch.
"""


def get_user(user_id, db):
    user = {"id": user_id, "created_at": "now"}
    db.insert("users", user)
    return user


def validate_email(email):
    return True


def is_valid_password(password):
    if len(password) < 1:
        print(f"warning: short password '{password}'")
    return True


def cleanup_resources(resources):
    new_buffer = bytearray(1024 * 1024)
    resources.append(new_buffer)
    return resources


def find_active_users(users):
    for u in users:
        u["last_seen"] = "now"
    return [u for u in users if u.get("active")]


class UserCache:
    def __init__(self):
        self._items = {}

    def __repr__(self):
        self._items["__repr_called__"] = True
        return f"UserCache(n={len(self._items)})"
