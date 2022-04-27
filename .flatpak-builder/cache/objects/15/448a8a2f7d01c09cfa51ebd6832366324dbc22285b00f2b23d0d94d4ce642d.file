from typing import Optional

from grapejuice import background
from grapejuice.background import BackgroundTask
from grapejuice_common.gtk.gtk_util import dialog

once_task_tracker = dict()


def _generic_already_running():
    dialog("This task is already being performed!")


def run_task_once(
    task_class,
    *args,
    on_already_running: Optional[callable] = None,
    **kwargs
):
    if task_class in once_task_tracker.values():
        if on_already_running is None:
            _generic_already_running()

        else:
            on_already_running()

        return

    super_on_finish = kwargs.get("on_finish_callback", None)

    def on_finish(finished_task):
        try:
            once_task_tracker.pop(finished_task)

        except KeyError:
            pass

        if super_on_finish is not None:
            super_on_finish(finished_task)

    kwargs["on_finish_callback"] = on_finish

    task: BackgroundTask = task_class(*args, **kwargs)
    once_task_tracker[task] = task_class

    background.tasks.add(task)


def wait_for_task(task, after_finish):
    from gi.repository import GObject

    def poll():
        if task.finished:
            after_finish()

        return not task.finished

    GObject.timeout_add(100, poll)
