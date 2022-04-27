import shutil
import time
from gettext import gettext as _
from typing import Optional, List

from gi.repository import Gtk

from grapejuice import gui_task_manager, background
from grapejuice.components.main_window_components import \
    GrapeStartUsingGrapejuiceRow, \
    GrapeWineprefixRow, \
    GtkAddWineprefixRow
from grapejuice.helpers.background_task_helper import BackgroundTaskHelper
from grapejuice.helpers.prefix_feature_toggles import PrefixFeatureToggles
from grapejuice.helpers.prefix_name_handler import PrefixNameHandler
from grapejuice.tasks import \
    InstallRoblox, \
    OpenLogsDirectory, \
    ShowDriveC, \
    ExtractFastFlags, \
    RunRobloxStudio, \
    PerformUpdate, \
    RunBuiltinWineApp, \
    RunLinuxApp, \
    KillWineserver, \
    InstallFPSUnlocker, \
    SetDXVKState, \
    SignIntoStudio, \
    PreloadXRandR
from grapejuice.windows.settings_window import SettingsWindow
from grapejuice_common import variables, paths
from grapejuice_common.features.settings import current_settings
from grapejuice_common.gtk.gtk_base import GtkBase, WidgetAccessor, handler, manually_connected_handler
from grapejuice_common.gtk.gtk_util import \
    set_gtk_widgets_visibility, \
    set_label_text_and_hide_if_no_text, \
    set_style_class_conditionally, \
    dialog
from grapejuice_common.gtk.yes_no_dialog import yes_no_dialog
from grapejuice_common.models.wineprefix_configuration_model import WineprefixConfigurationModel, ThirdPartyKeys
from grapejuice_common.util.computed_field import ComputedField
from grapejuice_common.util.event import Subscription
from grapejuice_common.util.stores import WritableStore
from grapejuice_common.wine.wine_functions import create_new_model_for_user, get_studio_wineprefix
from grapejuice_common.wine.wineprefix import Wineprefix


def _open_fast_flags_for(prefix: Wineprefix):
    from grapejuice.windows.fast_flag_warning import FastFlagWarning

    def show_fast_flag_window():
        from grapejuice.windows.fast_flag_editor import FastFlagEditor

        fast_flag_editor = FastFlagEditor(target_prefix=prefix)
        fast_flag_editor.window.show()

    def warning_callback(confirmed: bool):
        if not confirmed:
            return

        task = ExtractFastFlags(prefix)
        background.tasks.add(task)

        gui_task_manager.wait_for_task(task, show_fast_flag_window)

    warning_window = FastFlagWarning(warning_callback)
    warning_window.show()


def _check_for_updates(
    widgets: WidgetAccessor,
    time_to_be_wasted: Optional[int] = None,
    pop_down_dots_menu: Optional[bool] = False
):
    from grapejuice_common.update_info_providers import guess_relevant_provider

    update_provider = guess_relevant_provider()

    if pop_down_dots_menu:
        widgets.dots_menu.popdown()

    class CheckForUpdates(background.BackgroundTask):
        def __init__(self, **kwargs):
            super().__init__(_("Checking for a newer version of Grapejuice"), **kwargs)

        def work(self) -> None:
            show_button = False

            # Calculate info
            update_available = update_provider.update_available()

            if update_available:
                show_button = True
                update_status = _("This version of Grapejuice is out of date.")
                update_info = f"{update_provider.local_version()} -> {update_provider.target_version()}"

            else:
                if update_provider.local_is_newer():
                    update_status = _("This version of Grapejuice is from the future")
                    update_info = f"\n{update_provider.local_version()}"

                else:
                    update_status = _("Grapejuice is up to date")
                    update_info = str(update_provider.local_version())

            if not update_provider.can_update():
                show_button = False

            # Make it feel like its working
            if time_to_be_wasted is not None:
                time.sleep(time_to_be_wasted)

            # Update Interface
            set_label_text_and_hide_if_no_text(widgets.update_status_label, update_status)
            set_label_text_and_hide_if_no_text(widgets.update_info_label, update_info)
            set_gtk_widgets_visibility([widgets.update_button], show_button)
            set_style_class_conditionally(
                [widgets.update_menu_button_image],
                "update-available-highlight",
                update_available
            )

    background.tasks.add(CheckForUpdates())


