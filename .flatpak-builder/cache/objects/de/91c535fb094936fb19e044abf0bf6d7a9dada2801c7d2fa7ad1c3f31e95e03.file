import logging

from grapejuice_common.errors import WineHomeInvalid
from grapejuice_common.recipes.common_indicators import roblox_is_installed
from grapejuice_common.recipes.recipe import Recipe
from grapejuice_common.wine.wineprefix import Wineprefix
from grapejuice_common.wine.wineprefix_hints import WineprefixHint

log = logging.getLogger(__name__)


class RobloxPlayerRecipe(Recipe):
    def __init__(self):
        super().__init__(
            indicators=[roblox_is_installed],
            hint=WineprefixHint.player
        )

    def _can_make_in(self, prefix: Wineprefix):
        try:
            wine_home = prefix.core_control.wine_home
            log.info(f"Wine home: {wine_home}")

            return True

        except WineHomeInvalid as e:
            log.warning(str(e))

        return False

    def _make_in(self, prefix: Wineprefix):
        prefix.roblox.install_roblox()
