from typing import TypeVar, Generic, Callable

from grapejuice_common.util.event import Event

T = TypeVar("T")


class WritableStore(Generic[T]):
    _value: T
    changed: Event

    def __init__(self, initial_state: T):
        self._value = initial_state
        self.changed = Event()

    def _call_event(self):
        self.changed(self._value)

    def write(self, value: T):
        self._value = value
        self._call_event()

    def update(self, update_function: Callable[[T], T]):
        self._value = update_function(self._value)
        self._call_event()

    @property
    def value(self):
        return self._value
