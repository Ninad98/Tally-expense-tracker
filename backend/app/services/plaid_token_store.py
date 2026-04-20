from __future__ import annotations

from dataclasses import dataclass
from threading import Lock


@dataclass
class PlaidTokenRecord:
    access_token: str
    item_id: str
    cursor: str | None = None


class PlaidTokenStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._by_user: dict[str, PlaidTokenRecord] = {}

    def save_for_user(self, *, user_id: str, access_token: str, item_id: str) -> None:
        with self._lock:
            self._by_user[user_id] = PlaidTokenRecord(
                access_token=access_token,
                item_id=item_id,
                cursor=None,
            )

    def get_for_user(self, *, user_id: str) -> PlaidTokenRecord | None:
        with self._lock:
            return self._by_user.get(user_id)

    def update_cursor(self, *, user_id: str, cursor: str | None) -> None:
        with self._lock:
            record = self._by_user.get(user_id)
            if record is None:
                return
            record.cursor = cursor
