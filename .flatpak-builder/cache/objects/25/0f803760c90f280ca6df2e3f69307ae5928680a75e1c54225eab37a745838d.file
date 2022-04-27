import logging
import os
import sys
import time

from dbus import DBusException

from grapejuice_common.ipc import dbus_config
from grapejuice_common.ipc.i_dbus_connection import IDBusConnection
from grapejuice_common.ipc.pid_file import daemon_pid_file

LOG = logging.getLogger(__name__)


class DBusConnection(IDBusConnection):
    def __init__(self, connection_attempts=5, **kwargs):
        import dbus

        if "bus" in kwargs:
            self.bus = kwargs["bus"]

        else:
            self.bus = dbus.SessionBus()

        self.pid_file = daemon_pid_file()
        self.daemon_alive = self.pid_file.is_running()
        self.proxy = None

        if not self.daemon_alive:
            LOG.debug("There is no Grapejuice daemon running, going to spawn one")
            self._spawn_daemon()
            self._wait_for_daemon(10)

        self._try_connect(attempts=connection_attempts)

    @property
    def connected(self):
        return self.proxy is not None

    def _wait_for_daemon(self, attempts: int):
        LOG.debug("Waiting for Grapejuice daemon to start")
        attempts_remaining = attempts

        while not self.daemon_alive and attempts_remaining > 0:
            attempts_remaining -= 1
            self.daemon_alive = self.pid_file.is_running(remove_junk=False)
            time.sleep(.5)

        if not self.daemon_alive:
            LOG.warning("Grapejuice daemon is not alive after waiting for it!")

    def _try_connect(self, attempts: int):
        attempts_remaining = attempts
        while attempts_remaining > 0 and not self.connected:
            LOG.debug(f"Connecting to Grapejuice daemon, attempt = {attempts - attempts_remaining}")

            attempts_remaining -= 1
            try:
                self.proxy = self.bus.get_object(dbus_config.bus_name, dbus_config.bus_path)

            except DBusException:
                self.daemon_alive = False

            if not self.connected:
                time.sleep(.5)

        if self.connected:
            LOG.debug("Connected to the Grapejuice daemon!")

    def launch_studio(self, prefix_id: str):
        return self.proxy.LaunchStudio(prefix_id)

    def play_game(self, prefix_id: str, uri: str):
        if uri:
            return self.proxy.PlayGame(prefix_id, uri)

        else:
            LOG.debug("No uri provided to play_game, returning False")

        return False

    def launch_app(self, prefix_id: str):
        return self.proxy.LaunchApp(prefix_id)

    def edit_local_game(self, prefix_id: str, place_path: str):
        return self.proxy.EditLocalGame(place_path)

    def edit_cloud_game(self, prefix_id: str, uri: str):
        if uri:
            return self.proxy.EditCloudGame(uri)

        return self.launch_studio(prefix_id)

    def _spawn_daemon(self):
        LOG.debug("Spawning Grapejuice daemon")
        os.spawnlp(os.P_NOWAIT, sys.executable, sys.executable, "-m", "grapejuiced", "daemonize")

    def version(self):
        return self.proxy.Version()

    def extract_fast_flags(self):
        self.proxy.ExtractFastFlags()

    def install_roblox(self, prefix_id: str):
        return self.proxy.InstallRoblox(prefix_id)
