import locale
import logging
import re
from gettext import gettext as _

import click

import grapejuice_common.util
from grapejuice.cli.cli_common import handle_fatal_error, common_prepare, common_exit
from grapejuice_common.gtk.gtk_util import gtk_boot
from grapejuice_common.recipes.recipe import CannotMakeRecipe


@click.group()
def cli():
    ...


@cli.command()
@click.argument("uri", type=str)
def player(uri: str):
    def player_main():
        from grapejuice_common.ipc.dbus_client import dbus_connection
        from grapejuice_common.wine.wine_functions import get_player_wineprefix

        prefix = get_player_wineprefix()

        dbus_connection().play_game(
            prefix.configuration.id,
            grapejuice_common.util.prepare_uri(uri)
        )

    gtk_boot(player_main, gtk_main=False)

    return 0


@cli.command()
def app():
    def player_main():
        from grapejuice_common.ipc.dbus_client import dbus_connection
        from grapejuice_common.wine.wine_functions import get_app_wineprefix

        prefix = get_app_wineprefix()

        dbus_connection().launch_app(prefix.configuration.id)

    gtk_boot(player_main, gtk_main=False)

    return 0


@cli.command()
@click.argument("uri", nargs=-1)
def studio(uri):
    from grapejuice_common.wine.wine_functions import get_studio_wineprefix
    from grapejuice_common.ipc.dbus_client import dbus_connection

    prefix = get_studio_wineprefix()
    uri = grapejuice_common.util.prepare_uri(next(iter(uri), None))

    if uri:
        is_local = False
        if not uri.startswith("roblox-studio:"):
            uri = "Z:" + uri.replace("/", "\\")
            is_local = True

        if is_local:
            dbus_connection().edit_local_game(prefix.configuration.id, uri)

        else:
            dbus_connection().edit_cloud_game(prefix.configuration.id, uri)

    else:
        dbus_connection().launch_studio(prefix.configuration.id)


@cli.command()
def first_time_setup():
    from grapejuice_common.features.settings import current_settings
    from grapejuice_common.errors import WineprefixNotFoundUsingHints
    from grapejuice_common.wine.wineprefix import Wineprefix
    from grapejuice_common.recipes.roblox_player_recipe import RobloxPlayerRecipe
    from grapejuice_common.wine.wine_functions import \
        get_player_wineprefix, \
        get_studio_wineprefix, \
        create_player_prefix_model, \
        create_studio_prefix_model

    log = logging.getLogger("first_time_setup")

    log.info("Retrieving settings as dict")
    settings_dict = current_settings.as_dict()

    log.info("Getting player Wineprefix")
    try:
        player_prefix = get_player_wineprefix()

    except WineprefixNotFoundUsingHints:
        log.info("Creating player Wineprefix")

        player_prefix_model = create_player_prefix_model(settings_dict)

        log.info("Saving player wineprefix to settings")
        current_settings.save_prefix_model(player_prefix_model)
        settings_dict = current_settings.as_dict()

        player_prefix = Wineprefix(player_prefix_model)

    log.info("Starting Roblox Player recipe")
    player_recipe = RobloxPlayerRecipe()
    if not player_recipe.exists_in(player_prefix):
        log.info("Roblox is not installed!")

        try:
            player_recipe.make_in(player_prefix)

        except CannotMakeRecipe:
            log.warning("Could not make Roblox Player recipe")

    log.info("Getting studio Wineprefix")
    try:
        studio_prefix = get_studio_wineprefix()

    except WineprefixNotFoundUsingHints:
        log.info("Creating studio wineprefix")
        studio_prefix_model = create_studio_prefix_model(settings_dict)

        log.info("Saving studio Wineprefix to settings")
        current_settings.save_prefix_model(studio_prefix_model)

        studio_prefix = Wineprefix(studio_prefix_model)

    assert studio_prefix, "Studio Wineprefix was not created?!"

    log.info("Completed first time setup!")


@cli.command()
def uninstall():
    from grapejuice_common import uninstall as uninstall_module

    yes_ptn = re.compile(locale.nl_langinfo(locale.YESEXPR))
    no_ptn = re.compile(locale.nl_langinfo(locale.NOEXPR))

    uninstall_grapejuice_response = input(_("Are you sure you want to uninstall Grapejuice? [y/N] ")).strip()
    uninstall_grapejuice = yes_ptn.match(uninstall_grapejuice_response) is not None  # Check if user said yes

    if uninstall_grapejuice:
        delete_prefix_response = input(_(
            "Remove the Wineprefixes that contain your installations of Roblox? "
            "This will cause all configurations for Roblox to be permanently deleted! [n/Y] "
        )).strip()
        delete_prefix = no_ptn.match(delete_prefix_response) is None  # Check if user didn't say no

        params = uninstall_module.UninstallationParameters(delete_prefix, for_reals=True)
        uninstall_module.go(params)

        print(_("Grapejuice has been uninstalled. Have a nice day!"))

    else:
        print(_("Uninstallation aborted"))


@cli.command()
@click.argument("hint", type=str)
def top(hint: str):
    from grapejuice_common.wine.wineprefix_hints import WineprefixHint
    from grapejuice_common.wine.wine_functions import get_wineprefix

    hint = WineprefixHint(hint)
    prefix = get_wineprefix([hint])

    for proc in prefix.core_control.process_list:
        print(repr(proc))


def main():
    common_prepare()

    try:
        cli()

    except Exception as e:
        handle_fatal_error(e)

    common_exit()


def easy_install_main():
    main()


def module_invocation_main():
    main()


if __name__ == "__main__":
    main()
