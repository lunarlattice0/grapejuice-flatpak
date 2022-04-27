import sys

from grapejuice_common import paths
from grapejuice_packaging.builders.linux_package_builder import LinuxPackageBuilder, LinuxPackageConfiguration


class LinuxSupplementalPackageBuilder(LinuxPackageBuilder):
    def __init__(self, build_dir, dist_dir, level_1_directory: str = ".local"):
        configuration = LinuxPackageConfiguration(build_dir)
        configuration.python_site_type = "site-packages"
        configuration.python_site_version = f"python{sys.version_info.major}.{sys.version_info.minor}"
        configuration.copy_packages = False
        configuration.level_1_directory = level_1_directory
        configuration.target_system_root = paths.home()

        super().__init__(build_dir, dist_dir, configuration)

    def dist(self):
        self.clean_dist()
        self._prepare_dist()

        super().dist()
