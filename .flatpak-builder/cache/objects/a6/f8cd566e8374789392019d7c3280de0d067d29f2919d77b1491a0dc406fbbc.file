title: Install Grapejuice on Arch Linux and similar distributions
---
## Preamble

:question: If you didn't click on the guide for Arch Linux, but ended up on this page regardless, please do not panic!
Arch Linux is a distribution that is the base for other distributions in the Linux landscape. This guide is applicable
to the following distributions:

- Arch Linux
- Manjaro Linux
- SteamOS 3.0

---

:computer: Grapejuice assumes your desktop is configured properly.

---

:package: This setup guide assumes you have AUR support enabled on your system, which implies that the `base-devel`
package is installed and that your account can use the `sudo` command.

## SteamOS 3.0
 
Before you begin, if you are using SteamOS 3.0, you will need to run `sudo steamos-readonly disable` once you have done that, you may continue.

## Enabling 32-bit support

Even though Roblox Studio runs in 64-bit mode, 32-bit libraries are still required for some parts of the program. This
is due to backwards compatibility in the Windows operating system.

You enable 32-bit support by editing `/etc/pacman.conf` with your favourite editor, where you uncomment the multilib
repository. Note that you have to be root in order to edit the file. The resulting file should contain the following:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

## Synchronize the package database

Before installing anything, you should always synchronize the package database in order to prevent strange
package-not-found errors.

```sh
sudo pacman -Syu
```

## Installing dependencies for audio

Install `libpulse` and `lib32-libpulse` with `sudo pacman -S libpulse lib32-libpulse`.

In addition, if you're using Pipewire (check if the `pipewire` process is running), follow
[these instructions](https://wiki.archlinux.org/title/PipeWire#PulseAudio_clients).

## Installing dependencies for networking

Install `gnutls` and `lib32-gnutls` with the following command:

```sh
sudo pacman -S gnutls lib32-gnutls
```

## Installing dependencies for Grapejuice
Grapejuice requires several native dependencies for the user interface, plus you'll need git for cloning the source repository. Without these dependencies, Grapejuice will not function properly. The full list of dependencies is:

- git
- python-pip
- cairo
- gtk3
- gobject-introspection
- desktop-file-utils
- xdg-utils
- xdg-user-dirs
- gtk-update-icon-cache
- shared-mime-info
- mesa-utils
- wine

If you want to install them all at once, you can make use of this handy command:
```sh
pacman -S git python-pip cairo gtk3 gobject-introspection desktop-file-utils xdg-utils xdg-user-dirs gtk-update-icon-cache shared-mime-info mesa-utils
```

## Installing Grapejuice

First, you have to acquire a copy of the source code. This is easily done by cloning the git repository.

```sh
git clone --depth=1 https://gitlab.com/brinkervii/grapejuice.git /tmp/grapejuice
```

After the git clone command is finished, Grapejuice can be installed.

```sh
cd /tmp/grapejuice
./install.py
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
