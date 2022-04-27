import io
import logging
import os
import re
import shutil
import subprocess
import sys
import tarfile
from abc import ABC, abstractmethod
from pathlib import Path

import requests
from packaging import version

from grapejuice_common import variables, paths
from grapejuice_common.features import settings
from grapejuice_common.logs.log_util import log_function

LOG = logging.getLogger(__name__)

VERSION_PTN = re.compile(r"__version__\s*=\s*\"([\d\.]+)\".*")


class UpdateError(RuntimeError):
    pass


class UpdateInformationProvider(ABC):
    _cached_gitlab_version: version.Version = None

    @staticmethod
    def local_version() -> version.Version:
        from grapejuice.__about__ import gj_package_version
        return version.parse(gj_package_version)

    @staticmethod
    def gitlab_version(return_cached: bool = False) -> version.Version:
        if return_cached and UpdateInformationProvider._cached_gitlab_version is not None:
            return UpdateInformationProvider._cached_gitlab_version

        url = variables.git_grapejuice_init()
        response = requests.get(url)

        if response.status_code < 200 or response.status_code > 299:
            LOG.error(
                "Failed to get the version of grapejuice on GitLab. Returning version 0\n"
                f"URL: {url}\n"
                f"Response text: {response.text}\n"
            )

            return version.parse("0.0.0")

        for line in response.text.replace("\r", "").split("\n"):
            match = VERSION_PTN.match(line)
            if not match:
                continue

            ver = version.parse(match.group(1).strip())
            UpdateInformationProvider._cached_gitlab_version = ver

            return ver

        LOG.error("Could not match a Grapejuice version string in the remote repository")
        LOG.warning("Returning version 0.0.0")

        return version.parse("0.0.0")

    @staticmethod
    def can_update() -> bool:
        return False

    @abstractmethod
    def do_update(self) -> None:
        pass

    @abstractmethod
    def update_available(self) -> bool:
        pass

    @abstractmethod
    def local_is_newer(self) -> bool:
        pass

    @abstractmethod
    def target_version(self) -> version.Version:
        pass


class SourceUpdateInformationProvider(UpdateInformationProvider):
    def target_version(self) -> version.Version:
        return UpdateInformationProvider.gitlab_version(return_cached=True)

    def update_available(self) -> bool:
        return UpdateInformationProvider.gitlab_version() > UpdateInformationProvider.local_version()

    def local_is_newer(self) -> bool:
        return UpdateInformationProvider.local_version() > UpdateInformationProvider.gitlab_version(return_cached=True)

    @staticmethod
    def can_update() -> bool:
        from grapejuice_common.features.settings import current_settings

        return not current_settings.get(settings.k_disable_updates)

    def do_update(self):
        from grapejuice_common.features.settings import current_settings

        tmp_path = variables.temporary_directory()
        LOG.info(f"Temporary files path at: {tmp_path}")
        update_package_path = os.path.join(tmp_path, "update")

        response = requests.get(variables.git_source_tarball())
        if response.status_code < 200 or response.status_code > 299:
            raise UpdateError(f"Received HTTP error {response.status_code} from GitLab")

        if os.path.exists(update_package_path):
            LOG.warning(f"Removing existing update package: {update_package_path}")
            shutil.rmtree(update_package_path, ignore_errors=True)

        else:
            LOG.debug(f"Creating update package directory: {update_package_path}")
            os.makedirs(update_package_path)

        fp = io.BytesIO(response.content)
        with tarfile.open(fileobj=fp) as tar:
            tar.extractall(update_package_path)

        cwd = os.getcwd()

        release_channel = current_settings.get(settings.k_release_channel)
        os.chdir(os.path.join(update_package_path, f"grapejuice-{release_channel}"))

        LOG.debug("Installing update")
        subprocess.check_call([sys.executable, "./install.py"])
        os.chdir(cwd)

        fp.close()
        del fp
        del response

        shutil.rmtree(tmp_path)


class NonUpgradablePackageInformationProvider(UpdateInformationProvider):
    def target_version(self) -> version.Version:
        return self.gitlab_version()

    def update_available(self) -> bool:
        return self.gitlab_version() > self.local_version()

    def local_is_newer(self) -> bool:
        return self.local_version() > self.gitlab_version()

    @staticmethod
    def can_update() -> bool:
        return False

    def do_update(self) -> None:
        raise UpdateError("Grapejuice cannot upgrade a system package")


class SystemUpdateInformationProvider(NonUpgradablePackageInformationProvider):
    pass


@log_function
def guess_relevant_provider() -> UpdateInformationProvider:
    this_file = Path(__file__).resolve()
    stat = this_file.stat()

    if stat.st_uid == 0 and stat.st_gid == 0:
        return SystemUpdateInformationProvider()

    elif str(this_file).startswith(str(paths.home())):
        return SourceUpdateInformationProvider()

    else:
        return NonUpgradablePackageInformationProvider()
