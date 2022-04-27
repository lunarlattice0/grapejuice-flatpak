import os
from pathlib import Path

HERE = Path(__file__).resolve().parent


def _ensure_directory(p: Path) -> Path:
    p.mkdir(parents=True, exist_ok=True)
    return p


def home() -> Path:
    return Path(os.environ["HOME"]).resolve()


def dot_local() -> Path:
    return _ensure_directory(home() / ".local")


def local_share() -> Path:
    if "XDG_DATA_HOME" in os.environ:
        return _ensure_directory(Path(os.environ["XDG_DATA_HOME"]).resolve())

    else:
        return dot_local() / "share"


def local_var() -> Path:
    return dot_local() / "var"


def local_log() -> Path:
    return local_var() / "log"


def xdg_config_home() -> Path:
    if "XDG_CONFIG_HOME" in os.environ:
        return _ensure_directory(Path(os.environ["XDG_CONFIG_HOME"]).resolve())

    return _ensure_directory(home() / ".config")


def xdg_cache_home() -> Path:
    if "XDG_CACHE_HOME" in os.environ:
        return _ensure_directory(Path(os.environ["XDG_CACHE_HOME"]).resolve())

    return _ensure_directory(home() / ".cache")


def local_share_grapejuice() -> Path:
    return local_share() / "grapejuice"


def configuration_base_directory() -> Path:
    return xdg_config_home() / "brinkervii"


def grapejuice_configuration_directory() -> Path:
    return configuration_base_directory() / "grapejuice"


def grapejuice_user_settings() -> Path:
    return grapejuice_configuration_directory() / "user_settings.json"


def wineprefixes_directory() -> Path:
    return local_share_grapejuice() / "prefixes"


def application_manifest() -> Path:
    return local_share_grapejuice() / "package_manifest.json"


def logging_directory() -> Path:
    return local_log() / "grapejuice"


def assets_directory() -> Path:
    search_locations = [
        HERE / "assets",
        Path(".").resolve() / "assets"
    ]

    for p in search_locations:
        if p.exists():
            return p

    raise RuntimeError("Could not find assets directory")


def desktop_assets_directory() -> Path:
    return assets_directory() / "desktop"


def mime_xml_assets_directory() -> Path:
    return assets_directory() / "mime_xml"


def icons_assets_directory() -> Path:
    return assets_directory() / "icons"


def glade_directory() -> Path:
    return assets_directory() / "glade"


def grapejuice_glade() -> Path:
    return glade_directory() / "grapejuice.glade"


def global_css() -> Path:
    return glade_directory() / "global.css"


def about_glade() -> Path:
    return glade_directory() / "about.glade"


def fast_flag_editor_glade() -> Path:
    return glade_directory() / "fast_flag_editor.glade"


def grapejuice_components_glade() -> Path:
    return glade_directory() / "grapejuice_components.glade"


def fast_flag_warning_glade() -> Path:
    return glade_directory() / "fast_flag_warning.glade"


def exception_viewer_glade() -> Path:
    return glade_directory() / "exception_viewer.glade"


def settings_glade() -> Path:
    return glade_directory() / "settings.glade"


def grapejuice_cache_directory() -> Path:
    return _ensure_directory(xdg_cache_home() / "grapejuice")


def fast_flag_cache_location() -> Path:
    return grapejuice_cache_directory() / "fast_flags.json"


# TODO: Add method to extract this data
path_resolve_record = dict()


def _hack_path_functions():
    from typing import get_type_hints

    def wrap_function(path_name: str, f: callable):
        def wrapper(*args, **kwargs):
            path = f(*args, **kwargs)
            path_resolve_record[path_name] = path

            return path

        return wrapper

    for k in list(globals()):
        v = globals()[k]

        if callable(v) and k.strip("_").islower():
            type_hints = get_type_hints(v)
            if type_hints.get("return", None) is Path:
                globals()[k] = wrap_function(k, v)


_hack_path_functions()
