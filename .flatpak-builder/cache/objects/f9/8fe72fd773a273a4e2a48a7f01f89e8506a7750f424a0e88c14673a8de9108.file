import logging
from typing import List, Tuple


class TaskError(RuntimeError):
    def __init__(self, message: str, can_continue: bool = True):
        super().__init__(message)
        self._can_continue = can_continue

    @property
    def can_continue(self) -> bool:
        return self._can_continue


class TaskSequence:
    _ok_str = "Y"
    _fail_str = "N"
    _pending_str = "?"

    def __init__(self, name: str):
        self._name = name
        self._log = logging.getLogger(self._name)
        self._tasks: List[Tuple[str, callable]] = []
        self._results: List[str] = []
        self._reset_results()

    def task(self, name: str):
        tasks = self._tasks

        def wrap_function(func: callable):
            tasks.append((name, func))

            def wrapper():
                return func()

            return wrapper

        return wrap_function

    def _reset_results(self):
        self._results = ["?" for _ in self._tasks]

    def _log_results(self):
        self._log.info("Task status: " + "".join(self._results))

    def run(self):
        self._log.info("Running task sequence")
        self._reset_results()
        self._log_results()

        task_counter = 0
        for task_name, task_func in self._tasks:
            self._log.info(f"-- Running task -> {task_name} --")

            try:
                task_func(self._log)
                self._results[task_counter] = self._ok_str

            except TaskError as e:
                self._log.error(str(e))
                self._results[task_counter] = self._fail_str

                if e.can_continue:
                    self._log.warning(f"Task '{task_name}' failed, but we can continue")

                else:
                    self._log.error(f"Aborting due to failed task '{task_name}'")
                    raise e

            self._log.info("-- End of task --")

            task_counter += 1
            self._log_results()

        self._log.info(f"{self._name} OK")
