import os
from contextlib import contextmanager
from pathlib import Path
from typing import Optional, Dict, TypeVar, Tuple, Iterable


def prepare_uri(uri):
    if uri is None:
        return None

    if os.path.exists(uri):
        return uri

    prepared_uri = uri.replace("'", "")
    if prepared_uri:
        return prepared_uri
    else:
        return None


def download_file(url, target_path: Path):
    import requests

    response = requests.get(url)
    response.raise_for_status()

    with open(target_path, "wb+") as fp:
        fp.write(response.content)

    return target_path


def xdg_open(*args):
    # Find a less heinous way of opening a program while deferring ownership
    os.spawnlp(os.P_NOWAIT, "xdg-open", "xdg-open", *list(map(str, args)))


def strip_pii(s: str):
    from grapejuice_common import paths
    import getpass

    s = s.replace(str(paths.home()), "~")

    if getpass.getuser().lower() != "root":
        s = s.replace(getpass.getuser(), "[REDACTED]")

    return s


@contextmanager
def working_directory_as(working_directory: Optional[Path] = None):
    if working_directory is not None:
        current_directory = os.curdir
        os.chdir(working_directory)
        yield

        os.chdir(current_directory)

    else:
        yield


EnvironmentValue = Optional[str]
Environment = Dict[str, EnvironmentValue]


def _environment_snapshot(keys: Iterable[str]) -> Environment:
    snapshot = {}

    for k in keys:
        snapshot[k] = os.environ.get(k, None)

    return snapshot


def _apply_environment(environment: Environment):
    for k, v in environment.items():
        if v is None:
            os.environ.pop(k, None)

        else:
            os.environ[k] = v


@contextmanager
def environment_as(environment: Optional[Environment]):
    if environment is None:
        yield
        return

    err = None

    snapshot = _environment_snapshot(environment.keys())
    _apply_environment(environment)

    try:
        yield

    except Exception as e:
        err = e

    _apply_environment(snapshot)

    if err is not None:
        raise err


DictValue = TypeVar("DictValue")


def dunder_storm(input_dict: Dict[str, DictValue]) -> Tuple[Dict[str, DictValue], Dict[str, DictValue]]:
    regular_dict = dict()
    dunder_dict = dict()

    for k, v in input_dict.items():
        if k.startswith("__") and k.endswith("__"):
            dunder_dict[k] = v

        else:
            regular_dict[k] = v

    return dunder_dict, regular_dict
