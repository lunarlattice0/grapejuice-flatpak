import json
import logging
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Optional, Dict

from grapejuice_common import paths
from grapejuice_common.hardware_info.lspci import LSPciEntry

log = logging.getLogger(__name__)


# nVidia Vulkan reference: https://developer.nvidia.com/vulkan-driver
# AMD Vulkan reference: https://www.amd.com/en/technologies/vulkan


class GPUVendor(Enum):
    INTEL = 0
    AMD = 1
    NVIDIA = 2
    UNKNOWN = 999


GPU_VENDOR_PRIORITY = {
    GPUVendor.NVIDIA: 0,
    GPUVendor.AMD: 1,
    GPUVendor.INTEL: 2,

    GPUVendor.UNKNOWN: 999
}

DRIVER_TO_VENDOR_MAPPING = {
    "i915": GPUVendor.INTEL,
    "amdgpu": GPUVendor.AMD,
    "r600": GPUVendor.AMD,
    "radeon": GPUVendor.AMD,
    "nvidia": GPUVendor.NVIDIA,
    "nouveau": GPUVendor.NVIDIA
}


def _can_use_icd(icd_name):
    search_paths = [
        Path("/usr/share/vulkan/icd.d"),
        paths.local_share() / "vulkan" / "icd.d"
    ]

    for search_path in search_paths:
        icd_path = search_path / icd_name

        if icd_path.exists():
            log.info(f"Found ICD at '{str(icd_path)}'")
            return True

        else:
            log.info(f"Could not find ICD at '{str(icd_path)}'")

    return False


@dataclass()
class GraphicsCard:
    lspci_entry: LSPciEntry
    _can_do_vulkan_value: Optional[bool] = None

    @property
    def vendor(self) -> GPUVendor:
        driver = self.lspci_entry.kernel_driver
        if driver in DRIVER_TO_VENDOR_MAPPING:
            return DRIVER_TO_VENDOR_MAPPING[driver]

        return GPUVendor.UNKNOWN

    @property
    def pci_id(self) -> str:
        return self.lspci_entry.pci_id

    @property
    def can_do_vulkan(self):
        if self._can_do_vulkan_value is not None:
            return self._can_do_vulkan_value

        def resolve(x):
            # Return with side effects
            self._can_do_vulkan_value = x
            return x

        if self.vendor is GPUVendor.NVIDIA:
            return resolve(_can_use_icd("nvidia_icd.json"))

        elif self.vendor is GPUVendor.AMD:
            return resolve(
                (_can_use_icd("radeon_icd.x86_64.json") and _can_use_icd("radeon_icd.i686.json")) or
                (_can_use_icd("amd_icd64.json") and _can_use_icd("amd_icd32.json"))
            )

        elif self.vendor is GPUVendor.INTEL:
            return resolve(_can_use_icd("intel_icd.x86_64.json") and _can_use_icd("intel_icd.i686.json"))

        return resolve(False)

    def as_serializable_dict(self) -> Dict[str, any]:
        return {
            "pci_id": self.pci_id,
            "vendor": self.vendor.value,
            "can_do_vulkan": self.can_do_vulkan,
            **self.lspci_entry.attributes
        }

    def __str__(self):
        return f"<{type(self).__name__}> " + json.dumps(self.as_serializable_dict(), indent=2)

    def __hash__(self):
        return hash(self.lspci_entry)
