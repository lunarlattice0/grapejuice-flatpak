from gettext import gettext as _

def yes_no_dialog(title: str = _("Untitled Dialog"), message=_("This is a message")):
    from gi.repository import Gtk

    # Prepare message, it can be no more than 80 columns wide
    idx = 0
    line_limit = 80
    lines = [""]
    words = message.split(" ")

    while len(words) > 0:
        word = words.pop(0)

        if len(lines[idx]) > line_limit:
            idx += 1
            lines.append(word + " ")

        else:
            lines[idx] += word + " "

    message = "\n".join(list(map(str.rstrip, lines)))

    # Create dialog class, duh
    class DialogClass(Gtk.Dialog):
        def __init__(self):
            Gtk.Dialog.__init__(self, title=title, flags=0)

            self.add_buttons(
                Gtk.STOCK_NO, Gtk.ResponseType.CANCEL,
                Gtk.STOCK_YES, Gtk.ResponseType.OK
            )
            self.set_resizable(False)

            self.set_default_size(150, 100)

            label = Gtk.Label(label=message)
            label.set_margin_top(10)
            label.set_margin_right(10)
            label.set_margin_bottom(10)
            label.set_margin_left(10)

            box = self.get_content_area()
            box.add(label)

            self.show_all()

    # Run the dialog
    dlg = DialogClass()
    response = dlg.run()
    dlg.destroy()

    # Process the response
    return response == Gtk.ResponseType.OK
