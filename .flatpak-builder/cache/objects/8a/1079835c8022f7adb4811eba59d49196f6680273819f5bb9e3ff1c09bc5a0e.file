from typing import Optional


class Event:
    def __init__(self):
        self._listeners = []

    def add_listener(self, listener: callable):
        assert callable(listener), "The given listener must be callable"
        self._listeners.append(listener)

    def remove_listener(self, listener):
        if listener in self._listeners:
            self._listeners.remove(listener)

    def __call__(self, *args, **kwargs):
        for listener in self._listeners:
            listener(*args, **kwargs)


class Subscription:
    _unsubscribe: Optional[callable] = None

    def __init__(self, event: Event, listener: callable):
        event.add_listener(listener)
        self._unsubscribe = lambda: event.remove_listener(listener)

    def unsubscribe(self):
        if self._unsubscribe is not None:
            self._unsubscribe()
            self._unsubscribe = None
