import logging
from dataclasses import dataclass
from gettext import gettext as _
from typing import Optional

from grapejuice_common.gtk.components.grape_setting import GrapeSetting
from grapejuice_common.gtk.components.grape_settings_group import GrapeSettingsGroup
from grapejuice_common.gtk.components.grape_settings_pane import GrapeSettingsPane
from grapejuice_common.hardware_info.xrandr import XRandRProvider
from grapejuice_common.hardware_info.xrandr_factory import xrandr_factory
from grapejuice_common.models.wineprefix_configuration_model import ThirdPartyKeys
from grapejuice_common.roblox_product import RobloxProduct
from grapejuice_common.roblox_renderer import RobloxRenderer
from grapejuice_common.util.event import Event, Subscription
from grapejuice_common.wine.wineprefix import Wineprefix
from grapejuice_common.wine.wineprefix_hints import WineprefixHint

log = logging.getLogger(__name__)


def _app_hints(prefix: Wineprefix) -> GrapeSettingsGroup:
    product_map = {
        RobloxProduct.app: {
            "display_name": _("Desktop App"),
            "hint": WineprefixHint.app
        },
        RobloxProduct.studio: {
            "display_name": _("Studio"),
            "hint": WineprefixHint.studio
        },
        RobloxProduct.player: {
            "display_name": _("Experience Player"),
            "hint": WineprefixHint.player
        }
    }

    def map_product(product: RobloxProduct):
        info = product_map[product]

        return GrapeSetting(
            key=info["hint"].value,
            display_name=info["display_name"],
            value=info["hint"].value in prefix.configuration.hints
        )

    return GrapeSettingsGroup(
        title=_("Application Hints"),
        description=_("Grapejuice uses application hints to determine which prefix should be used to launch a Roblox "
                    "application. If you toggle the hint for a Roblox application on for this prefix, Grapejuice will "
                    "use this prefix for that application."),
        settings=list(map(map_product, iter(RobloxProduct)))
    )


def _graphics_settings(prefix: Wineprefix) -> Optional[GrapeSettingsGroup]:
    from grapejuice_common.features.settings import current_settings

    def _get_renderer():
        return RobloxRenderer(prefix.configuration.roblox_renderer)

    def _renderer_setting():
        return GrapeSetting(
            key="roblox_renderer",
            display_name=_("Roblox Renderer"),
            value_type=RobloxRenderer,
            value=_get_renderer()
        )

    def _prime_offload_sink():
        try:
            xrandr = xrandr_factory()
            profile = current_settings.hardware_profile
            provider_index = profile.provider_index

        except Exception as e:
            log.error(str(e))
            return []

        if not profile.is_multi_gpu:
            return []

        def provider_to_string(provider: XRandRProvider):
            return f"{provider.index}: {provider.name}"

        provider_list = list(map(provider_to_string, xrandr.providers))

        return [
            GrapeSetting(
                key="should_prime",
                display_name=_("Use PRIME offloading"),
                value=profile.should_prime
            ),
            GrapeSetting(
                key="prime_offload_sink",
                display_name=_("PRIME offload sink"),
                value_type=provider_list,
                value=provider_list,
                __list_index__=provider_index
            )
        ]

    def _mesa_gl_override():
        return GrapeSetting(
            key="use_mesa_gl_override",
            display_name=_("Use Mesa OpenGL version override"),
            value=prefix.configuration.use_mesa_gl_override
        )

    settings = list(filter(
        None,
        [
            _renderer_setting(),
            *_prime_offload_sink(),
            _mesa_gl_override()
        ]
    ))

    if not settings:
        return None

    return GrapeSettingsGroup(
        title=_("Graphics Settings"),
        description=_("Grapejuice can assist with graphics performance in Roblox. These are the settings that control "
                    "Grapejuice's graphics acceleration features."),
        settings=settings
    )


