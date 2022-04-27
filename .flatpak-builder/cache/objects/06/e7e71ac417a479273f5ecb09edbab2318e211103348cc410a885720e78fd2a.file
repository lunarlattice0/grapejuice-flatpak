import logging
import os
import sys
from datetime import datetime
from logging import LogRecord
from pathlib import Path
from typing import IO, Union, Optional

from grapejuice_common import paths
from grapejuice_common.util import strip_pii


class GrapejuiceLogFormatter(logging.Formatter):
    def format(self, record: LogRecord) -> str:
        return strip_pii(super().format(record))

    def formatTime(self, record: LogRecord, datefmt: Optional[str] = ...) -> str:
        return strip_pii(super().formatTime(record, datefmt))

    def formatException(self, ei) -> str:
        return strip_pii(super().formatException(ei))

    def formatMessage(self, record: LogRecord) -> str:
        return strip_pii(super().formatMessage(record))

    def formatStack(self, stack_info: str) -> str:
        return strip_pii(super().formatStack(stack_info))


class LoggerConfiguration:
    _output_stream: IO = sys.stderr
    _output_file: Union[Path] = None
    _formatter: logging.Formatter = None
    _environment_key: Union[str, None] = "LOG_LEVEL"
    _log_level_override: Union[str, None] = None

    def __init__(self, app_name: str):
        self._app_name = app_name
        self._formatter = GrapejuiceLogFormatter(f"[%(levelname)s] {app_name}/%(name)s:- %(message)s")

    @property
    def use_output_stream(self):
        return self._output_stream is not None

    @property
    def output_stream(self):
        stream = self._output_stream
        assert stream is not None
        return stream

    @output_stream.setter
    def output_stream(self, stream: IO):
        self._output_stream = stream

    @property
    def use_output_file(self):
        return self._output_file is not None

    @property
    def output_file(self) -> Path:
        return self._output_file

    @output_file.setter
    def output_file(self, path: Path):
        self._output_file = path
        path.parent.mkdir(parents=True, exist_ok=True)

    @property
    def formatter(self) -> logging.Formatter:
        return self._formatter

    @property
    def log_level_str(self) -> str:
        if self._log_level_override is not None:
            return self._log_level_override.upper()

        if self._environment_key is not None and self._environment_key in os.environ:
            return os.environ[self._environment_key].upper()

        return "INFO"

    @property
    def app_name(self):
        return self._app_name


def configure_logging(app_name: str = None, configuration: LoggerConfiguration = None):
    if configuration is None:
        assert isinstance(app_name, str)
        configuration = LoggerConfiguration(app_name)

        datetime_now = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        configuration.output_file = paths.logging_directory() / f"{datetime_now}_{configuration.app_name}.log"

    root_logger = logging.getLogger()

    if configuration.use_output_stream:
        stream_handler = logging.StreamHandler(configuration.output_stream)
        stream_handler.setFormatter(configuration.formatter)
        root_logger.addHandler(stream_handler)

    if configuration.use_output_file:
        file_handler = logging.FileHandler(configuration.output_file, "w+", "UTF-8")
        file_handler.setFormatter(configuration.formatter)
        root_logger.addHandler(file_handler)

    log_level = configuration.log_level_str
    assert hasattr(logging, log_level), \
        f"An invalid log level string was provided: {log_level}"

    root_logger.setLevel(getattr(logging, log_level))

    root_logger.info(f"Log level was set to '{log_level}'")
    if configuration.use_output_file:
        root_logger.info(f"The log file is stored at '{configuration.output_file}'")
