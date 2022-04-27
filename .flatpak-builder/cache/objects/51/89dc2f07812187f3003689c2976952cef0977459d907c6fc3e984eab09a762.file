import logging
from abc import ABC
from typing import Callable, Union, List

from grapejuice_common.wine.wineprefix import Wineprefix
from grapejuice_common.wine.wineprefix_hints import WineprefixHint

log = logging.getLogger(__name__)

RecipeIndicator = Callable[[Wineprefix], bool]
RecipeIndicatorList = List[RecipeIndicator]


class CannotMakeRecipe(RuntimeError):
    ...


class Recipe(ABC):
    _indicators: RecipeIndicatorList
    _hint: Union[WineprefixHint, None]

    def __init__(
        self,
        indicators: Union[RecipeIndicatorList, None] = None,
        hint: Union[WineprefixHint, None] = None
    ):
        self._indicators = indicators or []
        self._hint = hint

    def _run_indicators(self, prefix: Wineprefix) -> bool:
        results = list(map(lambda fn: fn(prefix), self._indicators))
        v = all(results)

        return v

    def exists_in(self, prefix: Wineprefix) -> bool:
        return self._run_indicators(prefix)

    @property
    def hint(self) -> Union[WineprefixHint, None]:
        return self._hint

    def _make_in(self, prefix: Wineprefix):
        raise NotImplementedError()

    def _can_make_in(self, prefix: Wineprefix):
        log.debug(f"Returning True for _can_make_in prefix {prefix}")
        return True

    def make_in(self, prefix: Wineprefix):
        if not self._can_make_in(prefix):
            raise CannotMakeRecipe()

        self._make_in(prefix)
