title: Install Grapejuice on Fedora
---
## Preamble

⚠ These instructions have only been tested on Fedora Workstation 32!

---

🖥 If you are using the Wayland display server, you might not get any graphical output from Roblox. In that case you
should try running Roblox Studio using an Xorg session.

## Installing Grapejuice dependencies

Grapejuice requires a set of libraries to be installed and to be run. These dependencies can be installed by running the
following command:

```sh
sudo dnf install gettext git python3-devel python3-pip cairo-devel gobject-introspection-devel cairo-gobject-devel make xdg-utils glx-utils
```

## Installing Grapejuice

First, you have to aquire a copy of the source code. This is easily done by cloning the git repository.

```sh
git clone --depth=1 https://gitlab.com/brinkervii/grapejuice.git
```

After the git clone command is finished, Grapejuice can be installed.

```sh
cd grapejuice
./install.py
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.
**Make sure you have installed Wine with `dnf` first, otherwise Grapejuice might tell you the Wine binary does not exist**.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
