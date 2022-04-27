import json
from typing import Optional, Union, Iterable, List

from gi.repository import Gtk, Pango

from grapejuice_common.gtk.components.grape_setting import GrapeSetting
from grapejuice_common.gtk.gtk_util import set_all_margins
from grapejuice_common.util.event import Event, Subscription


def _title(title: str) -> Gtk.Label:
    label = Gtk.Label()
    label.set_halign(Gtk.Align.START)
    label.modify_font(Pango.FontDescription("sans-serif 12"))
    label.set_markup(f"<b>{title}</b>")
    label.set_margin_bottom(5)

    return label


def _description(description: str) -> Gtk.Label:
    label = Gtk.Label()
    label.set_halign(Gtk.Align.START)
    label.set_text(description)
    label.set_margin_bottom(15)
    label.set_max_width_chars(64)
    label.set_line_wrap(True)

    return label


class GrapeSettingsGroup(Gtk.Box):
    _title: Gtk.Label
    _description: Optional[Gtk.Label]
    _settings: List[GrapeSetting]
    _list: Gtk.ListBox

    _settings_changed_subscriptions: List[Subscription]
    changed: Event

    def __init__(
        self,
        title: str,
        *args,
        description: Optional[Union[Gtk.Widget, str]] = None,
        settings: Optional[Iterable[GrapeSetting]] = None,
        **kwargs
    ):
        super().__init__(*args, orientation=Gtk.Orientation.VERTICAL, **kwargs)

        self.changed = Event()
        self._settings_changed_subscriptions = []
        self._settings = []

        set_all_margins(self, 10)
        self.set_margin_bottom(20)

        self._title = _title(title or "")
        self.add(self._title)

        self._description = None
        if isinstance(description, str):
            self._description = _description(description)

        elif description is not None:
            self._description = description

        if self._description:
            self.add(self._description)

        self._list = Gtk.ListBox()
        self._list.set_selection_mode(Gtk.SelectionMode.NONE)
        self.add(self._list)

        if settings:
            for setting in settings:
                self.add_setting(setting)

        separator = Gtk.Separator()
        separator.set_margin_top(20)
        self.add(separator)

    def add_setting(self, setting: GrapeSetting) -> "GrapeSettingsGroup":
        self._list.add(setting)
        self._settings.append(setting)

        sub = Subscription(setting.changed, lambda: self.changed())
        self._settings_changed_subscriptions.append(sub)

        return self

    @property
    def settings_dictionary(self):
        return dict(map(lambda setting: (setting.key, setting.value), self._settings))

    @property
    def settings_json(self):
        return json.dumps(self.settings_dictionary)

    def destroy(self, *args, **kwargs):
        for sub in self._settings_changed_subscriptions:
            sub.unsubscribe()

        self._settings_changed_subscriptions = []

        super().destroy(*args, **kwargs)
