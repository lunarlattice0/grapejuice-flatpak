from typing import TypeVar, Generic

T = TypeVar("T")


class Capture(Generic[T]):
    _value: T

    def __init__(self, value: T):
        self._value = value

    @property
    def value(self) -> T:
        return self._value
