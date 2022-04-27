from typing import TypeVar, Optional, Callable, Generic

ComputedValue = TypeVar("ComputedValue")
ComputedValueFactory = Callable[[], ComputedValue]


class ComputedField(Generic[ComputedValue]):
    _value: Optional[ComputedValue] = None
    _factory: ComputedValueFactory

    def __init__(self, factory: ComputedValueFactory):
        self._factory = factory

    @property
    def value(self) -> ComputedValue:
        if self._value is None:
            self._value = self._factory()

        return self._value

    def clear_cached_value(self):
        self._value = None
