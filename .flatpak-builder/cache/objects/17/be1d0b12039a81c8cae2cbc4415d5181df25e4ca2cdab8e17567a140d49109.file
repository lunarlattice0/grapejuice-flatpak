import json
import logging
from copy import deepcopy
from dataclasses import asdict
from pathlib import Path
from typing import Dict, List, Optional

from grapejuice_common import paths
from grapejuice_common.errors import HardwareProfilingError, NoHardwareProfile, PresentableError
from grapejuice_common.hardware_info.hardware_profile import HardwareProfile, profile_hardware
from grapejuice_common.models.wineprefix_configuration_model import WineprefixConfigurationModel

LOG = logging.getLogger(__name__)

CURRENT_SETTINGS_VERSION = 2

k_version = "__version__"  # Magic variable gets underscores
k_hardware_profile = "__hardware_profile__"

k_show_fast_flag_warning = "show_fast_flag_warning"
k_wine_binary = "wine_binary"
k_dll_overrides = "dll_overrides"
k_no_daemon_mode = "no_daemon_mode"
k_release_channel = "release_channel"
k_environment_variables = "env"
k_disable_updates = "disable_updates"
k_wineprefixes = "wineprefixes"
k_enabled_tweaks = "enabled_tweaks"
k_ignore_wine_version = "ignore_wine_version"
k_unsupported_settings = "unsupported_settings"
k_try_profiling_hardware = "try_profiling_hardware"


def default_settings() -> Dict[str, any]:
    return {
        k_version: 0,
        k_hardware_profile: None,
        k_show_fast_flag_warning: True,
        k_no_daemon_mode: True,
        k_release_channel: "master",
        k_disable_updates: False,
        k_ignore_wine_version: False,
        k_try_profiling_hardware: True,
        k_wineprefixes: [],
        k_unsupported_settings: dict()
    }


def _text_encoding():
    from grapejuice_common.variables import text_encoding
    return text_encoding()


