import logging
import subprocess
from pathlib import Path

from grapejuice_common import paths

log = logging.getLogger(__name__)


def compile_mo_files(locale_directory: Path):
    log.info(f"Compiling mo files into {locale_directory}")

    linguas_file = paths.po_directory() / "LINGUAS"
    log.info(f"Using LINGUAS {linguas_file}")

    with linguas_file.open("r") as fp:
        for language in fp:
            language = language.strip()
            po_file = paths.po_directory() / f"{language}.po"
            mo_file = locale_directory / language / "LC_MESSAGES" / "grapejuice.mo"
            mo_file.parent.mkdir(parents=True, exist_ok=True)

            subprocess.check_call(["msgfmt", str(po_file), "-o", str(mo_file)])
