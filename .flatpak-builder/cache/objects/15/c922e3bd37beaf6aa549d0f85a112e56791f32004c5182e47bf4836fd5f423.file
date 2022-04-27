import re
from copy import deepcopy
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Dict, List

from grapejuice_common.roblox_renderer import RobloxRenderer
from grapejuice_common.wine.wineprefix_hints import WineprefixHint


class ThirdPartyKeys:
    fps_unlocker = "fps_unlocker"
    dxvk = "dxvk"


@dataclass
class WineprefixConfigurationModel:
    id: str
    priority: int
    name_on_disk: str
    display_name: str
    wine_home: str
    dll_overrides: str
    prime_offload_sink: int = -1
    use_mesa_gl_override: bool = False
    enable_winedebug: bool = False
    winedebug_string: str = ""
    roblox_renderer: str = RobloxRenderer.Undetermined.value
    env: Dict[str, str] = field(default_factory=dict)
    hints: List[str] = field(default_factory=list)
    fast_flags: Dict[str, Dict[str, any]] = field(default_factory=dict)
    third_party: Dict[str, bool] = field(default_factory=dict)

    @property
    def hints_as_enum(self) -> List[WineprefixHint]:
        return list(map(WineprefixHint, self.hints))

    @property
    def base_directory(self) -> Path:
        from grapejuice_common import paths

        return paths.wineprefixes_directory() / self.name_on_disk

    @property
    def exists_on_disk(self):
        return self.base_directory.exists()

    def create_name_on_disk_from_display_name(self):
        from unidecode import unidecode

        s = unidecode(self.display_name)  # Remove wacky non-ascii characters
        s = s.strip()  # Remove surrounding whitespace
        s = re.sub(r"\s+/\s+", "_", s)  # Replace slashes surrounded by whitespace by a single underscore
        s = re.sub(r"[/ \W]+", "_", s)
        s = s.lower()

        self.name_on_disk = s

    def copy(self):
        data = deepcopy(asdict(self))
        return WineprefixConfigurationModel(**data)

    def apply_dict(self, d: Dict[str, any]):
        for k, v in d.items():
            setattr(self, k, v)

    @classmethod
    def from_dict(cls, data: Dict[str, any]):
        return cls(**data)
