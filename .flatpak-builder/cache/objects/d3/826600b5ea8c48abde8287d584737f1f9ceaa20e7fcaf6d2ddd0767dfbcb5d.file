import os
from gettext import gettext as _
from typing import Dict, Optional, List

from grapejuice.components.fast_flag_components import GrapeFastFlagRow
from grapejuice_common import paths
from grapejuice_common.gtk.components.grape_enum_menu import GrapeEnumMenu
from grapejuice_common.gtk.gtk_base import GtkBase, handler
from grapejuice_common.gtk.gtk_paginator import GtkPaginator
from grapejuice_common.gtk.gtk_util import set_style_class_conditionally
from grapejuice_common.models.fast_flags import FastFlagList
from grapejuice_common.models.paginator import Paginator
from grapejuice_common.roblox_product import RobloxProduct
from grapejuice_common.util.event import Subscription
from grapejuice_common.wine.wineprefix import Wineprefix
from grapejuice_common.wine.wineprefix_hints import WineprefixHint


def _base_fast_flags() -> FastFlagList:
    from grapejuice_common.wine.wine_functions import get_studio_wineprefix

    studio_prefix = get_studio_wineprefix()

    return FastFlagList(source_file=next(
        filter(
            lambda f: f.exists(),
            (paths.fast_flag_cache_location(), studio_prefix.roblox.fast_flag_dump_path)
        )
    ))


def _parse_saved_flags(prefix: Wineprefix) -> Dict[RobloxProduct, FastFlagList]:
    def map_flags(product: RobloxProduct):
        flags = _base_fast_flags()
        saved_dict = prefix.configuration.fast_flags.get(product.value, None)

        if saved_dict is not None:
            flags.overlay_flags(FastFlagList(source_dictionary=saved_dict))

        return product, flags

    return dict(map(map_flags, RobloxProduct))


hint_to_product_mapping = {
    WineprefixHint.studio: RobloxProduct.studio,
    WineprefixHint.player: RobloxProduct.player,
    WineprefixHint.app: RobloxProduct.app
}


