from typing import Optional, Iterable, List

from gi.repository import Gtk

from grapejuice_common.gtk.components.grape_settings_group import GrapeSettingsGroup
from grapejuice_common.util.event import Subscription, Event


class GrapeSettingsPane(Gtk.ScrolledWindow):
    _viewport: Gtk.Viewport
    _box: Gtk.Box

    _groups_changed_subscriptions: List[Subscription]
    changed: Event

    def __init__(
        self,
        *args,
        groups: Optional[Iterable[GrapeSettingsGroup]] = None,
        min_content_height: Optional[int] = 550,
        **kwargs
    ):
        super().__init__(*args, **kwargs)

        self._groups_changed_subscriptions = []
        self.changed = Event()

        self.set_hexpand(True)
        self.set_hexpand_set(True)
        self.set_vexpand(True)
        self.set_vexpand_set(True)
        self.set_min_content_height(min_content_height)

        self._viewport = Gtk.Viewport()
        self.add(self._viewport)

        self._box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self._viewport.add(self._box)

        if groups:
            for group in groups:
                self.add_group(group)

    def add_group(self, group: GrapeSettingsGroup) -> "GrapeSettingsPane":
        self._box.add(group)

        sub = Subscription(group.changed, lambda: self.changed())
        self._groups_changed_subscriptions.append(sub)

        return self

    def destroy(self, *args, **kwargs):
        for sub in self._groups_changed_subscriptions:
            sub.unsubscribe()

        self._groups_changed_subscriptions = []

        super().destroy(*args, **kwargs)
