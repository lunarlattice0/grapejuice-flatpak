title: Install Grapejuice on FreeBSD
---
## Preamble

:package: This setup guide assumes that your account can use the `sudo` command.

## Staying up-to-date

Before installing anything, you should always stay up to date in order to prevent strange
package-not-found errors.

```sh
sudo pkg upgrade
```

## Installing dependencies for Grapejuice
Grapejuice requires several native dependencies for the user interface, plus you'll need git for cloning the source repository. Without these dependencies, Grapejuice will not function properly. The full list of dependencies is:

- python38
- gettext
- git
- py38-pip
- cairo
- gtk3
- gobject-introspection
- desktop-file-utils
- xdg-utils
- xdg-user-dirs
- gtk-update-icon-cache
- shared-mime-info

If you want to install them all at once, you can make use of this handy command:
```sh
sudo pkg install gettext git py38-pip cairo gtk3 gobject-introspection desktop-file-utils xdg-utils xdg-user-dirs gtk-update-icon-cache shared-mime-info python38
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
It's recommended to compile Wine from ports with patches using poudriere. Not patching & compiling it can lead to the in-game cursor not moving properly.

## 🤔 Still having issues?

Even after installing Grapejuice and patching Wine, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
