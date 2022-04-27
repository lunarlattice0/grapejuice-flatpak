import logging
from typing import TypeVar

LoggedFunction = TypeVar("LoggedFunction")


def log_function(func: LoggedFunction) -> LoggedFunction:
    log = logging.getLogger(f"log_function/{func.__name__}")

    def wrapper(*args, **kwargs):
        log.debug(f"Calling function :: {repr(args)} :: {repr(kwargs)}")

        result = func(*args, **kwargs)

        if isinstance(result, tuple):
            result_list = list(result)

        else:
            result_list = [result]

        log.debug(f"Function result :: {repr(result_list)}")

        return result

    return wrapper


def log_on_call(message: str):
    def wrap_function(func: callable):
        log = logging.getLogger(f"log_on_call/{func.__name__}")

        def wrapper(*args, **kwargs):
            log.info(message)
            return func(*args, **kwargs)

        return wrapper

    return wrap_function
