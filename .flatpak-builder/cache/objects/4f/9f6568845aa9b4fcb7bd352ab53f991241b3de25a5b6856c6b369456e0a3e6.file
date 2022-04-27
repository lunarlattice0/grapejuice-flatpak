import logging
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Dict

from grapejuice_common.errors import WineprefixNotFoundUsingHints, HardwareProfilingError
from grapejuice_common.hardware_info.hardware_profile import HardwareProfile
from grapejuice_common.models.wineprefix_configuration_model import WineprefixConfigurationModel
from grapejuice_common.roblox_renderer import RobloxRenderer
from grapejuice_common.wine.wineprefix import Wineprefix
from grapejuice_common.wine.wineprefix_hints import WineprefixHint

LOG = logging.getLogger(__name__)


def get_wineprefix(hints: List[WineprefixHint], when_not_found_prefix_factory: Optional[callable] = None):
    from grapejuice_common.features.settings import current_settings, k_wineprefixes

    for prefix_configuration in current_settings.get(k_wineprefixes):
        has_all_hints = True

        for hint in hints:
            has_all_hints = has_all_hints and hint.value in prefix_configuration.get("hints", [])

        if has_all_hints:
            return Wineprefix(
                configuration=WineprefixConfigurationModel.from_dict(prefix_configuration)
            )

    if callable(when_not_found_prefix_factory):
        when_not_found_prefix_factory()
        return get_wineprefix(hints)

    else:
        raise WineprefixNotFoundUsingHints(hints)


def _create_and_save_wineprefix(model_factory):
    def factory():
        from grapejuice_common.features.settings import current_settings

        model = model_factory()
        current_settings.save_prefix_model(model)

    return factory


OtherHints = Optional[List[WineprefixHint]]


def _get_wineprefix_with_other_hints(
    hint: WineprefixHint,
    other_hints: OtherHints,
    when_not_found_prefix_factory: Optional[callable] = None
) -> Wineprefix:
    return get_wineprefix(
        hints=list({hint, *(other_hints or [])}),
        when_not_found_prefix_factory=when_not_found_prefix_factory
    )


def find_wineprefix(prefix_id: str) -> Wineprefix:
    from grapejuice_common.features.settings import current_settings
    return Wineprefix(configuration=current_settings.find_wineprefix(prefix_id))


def _dll_overrides(settings) -> str:
    return settings.get("dll_overrides", "dxdiagn=;winemenubuilder.exe=")


def _env(settings) -> Dict[str, str]:
    return settings.get("env", dict())


def _wine_home(settings) -> str:
    if "wine_home" in settings:
        return settings.get("wine_home")

    if "wine_binary" in settings:
        return str(Path(settings["wine_binary"]).resolve().parent.parent)

    # Empty string should resolve to wine_home during launch
    return ""


def _hardware_profile() -> Optional[HardwareProfile]:
    from grapejuice_common.features.settings import current_settings

    try:
        return current_settings.hardware_profile

    except HardwareProfilingError as e:
        LOG.error(e)

    return None


@dataclass(init=False)
class ProfiledParameters:
    prime_offload_sink: int = -1
    use_mesa_gl_override: bool = False
    renderer: str = RobloxRenderer.Undetermined.value

    def __init__(self):
        p = _hardware_profile()

        if p:
            self.renderer = p.preferred_roblox_renderer.value
            self.use_mesa_gl_override = p.use_mesa_gl_override

            if p.should_prime:
                self.prime_offload_sink = p.provider_index


def create_player_prefix_model(settings: Optional[Dict] = None):
    settings = settings or dict()
    params = ProfiledParameters()

    return WineprefixConfigurationModel(
        id=str(uuid.uuid4()),
        priority=0,
        name_on_disk="player",
        display_name="Player",
        wine_home=_wine_home(settings),
        dll_overrides=_dll_overrides(settings),
        env=_env(settings),
        hints=[WineprefixHint.player.value, WineprefixHint.app.value],
        prime_offload_sink=params.prime_offload_sink,
        use_mesa_gl_override=params.use_mesa_gl_override,
        roblox_renderer=params.renderer
    )


def create_studio_prefix_model(settings: Optional[Dict] = None):
    settings = settings or dict()
    params = ProfiledParameters

    return WineprefixConfigurationModel(
        id=str(uuid.uuid4()),
        priority=0,
        name_on_disk="studio",
        display_name="Studio",
        wine_home=_wine_home(settings),
        dll_overrides=_dll_overrides(settings),
        env=_env(settings),
        hints=[WineprefixHint.studio.value],
        prime_offload_sink=params.prime_offload_sink,
        use_mesa_gl_override=params.use_mesa_gl_override,
        roblox_renderer=RobloxRenderer.DX11.value
    )


def create_new_model_for_user(settings: Optional[Dict] = None):
    settings = settings or dict()
    params = ProfiledParameters()

    model = WineprefixConfigurationModel(
        id=str(uuid.uuid4()),
        priority=0,
        name_on_disk=".",
        display_name="New Wineprefix",
        wine_home=_wine_home(settings),
        dll_overrides=_dll_overrides(settings),
        env=_env(settings),
        hints=[],
        prime_offload_sink=params.prime_offload_sink,
        use_mesa_gl_override=params.use_mesa_gl_override,
        roblox_renderer=params.renderer
    )

    model.create_name_on_disk_from_display_name()

    return model


def get_studio_wineprefix(other_hints: OtherHints = None) -> Wineprefix:
    return _get_wineprefix_with_other_hints(
        WineprefixHint.studio,
        other_hints,
        when_not_found_prefix_factory=_create_and_save_wineprefix(create_studio_prefix_model)
    )


def get_player_wineprefix(other_hints: OtherHints = None) -> Wineprefix:
    return _get_wineprefix_with_other_hints(
        WineprefixHint.player,
        other_hints,
        when_not_found_prefix_factory=_create_and_save_wineprefix(create_player_prefix_model)
    )


def get_app_wineprefix(other_hints: OtherHints = None) -> Wineprefix:
    return _get_wineprefix_with_other_hints(
        WineprefixHint.app,
        other_hints,
        when_not_found_prefix_factory=_create_and_save_wineprefix(create_player_prefix_model)
    )
