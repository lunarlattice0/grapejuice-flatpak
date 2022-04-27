import logging
from abc import ABC, abstractmethod

LOG = logging.getLogger(__name__)


class IDBusConnection(ABC):
    @property
    def connected(self):
        return False

    @abstractmethod
    def launch_studio(self, prefix_id: str):
        pass

    @abstractmethod
    def play_game(self, prefix_id: str, uri: str):
        pass

    @abstractmethod
    def launch_app(self, prefix_id: str):
        pass

    @abstractmethod
    def edit_local_game(self, prefix_id: str, place_path: str):
        pass

    @abstractmethod
    def edit_cloud_game(self, prefix_id: str, uri):
        pass

    @abstractmethod
    def version(self):
        pass

    @abstractmethod
    def extract_fast_flags(self):
        pass

    @abstractmethod
    def install_roblox(self, prefix_id: str):
        pass
