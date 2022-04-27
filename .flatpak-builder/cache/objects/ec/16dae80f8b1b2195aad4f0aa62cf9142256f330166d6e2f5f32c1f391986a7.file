import json
import os
import re
import subprocess
from abc import ABC
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict

# pylint: disable=C0301
XRANDR_LINE_PTN = re.compile(
    r"Provider\s+(\d+):\s+id:\s+([a-f\dx]+)\s+cap:\s+(.+)\s+crtcs:\s+(\d+)\s+outputs:\s+(\d+)\s+associated providers:\s+(\d+)\s+name:(.+)"
)


@dataclass(frozen=True)
class XRandRProvider:
    index: int
    id: int
    cap: List[str]
    crtcs: int
    outputs: int
    associated_providers: int
    name: str

    @property
    def source_output(self) -> bool:
        return "Source Output" in self.cap

    @property
    def sink_output(self) -> bool:
        return "Sink Output" in self.cap

    @property
    def source_offload(self) -> bool:
        return "Source Offload" in self.cap

    @property
    def sink_offload(self) -> bool:
        return "Sink Offload" in self.cap

    @property
    def pci_id(self) -> Optional[str]:
        match = re.search(r"@\s+(pci:.+)$", self.name)
        if match:
            return match.group(1).strip()

        return None

    @property
    def pci_device_id(self) -> Optional[str]:
        pci_id = self.pci_id
        if pci_id:
            return ":".join(pci_id.split(":")[-2:])

        return None

    def __hash__(self):
        return hash(json.dumps(asdict(self)))

    @classmethod
    def from_line(cls, line: str):
        line = line.strip()
        match = XRANDR_LINE_PTN.search(line)

        if match is None:
            raise ValueError("Could not parse this XRandR line")

        return cls(
            index=int(match.group(1)),
            id=int(match.group(2), 0),
            cap=list(filter(None, map(str.strip, match.group(3).split(",")))),
            crtcs=int(match.group(4)),
            outputs=int(match.group(5)),
            associated_providers=int(match.group(6)),
            name=match.group(7)
        )

    def as_serializable_dict(self) -> Dict[str, any]:
        return {
            "pci_id": self.pci_id or "",
            "pci_device_id": self.pci_device_id or "",
            "source_output": self.source_output,
            "sink_output": self.sink_output,
            "source_offload": self.source_offload,
            "sink_offload": self.sink_offload,
            **asdict(self)
        }

    def __str__(self):
        return f"<{type(self).__name__}> " + json.dumps(self.as_serializable_dict(), indent=2)


class IXRandR(ABC):
    @property
    def providers(self) -> List[XRandRProvider]:
        return []


class XRandR:
    _providers: List[XRandRProvider]

    def __init__(self):
        if os.environ.get("NO_XRANDR", "0") == "1":
            self._providers = []

        else:
            output = subprocess.check_output(["xrandr", "--listproviders"]).decode("UTF-8")
            lines = list(filter(None, map(str.strip, output.split("\n"))))

            self._providers = list(map(XRandRProvider.from_line, lines[1:]))

    @property
    def providers(self) -> List[XRandRProvider]:
        return self._providers
