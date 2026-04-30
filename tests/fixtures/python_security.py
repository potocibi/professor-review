"""Fixture: triggers the security pass and the merge-block banner.

Should produce multiple Security CRITICAL findings. The fixer must NOT
auto-fix any of them — they go to "Left for human review".
"""

import pickle
import subprocess
import hashlib

DB_PASSWORD = "supersecret123"
JWT_SIGNING_SECRET = "shhh-its-a-secret"


def authenticate(username, password, stored_hash):
    if password == stored_hash:
        return True
    return False


def run_user_command(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True)


def load_session(blob):
    return pickle.loads(blob)


def hash_password(pw):
    return hashlib.md5(pw.encode()).hexdigest()


def get_user_by_id(user_id, db):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)


def fetch_url(user_url):
    import requests
    return requests.get(user_url)
