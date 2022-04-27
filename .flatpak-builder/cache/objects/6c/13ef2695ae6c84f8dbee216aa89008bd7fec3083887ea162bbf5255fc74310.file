title: Install Grapejuice on Ubuntu 18.04 and similar distributions
---
## Preamble

❓ If you didn't click on the guide for Ubuntu 18.04, but ended up on this page regardless, please do not panic! Ubuntu
18.04 is a distribution that is similar enough to other distributions in the Linux landscape. This guide is applicable
to the following distributions:

- Ubuntu 18.04 (Bionic Beaver)
- Zorin OS 15.2
- Linux Mint 19.3 (Tricia)

---

💻 All commands in this guide should be run in a terminal emulator using a regular user account that has access to `su`
or `sudo`. If you are running a fully fledged desktop environment, you can find a terminal emulator in your applications
menu.

---

⭐ Some commands do not produce any output. This usually means that the command ran successfully, so don't worry!

## Enabling 32-bit support

Even though Roblox Studio runs in 64-bit mode, 32-bit libraries are still required for some parts of the program. This
is due to backwards compatibility in the Windows operating system. Run the following command in a terminal:

```sh
sudo dpkg --add-architecture i386
```

## Install FAudio

FAudio audio libraries are not supplied by the Ubuntu repositories, so we will have to install these manually.

**01:** Download the FAudio packages to a temporary location

```sh
wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/i386/libfaudio0_19.07-0~bionic_i386.deb -O /tmp/faudio_i386.deb
wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/amd64/libfaudio0_19.07-0~bionic_amd64.deb -O /tmp/faudio_amd64.deb
```

**02:** Install the FAudio packages that you just downloaded

```sh
sudo apt install -y /tmp/faudio_i386.deb
sudo apt install -y /tmp/faudio_amd64.deb
```

## Add the 'deadsnakes' repository

Grapejuice requires at least Python3.7. During the dependency installation we are going to do this. However, we need a
repository that provides Python3.7 since Ubuntu 18.04 and similar distributions only provide up to Python3.6. Run the
following commands and press the enter key when prompted.

```sh
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
```

## Synchronise the package repositories

We have to make sure that all repositories and locally installed packages are up to date. Run the following two commands
in a terminal:

```sh
sudo apt update
sudo apt upgrade -y
```

## Installing curl

The `curl` utility is required for the following step. Run the following command in a terminal:

```sh
sudo apt install -y curl
```

## Downloading Grapejuice's keyring

In order to ensure that the Grapejuice package hasn't been tampered with, you need Grapejuice's keyring.
To download the keyring, run the following commands in a terminal:

```sh
curl https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg > /dev/null
```

## Adding the Grapejuice repository

The Grapejuice repository needs to be added to your system to get the Grapejuice package.
Run the following command in a terminal:

```sh
sudo tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main' > /dev/null
```

## Installing Grapejuice

Since a new repository was added, you need to update package information on your system so apt can find Grapejuice.
Run the following commands in a terminal:

```sh
sudo apt update
sudo apt install -y grapejuice
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