class MainWindow(GtkBase):
    _current_page = None
    _current_prefix_model: Optional[WineprefixConfigurationModel] = None
    _prefix_name_handler: PrefixNameHandler
    _background_task_helper: BackgroundTaskHelper
    _prefix_feature_toggles: PrefixFeatureToggles
    _current_prefix: ComputedField[Wineprefix]
    _toggles_unsaved_changes_state: WritableStore[bool]
    _subs: List[Subscription]

    def __init__(self):
        super().__init__(glade_path=paths.grapejuice_glade(), handler_instance=self)

        self._subs = []
        self._toggles_unsaved_changes_state = WritableStore(False)
        self._prefix_name_handler = PrefixNameHandler(self.widgets.prefix_name_wrapper)
        self._background_task_helper = BackgroundTaskHelper(self.widgets)
        self._prefix_feature_toggles = PrefixFeatureToggles(self.widgets.feature_toggle_pane)

        self._connect_signals()
        self._populate_prefix_list()
        self._show_start_page()

        self._current_prefix = ComputedField(
            lambda: None if self._current_prefix_model is None else Wineprefix(self._current_prefix_model)
        )

        _check_for_updates(self.widgets)

        gui_task_manager.run_task_once(PreloadXRandR)

    def _save_current_prefix(self):
        if self._current_prefix_model is not None:
            current_settings.save_prefix_model(self._current_prefix_model)

    def _connect_signals(self):
        # General buttons
        self.widgets.main_window.connect("destroy", self._on_destroy)
        self.widgets.prefix_list.connect("row-selected", self._prefix_row_selected)

        # Prefix pane
        self.widgets.edit_prefix_name_button.connect("clicked", self._edit_prefix_name)
        self.widgets.install_roblox_button.connect(
            "clicked",
            lambda _b: gui_task_manager.run_task_once(InstallRoblox, self._current_prefix.value)
        )
        self.widgets.drive_c_button.connect(
            "clicked",
            lambda _b: gui_task_manager.run_task_once(ShowDriveC, self._current_prefix.value)
        )
        self.widgets.fflags_button.connect(
            "clicked",
            lambda _b: _open_fast_flags_for(self._current_prefix.value)
        )

        self.widgets.create_prefix_button.connect(
            "clicked",
            lambda _b: self._create_current_prefix()
        )
        self.widgets.delete_prefix_button.connect(
            "clicked",
            lambda _b: self._delete_current_prefix()
        )
        self.widgets.update_prefix_button.connect(
            "clicked",
            lambda _b: self._update_current_prefix()
        )

        # Dots menu
        self.widgets.about_grapejuice_button.connect(
            "clicked",
            lambda _b: self._show_about_window()
        )
        self.widgets.show_documentation_button.connect(
            "clicked",
            lambda _b: self._show_grapejuice_documentation()
        )
        self.widgets.check_for_updates_button.connect(
            "clicked",
            lambda _b: _check_for_updates(self.widgets, time_to_be_wasted=2, pop_down_dots_menu=True)
        )

        def do_finish_editing_prefix_name(_handler):
            if self._current_prefix_model is not None:
                self._current_prefix_model.display_name = self._prefix_name_handler.prefix_name
                self._update_prefix_in_prefix_list(self._current_prefix_model)
                self._save_current_prefix()

        self._prefix_name_handler.on_finish_editing(do_finish_editing_prefix_name)

        def on_unsaved_changed_state_changed(v: bool):
            set_style_class_conditionally(
                [self.widgets.update_prefix_button],
                "prefix-unsaved-changes-highlight",
                v
            )

        self._subs.append(
            Subscription(
                self._prefix_feature_toggles.changed,
                lambda: self._toggles_unsaved_changes_state.write(True)
            )
        )

        self._subs.append(
            Subscription(
                self._toggles_unsaved_changes_state.changed,
                on_unsaved_changed_state_changed)
        )

    @handler
    def open_roblox_studio(self, *_):
        studio_prefix = get_studio_wineprefix()

        gui_task_manager.run_task_once(RunRobloxStudio, studio_prefix)

    @handler
    def sign_in_to_studio(self, *_):
        gui_task_manager.run_task_once(SignIntoStudio)

    @handler
    def open_grapejuice_documentation(self, *_):
        self._show_grapejuice_documentation()

    @handler
    def open_settings_window(self, *_):
        window = SettingsWindow()
        window.show()

    @handler
    def show_errors(self, *_):
        errors = self._background_task_helper.take_errors()
        if not errors:
            return

        from grapejuice.windows.exception_viewer import ExceptionViewer

        window = ExceptionViewer(exceptions=errors)
        window.show()

    @handler
    def update_grapejuice(self, *_args):
        from grapejuice_common.update_info_providers import guess_relevant_provider

        update_provider = guess_relevant_provider()
        if not update_provider.can_update():
            dialog(_("This installation of Grapejuice does not support updating itself."))
            return

        dialog(_(
            "Grapejuice will now update and will re-open after the process has finished.\n"
            "If Grapejuice does not re-open, you might have to redo your source install."
        ))

        gui_task_manager.run_task_once(PerformUpdate, update_provider, True)

    @handler
    def view_logs(self, *_):
        gui_task_manager.run_task_once(OpenLogsDirectory)

    @handler
    def open_wine_cfg(self, *_):
        background.tasks.add(RunBuiltinWineApp(self._current_prefix.value, "winecfg"))

    @handler
    def open_wine_explorer(self, *_):
        background.tasks.add(RunBuiltinWineApp(self._current_prefix.value, "explorer.exe"))

    @handler
    def open_wine_regedit(self, *_):
        background.tasks.add(RunBuiltinWineApp(self._current_prefix.value, "regedit.exe"))

    @handler
    def open_wine_task_manager(self, *_):
        background.tasks.add(RunBuiltinWineApp(self._current_prefix.value, "taskmgr.exe"))

    @handler
    def open_winetricks(self, *_):
        background.tasks.add(RunLinuxApp(self._current_prefix.value, "winetricks"))

    @handler
    def kill_wineserver(self, *_):
        gui_task_manager.run_task_once(KillWineserver, self._current_prefix.value)

    @manually_connected_handler
    def _show_about_window(self):
        self.widgets.dots_menu.popdown()

        from grapejuice.windows.about_window import AboutWindow
        wnd = AboutWindow()
        wnd.run()

        del wnd

    @manually_connected_handler
    def _show_grapejuice_documentation(self):
        self.widgets.dots_menu.popdown()

        from grapejuice_common.util import xdg_open

        xdg_open(variables.documentation_link())

    def _show_start_page(self):
        self._set_page(self.widgets.cc_start_page)

    @manually_connected_handler
    def _edit_prefix_name(self, _button):
        if self._prefix_name_handler.is_editing:
            self._prefix_name_handler.finish_editing()

        else:
            self._prefix_name_handler.activate_entry()

    @manually_connected_handler
    def _prefix_row_selected(self, _prefix_list, prefix_row):
        if isinstance(prefix_row, GrapeWineprefixRow):
            self._show_prefix_model(prefix_row.prefix_model)

        elif isinstance(prefix_row, GrapeStartUsingGrapejuiceRow):
            self._show_start_page()

        elif isinstance(prefix_row, Gtk.ListBoxRow):
            self._show_page_for_new_prefix()

    def _populate_prefix_list(self):
        listbox = self.widgets.prefix_list

        for child in listbox.get_children():
            listbox.remove(child)
            child.destroy()

        start_row = GrapeStartUsingGrapejuiceRow()
        listbox.add(start_row)

        for prefix in current_settings.parsed_wineprefixes_sorted:
            row = GrapeWineprefixRow(prefix)
            listbox.add(row)

        add_prefix_row = GtkAddWineprefixRow()
        listbox.add(add_prefix_row)

        listbox.show_all()

    def _update_prefix_in_prefix_list(self, prefix: WineprefixConfigurationModel):
        for child in self.widgets.prefix_list.get_children():
            if isinstance(child, GrapeWineprefixRow):
                if child.prefix_model.id == prefix.id:
                    child.prefix_model = prefix

    @manually_connected_handler
    def _delete_current_prefix(self):
        model = self._current_prefix_model

        do_delete = yes_no_dialog(
            _("Delete Wineprefix"),
            _("Do you really want to delete the Wineprefix '{prefix}'?").format(prefix=model.display_name)
        )

        if do_delete:
            current_settings.remove_prefix_model(model)
            self._populate_prefix_list()
            self._show_start_page()

            shutil.rmtree(model.base_directory, ignore_errors=True)

    @manually_connected_handler
    def _update_current_prefix(self):
        self._toggles_unsaved_changes_state.write(False)

        model = self._prefix_feature_toggles.configured_model
        current_settings.save_prefix_model(model)
        self._update_prefix_in_prefix_list(model)

        gui_task_manager.run_task_once(
            SetDXVKState,
            self._current_prefix.value,
            should_be_installed=model.third_party.get(ThirdPartyKeys.dxvk, False)
        )

        if model.third_party.get(ThirdPartyKeys.fps_unlocker, False):
            gui_task_manager.run_task_once(InstallFPSUnlocker, self._current_prefix.value, check_exists=True)

    @manually_connected_handler
    def _create_current_prefix(self):
        self._prefix_name_handler.finish_editing()

        model = self._current_prefix_model

        model.create_name_on_disk_from_display_name()
        current_settings.save_prefix_model(model)
        prefix = Wineprefix(model)

        def after_installation(_task):
            self._populate_prefix_list()
            self._show_prefix_model(self._current_prefix_model)

        gui_task_manager.run_task_once(
            InstallRoblox,
            prefix,
            on_finish_callback=after_installation
        )

    def _show_prefix_model(self, prefix: WineprefixConfigurationModel):
        self._current_prefix.clear_cached_value()
        self._set_page(self.widgets.cc_prefix_page)
        self._current_prefix_model = prefix
        self._prefix_name_handler.set_prefix_name(prefix.display_name)

        prefix_exists_on_disk = prefix.exists_on_disk

        set_gtk_widgets_visibility(
            [
                self.widgets.prefix_page_sep_0,
                self.widgets.prefix_action_buttons,
                self.widgets.delete_prefix_button,
                self.widgets.update_prefix_button
            ],
            prefix_exists_on_disk
        )

        set_gtk_widgets_visibility(
            [self.widgets.create_prefix_button],
            not prefix_exists_on_disk
        )

        if prefix_exists_on_disk:
            self._prefix_feature_toggles.use_prefix(self._current_prefix.value)

        else:
            self._prefix_feature_toggles.clear_toggles()

        self._toggles_unsaved_changes_state.write(False)

    def _show_page_for_new_prefix(self):
        model = create_new_model_for_user(current_settings.as_dict())

        if model.exists_on_disk:
            n = 1

            while model.exists_on_disk:
                model.display_name = _("New Wineprefix - {n}").format(n=n)
                model.create_name_on_disk_from_display_name()

                n += 1

        self._show_prefix_model(model)

    def _set_page(
        self,
        new_page: Optional = None,
        show_all: bool = True,
        clear_current_prefix: bool = True
    ):
        if self._current_page is not None:
            self.widgets.page_wrapper.remove(self._current_page)
            self._current_page = None

        if new_page is not None:
            self.widgets.page_wrapper.add(new_page)
            self._current_page = new_page

            if show_all:
                self._current_page.show_all()

        if clear_current_prefix:
            self._current_prefix_model = None

    def _on_destroy(self, *_):
        self._background_task_helper.destroy()
        self._prefix_feature_toggles.destroy()

        Gtk.main_quit()

    def show(self):
        self.widgets.main_window.show()
