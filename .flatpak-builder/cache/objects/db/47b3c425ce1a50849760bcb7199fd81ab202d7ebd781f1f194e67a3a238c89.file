import os
import subprocess
import sys
import tarfile
from pathlib import Path

from setuptools import Command

from grapejuice_common import paths
from grapejuice_packaging.util.task_sequence import TaskSequence

PYTHON_INTERPRETER = sys.executable

ROBLOX_STUDIO = "roblox-studio.desktop"
ROBLOX_PLAYER = "roblox-player.desktop"

MIME = {
    "x-scheme-handler/roblox-studio": ROBLOX_STUDIO,
    "x-scheme-handler/roblox-player": ROBLOX_PLAYER,
    "application/x-roblox-rbxl": ROBLOX_STUDIO,
    "application/x-roblox-rbxlx": ROBLOX_STUDIO
}


def _xdg_mime_default(desktop_entry: str, mime: str):
    subprocess.check_call(["xdg-mime", "default", desktop_entry, mime])


def _do_install(*_):
    assert os.path.exists("setup.py"), \
        "Project file not found, make sure you're in the Grapejuice root!"

    src_path = os.path.join(os.path.abspath(os.getcwd()), "src")
    if "PYTHONPATH" in os.environ:
        os.environ["PYTHONPATH"] = src_path + ":" + os.environ["PYTHONPATH"]

    else:
        os.environ["PYTHONPATH"] = src_path

    install = TaskSequence("Install Grapejuice locally")

    @install.task("Build package of supplemental files")
    def build_supplemental(_log):
        subprocess.check_call([
            PYTHON_INTERPRETER, "-m", "grapejuice_packaging",
            "supplemental_package"
        ])

    @install.task("Install supplemental packages")
    def install_supplemental_packages(log):
        for file in Path("dist", "supplemental_package").glob("*.tar.gz"):
            log.info(f"Installing supplemental package {file}")

            with tarfile.open(file) as tar:
                tar.extractall(paths.home())

    @install.task("Install Grapejuice package")
    def install_package(log):
        env_snapshot = None

        if "VIRTUAL_ENV" in os.environ:
            virtual_env = os.environ["VIRTUAL_ENV"]
            log.warning(f"Breaking out of virtualenv: {virtual_env}")
            env_snapshot = dict(os.environ)

            path = os.environ["PATH"].split(os.pathsep)
            path = list(filter(lambda s: not s.startswith(virtual_env), path))
            os.environ["PATH"] = os.pathsep.join(path)

            log.info("Set PATH to: " + os.environ["PATH"])
            os.environ.pop("VIRTUAL_ENV", None)

        subprocess.check_call([
            PYTHON_INTERPRETER, "-m", "pip",
            "install", ".",
            "--user",
            "--upgrade"
        ])

        if env_snapshot is not None:
            log.info("Restoring environment snapshot...")
            for env_key, env_value in env_snapshot.items():
                os.environ[env_key] = env_value

    @install.task("Updating GTK icon cache")
    def update_icon_cache(_log):
        subprocess.check_call(["gtk-update-icon-cache"])

    @install.task("Updating desktop database")
    def update_desktop_database(log):
        path = (paths.home() / ".local" / "share" / "applications").resolve()
        log.info(f"Updating desktop database: {path}")

        subprocess.check_call(["update-desktop-database", str(path)])

    @install.task("Updating MIME type associations")
    def update_mime_associations(log):
        for mime, desktop in MIME.items():
            log.info(f"Associating {mime} with {desktop}")
            _xdg_mime_default(desktop, mime)

    @install.task("Updating MIME database")
    def update_mime_database(log):
        path = (paths.home() / ".local" / "share" / "mime").resolve()
        log.info(f"Updating MIME database: {path}")

        subprocess.check_call(["update-mime-database", str(path)])

    install.run()


class InstallLocally(Command):
    description = "Install Grapejuice locally"
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        _do_install(self.user_options)
