import getpass
from pathlib import Path
from typing import List


class WineprefixPaths:
    _base_directory: Path

    def __init__(self, base_directory: Path):
        self._base_directory = base_directory

    @property
    def base_directory(self) -> Path:
        return self._base_directory

    @property
    def present_on_disk(self) -> bool:
        return self._base_directory.exists()

    @property
    def drive_c(self) -> Path:
        return self._base_directory / "drive_c"

    @property
    def user_reg(self) -> Path:
        return self._base_directory / "user.reg"

    @property
    def roblox_program_files(self) -> Path:
        return self.drive_c / "Program Files (x86)" / "Roblox"

    @property
    def local_appdata(self):
        return self.user_directory / "Local" / "AppData"

    @property
    def temp_directory(self):
        return self.drive_c / "windows" / "temp"

    @property
    def user_directory(self):
        return self.drive_c / "users" / getpass.getuser()

    @property
    def possible_roblox_appdata(self) -> List[Path]:
        return [
            self.user_directory / "AppData" / "Local" / "Roblox",
            self.user_directory / "Local Settings" / "Application Data" / "Roblox"
        ]

    @property
    def roblox_appdata(self):
        possible_locations = self.possible_roblox_appdata

        for location in possible_locations:
            if location.exists():
                return location

        return possible_locations[0]

    @property
    def installer_download_location(self):
        # Do not call it RobloxPlayerLauncherBeta because it will try to import itself
        return self.temp_directory / "Roblox_Installer.exe"

    @property
    def grapejuice_in_drive_c(self):
        return self.drive_c / "Grapejuice"

    @property
    def vendor_directory(self):
        return self.grapejuice_in_drive_c / "Vendor"

    @property
    def fps_unlocker_directory(self):
        return self.vendor_directory / "rbxfpsunlocker"

    @property
    def fps_unlocker_executable_path(self):
        return self.fps_unlocker_directory / "rbxfpsunlocker.exe"

    @property
    def system_registry_hive(self):
        return self._base_directory / "system.reg"

    @property
    def user_registry_hive(self):
        return self._base_directory / "user.reg"

    @property
    def dxvk_directory(self):
        return self.vendor_directory / "DXVK"

    @property
    def system32(self):
        return self.drive_c / "windows" / "system32"
