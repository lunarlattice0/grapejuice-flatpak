from gettext import gettext as _
from typing import Optional, List

from grapejuice_common import paths
from grapejuice_common.gtk.gtk_base import GtkBase
from grapejuice_common.models.paginator import Paginator
from grapejuice_common.util.event import Subscription


class GtkPaginator(GtkBase):
    _model: Optional[Paginator] = None
    _model_subscriptions: List[Subscription]

    def __init__(self, paginator: Optional[Paginator] = None):
        super().__init__(
            glade_path=paths.grapejuice_components_glade(),
            root_widget_name="paginator"
        )

        self._model_subscriptions = []

        def go_back(*_):
            if self._model:
                self._model.previous()

        def go_forward(*_):
            if self._model:
                self._model.next()

        self.widgets.paginator_previous.connect("clicked", go_back)
        self.widgets.paginator_next.connect("clicked", go_forward)

        self.model = paginator

    @property
    def _label_text(self):
        if self._model:
            return f"{self._model.current_page_index + 1}/{self._model.n_pages}"

        return _("No model")

    def _on_model_paged(self):
        self.widgets.paginator_label.set_text(self._label_text)

    def _clear_model_subscriptions(self):
        for sub in self._model_subscriptions:
            sub.unsubscribe()

        self._model_subscriptions = []

    @property
    def model(self) -> Paginator:
        return self._model

    @model.setter
    def model(self, model: Paginator):
        self._clear_model_subscriptions()
        self._model = model

        if self._model is not None:
            self._model_subscriptions.append(
                Subscription(
                    self._model.paged,
                    self._on_model_paged
                )
            )

            self._on_model_paged()

    def __del__(self):
        self._clear_model_subscriptions()
