from pathlib import Path
from typing import Optional, Type, TypeVar, List

from gi.repository import Gtk

HandlerType = TypeVar("HandlerType")
HandlerMethod = TypeVar("HandlerMethod")


def handler(x: HandlerMethod) -> HandlerMethod:
    def wrapper(*args, **kwargs):
        try:
            return x(*args, **kwargs)

        except Exception as e:
            from grapejuice.windows.exception_viewer import ExceptionViewer

            window = ExceptionViewer(exception=e)
            window.show()

            return None

    return wrapper


manually_connected_handler = handler


class WidgetAccessor:
    _builder: Optional

    def __init__(self, builder):
        self._builder = builder

    def __getattr__(self, item) -> Optional[Gtk.Widget]:
        return self._builder.get_object(item)

    def __getitem__(self, item) -> Optional[Gtk.Widget]:
        return self._builder.get_object(item)


class NullWidgetAccessor(WidgetAccessor):
    def __init__(self):
        super().__init__(None)

    def __getattr__(self, _) -> Optional[Gtk.Widget]:
        return None

    def __getitem__(self, _) -> Optional[Gtk.Widget]:
        return None


class GtkBase:
    _widgets: WidgetAccessor
    _glade_path: Optional[Path] = None
    _builder: Optional = None
    _handlers: List[HandlerType] = None
    _root_widget_name: Optional[str] = None

    def __init__(
        self,
        glade_path: Optional[Path] = None,
        handler_class: Optional[Type[HandlerType]] = None,
        handler_instance: Optional[HandlerType] = None,
        root_widget_name: Optional[str] = None,
    ):
        # Configure fields
        self._handlers = []

        self._glade_path = glade_path
        self._builder = self._create_builder()
        self._root_widget_name = root_widget_name

        # Load ui files
        if self._builder is None:
            self._widgets = NullWidgetAccessor()

        else:
            if handler_class is not None:
                self._handlers.append(handler_class())

            if handler_instance is not None:
                self._handlers.append(handler_instance)

            for h in self._handlers:
                self._builder.connect_signals(h)

            self._widgets = WidgetAccessor(self._builder)

    def _create_builder(self) -> Optional[Gtk.Builder]:
        if self._glade_path is not None:
            builder = Gtk.Builder()
            builder.set_translation_domain("grapejuice")
            builder.add_from_file(str(self._glade_path))

            return builder

        return None

    @property
    def widgets(self) -> WidgetAccessor:
        return self._widgets

    @property
    def root_widget(self) -> Optional[Gtk.Widget]:
        return self.widgets[self._root_widget_name]

    def __del__(self):
        if self._builder is not None:
            del self._builder
            self._builder = None
