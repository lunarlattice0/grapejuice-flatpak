import click

from grapejuice.cli.cli_common import handle_fatal_error, common_prepare, common_exit
from grapejuice_common.gtk.gtk_util import gtk_boot


@click.command()
def main():
    common_prepare()

    try:
        def make_main_window():
            from grapejuice.windows.main_window import MainWindow
            window = MainWindow()
            window.show()

        gtk_boot(make_main_window)

    except Exception as e:
        handle_fatal_error(e)

    common_exit()


def easy_install_main():
    main()


def module_invocation_main():
    main()


if __name__ == "__main__":
    main()
