import json
import logging
import os
import shutil
import time
from pathlib import Path
from typing import Generator, List, Iterable

from grapejuice_common import paths, variables
from grapejuice_common.errors import RobloxExecutableNotFound
from grapejuice_common.models.wineprefix_configuration_model import WineprefixConfigurationModel, ThirdPartyKeys
from grapejuice_common.roblox_product import RobloxProduct
from grapejuice_common.roblox_renderer import RobloxRenderer
from grapejuice_common.util import download_file
from grapejuice_common.wine.registry_file import RegistryFile
from grapejuice_common.wine.wineprefix_core_control import WineprefixCoreControl, ProcessWrapper
from grapejuice_common.wine.wineprefix_paths import WineprefixPaths

LOG = logging.getLogger(__name__)

ROBLOX_DOWNLOAD_URL = "https://www.roblox.com/download/client"


def _app_settings_path(executable_path: Path) -> Path:
    client_app_settings = executable_path.parent / "ClientSettings" / "ClientAppSettings.json"

    return client_app_settings


class WineprefixRoblox:
    _prefix_paths: WineprefixPaths
    _core_control: WineprefixCoreControl
    _configuration: WineprefixConfigurationModel

    def __init__(
        self,
        prefix_paths: WineprefixPaths,
        core_control: WineprefixCoreControl,
        configuration: WineprefixConfigurationModel
    ):
        self._prefix_paths = prefix_paths
        self._core_control = core_control
        self._configuration = configuration

    def download_installer(self):
        path = self._prefix_paths.installer_download_location

        if path.exists():
            LOG.debug(f"Removing old installer at {path}")
            os.remove(path)

        download_file(ROBLOX_DOWNLOAD_URL, path)

        return path

    def install_roblox(self, post_install_function: callable = None):
        self._core_control.create_prefix()

        self._core_control.run_exe(
            self.download_installer(),
            post_run_function=post_install_function
        )

    def is_logged_into_studio(self) -> bool:
        with RegistryFile(self._prefix_paths.user_reg) as registry_file:
            registry_file.load()

            roblox_com = registry_file.find_key(r"Software\\Roblox\\RobloxStudioBrowser\\roblox.com")
            return (roblox_com is not None) and (roblox_com.get_attribute(".ROBLOSECURITY") is not None)

    def locate_all_roblox_executables_in_versions(self, executable_name: str) -> Generator[Path, None, None]:
        search_locations = [
            self._prefix_paths.roblox_appdata,
            self._prefix_paths.roblox_program_files
        ]

        for location in search_locations:
            versions_directory = location / "Versions"

            if location.exists() and versions_directory.exists() and versions_directory.is_dir():
                executable_path = versions_directory / executable_name

                if executable_path.exists() and executable_path.is_file():
                    yield executable_path

                for version in filter(Path.is_dir, versions_directory.glob("*")):
                    executable_path = version / executable_name

                    if executable_path.exists() and executable_path.is_file():
                        yield executable_path

    def locate_all_roblox_executables(self, executable_name: str) -> Generator[Path, None, None]:
        for executable in self.locate_all_roblox_executables_in_versions(executable_name):
            yield executable

        executable_path = self._prefix_paths.roblox_program_files / "Versions" / executable_name
        if executable_path.exists():
            yield executable_path

    def locate_roblox_executable(self, executable_name: str) -> Path:
        executable = next(self.locate_all_roblox_executables(executable_name), None)

        if executable is None:
            LOG.warning(f"Failed to locate Roblox executable: {executable_name}")
            raise RobloxExecutableNotFound(executable_name)

        return executable

    @property
    def roblox_studio_launcher_path(self) -> Path:
        return self.locate_roblox_executable("RobloxStudioLauncherBeta.exe")

    @property
    def roblox_studio_executable_path(self) -> Path:
        return self.locate_roblox_executable("RobloxStudioBeta.exe")

    @property
    def roblox_player_launcher_path(self) -> Path:
        return self.locate_roblox_executable("RobloxPlayerLauncher.exe")

    @property
    def fast_flag_dump_path(self) -> Path:
        def append_app_settings(p):
            return p / "ClientSettings" / "StudioAppSettings.json"

        possible_locations = list(map(append_app_settings, self._prefix_paths.possible_roblox_appdata))

        for location in possible_locations:
            if location.exists():
                return location

        return possible_locations[0]

    @property
    def roblox_studio_app_settings_path(self) -> Path:
        return _app_settings_path(self.roblox_studio_executable_path)

    @property
    def roblox_player_app_settings_path(self) -> Path:
        return _app_settings_path(self.roblox_player_launcher_path)

    @property
    def all_studio_app_settings_paths(self) -> List[Path]:
        return list(map(_app_settings_path, self.locate_all_roblox_executables("RobloxStudioBeta.exe")))

    @property
    def all_player_app_settings_paths(self) -> List[Path]:
        return list(map(_app_settings_path, self.locate_all_roblox_executables("RobloxPlayerLauncher.exe")))

    @property
    def is_installed(self) -> bool:
        try:
            self.locate_roblox_executable("RobloxPlayerLauncher.exe")
            return True

        except RobloxExecutableNotFound:
            return False

    @property
    def fps_unlocker_is_running(self) -> bool:
        executable_path = self._prefix_paths.fps_unlocker_executable_path

        for proc in self._core_control.process_list:
            if proc.image == executable_path.name:
                return True

        return False

    def _write_flags(self, product: RobloxProduct, settings_paths: Iterable[Path]):
        flags = self._configuration.fast_flags.get(product.value, None) or dict()

        # Apply rendering flag
        renderer = RobloxRenderer(self._configuration.roblox_renderer)
        if renderer is not RobloxRenderer.Undetermined:
            flags[renderer.prefer_flag] = True

        # Don't do anything when we don't have any flags
        if len(flags) <= 0:
            return

        json_dump = json.dumps(flags, indent=2)

        for p in settings_paths:
            LOG.info(f"Writing flags for {product} to: {p}")
            p.parent.mkdir(parents=True, exist_ok=True)

            with p.open("w+", encoding=variables.text_encoding()) as fp:
                fp.write(json_dump)

    def run_roblox_studio(self, uri: str = None, ide: bool = False):
        launcher_path = self.roblox_studio_launcher_path

        self._write_flags(RobloxProduct.studio, self.all_studio_app_settings_paths)

        run_args = [launcher_path]
        run_args.extend(list(
            filter(
                None,
                [
                    "-ide" if ide else None,
                    uri
                ]
            )
        ))

        self._core_control.run_exe(*run_args, accelerate_graphics=True)

    def _run_fps_unlocker(self):
        if self._configuration.third_party.get(ThirdPartyKeys.fps_unlocker, False):
            if not self.fps_unlocker_is_running:
                LOG.info("FPS unlocker is enabled, starting...")
                self._core_control.run_exe(
                    self._prefix_paths.fps_unlocker_executable_path,
                    run_async=True,
                    working_directory=self._prefix_paths.fps_unlocker_directory
                )

    def run_roblox_player(self, uri):
        player_launcher_path = self.roblox_player_launcher_path

        product = RobloxProduct.app if uri == variables.roblox_app_experience_url() else RobloxProduct.player
        self._write_flags(product, self.all_player_app_settings_paths)

        self._run_fps_unlocker()
        self._core_control.run_exe(player_launcher_path, uri, accelerate_graphics=True)

    def launch_app(self):
        player_executable_path = self.locate_roblox_executable("RobloxPlayerBeta.exe")

        product = RobloxProduct.app
        self._write_flags(product, self.all_player_app_settings_paths)

        self._run_fps_unlocker()
        self._core_control.run_exe(player_executable_path, "--app", accelerate_graphics=True)

    def run_roblox_studio_with_events(self, run_async: bool = True, **events) -> ProcessWrapper:
        roblox_studio_path = self.roblox_studio_executable_path

        run_args = [roblox_studio_path]

        for k, v in events.items():
            run_args.append("-" + k)
            run_args.append(v)

        return self._core_control.run_exe(*run_args, run_async=run_async)

    def extract_fast_flags(self):
        fast_flag_path = self.fast_flag_dump_path

        if fast_flag_path.exists():
            os.remove(fast_flag_path)

        studio_process = self.run_roblox_studio_with_events(startEvent="FFlagExtract", showEvent="NoSplashScreen")

        def fast_flags_present():
            if fast_flag_path.exists():
                stat = os.stat(fast_flag_path)

                if stat.st_size > 0:
                    return True

            return False

        while not fast_flags_present():
            time.sleep(0.1)

        shutil.copy(fast_flag_path, paths.fast_flag_cache_location())

        if studio_process:
            studio_process.kill()
            time.sleep(1)  # Give Roblox a chance
            self._core_control.kill_wine_server()
