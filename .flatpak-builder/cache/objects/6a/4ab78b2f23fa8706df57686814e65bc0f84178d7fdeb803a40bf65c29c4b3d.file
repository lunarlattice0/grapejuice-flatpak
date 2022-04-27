from typing import Callable

from gi.repository import Gtk

from grapejuice_common import paths
from grapejuice_common.gtk.gtk_base import GtkBase
from grapejuice_common.gtk.gtk_util import set_gtk_widgets_visibility
from grapejuice_common.models.fast_flags import FastFlag
from grapejuice_common.util.event import Event, Subscription


class GrapeFlagEditorWidget(Gtk.Box):
    _getter: Callable[[], any]
    _setter: Callable[[any], None]

    changed: Event()

    def __init__(self, flag: FastFlag, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.changed = Event()

        if flag.is_a(bool):
            widget = Gtk.Switch()
            widget.set_active(flag.value)
            widget.set_vexpand(False)
            widget.set_vexpand_set(True)

            self._getter = widget.get_active
            self._setter = widget.set_active

            widget.connect("state-set", lambda *_: self.changed())

        elif flag.is_a(str):
            widget = Gtk.Entry()
            widget.set_text(flag.value)
            widget.set_hexpand(True)
            widget.set_hexpand_set(True)

            self._getter = widget.get_text
            self._setter = lambda v: widget.set_text(str(v))

            widget.connect("changed", lambda *_: self.changed())

        elif flag.is_a(int):
            adjustment = Gtk.Adjustment()
            adjustment.set_step_increment(1.0)
            adjustment.set_upper(2147483647)
            adjustment.set_value(flag.value)

            widget = Gtk.SpinButton()
            widget.set_adjustment(adjustment)
            widget.set_value(flag.value)

            self._getter = lambda: int(adjustment.get_value())
            self._setter = lambda v: adjustment.set_value(int(v))

            adjustment.connect("value-changed", lambda *_: self.changed())

        else:
            widget = Gtk.Label()

            self._setter = lambda v: widget.set_text(f"{v} (unknown type!)")
            self._getter = lambda: None

        self.add(widget)

        widget.show()

    @property
    def value(self):
        return self._getter()

    @value.setter
    def value(self, v):
        self._setter(v)


class GrapeFastFlagRow(GtkBase):
    _flag: FastFlag
    _editor_widget: GrapeFlagEditorWidget
    _change_subscription: Subscription = None

    flag_changed: Event

    def __init__(self, flag: FastFlag):
        super().__init__(
            glade_path=paths.fast_flag_editor_glade(),
            root_widget_name="fast_flag_row"
        )

        self._flag = flag
        self.flag_changed = Event()

        self._editor_widget = GrapeFlagEditorWidget(flag)
        self.widgets.fast_flag_widgets.add(self._editor_widget)
        self._change_subscription = Subscription(
            self._editor_widget.changed,
            self._on_editor_value_changed
        )

        self.widgets.fflag_reset_button.connect("clicked", self._reset_button_clicked)

        self.update_display()

    def _on_editor_value_changed(self):
        self._flag.value = self._editor_widget.value
        self.update_display()

        self.flag_changed(self._flag)

    def _reset_button_clicked(self, *_):
        self._flag.reset()
        self._editor_widget.value = self._flag.value

    def update_display(self):
        self.widgets.fflag_name_label.set_text(self._flag.name)
        set_gtk_widgets_visibility([self.widgets.icon_fflag_changed], self._flag.has_changed)
        set_gtk_widgets_visibility(
            [self.widgets.fflag_reset_button],
            self._flag.has_changed and (not self._flag.is_a(bool))
        )

    def destroy(self):
        self.root_widget.destroy()
        self._change_subscription.unsubscribe()
