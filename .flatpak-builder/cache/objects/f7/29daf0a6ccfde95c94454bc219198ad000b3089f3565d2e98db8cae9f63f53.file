from grapejuice_common.features import settings
from grapejuice_common.ipc.i_dbus_connection import IDBusConnection

connection = None


def dbus_connection() -> IDBusConnection:
    global connection

    if connection is None:
        from grapejuice_common.features.settings import current_settings

        if current_settings.get(settings.k_no_daemon_mode, True):
            from grapejuice_common.ipc.no_daemon_connection import NoDaemonModeConnection
            connection = NoDaemonModeConnection()

        else:
            from grapejuice_common.ipc.dbus_connection import DBusConnection
            connection = DBusConnection()

    return connection
