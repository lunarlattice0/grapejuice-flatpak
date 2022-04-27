title: Install Grapejuice on Android
---
## Requirements

- Device must have Android 7 or higher.
- Device must be x86_64, not ARM.

- Please keep in mind that the device does not need to be rooted.

## Please read

This is expected to be extremely laggy and buggy. Your phone most likely wont be able to run Grapejuice. This is all theoretical, and has not been tested yet.

## Installing a VNC client

You will need a VNC client to access your desktop. A VNC client is an an app used to connect to a remote device. Without it, you wont have a GUI view. You will need it to connect to an Ubuntu installation running on your phone. A popular VNC client can be downloaded from the Google Play Store [here](https://play.google.com/store/apps/details?id=com.realvnc.viewer.android&hl=en_US&gl=US)

## Installing Termux

Grapejuice needs a linux environment to run properly. The most popular terminal emulator for Android is Termux, which can be downloaded from F-Droid [here](https://f-droid.org/en/packages/com.termux/)

Please note that even though Termux is available on the Google Play Store, you should still download the version from F-Droid. The Google Play Store version is deprecated and no longer supported.

## Installing Ubuntu within Termux

Termux will not be able to run Grapejuice on its own. You will need to install an operating system within Termux. This guide uses Ubuntu Impish as an example.

Open Termux, update your repos and upgrade your packages so you are 100% up to date:

```sh
pkg update && pkg upgrade -y
```

Install proot-distro. Proot distro is a command line utility allowing for easy installation of linux distros in Termux :

```sh
pkg install proot-distro
```

Install Ubuntu. Use Proot distro to install Ubuntu Impish:

```sh
proot-distro install ubuntu
```

Log into your fresh Ubuntu installation:

```sh
proot-distro login ubuntu
```

Update repos and upgrade packages. You need to be up to date:

```sh
apt update && apt upgrade -y
```

You will need a desktop environment, this guide will be using XFCE. Indtall XFCE with:

```sh
apt install xfce4
```

Install a VNC server. A VNC server will allow you to connect to your Ubuntu installation using a VNC client.

```sh
apt install tightvncserver
```

## Configuring Tight VNC

Type in the following command to start the VNC server.

```sh
vncserver
```

The first time you start the VNC server, it will ask you to create a password. Create one. then run the following to kill the server, replacing :1 with the port yours is running on:

```sh
vncserver -kill :1
```

Using your favorite text editor, open your ~/.xstartup file. This file lists the apps that are ran when the VNC server starts. We will be using nano for this guide.

```sh
nano ~/.vnc/xstartup
```

Add the following to the end of that file, then save. This starts the XFCE desktop environment whenever the VNC server has started:

```sh
startxfce4 &
```

## Starting your Desktop

First, login to your Ubuntu installation, and start the VNC server like before:

```sh
vncserver
```

Locate where it says "New 'X' desktop is localhost:#" '#' is the port being used. Remember this number for later use.

Open your VNC-Viewer app.

Tap the "+" sign to create a new session.

In the Address box, type "127.0.0.1:#" Remember that '#' is your port number from earlier.

Add any name you want.

Finally, hit "create", then tap on the new entry to connect. You should now be seeing the default XFCE desktop!

## Installing Grapejuice

Make sure you're logged into Ubuntu!

Optionally, you can follow the Debian 10 installation guide [here](Debian-10-and-similar). However, please keep in mind that the use of 'sudo'is omitted.



Update your repos and upgrade your packages. This ensures you are fully up to date.

```sh
apt update && apt upgrade -y
```

Install Curl. Curl will be used to install Grapejuice's keyring.

```sh
apt install -y curl
```

Download Grapejuice's keyring using Curl.

```sh
curl https://gitlab.com/brinkervii/grapejuice/-/raw/master/ci_scripts/signing_keys/public_key.gpg | sudo tee /usr/share/keyrings/grapejuice-archive-keyring.gpg > /dev/null
```

Add the Grapejuice repo.

```sh
tee /etc/apt/sources.list.d/grapejuice.list <<< 'deb [signed-by=/usr/share/keyrings/grapejuice-archive-keyring.gpg] https://brinkervii.gitlab.io/grapejuice/repositories/debian/ universal main' > /dev/null
```

Once again, update your repos. Since you added the Grapejuice repo, you need to update your repos for it to take effect.

```sh
apt update
```

Finally, install Grapejuice using the apt package manager.

```sh
apt install -y grapejuice
```

Once Grapejuice has been installed, you can proceed to the section below.

## 🍷 Installing Wine

**You will need to install Wine before you can use Grapejuice**.
It's recommended to install the patched wine version. Not installing it can lead to crashes, or the in-game cursor not moving properly.
See [this guide](../Guides/Installing-Wine) for instructions on installing the patched Wine build.

## 🤔 Still having issues?

Even after installing Grapejuice and the patched wine version above, you may still have issues (examples: bad performance, Roblox not opening, etc). Usually, you can find the solutions here: [Troubleshooting page](../Troubleshooting)
