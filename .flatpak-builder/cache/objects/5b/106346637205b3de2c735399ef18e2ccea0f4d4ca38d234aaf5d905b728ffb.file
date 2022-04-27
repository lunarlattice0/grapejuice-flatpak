import json
import re
import subprocess
from copy import deepcopy
from typing import Dict, Optional, Tuple

from grapejuice_common.util import environment_as

OPENGL_ATTRIBUTE_PTN = re.compile(r"(OpenGL.+):(.+)")


def _parse_opengl_version(s):
    m = re.search(r"([\d.]+)", s.strip())

    if m:
        return tuple(map(int, m.group(1).split(".")))

    return None


def _get_glx_info() -> str:
    return subprocess.check_output(["glxinfo"]).decode("UTF-8")


class GLXInfo:
    _attributes: Dict[str, str]

    def __init__(self, env: Optional[Dict[str, str]] = None):
        with environment_as(env):
            info_string = _get_glx_info()

        lines_of_interest = list(
            map(
                lambda t: t[1],
                filter(
                    lambda t: "opengl es" not in t[0],
                    filter(
                        lambda t: "opengl" in t[0],
                        map(
                            lambda s: (s.lower(), s),
                            info_string.split("\n")
                        )
                    )
                )
            )
        )

        self._attributes = dict(
            map(
                lambda m: (m.group(1).strip(), m.group(2).strip()),
                filter(
                    None,
                    map(
                        OPENGL_ATTRIBUTE_PTN.search,
                        lines_of_interest
                    )
                )
            )
        )

    @property
    def core_profile_version_string(self) -> Optional[str]:
        return self._attributes.get("OpenGL core profile version string", None)

    @property
    def version_string(self) -> Optional[str]:
        return self._attributes.get("OpenGL version string", None)

    @property
    def version(self) -> Tuple[int, ...]:
        versions = list(
            filter(
                None,
                map(
                    _parse_opengl_version,
                    filter(
                        None,
                        (self.core_profile_version_string, self.version_string)
                    )
                )
            )
        )

        if len(versions) <= 0:
            raise ValueError("No valid version strings found")

        return max(versions)

    @property
    def attributes(self):
        return deepcopy(self._attributes)

    def __hash__(self):
        return hash(json.dumps(self._attributes))
