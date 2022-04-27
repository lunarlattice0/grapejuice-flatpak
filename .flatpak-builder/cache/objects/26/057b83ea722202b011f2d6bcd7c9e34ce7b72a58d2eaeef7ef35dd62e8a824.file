from typing import List, Callable

from gi.repository import Gtk, Gdk


class PrefixNameHandler:
    _wrapper = None
    _active_widget = None
    _prefix_name: str = ""
    _on_finish_editing_callbacks: List[Callable[["PrefixNameHandler"], None]]

    def __init__(self, prefix_name_wrapper):
        self._on_finish_editing_callbacks = []
        self._wrapper = prefix_name_wrapper

        label = Gtk.Label()
        label.set_text("__invalid__")
        self._label = label

        entry = Gtk.Entry()
        entry.connect("key-press-event", self._on_key_press)

        self._entry = entry

    def _on_key_press(self, _entry, event):
        key = Gdk.keyval_name(event.keyval)

        if key == "Return":
            self.finish_editing()

        elif key == "Escape":
            self.cancel_editing()

    def on_finish_editing(self, callback: Callable[["PrefixNameHandler"], None]):
        self._on_finish_editing_callbacks.append(callback)

    def finish_editing(self, use_entry_value: bool = True):
        self._set_active_widget(self._label)

        new_name = self._entry.get_text().strip()
        if not new_name:
            # Cannot use empty names
            use_entry_value = False

        if new_name == self.prefix_name:
            # No need to update
            use_entry_value = False

        if use_entry_value:
            self._prefix_name = new_name
            self._label.set_text(new_name)

            for cb in self._on_finish_editing_callbacks:
                cb(self)

    def _clear_active_widget(self):
        if self._active_widget is not None:
            self._wrapper.remove(self._active_widget)
            self._active_widget = None

    def _set_active_widget(self, widget):
        self._clear_active_widget()
        self._wrapper.add(widget)
        self._active_widget = widget
        widget.show()

    def set_prefix_name(self, name: str):
        self._set_active_widget(self._label)
        self._label.set_text(name)
        self._prefix_name = name

    def activate_entry(self):
        self._entry.set_text(self._prefix_name)
        self._set_active_widget(self._entry)
        self._entry.grab_focus()

    def cancel_editing(self):
        self.finish_editing(use_entry_value=False)

    @property
    def is_editing(self):
        return self._active_widget is self._entry

    @property
    def prefix_name(self) -> str:
        return self._prefix_name
