import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

from grapejuice_common.ipc.dbus_config import bus_path
from grapejuiced.dbus_service import DBusService


class State:
    def __init__(self, **kwargs):
        DBusGMainLoop(set_as_default=True)

        if "bus" in kwargs:
            self.session_bus = kwargs["bus"]
        else:
            self.session_bus = dbus.SessionBus()

        if "start_service" in kwargs and kwargs["start_service"]:
            self.start_service()

        else:
            self.service = None

        self.loop = GLib.MainLoop()

    def start(self):
        self.loop.run()
        return self

    def stop(self):
        self.loop.quit()

    def start_service(self, bus=None):
        if bus is None:
            bus = self.session_bus

        if self.service is None:
            self.service = DBusService(bus, bus_path)
