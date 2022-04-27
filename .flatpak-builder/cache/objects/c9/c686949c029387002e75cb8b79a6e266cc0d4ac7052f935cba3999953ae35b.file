title: Install Grapejuice on Void Linux
---
## Installing Grapejuice dependencies

Grapejuice requires a set of libraries to be installed and to be run. These dependencies can be installed by running the
following command:

```sh
sudo xbps-install -S gettext python3 python3-pip python3-wheel python3-setuptools python3-cairo python3-gobject cairo-devel desktop-file-utils xdg-user-dirs xdg-utils gtk-update-icon-cache shared-mime-info pkg-config gobject-introspection
```

## Installing Grapejuice

First, you have to aquire a copy of the source code. This is easily done by cloning the git repository.

```sh
git clone --depth=1 https://gitlab.com/brinkervii/grapejuice.git /tmp/grapejuice
```

After the git clone command is finished, Grapejuice can be installed.

```sh
cd /tmp/grapejuice
./install.py
```

## Enabling 32-bit support

```sh
sudo xbps-install void-repo-multilib
```

## Installing Audio dependencies

```sh
sudo xbps-install -S libpulseaudio-32bit
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.

Wine will also require dependencies to make Roblox function correctly.

```sh
sudo xbps-install -S freetype-32bit gnutls-32bit libgcc-32bit libXi-32bit
```

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
