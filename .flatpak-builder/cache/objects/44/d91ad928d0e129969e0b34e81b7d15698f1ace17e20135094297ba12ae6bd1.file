import logging
import re
from copy import deepcopy
from pathlib import Path
from typing import Union, IO, List, Callable, Dict

LOG = logging.getLogger(__name__)

KEY_PTN = re.compile(r"\[(.*)?].*")


def line_iterator(fp: IO):
    for line in fp.read().split("\n"):
        yield line.strip("\r").strip()


class RegistryKey:
    _path: str
    _value: any
    _attributes: Dict[str, str]

    def __init__(self, path: str):
        self._path = path
        self._attributes = dict()

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, v):
        self._value = v

    def set_attribute(self, key: str, value: str):
        self._attributes[key] = value

    def get_attribute(self, key: str):
        return self._attributes.get(key, None)

    @property
    def attributes(self) -> Dict[str, str]:
        return deepcopy(self._attributes)


class RegistryFile:
    _path: Path

    _version: str = ""
    _comments: List[str]
    _root_key: RegistryKey
    _keys: Dict[str, RegistryKey]
    _last_key_read: Union[RegistryKey, None] = None

    def __init__(self, path: Union[str, Path]):
        if isinstance(path, str):
            self._path = Path(path).absolute()

        else:
            self._path = path.absolute()

        self._comments = []
        self._keys = dict()
        self._root_key = RegistryKey("\\")

    @property
    def _current_key(self) -> RegistryKey:
        if self._last_key_read is not None:
            return self._last_key_read

        else:
            return self._root_key

    def find_key(self, path: str):
        return self._keys.get(path, None)

    def load(self):
        class LoadState:
            operator: Callable[[str], None]

        def normal(ln: str):
            if ln.startswith(";;"):
                return comment(ln)

            match = KEY_PTN.match(ln)
            if match:
                return key(ln)

            return attribute(ln)

        def version(ln: str):
            self._version = ln
            LoadState.operator = normal

        def comment(ln: str):
            self._comments.append(ln)

        def key(ln: str):
            split = ln.split(" ")
            path = split[0].lstrip("[").strip("]")
            registry_key = self._keys.setdefault(path, RegistryKey(path))

            if len(split) > 1:
                registry_key.value = split[1].strip()

            self._last_key_read = registry_key

        def attribute(ln: str):
            if not ln:
                return

            match = re.match(r"#(.*)?=(.*)", ln)
            if match:
                self._current_key.set_attribute(match.group(1), match.group(2))
                return

            match = re.match(r"\"(.*)?\"\s*=\s*(.*)", ln)
            if match:
                self._current_key.set_attribute(match.group(1), match.group(2))
                return

        LoadState.operator = version

        with self._path.open("r") as fp:
            if callable(LoadState.operator):
                for line in line_iterator(fp):
                    LoadState.operator(line)

            else:
                LOG.warning("LoadState.operator is not callable")

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass
