import os
import shutil
from pathlib import Path

from grapejuice_common import paths


def do_wineprefix_migration(legacy_wineprefix_path: Path, new_name_on_disk: str):
    new_prefix_path = paths.wineprefixes_directory() / new_name_on_disk

    # Try to not destroy any perfectly ok wineprefixes
    if (legacy_wineprefix_path.exists() and legacy_wineprefix_path.is_dir()) and not new_prefix_path.exists():
        new_prefix_path.parent.mkdir(parents=True, exist_ok=True)

        shutil.move(legacy_wineprefix_path, new_prefix_path)

        # Legacy tool compatability
        os.symlink(
            new_prefix_path,
            legacy_wineprefix_path
        )
