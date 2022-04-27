from enum import Enum


class RobloxRenderer(Enum):
    Vulkan = "Vulkan"
    OpenGL = "OpenGL"
    DX11 = "D3D11"
    Undetermined = "__undetermined__"

    @property
    def prefer_flag(self):
        return f"FFlagDebugGraphicsPrefer{self.value}"

    @property
    def disable_flag(self):
        return f"FFlagDebugGraphicsDisable{self.value}"
