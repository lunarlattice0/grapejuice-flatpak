from gi.repository import Gtk


class GrapeListBoxRowWithIcon(Gtk.ListBoxRow):
    box: Gtk.Box

    def __init__(self, *args, icon_name: str = "security-low", **kwargs):
        super().__init__(*args, **kwargs)

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        box.set_margin_top(5)
        box.set_margin_bottom(5)
        box.set_margin_start(10)
        box.set_margin_end(10)

        image = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.BUTTON)
        image.set_margin_right(10)
        box.add(image)

        self.box = box
        self.add(box)
