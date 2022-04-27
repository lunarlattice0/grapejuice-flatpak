from grapejuice import __version__ as grapejuice_version
from grapejuice_common import paths
from grapejuice_common.gtk.gtk_base import GtkBase


class AboutWindow(GtkBase):
    def __init__(self):
        super().__init__(
            glade_path=paths.about_glade(),
            handler_instance=self
        )

        self.widgets.grapejuice_about.set_version(grapejuice_version)

    def close_about(self, *_):
        self.widgets.grapejuice_about.destroy()

    def run(self):
        self.widgets.grapejuice_about.run()
