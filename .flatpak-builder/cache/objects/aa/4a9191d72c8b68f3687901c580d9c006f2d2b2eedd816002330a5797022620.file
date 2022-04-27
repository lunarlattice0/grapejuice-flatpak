from grapejuice_common.gtk.gtk_util import gtk_boot
from grapejuice_common.logs.log_vacuum import vacuum_logs


def handle_fatal_error(ex: Exception):
    print("Fatal error: " + str(ex))

    def make_exception_window():
        from grapejuice.windows.exception_viewer import ExceptionViewer
        window = ExceptionViewer(exception=ex, is_main=True)

        window.show()

    gtk_boot(make_exception_window)


def common_prepare():
    from grapejuice_common.logs import log_config
    log_config.configure_logging("grapejuice")

    from grapejuice_common.features.settings import current_settings

    if current_settings:
        current_settings.perform_migrations()


def common_exit():
    vacuum_logs()
