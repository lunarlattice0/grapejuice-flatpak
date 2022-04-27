import json
import logging
import os
import shutil
import subprocess
import sys
import tarfile
from io import BytesIO
from pathlib import Path
from string import Template

import grapejuice.__about__ as about
import grapejuice_packaging.packaging_resources as res
from grapejuice_common import paths
from grapejuice_common.util import mo_util
from grapejuice_packaging.builders.package_builder import PackageBuilder
from grapejuice_packaging.util.task_sequence import TaskSequence

LOG = logging.getLogger(__name__)


class LinuxPackageConfiguration:
    root: str = None
    level_1_directory: str = "usr"
    copy_packages: bool = True
    python_site_type: str = "dist-packages"
    python_site_version: str = "python3"
    package_name: str = f"{about.package_name}-{about.package_version}.tar.gz"
    target_system_root: str = os.path.sep

    def __init__(self, root: str):
        self.root = root


def _build_package(configuration: LinuxPackageConfiguration):
    root = configuration.root
    build = TaskSequence("Build Linux Package")

    bin_path_components = [configuration.level_1_directory, "bin"]
    grapejuice_exec_name = "grapejuice"
    grapejuice_gui_exec_name = "grapejuice-gui"

    if configuration.copy_packages:
        python_site = Path(
            root,
            configuration.level_1_directory,
            "lib",
            configuration.python_site_version,
            configuration.python_site_type
        )

        @build.task("Copy packages to site")
        def copy_packages(log):
            log.info(f"Using site directory: {python_site}")
            os.makedirs(python_site, exist_ok=True)

            subprocess.check_call([
                sys.executable, "-m", "pip",
                "install", ".",
                "--no-dependencies",
                "--target", str(python_site)
            ])

    @build.task("Compile mo files")
    def compile_mo_files(log):
        locale_directory = Path(root, configuration.level_1_directory, "share", "locale")
        log.info(f"Using locale directory: {locale_directory}")

        mo_util.compile_mo_files(locale_directory)

    @build.task("Copy MIME files")
    def mime_files(log):
        mime_packages = Path(root, configuration.level_1_directory, "share", "mime", "packages")
        log.info(f"Using mime packages directory: {mime_packages}")
        os.makedirs(mime_packages, exist_ok=True)

        for file in paths.mime_xml_assets_directory().glob("*.xml"):
            shutil.copyfile(str(file.absolute()), mime_packages.joinpath(file.name))

    @build.task("Copy icons")
    def copy_icons(log):
        icons = Path(root, configuration.level_1_directory, "share", "icons")
        log.info(f"Using icons directory: {icons}")

        shutil.copytree(paths.icons_assets_directory(), icons)

    @build.task("Copy desktop entries")
    def copy_desktop_files(log):
        xdg_applications = Path(root, configuration.level_1_directory, "share", "applications")
        log.info(f"Using XDG applications directory: {xdg_applications}")
        os.makedirs(xdg_applications, exist_ok=True)

        desktop_variables = {
            "GRAPEJUICE_ICON": "grapejuice",
            "GRAPEJUICE_EXECUTABLE": os.path.join(
                configuration.target_system_root,
                *bin_path_components,
                grapejuice_exec_name
            ),
            "GRAPEJUICE_GUI_EXECUTABLE": os.path.join(
                configuration.target_system_root,
                *bin_path_components,
                grapejuice_gui_exec_name
            ),
            "PLAYER_ICON": "grapejuice-roblox-player",
            "STUDIO_ICON": "grapejuice-roblox-studio"
        }

        for file in paths.desktop_assets_directory().glob("*.desktop"):
            with file.open("r") as fp:
                template = Template(fp.read())
                finished_desktop_entry = template.substitute(desktop_variables)

            target_path = xdg_applications.joinpath(file.name)
            with target_path.open("w+") as fp:
                fp.write(finished_desktop_entry)

            target_path.chmod(0o755)

    @build.task("Copy binary entries")
    def copy_bin_scripts(log):
        usr_bin = Path(root, *bin_path_components)
        log.info(f"Using bin directory: {usr_bin}")
        os.makedirs(usr_bin, exist_ok=True)

        shutil.copyfile(res.bin_grapejuice_path(), usr_bin.joinpath(grapejuice_exec_name))
        shutil.copyfile(res.bin_grapejuiced_path(), usr_bin.joinpath("grapejuiced"))
        shutil.copyfile(res.bin_grapejuice_gui_path(), usr_bin.joinpath("grapejuice-gui"))

        for file in usr_bin.glob("*"):
            file.chmod(0o755)

    build.run()


class LinuxPackageBuilder(PackageBuilder):
    def __init__(self, build_dir, dist_dir, configuration: LinuxPackageConfiguration = None):

        super().__init__(build_dir, dist_dir)

        self._configuration: LinuxPackageConfiguration = \
            configuration or LinuxPackageConfiguration(self._build_dir)

    def build(self):
        self.clean_build()
        self._prepare_build()

        _build_package(self._configuration)

    def dist(self):
        self.clean_dist()
        self._prepare_dist()
        path = Path(self._dist_dir, self._configuration.package_name)

        manifest = {
            "package": about.package_name,
            "package_version": about.package_version,
            "author": f"{about.author_name} <{about.author_email}>",
            "files": []
        }

        with tarfile.open(path, "w:gz") as tar:
            for file in Path(self._build_dir).rglob("*"):
                if file.is_dir():
                    continue

                file_path = str(file.absolute())
                if "__pycache__" in file_path:
                    continue

                arc_name = str(file.relative_to(self._build_dir))
                manifest["files"].append(arc_name)

                LOG.info(f"Adding to tar.gz: {file_path} -> {arc_name}")

                tar.add(
                    file_path,
                    arcname=arc_name
                )

            manifest_string = json.dumps(manifest).encode("UTF-8")
            manifest_info = tarfile.TarInfo(name="/".join([
                self._configuration.level_1_directory,
                "share",
                "grapejuice",
                "package_manifest.json"
            ]))
            manifest_info.size = len(manifest_string)

            buf = BytesIO()
            buf.write(manifest_string)
            buf.seek(0)

            tar.addfile(tarinfo=manifest_info, fileobj=buf)
