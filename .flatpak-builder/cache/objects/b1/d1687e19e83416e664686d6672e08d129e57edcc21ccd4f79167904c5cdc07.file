import traceback
from pathlib import Path
from string import Template
from typing import List, Optional, Tuple

from grapejuice_common.wine.wineprefix_hints import WineprefixHint


def format_exception(ex: Exception):
    return "".join(traceback.format_exception(type(ex), ex, ex.__traceback__))


class PresentableError(RuntimeError):
    _title: str
    _description: str
    _traceback_value: Optional[str] = None

    def __init__(
        self,
        title: str,
        description: str,
        cause: Optional[Exception] = None,
        technical_description: Optional[str] = None,
        traceback_from_given_info: Optional[bool] = False
    ):
        super_arg = cause or technical_description
        if super_arg is None:
            super_arg = f"{title}:\n{description}"

        super().__init__(super_arg)

        self._title = title
        self._description = description

        if traceback_from_given_info:
            self._traceback_value = f"{title}:\n{description}"

    @property
    def title(self) -> str:
        return self._title

    @property
    def description(self) -> str:
        return self._description

    @property
    def traceback(self) -> str:
        if self._traceback_value:
            return self._traceback_value

        self._traceback_value = format_exception(self)

        return self._traceback_value


class CouldNotFindSystemWineHome(RuntimeError):
    def __init__(self):
        super().__init__("A valid wine binary could not be found")


class RobloxDownloadError(RuntimeError):
    def __init__(self):
        super().__init__("Roblox installer couldn't be downloaded")


class RobloxExecutableNotFound(RuntimeError):
    def __init__(self, executable_name: str):
        super().__init__(f"Roblox executable '{executable_name}' could not be found!")


class NoWineprefixConfiguration(RuntimeError):
    def __init__(self):
        super().__init__("Configuration for a Wineprefix instance cannot be None")


class WineprefixNotFoundUsingHints(RuntimeError):
    def __init__(self, hints: List[WineprefixHint]):
        hints_as_string = "\n".join(list(map(lambda hint: hint.value, hints)))
        msg = f"A wineprefix could not be found using hints. The following hints were used:\n\n{hints_as_string}"

        super().__init__(msg)


class HardwareProfilingError(RuntimeError):
    pass


class NoHardwareProfile(HardwareProfilingError):
    pass


class WineHomeNotAbsolute(PresentableError):
    def __init__(self, wine_home: Path):
        super().__init__(
            title="Wine home path is not absolute",
            description=f"The Wine home path pointing to {wine_home} could not be resolved to an absolute directory. "
                        "Make sure the path is valid and points to an existing directory!"
        )


class WineHomeInvalid(PresentableError):
    def __init__(self, wine_home: Optional[Path]):
        wine_home = wine_home or "(undefined)"

        super().__init__(
            title="Wine home path is invalid",
            description=f"The wine home path pointing to {wine_home} is invalid! Make sure the directory at this "
                        "location contains a valid wine installation. 'wine_home' must point to a directory "
                        "containing your Wine installation files (bin, lib, etc... "
        )


class NoValidWineHomes(PresentableError):
    def __init__(self, available_homes: List[str], invalid_reasons: List[Tuple[Path, str]]):
        reasons_lines = []
        for home_path, reason in invalid_reasons:
            reasons_lines.append(f"Wine home '{home_path}' is invalid because: {reason}")

        description_template = Template("""\
Grapejuice could not find a valid Wine Home directory to use. Keep in mind that a valid Wine Home
is a directory of a Wine build where the bin, lib, etc directories are located. If you have used an
older guide that still uses a path ending in /bin, please remove the /bin part of the path.

The list of available Wine homes is:
$AVAILABLE_HOMES

Reasons for Wine homes being invalid:
$REASONS_BLOB
        """)

        super().__init__(
            title="Grapejuice could not find a valid wine home",
            description=description_template.substitute({
                "AVAILABLE_HOMES": "\n".join(available_homes),
                "REASONS_BLOB": "\n".join(reasons_lines)
            })
        )
