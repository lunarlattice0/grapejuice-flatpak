import atexit
import json
import logging
import os
import re
import shutil
import uuid
from dataclasses import dataclass
from pathlib import Path

from grapejuice_common.errors import CouldNotFindSystemWineHome

HERE = Path(__file__).resolve().parent
INSTANCE_ID = str(uuid.uuid4())

LOG = logging.getLogger(__name__)


def ensure_dir(p):
    if not os.path.exists(p):
        os.makedirs(p)

    return p


def roblox_app_experience_url():
    return "roblox-player:+launchmode:app+robloxLocale:en_us+gameLocale:en_us+LaunchExp:InApp"


def roblox_return_to_studio():
    return "https://www.roblox.com/login/return-to-studio"


def git_repository():
    return "https://gitlab.com/brinkervii/grapejuice"


def documentation_link():
    return "https://brinkervii.gitlab.io/grapejuice/docs/"


def git_grapejuice_init():
    from grapejuice_common.features.settings import current_settings
    from grapejuice_common.features import settings

    release_channel = current_settings.get(settings.k_release_channel)
    return f"{git_repository()}/-/raw/{release_channel}/src/grapejuice/__init__.py"


def git_source_tarball():
    from grapejuice_common.features.settings import current_settings
    from grapejuice_common.features import settings

    release_channel = current_settings.get(settings.k_release_channel)
    return f"{git_repository()}/-/archive/{release_channel}/grapejuice-{release_channel}.tar.gz"


def system_wine_home() -> Path:
    for bin_directory_string in os.environ.get("PATH", "").split(os.path.pathsep):
        wine_binary_path = Path(bin_directory_string) / "wine"
        wine_home = wine_binary_path.parent.parent

        if wine_binary_path.exists() and wine_binary_path.is_file() and wine_home.is_dir():
            return wine_home

    static_search = [
        "/opt/wine-stable",
        "/opt/wine-devel",
        "/opt/wine-staging"
    ]

    for wine_home in map(Path, static_search):
        if not wine_home.exists():
            continue

        wine_bin = wine_home / "bin"
        wine_binary_path = wine_bin / "wine"

        if wine_home.is_dir() and wine_binary_path.is_file():
            return wine_home

    raise CouldNotFindSystemWineHome()


def required_wine_version():
    return "wine-7.0"


def required_player_wine_version():
    return "wine-7.0"


@dataclass(frozen=True)
class FpsUnlockerRelease:
    id: int
    tag: str
    download_url: str = "https://github.com/axstin/rbxfpsunlocker/files/5203791/rbxfpsunlocker-x86.zip"
    did_get_from_github_releases: bool = False


def current_rbxfpsunlocker_release() -> FpsUnlockerRelease:
    import requests

    try:

        gh_release = requests.get("https://api.github.com/repos/axstin/rbxfpsunlocker/releases/latest")
        gh_release.raise_for_status()

        gh_release = gh_release.json()

        url_ptn = re.compile(r"(https://github.com/axstin.rbxfpsunlocker/files/\d+/[\w-]+?\.zip)")
        found_urls = url_ptn.findall(gh_release["body"])

        if len(found_urls) <= 0:
            for asset in gh_release["assets"]:
                asset_name = asset["name"].lower()

                if asset_name in ("rbxfpsunlocker-x64.zip", "rbxfpsunlocker-x86.zip"):
                    found_urls.append(asset["browser_download_url"])

        LOG.info("Found FPS unlocker urls: " + json.dumps(found_urls))

        if len(found_urls) <= 0:
            raise RuntimeError("Did not find any valid fps unlocker urls")

        def prioritize_url(url):
            if "x64" in url:
                priority = 0

            elif "x86" in url:
                priority = 1

            else:
                priority = 99

            return {
                "priority": priority,
                "url": url
            }

        prioritized = list(sorted(map(prioritize_url, found_urls), key=lambda x: x["priority"]))

        return FpsUnlockerRelease(
            gh_release.get("id", -1),
            gh_release.get("tag_name", "unknown_tag"),
            prioritized[0]["url"],
            did_get_from_github_releases=True
        )

    except Exception as e:
        LOG.error(str(e))

        return FpsUnlockerRelease(-1, "unknown_tag")


@dataclass(frozen=True)
class DXVKRelease:
    id: int
    tag: str
    version: str = "1.9.2"
    download_url: str = "https://github.com/doitsujin/dxvk/releases/download/v1.9.2/dxvk-1.9.2.tar.gz"
    did_get_from_github_releases: bool = False

    @property
    def has_version(self):
        return not not self.version.strip()


DXVK_VERSION_PTN = re.compile(r"^v(.*)")


def current_dxvk_release() -> DXVKRelease:
    import requests

    try:

        gh_release = requests.get("https://api.github.com/repos/doitsujin/dxvk/releases/latest")
        gh_release.raise_for_status()

        gh_release = gh_release.json()
        version = None

        tag_name = gh_release.get("tag_name", "")
        version_match = DXVK_VERSION_PTN.search(tag_name)
        if version_match:
            version = version_match.group(1).strip()

        for asset in gh_release["assets"]:
            if asset.get("name", "").lower().endswith(".tar.gz"):
                return DXVKRelease(
                    id=int(asset.get("id", -1)),
                    tag=gh_release.get("tag_name", "unknown_tag"),
                    version=version or DXVKRelease.version,
                    download_url=asset["browser_download_url"]
                )

    except Exception as e:
        LOG.error(str(e))

    return DXVKRelease(-1, "unknown_tag")


def text_encoding() -> str:
    return "UTF-8"


def temporary_directory() -> Path:
    path = Path(os.path.sep, "tmp", f"grapejuice-{INSTANCE_ID}").resolve()
    if path.exists():
        return path

    def on_exit(*_, **__):
        if path.exists():
            shutil.rmtree(path, ignore_errors=True)

    atexit.register(on_exit)

    path.mkdir(parents=True, exist_ok=True)

    return path
