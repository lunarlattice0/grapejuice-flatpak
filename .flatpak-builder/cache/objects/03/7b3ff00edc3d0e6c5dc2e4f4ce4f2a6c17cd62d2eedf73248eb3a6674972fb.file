import math
from typing import Optional, Callable

from grapejuice_common.util.event import Event


class Paginator:
    def __init__(self, collection, page_size, filter_function: Optional[Callable] = None):
        self._collection = collection
        self._page_size = page_size
        self._current_page = 0
        self._filter_function = filter_function

        self.paged = Event()

    @property
    def _filtered_collection(self):
        collection = self._collection

        if callable(self._filter_function):
            collection = list(self._filter_function(self._collection))

        if hasattr(collection, "sort"):
            collection.sort()

        return collection

    @property
    def page(self):
        coll = self._filtered_collection

        lower_limit = self._current_page * self._page_size
        upper_limit = min(len(coll), lower_limit + self._page_size)

        return coll[lower_limit:upper_limit]

    @property
    def current_page_index(self):
        return self._current_page

    @property
    def n_pages(self):
        return math.ceil(len(self._filtered_collection) / self._page_size)

    @property
    def filter_function(self) -> Optional[Callable]:
        return self._filter_function

    @filter_function.setter
    def filter_function(self, v: callable):
        assert v is None or callable(v)

        self._filter_function = v
        self._current_page = max(0, min(self.n_pages - 1, self._current_page))
        self.paged()

    @property
    def at_first_page(self):
        return self._current_page == 0

    @property
    def at_last_page(self):
        return self._current_page >= self.n_pages - 1

    def next(self):
        if not self.at_last_page:
            self._current_page = min(self.n_pages - 1, self._current_page + 1)
            self.paged()

    def previous(self):
        if not self.at_first_page:
            self._current_page = max(0, self._current_page - 1)
            self.paged()
