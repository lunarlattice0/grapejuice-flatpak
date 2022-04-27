import os
import shutil
from abc import ABC, abstractmethod


class PackageBuilder(ABC):
    def __init__(self, build_dir, dist_dir):
        self._build_dir = os.path.abspath(build_dir)
        self._dist_dir = os.path.abspath(dist_dir)

    def _prepare_build(self):
        os.makedirs(self._build_dir, exist_ok=True)

    def _prepare_dist(self):
        os.makedirs(self._dist_dir, exist_ok=True)

    def clean_build(self):
        shutil.rmtree(self._build_dir, ignore_errors=True)

    def clean_dist(self):
        shutil.rmtree(self._dist_dir, ignore_errors=True)

    @abstractmethod
    def build(self):
        pass

    @abstractmethod
    def dist(self):
        pass
