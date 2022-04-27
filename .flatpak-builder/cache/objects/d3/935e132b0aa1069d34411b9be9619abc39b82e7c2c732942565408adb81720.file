from enum import Enum
from typing import Optional, Dict, Sequence

from gi.repository import Gtk

from grapejuice_common.util.capture import Capture
from grapejuice_common.util.event import Event


class GrapeEnumMenuPopover(Gtk.Popover):
    def __init__(self, children, *args, **kwargs):
        super().__init__(*args, **kwargs)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.set_margin_top(10)
        box.set_margin_bottom(10)
        box.set_margin_start(10)
        box.set_margin_end(10)

        for child in children:
            box.add(child)

        self.add(box)

        box.show_all()


def _make_enum_button(
    cap: Capture[Enum],
    display_strings: Dict[Enum, str],
    handler: callable
):
    button = Gtk.ModelButton()
    button.set_label(display_strings.get(cap.value, cap.value.value))

    def on_clicked(*event_args):
        handler(*event_args, cap.value)

    button.connect("clicked", on_clicked)

    return button


class GrapeEnumMenu(Gtk.MenuButton):
    _display_label: Gtk.ModelButton
    _popover: Gtk.Popover

    _current_enum = None
    _display_strings: Dict[Enum, str]
    enum_selected: Event()

    def __init__(
        self, enum: Sequence[Enum],
        *args,
        display_strings: Optional[Dict[Enum, str]] = None,
        active_enum: Optional[Enum] = None,
        **kwargs
    ):
        super().__init__(*args, **kwargs)

        self._display_strings = display_strings or dict()
        self.enum_selected = Event()

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        box.set_margin_start(5)
        box.set_margin_end(5)

        display_label = Gtk.Label()
        display_label.set_margin_end(5)

        self._display_label = display_label
        box.add(display_label)

        image = Gtk.Image.new_from_icon_name("go-down-symbolic", Gtk.IconSize.BUTTON)
        box.add(image)

        self.add(box)

        self.current_enum = self._current_enum or active_enum

        buttons = []
        for enum_item in enum:
            button = _make_enum_button(
                Capture(enum_item),
                self._display_strings,
                self._on_enum_activation
            )

            buttons.append(button)

        popover = GrapeEnumMenuPopover(buttons)
        self._popover = popover
        self.set_popover(popover)

    def _on_enum_activation(self, _button, enum_item):
        self.current_enum = enum_item
        self.enum_selected(enum_item)
        self._popover.popdown()

    @property
    def current_enum(self):
        return self._current_enum

    @current_enum.setter
    def current_enum(self, v):
        self._display_label.set_text(self._display_strings.get(v, v.value))
        self._current_enum = v
