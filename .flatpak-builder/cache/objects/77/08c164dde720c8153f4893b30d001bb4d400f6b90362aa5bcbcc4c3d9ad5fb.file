import logging
import sys
from pathlib import Path

import click

from grapejuice_common.util import mo_util

logging.basicConfig(stream=sys.stdout, level=logging.INFO)


@click.group()
def cli():
    ...


@cli.command()
@click.argument("locale_directory", type=Path)
def compile_mo_files(locale_directory: Path):
    locale_directory = locale_directory.resolve()
    locale_directory.mkdir(parents=True, exist_ok=True)

    mo_util.compile_mo_files(locale_directory)


if __name__ == "__main__":
    cli()