class UserSettings:
    _settings_object: Dict[str, any] = None
    _location: Path = None

    def __init__(self, file_location=paths.grapejuice_user_settings()):
        self._location = file_location
        self.load()

    def perform_migrations(self, desired_migration_version: int = CURRENT_SETTINGS_VERSION):
        if self.version == desired_migration_version:
            LOG.debug(f"Settings file is up to date at version {self.version}")
            return

        a = self.version
        LOG.info(f"Performing migration from {a} to{CURRENT_SETTINGS_VERSION}")

        direction = 1 if desired_migration_version > a else -1

        for x in range(a + direction, desired_migration_version + direction, direction):
            index = (a, x)
            LOG.info(f"Migration index {index}")
            from grapejuice_common.features.settings_migration import migration_index

            migration_function = migration_index.get(index, None)

            if callable(migration_function):
                LOG.info(f"Applying migration {index}: {migration_function}")
                migration_function(self._settings_object)

                LOG.info(f"Applying and saving new settings version {x}")
                self.set(k_version, x, save=True)

            else:
                LOG.warning(f"Migration {index} is invalid")

            a = x

    @property
    def version(self) -> int:
        return self.get(k_version, 0)

    @property
    def hardware_profile(self) -> HardwareProfile:
        if self._profile_hardware():
            self.save()

        if self._settings_object.get(k_hardware_profile, None) is None:
            raise NoHardwareProfile()

        return HardwareProfile.from_dict(self._settings_object[k_hardware_profile])

    @property
    def raw_wineprefixes_sorted(self) -> List[Dict]:
        return list(sorted(
            self._settings_object.get(k_wineprefixes),
            key=lambda wp: wp.get("priority", 999)
        ))

    @property
    def parsed_wineprefixes_sorted(self) -> List[WineprefixConfigurationModel]:
        return list(map(WineprefixConfigurationModel.from_dict, self.raw_wineprefixes_sorted))

    def find_wineprefix(self, search_id: str) -> Optional[WineprefixConfigurationModel]:
        for prefix_configuration in self._settings_object.get(k_wineprefixes, []):
            if prefix_configuration["id"] == search_id:
                return WineprefixConfigurationModel.from_dict(prefix_configuration)

        return None

    def get(self, key: str, default_value: any = None):
        if self._settings_object:
            return self._settings_object.get(key, default_value)

        return default_value

    def set(self, key: str, value: any, save: bool = False) -> any:
        self._settings_object[key] = value

        if save:
            self.save()

        return value

    def _profile_hardware(self, always_profile: Optional[bool] = False) -> bool:
        """
        Profile the hardware of the machine Grapejuice is running on. This method may silently
        fail as profiling hardware is quite a complex task. Due to this, the return value
        of this method is a boolean indicating if the caller should save the Grapejuice settings.
        :param always_profile: Override any logic in the method, and just go ahead with the profiling
        :return: Boolean indicating whether settings should be saved or not.
        """
        saved_profile = None if always_profile else self._settings_object.get(k_hardware_profile, None)

        should_try = self._settings_object.get(k_try_profiling_hardware, True)
        if not should_try:
            return False

        if saved_profile:
            from grapejuice_common.hardware_info.lspci import LSPci

            try:
                hardware_list = LSPci()

            except Exception as e:
                LOG.info("Failed to get LSPci info: " + str(e))

                return False

            should_profile_hardware = (hardware_list.graphics_id != saved_profile["graphics_id"]) or \
                                      (saved_profile.get("version", -1) != HardwareProfile.version)

        else:
            should_profile_hardware = True

        if should_profile_hardware:
            LOG.info("Going to profile hardware")

            try:
                profile = profile_hardware()
                self._settings_object[k_hardware_profile] = profile.as_dict

            except HardwareProfilingError as e:
                LOG.error("Failed to profile hardware: " + str(e))
                LOG.info("No longer try to profile hardware due to errors")

                self.set(k_try_profiling_hardware, False, save=False)

            return True

        return False

    def load(self):
        save_settings = False

        if self._location.exists():
            LOG.debug(f"Loading settings from '{self._location}'")

            try:
                with self._location.open("r") as fp:
                    self._settings_object = json.load(fp)

                    # Make sure all the default settings are present
                    # Using a for loop because magic settings shouldn't be touched
                    for k, v in default_settings().items():
                        # Do not touch magic variables here
                        if k.startswith("__") and k.endswith("__"):
                            continue

                        if k not in self._settings_object:
                            self._settings_object[k] = v
                            save_settings = True

            except json.JSONDecodeError as e:
                raise PresentableError(
                    title="Invalid settings file",
                    description="Grapejuice could not properly decode the information in the user settings file. This "
                                "is most likely due to a formatting error in the actual settings file. Did you make a "
                                "mistake while manually editing the file?",
                    cause=e
                )

        else:
            LOG.info("There is no settings file present, going to save one")
            self._settings_object = default_settings()
            save_settings = True

        save_settings = self._profile_hardware() or save_settings

        if save_settings:
            LOG.info("Saving settings after load, because something was wrong.")
            self.save()

    def save(self):
        LOG.debug(f"Saving settings file to '{self._location}'")

        # Sort wineprefixes before saving so the file order matches the UI
        self._settings_object[k_wineprefixes] = self.raw_wineprefixes_sorted

        # Store in value so its not called twice
        defaults = default_settings()

        # Preserve unsupported settings
        unsupported_setting_keys = set()

        for k, _ in self._settings_object.items():
            if k not in defaults:
                unsupported_setting_keys.add(k)

        for k in unsupported_setting_keys:
            self._settings_object[k_unsupported_settings][k] = self._settings_object.pop(k)

        # Perform actual save
        self._location.parent.mkdir(parents=True, exist_ok=True)
        with self._location.open("w+", encoding=_text_encoding()) as fp:
            self._settings_object = {
                **defaults,
                **(self._settings_object or {})
            }

            # Dump the string, `json.dump` destroys the file when something goes wrong
            json_string = json.dumps(self._settings_object, indent=2)

            fp.write(json_string)

    def save_prefix_model(self, model: WineprefixConfigurationModel):
        did_update = False
        model_as_dict = asdict(model)

        # Extract and re-insert wineprefixes list in case it doesn't exist
        prefixes = self._settings_object.get(k_wineprefixes, [])

        if self.find_wineprefix(model.id) is None:
            prefixes.append(model_as_dict)
            did_update = True

        else:
            for prefix_configuration in prefixes:
                if prefix_configuration["id"] == model.id:
                    for k, v in model_as_dict.items():
                        prefix_configuration[k] = v

                    did_update = True

        self._settings_object[k_wineprefixes] = prefixes

        if did_update:
            self.save()

    def remove_prefix_model(self, model: WineprefixConfigurationModel):
        def keep_model(m: Dict):
            return m["id"] != model.id

        self._settings_object[k_wineprefixes] = list(
            filter(
                keep_model,
                self._settings_object.get(k_wineprefixes, [])
            )
        )

        self.save()

    def as_dict(self) -> Dict:
        return deepcopy(self._settings_object)


current_settings = UserSettings()
