import io
import json
import logging
import tarfile
from pathlib import Path

import requests

from grapejuice_common import variables
from grapejuice_common.recipes.recipe import Recipe
from grapejuice_common.wine.registry_file import RegistryFile
from grapejuice_common.wine.wineprefix import Wineprefix

DXVK_OVERRIDES = ('d3d10core', 'd3d11', 'd3d9')
DXVK_DLL = tuple(map(lambda s: s + ".dll", DXVK_OVERRIDES))
DXVK_OLD_DLL = tuple(map(lambda s: s + ".old", DXVK_DLL))

log = logging.getLogger(__name__)


def _dxvk_metadata_path(prefix: Wineprefix):
    return prefix.paths.dxvk_directory / "grapejuice_metadata.json"


def _dxvk_is_installed(prefix: Wineprefix) -> bool:
    metadata_exists = _dxvk_metadata_path(prefix).exists()

    if not prefix.paths.user_registry_hive.exists():
        return False

    hive = RegistryFile(prefix.paths.user_registry_hive)
    hive.load()

    dll_overrides_key = hive.find_key(r"Software\\Wine\\DllOverrides")
    if not dll_overrides_key:
        return False

    attributes = dll_overrides_key.attributes

    overrides_present = all(map(
        lambda override: override in attributes,
        DXVK_OVERRIDES
    ))

    old_files_present = all(map(
        lambda p: p.exists(),
        map(
            lambda n: prefix.paths.system32 / n,
            DXVK_OLD_DLL
        )
    ))

    log.info("DXVK status: " + json.dumps({
        "metadata_exists": metadata_exists,
        "overrides_present": overrides_present,
        "old_files_present": old_files_present
    }))

    return metadata_exists and overrides_present and old_files_present


def _dxvk_is_not_installed(prefix: Wineprefix):
    return not _dxvk_is_installed(prefix)


class UninstallDXVKRecipe(Recipe):
    def __init__(self):
        super().__init__(indicators=[_dxvk_is_not_installed])

    def _make_in(self, prefix: Wineprefix):
        md_path = _dxvk_metadata_path(prefix)

        if md_path.exists():
            with md_path.open("r", encoding=variables.text_encoding()) as fp:
                metadata = json.load(fp)

            setup_script = metadata.get("setup_script", None)
            if setup_script:
                prefix.core_control.run_linux_command(
                    setup_script,
                    arguments=["uninstall"],
                    working_directory=Path(setup_script).parent
                )


class InstallDXVKRecipe(Recipe):
    def __init__(self):
        super().__init__(indicators=[_dxvk_is_installed])

    def _make_in(self, prefix: Wineprefix):
        release = variables.current_dxvk_release()

        response = requests.get(release.download_url)
        response.raise_for_status()

        prefix.paths.dxvk_directory.mkdir(parents=True, exist_ok=True)

        with io.BytesIO(response.content) as fp:
            with tarfile.open(fileobj=fp, mode="r:gz") as tf:
                tf.extractall(prefix.paths.dxvk_directory)

        versioned_dxvk_directory = prefix.paths.dxvk_directory / f"dxvk-{release.version}"
        if not versioned_dxvk_directory.exists():
            raise FileNotFoundError(versioned_dxvk_directory)

        setup_script_candidates = list(filter(
            lambda p: p.name == "setup_dxvk.sh",
            versioned_dxvk_directory.glob("*.sh")
        ))

        if len(setup_script_candidates) <= 0:
            raise RuntimeError("DXVK setup_script.sh could not be found in the extracted tarball")

        setup_script = setup_script_candidates[0]

        prefix.core_control.run_linux_command(
            setup_script,
            arguments=["install"],
            working_directory=versioned_dxvk_directory
        )

        md_path = _dxvk_metadata_path(prefix)
        with md_path.open("w+", encoding=variables.text_encoding()) as fp:
            json.dump({"version": release.version, "setup_script": str(setup_script)}, fp)
