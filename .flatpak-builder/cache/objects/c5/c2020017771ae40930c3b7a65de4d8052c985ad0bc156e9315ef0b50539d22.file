import sys

from grapejuice_common import paths

did_require_version = False


def gtk_boot(main_function, *args, gtk_main=True, **kwargs):
    global did_require_version

    assert callable(main_function)
    sys.argv[0] = "Grapejuice"

    if not did_require_version:
        import gi
        gi.require_version("Gtk", "3.0")

        did_require_version = True

    from gi.repository import Gtk

    from grapejuice_common.gtk.gtk_styling import load_style_from_path
    load_style_from_path(paths.global_css())

    main_function(*args, **kwargs)

    if gtk_main:
        Gtk.main()


def dialog(dialog_text):
    from gi.repository import Gtk

    gtk_dialog = Gtk.MessageDialog(
        message_type=Gtk.MessageType.INFO,
        buttons=Gtk.ButtonsType.OK,
        text=dialog_text
    )

    gtk_dialog.run()
    gtk_dialog.destroy()


def set_gtk_widgets_visibility(widgets, visible):
    for w in widgets:
        if visible:
            w.show_all()

        else:
            w.hide()


def set_label_text_and_hide_if_no_text(label, text):
    if text.strip():
        label.set_text(text)
        label.show()

    else:
        label.set_text("")
        label.hide()


def set_style_class_conditionally(widgets, style_class, condition):
    for w in widgets:
        style_context = w.get_style_context()
        method = style_context.add_class if condition else style_context.remove_class
        method(style_class)


def set_all_margins(widget, margin):
    for side in ("top", "end", "bottom", "start"):
        method = getattr(widget, f"set_margin_{side}")
        method(margin)


def set_vertical_margins(widget, margin):
    for side in ("top", "bottom"):
        method = getattr(widget, f"set_margin_{side}")
        method(margin)


def set_horizontal_margins(widget, margin):
    for side in ("start", "end"):
        method = getattr(widget, f"set_margin_{side}")
        method(margin)
