import hashlib
import json
import re
import subprocess
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

from grapejuice_common.util import environment_as


def _stdout_encoding():
    return "UTF-8"


@dataclass
class LSPciEntry:
    pci_id: str
    attributes: Dict[str, str] = field(default_factory=dict)

    @property
    def gpu_id_attribute(self) -> Optional[Tuple[str, str]]:
        for k, v in self.attributes.items():
            if k == "vga compatible controller":
                return k, v

            elif ("3d" in k) or ("2d" in k):
                return k, v

        return None

    @property
    def is_graphics_card(self) -> bool:
        return self.gpu_id_attribute is not None

    @property
    def gpu_id_string(self) -> str:
        return self.gpu_id_attribute[1]

    @property
    def kernel_driver(self) -> Optional[str]:
        v = self.attributes.get("kernel driver in use", None)

        if v is not None:
            v = v.strip()

        return v

    @property
    def kernel_modules(self) -> List[str]:
        return list(
            filter(
                lambda s: not not s,
                map(
                    str.strip,
                    re.split(r"[,\s]+", self.attributes.get("kernel modules", ""))
                )
            )
        )

    def __hash__(self):
        return hash(json.dumps(self.attributes))


class LSPci:
    _entries: List[LSPciEntry]

    def __init__(self):
        self._entries = []

        with environment_as({"LC_ALL": "C", "LANG": None}):
            content = subprocess.check_output(["lspci", "-vvv"]).decode(_stdout_encoding())
            self._parse(content)

    def _parse(self, content: str):
        work: Optional[LSPciEntry] = None

        whitespace_ptn = re.compile(r"^\s+\w+")
        pci_id_ptn = re.compile(r"([a-fA-F\d:\.]+)\s+(.*)\s*")

        def explode_line(line_to_be_exploded: str):
            s = line_to_be_exploded.split(":")
            key = s[0]
            value = ":".join(s[1:])

            return key.strip().lower(), value.strip()

        for line in content.split("\n"):
            if not line.strip():
                if work is not None:
                    self._entries.append(work)

                work = None

                continue

            match = whitespace_ptn.search(line)
            starts_with_whitespace = match is not None

            if starts_with_whitespace:
                k, v = explode_line(line.strip())

            else:
                match = pci_id_ptn.search(line)
                assert match is not None, "Invalid line"

                work = LSPciEntry(match.group(1))

                k, v = explode_line(match.group(2))

            assert work is not None, "Invalid state"
            work.attributes[k] = v

        if work is not None:
            self._entries.append(work)

    @property
    def graphics_cards(self) -> List[LSPciEntry]:
        return list(filter(lambda x: x.is_graphics_card, self._entries))

    @property
    def graphics_id(self) -> str:
        h = hashlib.new("blake2s")
        h.update(json.dumps([card.gpu_id_string for card in self.graphics_cards]).encode(_stdout_encoding()))

        return h.hexdigest()
