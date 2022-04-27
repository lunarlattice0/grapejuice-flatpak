import logging
from functools import lru_cache as cache

from grapejuice_common.errors import format_exception
from grapejuice_common.hardware_info.phony_xrandr import PhonyXRandR
from grapejuice_common.hardware_info.xrandr import XRandR

log = logging.getLogger(__name__)


@cache(maxsize=1)
def xrandr_factory():
    log.info("Creating XRandR instance")

    try:
        x = XRandR()
        if len(x.providers) > 0:
            return x

    except Exception as e:
        log.error(str(e))
        log.error(format_exception(e))

    log.info("Falling back to PhonyXRandR")

    x = PhonyXRandR()
    if len(x.providers) > 0:
        return x

    raise RuntimeError("Could not get any graphics card providers")