def _wine_debug_settings(prefix: Wineprefix):
    return GrapeSettingsGroup(
        title=_("Wine debugging settings"),
        description=_("Wine has an array of debugging options that can be used to improve wine. Some of them can cause "
                    "issues, be careful!"),
        settings=[
            GrapeSetting(
                key="enable_winedebug",
                display_name=_("Enable Wine debugging"),
                value=prefix.configuration.enable_winedebug,
            ),
            GrapeSetting(
                key="winedebug_string",
                display_name=_("WINEDEBUG string"),
                value=prefix.configuration.winedebug_string
            )
        ]
    )


def _third_party(prefix: Wineprefix):
    return GrapeSettingsGroup(
        title=_("Third party application integrations"),
        description=_("Grapejuice can assist in installing third party tools that will improve the Roblox experience"),
        settings=[
            GrapeSetting(
                key=ThirdPartyKeys.fps_unlocker,
                display_name=_("Use Roblox FPS Unlocker"),
                value_type=bool,
                value=prefix.configuration.third_party.get(ThirdPartyKeys.fps_unlocker, False)
            ),
            GrapeSetting(
                key=ThirdPartyKeys.dxvk,
                display_name=_("Use DXVK D3D implementation"),
                value=prefix.configuration.third_party.get(ThirdPartyKeys.dxvk, False)
            )
        ]
    )


@dataclass
class ToggleSettings:
    pass


@dataclass(frozen=True)
class Groups:
    app_hints: GrapeSettingsGroup
    winedebug: GrapeSettingsGroup
    graphics_settings: GrapeSettingsGroup
    third_party: GrapeSettingsGroup

    @property
    def as_list(self):
        return list(filter(
            None,
            [
                self.app_hints,
                self.winedebug,
                self.graphics_settings,
                self.third_party
            ]
        ))


class PrefixFeatureToggles:
    _target_widget = None
    _current_pane: Optional[GrapeSettingsPane] = None
    _groups: Optional[Groups] = None
    _prefix: Optional[Wineprefix] = None

    _pane_changed_subscription: Optional[Subscription] = None
    changed: Event

    def __init__(self, target_widget):
        self._target_widget = target_widget
        self.changed = Event()

    def _destroy_pane(self):
        if self._pane_changed_subscription:
            self._pane_changed_subscription.unsubscribe()
            self._pane_changed_subscription = None

        if self._current_pane:
            self._target_widget.remove(self._current_pane)
            self._current_pane.destroy()
            self._current_pane = None
            self._groups = None

    def clear_toggles(self):
        self._destroy_pane()

    def use_prefix(self, prefix: Wineprefix):
        self.clear_toggles()

        self._prefix = prefix
        self._groups = Groups(*list(
            map(
                lambda c: c(prefix),
                filter(
                    None,
                    [
                        _app_hints,
                        _wine_debug_settings,
                        _graphics_settings,
                        _third_party
                    ]
                )
            )
        ))

        pane = GrapeSettingsPane(groups=self._groups.as_list, min_content_height=200)

        self._target_widget.add(pane)
        pane.show_all()

        self._current_pane = pane

        self._pane_changed_subscription = Subscription(pane.changed, lambda: self.changed())

    def destroy(self):
        self._destroy_pane()

    @property
    def configured_model(self):
        model = self._prefix.configuration.copy()
        product_hints = list(map(lambda h: h.value, [WineprefixHint.player, WineprefixHint.app, WineprefixHint.studio]))

        hints = model.hints
        hints = list(filter(lambda h: h not in product_hints, hints))
        for k, v in self._groups.app_hints.settings_dictionary.items():
            if v:
                hints.append(k)

        model.hints = hints

        model.apply_dict(self._groups.winedebug.settings_dictionary)

        graphics = self._groups.graphics_settings.settings_dictionary
        model.roblox_renderer = graphics.pop("roblox_renderer", RobloxRenderer.Undetermined).value
        graphics.pop("roblox_renderer", None)

        should_prime = graphics.pop("should_prime", False)
        if should_prime and (graphics.get("prime_offload_sink", None) is not None):
            model.prime_offload_sink = int(graphics["prime_offload_sink"].split(":")[0])

        else:
            model.prime_offload_sink = -1

        graphics.pop("prime_offload_sink", None)

        model.apply_dict(graphics)

        model.third_party = self._groups.third_party.settings_dictionary

        return model

    def __del__(self):
        self.destroy()
