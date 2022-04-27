from gi.repository import Gtk

from grapejuice_common.gtk.components.grape_list_box_row_with_icon import GrapeListBoxRowWithIcon
from grapejuice_common.models.wineprefix_configuration_model import WineprefixConfigurationModel
from grapejuice_common.wine.wineprefix_hints import WineprefixHint


class GrapeWineprefixRow(GrapeListBoxRowWithIcon):
    _prefix_model: WineprefixConfigurationModel = None
    _label = None

    def __init__(self, prefix: WineprefixConfigurationModel, *args, **kwargs):
        icon_name = "preferences-desktop-screensaver-symbolic"

        if WineprefixHint.studio in prefix.hints_as_enum:
            icon_name = "grapejuice-roblox-studio"

        elif WineprefixHint.player in prefix.hints_as_enum:
            icon_name = "grapejuice-roblox-player"

        super().__init__(*args, icon_name=icon_name, **kwargs)

        self._prefix_model = prefix

        label = Gtk.Label()
        label.set_text(prefix.display_name)
        self._label = label

        self.box.add(label)

    @property
    def prefix_model(self) -> WineprefixConfigurationModel:
        return self._prefix_model

    @prefix_model.setter
    def prefix_model(self, new_model: WineprefixConfigurationModel):
        self._prefix_model = new_model
        self.set_text(self._prefix_model.display_name)

    def set_text(self, text: str):
        self._label.set_text(text)


class GrapeStartUsingGrapejuiceRow(GrapeListBoxRowWithIcon):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, icon_name="user-home-symbolic", **kwargs)

        label = Gtk.Label()
        label.set_text("Start")

        self.box.add(label)


class GtkAddWineprefixRow(Gtk.Box):
    def __init__(self, *args, **kwargs):
        super().__init__(
            *args,
            orientation=Gtk.Orientation.HORIZONTAL,
            **kwargs
        )

        self.set_margin_top(5)
        self.set_margin_bottom(5)
        self.set_halign(Gtk.Align.CENTER)

        image = Gtk.Image.new_from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON)

        self.add(image)
