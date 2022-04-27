title: Install Grapejuice on Debian 10 and similar
---
## Preamble

❓ If you didn't click on the guide for Debian, but ended up on this page regardless, please do not panic! Debian is a
distribution that is the base for many other distributions in the Linux landscape. This guide is applicable to the
following distributions:

- Debian 10 (buster)
- Debian 11 (bullseye)
- Ubuntu 21.10 (Impish Indri)
- Ubuntu 21.04 (Hirsute Hippo)
- Ubuntu 20.04 (Focal Fossa)
- LMDE 4 (Debbie)
- Linux Mint 20 (Ulyana)
- Zorin OS 16
- Chrome OS

---

❗ This guide assumes that you've properly set up your Debian system.

---

💻 All commands in this guide should be run in a terminal emulator using a regular user account that has access to `su`
or `sudo`. If you are running a fully fledged desktop environment, you can find a terminal emulator in your applications
menu.

## Synchronise the package repositories

We have to make sure that all repositories and locally installed packages are up to date. Run the following two commands
in a terminal:

```sh
sudo apt update
sudo apt upgrade -y
```

## Installing Grapejuice dependencies

Grapejuice requires a set of libraries to be installed and to be run. These dependencies can be installed by running the
following command:

```sh
sudo apt install -y gettext git python3-pip python3-setuptools python3-wheel python3-dev pkg-config mesa-utils libcairo2-dev gtk-update-icon-cache desktop-file-utils xdg-utils libgirepository1.0-dev gir1.2-gtk-3.0 gnutls-bin:i386
```

## Install Grapejuice

First, you have to acquire a copy of the source code. This is easily done by cloning the git repository.

```sh
git clone --depth=1 https://gitlab.com/brinkervii/grapejuice.git /tmp/grapejuice
```

After the git clone command is finished, Grapejuice can be installed.

```sh
cd /tmp/grapejuice
python3 ./install.py
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
