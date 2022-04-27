import json
import logging
import os
import shutil
from dataclasses import asdict
from pathlib import Path
from typing import Dict

from grapejuice_common import paths
from grapejuice_common.errors import RobloxExecutableNotFound
from grapejuice_common.models.wineprefix_configuration_model import ThirdPartyKeys
from grapejuice_common.roblox_product import RobloxProduct
from grapejuice_common.wine.wineprefix import Wineprefix

migration_index = dict()

log = logging.getLogger(__name__)


def register_migration(version_from: int, version_to: int):
    def decorator(migration_function):
        migration_index[(version_from, version_to)] = migration_function

        return migration_function

    return decorator


# Keep migrations between 0 and 1 even though they don't do anything
# Having these run is an indicator that the feature is working

@register_migration(0, 1)
def migration_one(_settings: Dict):
    log.info("Migration one application")


@register_migration(1, 0)
def undo_migration_one(_settings: Dict):
    log.info("Migration one undo")


def _get_wine_home(wine_binary_string: str, default_value: str) -> str:
    if not wine_binary_string:
        return default_value

    wine_binary = Path(wine_binary_string)
    can_be_used = False

    if wine_binary.name != "wine":
        log.warning("Could not migrate Wine binary because its name is not 'wine'")

    elif wine_binary.parent.name != "bin":
        log.warning("Could not migrate Wine binary because it's not in a folder named 'bin'")

    else:
        can_be_used = True

    return str(wine_binary.parent.parent) if can_be_used else default_value


def _get_fast_flags(prefix: Wineprefix) -> Dict[str, Dict[str, any]]:
    studio_fast_flags = {}
    player_fast_flags = {}

    try:
        with prefix.roblox.roblox_studio_app_settings_path.open("r") as fp:
            studio_fast_flags = json.load(fp)
    except (FileNotFoundError, RobloxExecutableNotFound):
        pass

    try:
        with prefix.roblox.roblox_player_app_settings_path.open("r") as fp:
            player_fast_flags = json.load(fp)
    except (FileNotFoundError, RobloxExecutableNotFound):
        pass

    return {
        RobloxProduct.studio.value: studio_fast_flags,
        RobloxProduct.player.value: player_fast_flags,
        RobloxProduct.app.value: player_fast_flags
    }


@register_migration(1, 2)
def upgrade_wineprefix(current_settings: Dict):
    from grapejuice_common.features.wineprefix_migration import do_wineprefix_migration
    from grapejuice_common.wine.wine_functions import create_player_prefix_model, create_studio_prefix_model
    from grapejuice_common.features import settings
    from grapejuice_common.recipes.fps_unlocker_recipe import FpsUnlockerRecipe

    prefixes = current_settings.get(settings.k_wineprefixes, [])

    if len(prefixes) > 0:
        return

    fps_unlocker_recipe = FpsUnlockerRecipe()

    new_player_prefix = create_player_prefix_model(current_settings)
    new_studio_prefix = create_studio_prefix_model(current_settings)
    unsupported_settings = current_settings.get("unsupported_settings", {})

    legacy_wineprefix_path = paths.local_share_grapejuice() / "wineprefix"
    do_wineprefix_migration(
        legacy_wineprefix_path=legacy_wineprefix_path,
        new_name_on_disk=new_player_prefix.name_on_disk
    )
    do_wineprefix_migration(
        legacy_wineprefix_path=legacy_wineprefix_path,
        new_name_on_disk=new_studio_prefix.name_on_disk
    )

    for prefix_configuration in (new_player_prefix, new_studio_prefix):
        prefix = Wineprefix(prefix_configuration)

        prefix_configuration.wine_home = _get_wine_home(
            unsupported_settings.get(settings.k_wine_binary, ""),
            prefix_configuration.wine_home
        )

        if settings.k_dll_overrides in unsupported_settings:
            prefix_configuration.dll_overrides = unsupported_settings.get(settings.k_dll_overrides)

        prefix_configuration.fast_flags = _get_fast_flags(prefix)

        env = dict(unsupported_settings.get(settings.k_environment_variables, {}))
        if env.get("MESA_GL_VERSION_OVERRIDE", "") == "4.4":
            prefix_configuration.use_mesa_gl_override = True
            env.pop("MESA_GL_VERSION_OVERRIDE")

        if "WINEDEBUG" in env:
            prefix_configuration.enable_winedebug = True
            prefix_configuration.winedebug_string = env.pop("WINEDEBUG")

        prefix_configuration.env = env

        use_fps_unlocker = "rbxfpsunlocker" in unsupported_settings.get(settings.k_enabled_tweaks, [])
        if use_fps_unlocker:
            if not fps_unlocker_recipe.exists_in(prefix):
                fps_unlocker_recipe.make_in(prefix)
        prefix_configuration.third_party = {
            ThirdPartyKeys.fps_unlocker: use_fps_unlocker,
            ThirdPartyKeys.dxvk: False
        }

    prefixes.extend(list(map(asdict, [new_player_prefix, new_studio_prefix])))

    current_settings[settings.k_wineprefixes] = prefixes


@register_migration(2, 1)
def downgrade_wineprefix(user_settings: Dict):
    from grapejuice_common.features import settings

    if len(user_settings[settings.k_wineprefixes]) <= 0:
        return

    user_settings["env"] = user_settings[settings.k_wineprefixes][0].get("env", dict())

    original_prefix_path = paths.local_share_grapejuice() / "wineprefix"
    new_prefix_path = paths.wineprefixes_directory() / user_settings[settings.k_wineprefixes][0]["name_on_disk"]

    # Try to not destroy any prefixes
    if original_prefix_path.exists():
        if original_prefix_path.is_symlink():
            os.remove(original_prefix_path)

        else:
            n = 1
            while original_prefix_path.exists():
                original_prefix_path = paths.local_share_grapejuice() / f"wineprefix ({n})"
                n += 1

    original_prefix_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(new_prefix_path, original_prefix_path)
