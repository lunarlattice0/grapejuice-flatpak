import json
import logging
import os
from itertools import chain
from pathlib import Path
from typing import List, Dict, Optional, Iterable

from grapejuice_common import variables

LOG = logging.getLogger(__name__)

FastFlagDictionary = Dict[str, any]


def mangle_flags(flags: Dict[str, str]):
    new_flags = dict()

    for k, v in flags.items():
        if isinstance(v, str):
            v = v.split(";")[0].strip()
            v_lower = v.lower()

            if v_lower in ("true", "false"):
                v = v_lower == "true"

            elif v_lower.isnumeric():
                v = int(v)

        new_flags[k] = v

    return new_flags


class FastFlag:
    def __init__(self, name, value):
        self._name = name
        self._original_value = value
        self.value = value

    def is_a(self, cls):
        return isinstance(self.value, cls)

    @property
    def name(self):
        return self._name

    @property
    def has_changed(self):
        return self.value != self._original_value

    def to_tuple(self):
        return self.name, self.value

    def reset(self):
        self.value = self._original_value

    def __lt__(self, other):
        if isinstance(other, FastFlag):
            return self._name < other.name

        return -1

    def __repr__(self):
        return f"FFlag '{self._name}': {self.value}"


class FastFlagList:
    _list: List[FastFlag]

    def __init__(
        self,
        initial_flags: Optional[Iterable[FastFlag]] = None,
        source_file: Optional[Path] = None,
        source_dictionary: Optional[Dict] = None
    ):
        self._list = list() if initial_flags is None else list(initial_flags)

        if source_file is not None:
            self._flags_from_file(source_file)

        if source_dictionary is not None:
            self._flags_from_dictionary(source_dictionary)

    def _flags_from_file(self, file: Path):
        with file.open("r", encoding=variables.text_encoding()) as fp:
            self._flags_from_dictionary(json.load(fp))

    def _flags_from_dictionary(self, flags):
        self._list = list(
            map(
                lambda t: FastFlag(*t),
                flags.items()
            )
        )

        self.sort()

    def export_to_file(self, fast_flags_path):
        os.makedirs(os.path.dirname(fast_flags_path), exist_ok=True)

        with open(fast_flags_path, "w+", encoding=variables.text_encoding()) as fp:
            json.dump(self.as_dictionary, fp)

    def overlay_flags(self, other_flags: "FastFlagList"):
        d = dict(zip(map(lambda f: f.name, self), self._list))

        for flag in filter(lambda f: f.name in d, other_flags):
            d[flag.name].value = flag.value

        self.sort()

    def get_changed_flags(self) -> "FastFlagList":
        return FastFlagList(initial_flags=filter(lambda flag: flag.has_changed, self._list))

    @property
    def as_dictionary(self) -> FastFlagDictionary:
        return dict(map(lambda flag: flag.to_tuple(), self))

    def reset_all_flags(self):
        for flag in self:
            flag.reset()

    def sort(self):
        self._list = list(
            chain(
                sorted(
                    filter(
                        lambda f: f.has_changed,
                        self._list
                    )
                ),
                sorted(
                    filter(
                        lambda f: not f.has_changed,
                        self._list
                    )
                )
            )
        )

    def __iter__(self):
        for flag in self._list:
            yield flag

    def __len__(self):
        return len(self._list)

    def __getitem__(self, *args):
        return self._list.__getitem__(*args)
