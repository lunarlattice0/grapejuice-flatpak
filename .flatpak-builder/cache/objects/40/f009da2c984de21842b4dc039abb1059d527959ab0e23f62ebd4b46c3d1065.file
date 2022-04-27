from typing import List, Optional

from gi.repository import Gtk

from grapejuice import background
from grapejuice.background import BackgroundTask
from grapejuice_common.gtk.gtk_base import WidgetAccessor
from grapejuice_common.gtk.gtk_util import set_gtk_widgets_visibility
from grapejuice_common.util.event import Subscription


class Swapper:
    _active = None

    def __init__(self, a, b):
        self._active = a
        self._a = a
        self._b = b

    def access(self):
        self._active = self._b if self._active is self._a else self._a
        return self._active


class GrapeTaskItem(Gtk.ListBoxRow):
    _task: BackgroundTask

    def __init__(self, task: BackgroundTask, **kwargs):
        super().__init__(**kwargs)
        self._task = task

        label = Gtk.Label(halign=Gtk.Align.START)
        label.set_text(task.name)

        self.add(label)

    @property
    def task(self):
        return self._task


class BackgroundTaskHelper:
    _widgets: WidgetAccessor

    _subscriptions: List[Subscription]

    _errors: List[Exception]
    _stack_swapper: Swapper
    _task_visible_on_label: Optional[BackgroundTask] = None

    _task_reference: List[GrapeTaskItem]

    def __init__(self, widgets: WidgetAccessor):
        self._widgets = widgets
        self._errors = []
        self._task_reference = list()

        self._stack_swapper = Swapper(
            self._widgets.background_task_status_label_a,
            self._widgets.background_task_status_label_b
        )

        self._subscriptions = [
            Subscription(
                background.tasks.tasks_changed,
                self._update
            ),
            Subscription(
                background.tasks.task_errored,
                self._on_task_errored
            ),
            Subscription(
                background.tasks.task_added,
                self._on_task_added
            ),
            Subscription(
                background.tasks.task_removed,
                self._on_task_removed
            )
        ]

        self._update()

    def _update(self):
        any_tasks_running = background.tasks.count > 0

        def on_no_primary_task():
            self._stack.set_visible_child(self._widgets.background_task_status_label_none)
            self._task_visible_on_label = None
            self._widgets.background_task_spinner.stop()

        if any_tasks_running:
            self._widgets.background_task_popover_status_label.set_text(
                f"Grapejuice is running {background.tasks.count} background tasks"
            )

            primary_task = background.tasks.primary_task

            if primary_task is not self._task_visible_on_label:
                if primary_task is None:
                    on_no_primary_task()

                else:
                    stack_label = self._stack_swapper.access()

                    stack_label.set_text(primary_task.name)
                    self._stack.set_visible_child(stack_label)

                    self._task_visible_on_label = primary_task

            self._widgets.background_task_spinner.start()

        else:
            on_no_primary_task()

        set_gtk_widgets_visibility([self._widgets.background_task_menu], any_tasks_running)
        set_gtk_widgets_visibility([self._widgets.background_task_error_button], self._have_errors)

    @property
    def _stack(self):
        return self._widgets.background_task_status_stack

    @property
    def _have_errors(self) -> bool:
        return len(self._errors) > 0

    def _on_task_errored(self, task: BackgroundTask):
        assert task.error
        self._errors.append(task.error)

    def _on_task_added(self, task: BackgroundTask):
        row = GrapeTaskItem(task)

        self._task_reference.append(row)
        self._widgets.background_task_list.add(row)

        row.show_all()

    def _on_task_removed(self, task: BackgroundTask):
        to_delete: Optional[GrapeTaskItem] = None

        for row in self._task_reference:
            if row.task is task:
                to_delete = row

        if to_delete is not None:
            self._task_reference.remove(to_delete)
            self._widgets.background_task_list.remove(to_delete)
            to_delete.destroy()

    def take_errors(self) -> List[Exception]:
        taken = [*self._errors]
        self._errors = []

        self._update()

        return taken

    def destroy(self):
        for subscription in self._subscriptions:
            subscription.unsubscribe()
