import atexit
import logging
import os
import re
import signal

import psutil

from grapejuice_common import variables

LOG = logging.getLogger(__name__)


class EmptyPIDError(RuntimeError):
    def __init__(self, path):
        super().__init__("Got empty string from PID file " + path)


class AlreadyRunningError(RuntimeError):
    pass


class PIDFile:
    def __init__(self, name: str):
        self._name = re.sub(r"(\W)", "_", name)

        if "XDG_RUNTIME_DIR" in os.environ:
            xdg_runtime_dir = os.environ["XDG_RUNTIME_DIR"]
            LOG.debug(f"PIDFile instance {self._name} is using XDG_RUNTIME_DIR '{xdg_runtime_dir}")
            self._path = os.path.join(xdg_runtime_dir, self._name + ".pid")

        else:
            LOG.debug(f"PIDFile instance {self._name} is using /tmp")
            self._path = os.path.join("/tmp", self._name + ".pid")

        self._wrote_pid = False
        LOG.info(f"PIDFile {self._name} got placed at '{self._path}'")

        atexit.register(self._at_exit)

    def _at_exit(self, *_):
        self._remove_file()

    def exists(self):
        return os.path.exists(self._path)

    @property
    def pid(self):
        with open(self._path, "r", encoding=variables.text_encoding()) as fp:
            s = fp.read().strip()
            if not s:
                raise EmptyPIDError(self._path)

            return int(s)

    def _remove_file(self):
        if self._wrote_pid:
            if os.path.exists(self._path):
                LOG.debug(f"Removing pidfile {self._path}")
                os.remove(self._path)

            else:
                LOG.warning(f"PIDFile {self._path} does not exist!")

        else:
            LOG.debug("Did not write PID, therefore I am not removing it")

    def is_running(self, remove_junk=True):
        if not self.exists():
            return False

        try:
            process = psutil.Process(pid=self.pid)
            return process.is_running()

        except psutil.NoSuchProcess:
            if remove_junk:
                self._remove_file()

            return False

    def write_pid(self):
        try:
            if self.is_running():
                raise AlreadyRunningError

        except EmptyPIDError:
            pass

        with open(self._path, "w+", encoding=variables.text_encoding()) as fp:
            fp.write(str(os.getpid()))

        self._wrote_pid = True

    def kill(self):
        if self.is_running():
            os.kill(self.pid, signal.SIGINT)
            self._remove_file()


def daemon_pid_file():
    return PIDFile("grapejuiced")
