import io
import json
import logging
import zipfile

import requests

from grapejuice_common.recipes.recipe import Recipe
from grapejuice_common.wine.wineprefix import Wineprefix

log = logging.getLogger(__name__)


def _fps_unlocker_metadata_path(prefix: Wineprefix):
    return prefix.paths.fps_unlocker_directory / "grapejuice_metadata.json"


def _is_present(prefix: Wineprefix) -> bool:
    return prefix.paths.fps_unlocker_executable_path.exists()


def _is_up_to_date(prefix: Wineprefix) -> bool:
    from grapejuice_common import variables

    try:
        release = variables.current_rbxfpsunlocker_release()
        if release.id >= 0 and release.did_get_from_github_releases:
            md_path = _fps_unlocker_metadata_path(prefix)

            with md_path.open("r", encoding=variables.text_encoding()) as fp:
                metadata = json.load(fp)
                return metadata.get("tag", "unknown_tag") == release.tag

    except Exception as e:
        log.error(str(e))

    # Assume it is not up-to-date
    return False


class FpsUnlockerRecipe(Recipe):
    def __init__(self):
        super().__init__(indicators=[_is_present, _is_up_to_date])

    def _make_in(self, prefix: Wineprefix):
        from grapejuice_common import variables

        release = variables.current_rbxfpsunlocker_release()

        package_path = prefix.paths.fps_unlocker_directory
        package_path.mkdir(parents=True, exist_ok=True)

        response = requests.get(release.download_url)
        response.raise_for_status()

        with io.BytesIO(response.content) as fp:
            with zipfile.ZipFile(fp) as zf:
                zf.extractall(package_path)

        md_path = _fps_unlocker_metadata_path(prefix)
        with md_path.open("w+", encoding=variables.text_encoding()) as fp:
            json.dump({"release_id": release.id, "tag": release.tag}, fp)
