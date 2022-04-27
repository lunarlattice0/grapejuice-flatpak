import subprocess
import sys

from grapejuice_packaging.builders.package_builder import PackageBuilder


class PyPiPackageBuilder(PackageBuilder):
    def build(self):
        self.clean_build()

    def dist(self):
        self.clean_dist()
        subprocess.check_call([sys.executable, "setup.py", "sdist", "bdist_wheel"])
