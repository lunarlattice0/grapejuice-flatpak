import os


def os_release():
    search_paths = [
        "/etc/os-release",
        "/usr/lib/os-release"
    ]

    for path in search_paths:
        if os.path.exists(path):
            with open(path, "r", encoding="UTF-8") as fp:
                return fp.read()

    raise RuntimeError("Could not open os-release")


def is_debian():
    return "ID=debian" in os_release()


def is_arch():
    return "ID=arch" in os_release()
