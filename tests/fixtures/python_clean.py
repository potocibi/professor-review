"""Fixture: well-written code. Should grade in the A range with minimal findings.

This is the false-positive guard — if the skill flags real issues here,
calibration has drifted toward over-flagging.
"""

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class Money:
    cents: int
    currency: str

    def __post_init__(self) -> None:
        if self.cents < 0:
            raise ValueError("Money cannot be negative")


def total(items: Iterable[Money]) -> Money:
    items = list(items)
    if not items:
        raise ValueError("Cannot total an empty list")

    currencies = {m.currency for m in items}
    if len(currencies) > 1:
        raise ValueError(f"Mixed currencies: {currencies}")

    return Money(
        cents=sum(m.cents for m in items),
        currency=items[0].currency,
    )
