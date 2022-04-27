from pathlib import Path
from typing import List

from gi.repository import Gtk, Gdk

from grapejuice_common.util.computed_field import ComputedField

_css_provider = ComputedField(lambda: Gtk.CssProvider())
_gdk_screen = ComputedField(lambda: Gdk.Screen.get_default())


def create_style_context() -> Gtk.StyleContext:
    ctx = Gtk.StyleContext()
    ctx.add_provider_for_screen(
        _gdk_screen.value,
        _css_provider.value,
        Gtk.STYLE_PROVIDER_PRIORITY_USER
    )

    return ctx


_style_context = ComputedField(create_style_context)
_loaded_styles_from_path: List[Path] = []
_loaded_styles_from_source: List[int] = []


def load_style_from_path(path: Path):
    assert _style_context.value

    if path in _loaded_styles_from_path:
        return

    _css_provider.value.load_from_path(str(path))

    _loaded_styles_from_path.append(path)


def load_style_from_source(source: str):
    assert _style_context.value

    source_hash = hash(source)
    if source_hash in _loaded_styles_from_source:
        return

    _css_provider.value.load_from_data(source)

    _loaded_styles_from_source.append(source_hash)
