from enum import Enum
from typing import Optional, Type, Callable, Any, Union, List

from gi.repository import Gtk

from grapejuice_common.gtk.components.grape_setting_action import GrapeSettingAction
from grapejuice_common.gtk.gtk_util import set_vertical_margins, set_horizontal_margins
from grapejuice_common.util import dunder_storm
from grapejuice_common.util.capture import Capture
from grapejuice_common.util.event import Event, Subscription

Transformer = Callable[[Any], Any]


def _row_auto_padding(axis: bool, minimum_size: Optional[int] = 10) -> Gtk.Fixed:
    w = Gtk.Fixed()

    if axis:
        w.set_hexpand(True)
        w.set_hexpand_set(True)
        w.set_size_request(minimum_size, -1)

    else:
        w.set_vexpand(True)
        w.set_vexpand_set(True)
        w.set_size_request(-1, minimum_size)

    return w


def _null_transformer(*args):
    n = len(args)

    if n == 1:
        return args[0]

    elif n > 1:
        return tuple(args)

    return None


class GrapeSettingWidget(Gtk.Box):
    _setter: Callable[[Any], None] = _null_transformer
    _getter: Callable[[], Any] = _null_transformer

    changed: Event

    # pylint: disable=E0102
    def __init__(
        self,
        initial_value: any,
        value_type: Type,
        *args,
        get_transformer: Optional[Transformer] = None,
        set_transformer: Optional[Transformer] = None,
        bidirectional_transformer: Optional[Transformer] = None,
        **kwargs
    ):
        dunder_dict, kwargs = dunder_storm(kwargs)
        super().__init__(*args, orientation=Gtk.Orientation.VERTICAL, **kwargs)

        self.changed = Event()

        widget = None

        set_transformer = set_transformer or bidirectional_transformer or _null_transformer
        get_transformer = get_transformer or bidirectional_transformer or _null_transformer

        def hook_up_changed_event(signal_name):
            widget.connect(signal_name, lambda *_: self.changed())

        if value_type is bool:
            widget = Gtk.Switch()
            widget.set_active(set_transformer(not not initial_value))

            self._getter = widget.get_active
            self._setter = widget.set_active

            hook_up_changed_event("state-set")

        elif value_type is str:
            widget = Gtk.Entry()
            widget.set_text(set_transformer(initial_value))

            self._getter = lambda: widget.get_text().strip()
            self._setter = lambda v: widget.set_text(str(v))

            hook_up_changed_event("changed")

        elif value_type is GrapeSettingAction:
            widget = Gtk.Button()
            widget.set_label(initial_value.display_name)

            widget.connect("clicked", initial_value.action)

        elif isinstance(initial_value, Enum):
            widget = Gtk.ComboBoxText()
            widget.set_entry_text_column(0)

            mapping = dict()

            active_index = 0
            for i, option in enumerate(type(initial_value)):
                mapping[i] = option
                widget.append_text(str(option.name))

                if option is initial_value:
                    active_index = i

            widget.set_active(dunder_dict.get("__list_index__", active_index))

            self._getter = lambda: mapping[widget.get_active()]
            self._setter = lambda v: widget.set_active(str(v.name))

            hook_up_changed_event("changed")

        elif isinstance(value_type, list):
            widget = Gtk.ComboBoxText()
            widget.set_entry_text_column(0)

            mapping = dict()

            active_index = 0
            for i, option in enumerate(value_type):
                mapping[i] = option
                widget.append_text(str(option))

                if option is initial_value:
                    active_index = i

            widget.set_active(dunder_dict.get("__list_index__", active_index))

            self._getter = lambda: mapping[widget.get_active()]
            self._setter = lambda v: widget.set_active(str(v.name))

            hook_up_changed_event("changed")

        if widget:
            self.add(_row_auto_padding(False))
            self.add(widget)
            self.add(_row_auto_padding(False))

        real_getter = Capture(self._getter)
        real_setter = Capture(self._setter)

        self._getter = lambda: get_transformer(real_getter.value())
        self._setter = lambda *x: real_setter.value(set_transformer(*x))

    @property
    def value(self):
        return self._getter()


class GrapeSetting(Gtk.ListBoxRow):
    _key: str
    _value_type: Union[Type, List[Any]]
    _display_name: str
    _use_tooltip = False
    _setting_widget: GrapeSettingWidget

    _box: Gtk.Box

    _widget_changed_subscription: Subscription
    changed: Event

    def __init__(
        self,
        key: str,
        value: any,
        *args,
        value_type: Optional[Union[Type, List[Any]]] = None,
        display_name: Optional[str] = None,
        description: Optional[str] = None,
        get_transformer: Optional[Transformer] = None,
        set_transformer: Optional[Transformer] = None,
        bidirectional_transformer: Optional[Transformer] = None,
        **kwargs
    ):
        dunder_dict, kwargs = dunder_storm(kwargs)
        super().__init__(*args, **kwargs)

        self._key = key
        self._value_type = value_type or type(value)
        self._display_name = display_name or key

        self.changed = Event()

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        set_horizontal_margins(box, 5)
        set_vertical_margins(box, 10)

        descriptive_text_parent = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        display_name_label = Gtk.Label()
        display_name_label.set_text(self._display_name)
        display_name_label.set_halign(Gtk.Align.START)
        display_name_label.set_justify(Gtk.Justification.LEFT)
        descriptive_text_parent.add(display_name_label)

        if description:
            if self._use_tooltip:
                self.set_tooltip_text(description)

            else:
                display_name_label.set_margin_bottom(5)

                description_label = Gtk.Label()
                description_label.set_text(description)
                description_label.set_halign(Gtk.Align.START)
                description_label.set_justify(Gtk.Justification.LEFT)
                description_label.set_max_width_chars(64)
                description_label.set_line_wrap(True)
                descriptive_text_parent.add(description_label)

        box.add(descriptive_text_parent)
        box.add(_row_auto_padding(True))

        self._setting_widget = GrapeSettingWidget(
            value,
            self._value_type,
            get_transformer=get_transformer,
            set_transformer=set_transformer,
            bidirectional_transformer=bidirectional_transformer,
            **dunder_dict,
            **kwargs
        )
        box.add(self._setting_widget)

        self._box = box
        self.add(box)

        self._widget_changed_subscription = Subscription(
            self._setting_widget.changed,
            lambda: self.changed()
        )

    @property
    def key(self):
        return self._key

    @property
    def value(self) -> Any:
        return self._setting_widget.value

    def destroy(self, *args, **kwargs):
        if self._widget_changed_subscription:
            self._widget_changed_subscription.unsubscribe()

        super().destroy(*args, **kwargs)
