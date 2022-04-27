title: Install Grapejuice on Gentoo Linux and similar distributions
---
## Preamble

:question: If you didn't click on the guide for Gentoo Linux, but ended up on this page regardless, please do not panic!
Gentoo Linux is a distribution that is the base for other distributions in the Linux landscape. This guide is applicable
to the following distributions:

- Gentoo Linux
- Calculate Linux
- Funtoo
- Sabayon Linux

---

:computer: Grapejuice assumes your desktop is configured properly. Even though Gentoo Linux to some, is all about minimalism, it is recommended that you run your desktop session using a display manager.

---


## Enabling 32-bit support

Even though Roblox Studio runs in 64-bit mode, 32-bit libraries are still required for some parts of the program. This
is due to backwards compatibility in the Windows operating system.

Enabling `multilib` support in Gentoo Linux during installation isn't trivial, as it's usually enabled using profiles while installing your system. If that isn't the case, you should change to a `multilib` enabled profile to continue with this guide. Refer to [**Profile**](https://wiki.gentoo.org/wiki/Profile_(Portage) "`Profile`") on the Gentoo Wiki to change your profile, as just using eselect to change your profile and updating your `@world` set can render your installation unusable.

## Synchronize the package database

Before installing anything, you should always synchronize the package database in order to prevent strange
package-not-found errors.

```sh
emerge --sync
```
Remember to not sync more than once a day, or you could get temporarily banned from the [**rsync**](https://wiki.gentoo.org/wiki/Rsync "`rsync`") mirror.

## Installing dependencies for audio

PulseAudio:
```sh
# /etc/portage/make.conf
USE='pulseaudio'
```
Then:
```sh
emerge --ask --changed-use --deep @world
```
With the `pulseaudio` USE flag not only are we building PulseAudio, but we'll add PulseAudio support to some packages. If you want to prevent certain packages from using the `pulseaudio` USE flag, refer to [**package.use**](https://wiki.gentoo.org/wiki//etc/portage/package.use "package.use") on the Gentoo Wiki.
If that still doesn't do the trick, you may still be missing the 32-bit packages from PulseAudio.
Regarding `media-libs/libpulse`, the package by default is `masked`, meaning that it's going to be removed from the repositories soon, it's advised to not build the package and just build `pulseaudio` with the `ABI_X86_32` USE flag.

### PipeWire:

Enable the `pipewire-pulse` service.

**SystemD**:

```sh
systemctl --user enable pipewire-pulse
```
Don't forget to disable the `pulseaudio` service before enabling the `pipewire-pulse` service.
```sh
systemctl --user disable --now pulseaudio.socket pulseaudio.service
```

**OpenRC**:

```sh
sudo cp -r /usr/share/pipewire/ /etc/
```
Note: On XDG-compliant desktops no more action is required, but if you don't have one, make sure to call `gentoo pipewire-launcher` in your scripts.

## Installing dependencies for networking

Install `gnutls` and its x86_32 variant with the following command:

```sh
 emerge --ask net-libs/gnutls
USE="abi_x86_32" emerge --ask net-libs/gnutls
```
The `ABI_X86_32` USE flag is used to build the package with 32-bit support.
Another way, and better way is to use `package.use` instead of manually adding the `ABI_X86_32` USE flag every time you update your system, refer to the Gentoo Wiki if you don't know how.

## Installing dependencies for Grapejuice
Grapejuice requires several native dependencies for the user interface, plus you'll need git for cloning the source repository. Without these dependencies, Grapejuice will not function properly. The full list of dependencies is:

- sys-devel/gettext
- dev-vcs/git
- dev-python/pip
- x11-libs/cairo
- x11-libs/gtk+
- dev-libs/gobject-introspection
- dev-util/desktop-file-utils
- x11-misc/xdg-utils
- x11-misc/xdg-user-dirs
- dev-util/gtk-update-icon-cache
- x11-misc/shared-mime-info
- x11-apps/mesa-progs

If you want to install them all at once, you can make use of this handy command:
```sh
sudo emerge --ask sys-devel/gettext dev-vcs/git dev-python/pip x11-libs/cairo x11-libs/gtk+ dev-libs/gobject-introspection dev-util/desktop-file-utils x11-misc/xdg-utils x11-misc/xdg-user-dirs dev-util/gtk-update-icon-cache x11-misc/shared-mime-info x11-apps/mesa-progs
```

## Installing Grapejuice

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
**Make sure you have installed Wine with `emerge` first, otherwise Grapejuice might tell you the Wine binary does not exist**.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
