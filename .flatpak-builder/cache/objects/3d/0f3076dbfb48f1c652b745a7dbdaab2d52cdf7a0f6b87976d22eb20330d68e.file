from grapejuice_common import paths
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
    import gettext
    import locale
    text_domain = "grapejuice"
    locale_directory = paths.locale_directory()

    gettext.bindtextdomain(text_domain, locale_directory)
    gettext.textdomain(text_domain)
    locale.bindtextdomain(text_domain, locale_directory)
    locale.setlocale(locale.LC_ALL, "")

    from grapejuice_common.logs import log_config

    log_config.configure_logging("grapejuice")

    # List out startup info
    # Has to be done after configure_logging to avoid load order conflicts
    import logging
    log = logging.getLogger("common_prepare")
    log.info(f"Using locale directory {locale_directory}")

    from grapejuice_common.features.settings import current_settings

    if current_settings:
        current_settings.perform_migrations()


def common_exit():
    vacuum_logs()