class FastFlagEditor(GtkBase):
    _target_prefix: Wineprefix
    _fast_flags: Dict[RobloxProduct, FastFlagList]
    _roblox_product_menu: GrapeEnumMenu
    _roblox_product_selected_subscription: Subscription
    _displayed_rows: List[GrapeFastFlagRow]
    _displayed_rows_subscriptions: List[Subscription]
    _paginator: Optional[Paginator] = None

    __selected_product: RobloxProduct
    __unsaved_changes: bool = False

    _paginator_paged_subscription: Optional[Subscription] = None

    def __init__(self, target_prefix: Wineprefix):
        super().__init__(
            glade_path=paths.fast_flag_editor_glade(),
            handler_instance=self,
            root_widget_name="fast_flag_editor"
        )

        self._target_prefix = target_prefix
        self._flags = _parse_saved_flags(target_prefix)

        self._displayed_rows = []
        self._displayed_rows_subscriptions = []

        self._gtk_paginator = GtkPaginator()
        self.widgets.paginator_box.add(self._gtk_paginator.root_widget)

        self._selected_product = next(
            iter(
                sorted(
                    filter(
                        None,
                        map(
                            lambda e: hint_to_product_mapping.get(e, None),
                            target_prefix.configuration.hints_as_enum
                        )
                    )
                )
            ),
            RobloxProduct.player
        )

        self._roblox_product_menu = GrapeEnumMenu(
            RobloxProduct,
            display_strings={
                RobloxProduct.player: _("Roblox Player"),
                RobloxProduct.studio: _("Roblox Studio"),
                RobloxProduct.app: _("Roblox App")
            },
            active_enum=self._selected_product
        )

        self._roblox_product_selected_subscription = Subscription(
            self._roblox_product_menu.enum_selected,
            self._on_selected_product_changed
        )

        self._roblox_product_menu.show_all()

        self.widgets.header_widgets.add(self._roblox_product_menu)

        self.widgets.fast_flag_editor_header.set_subtitle(
            _("Prefix: {prefix}").format(prefix=self._target_prefix.configuration.display_name)
        )

    def _on_selected_product_changed(self, product: RobloxProduct):
        self._selected_product = product

    def _clear_displayed_rows(self):
        gtk_list = self.gtk_fast_flag_list

        for sub in self._displayed_rows_subscriptions:
            sub.unsubscribe()

        for row in list(gtk_list.get_children()):
            gtk_list.remove(row)

        for row in self._displayed_rows:
            row.destroy()

        self._displayed_rows = list()
        self._displayed_rows_subscriptions = []

    @property
    def _selected_product(self) -> RobloxProduct:
        return self.__selected_product

    @_selected_product.setter
    def _selected_product(self, product: RobloxProduct):
        self.__selected_product = product

        page_size = 50

        if self._paginator and self._paginator.filter_function:
            self._paginator = Paginator(
                self._active_flags,
                page_size,
                filter_function=self._paginator.filter_function
            )

        else:
            self._paginator = Paginator(self._active_flags, page_size)

        self._gtk_paginator.model = self._paginator

        self._clear_displayed_rows()

        if self._paginator_paged_subscription:
            self._paginator_paged_subscription.unsubscribe()

        self._paginator_paged_subscription = Subscription(
            self._paginator.paged,
            self._populate_flag_list
        )

        self._populate_flag_list()

    @property
    def _active_flags(self):
        return self._flags[self.__selected_product]

    def _populate_flag_list(self):
        self._clear_displayed_rows()

        gtk_list = self.gtk_fast_flag_list

        def on_flag_changed(_flag):
            self._unsaved_changes = True

        for flag in self._paginator.page:
            row = GrapeFastFlagRow(flag)

            gtk_list.add(row.root_widget)
            self._displayed_rows.append(row)

            self._displayed_rows_subscriptions.append(
                Subscription(row.flag_changed, on_flag_changed)
            )

        self.fast_flag_scroll.get_vadjustment().set_value(0)
        gtk_list.show_all()

        for row in self._displayed_rows:
            row.update_display()

    @property
    def _unsaved_changes(self):
        return self.__unsaved_changes

    @_unsaved_changes.setter
    def _unsaved_changes(self, v):
        self.__unsaved_changes = v

        set_style_class_conditionally(
            [self.widgets.save_button_icon],
            "fast-flags-unsaved-changes-highlight",
            self.__unsaved_changes
        )

    @property
    def window(self):
        return self.widgets.fast_flag_editor

    @property
    def gtk_fast_flag_list(self):
        return self.widgets.fast_flag_list

    @property
    def gtk_header(self):
        return self.widgets.fast_flag_editor_header

    @property
    def fast_flag_scroll(self):
        return self.widgets.fast_flag_scroll

    @handler
    def save_flags(self, *_):
        save_prefix_model = False
        for product, flags in self._flags.items():
            changed_flags = flags.get_changed_flags()

            self._target_prefix.configuration.fast_flags[product.value] = changed_flags.as_dictionary
            save_prefix_model = True

        if save_prefix_model:
            from grapejuice_common.features.settings import current_settings

            current_settings.save_prefix_model(self._target_prefix.configuration)

        self._unsaved_changes = False

    @handler
    def on_search_changed(self, search_entry):
        query = search_entry.get_text().lower()

        if query:
            def filter_function(flags_list):
                return filter(lambda flag: query in flag.name.lower(), flags_list)

            self._paginator.filter_function = filter_function

        else:
            self._paginator.filter_function = None

    @handler
    def reset_all_flags(self, *_):
        for flags in self._flags.values():
            flags.reset_all_flags()

            for row in self._displayed_rows:
                row.update_display()

        self._unsaved_changes = True

    @handler
    def delete_user_flags(self, *_):
        settings_paths = \
            self._target_prefix.roblox.all_studio_app_settings_paths + \
            self._target_prefix.roblox.all_player_app_settings_paths

        for path in filter(lambda p: p and p.exists(), settings_paths):
            os.remove(path)

    @handler
    def reload_flags(self, *_):
        self._flags = _parse_saved_flags(self._target_prefix)
        self._selected_product = self.__selected_product
        self._unsaved_changes = False

    def __del__(self):
        self._clear_displayed_rows()

        self._roblox_product_selected_subscription.unsubscribe()

        if self._paginator_paged_subscription:
            self._paginator_paged_subscription.unsubscribe()
            self._paginator_paged_subscription = None
