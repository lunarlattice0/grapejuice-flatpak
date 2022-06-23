# grapejuice-flatpak
*grapejuice-flatpak* is a community-built Flatpak version of *[grapejuice](https://gitlab.com/brinkervii/grapejuice)*, a utility program to easily run and manage both Roblox Player and Studio on Linux originally developed by [brinkervii](https://gitlab.com/brinkervii) on GitLab.

Please note, as this version is still a work-in-progress, proceed with caution and at your own risk.

For more information, please read the [disclaimers](https://github.com/FazlyMR/grapejuice-flatpak/edit/master/README.md#disclaimer) here.
## Installation
*grapejuice-flatpak* can be installed in two ways: through a simplified included bash script, or manually. 

But first, please add the Flathub repository and install the following Flatpak dependencies with the following commands
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.freedesktop.Platform/x86_64/21.08
flatpak install app/org.winehq.Wine/x86_64/stable-21.08
```
Then, clone this repository and enter the folder in which it is then stored with the following commands
```bash
git clone https://github.com/Thelolguy1/grapejuice-flatpak.git
cd grapejuice-flatpak
```

## Simplified installation
Run ./install.sh to install, or ./uninstall.sh to uninstall.

## Manual installation

### Step 1
Add the GJTestRepo Flatpak repository
```bash
flatpak --user remote-add --no-gpg-verify grapejuiceTest GJTestRepo
```
### Step 2
Finally install the *grapejuice-flatpak* Flatpak
```bash
flatpak --user install grapejuiceTest com.gitlab.brinkervii.grapejuice
```
_If you want a global (system-wide) installation, please remove the '--user' flag from steps 1 and 2._

## Build It Yourself
To build the flatpak by yourself, run
1. build.sh (generates build-dir)
2. run_bash.sh and verify that the container works.
3. export.sh (generates GJTestRepo)

## Disclaimer
The wine builds stored in wine_builds are repackaged from community-sourced builds, as retrieved from (https://brinkervii.gitlab.io/grapejuice/docs/Guides/Installing-Wine.html). I, Thelolguy1, am not liable for any damages caused by the usage of the builds.

## Honorable Mentions
Thank you to Infinitybeond1, LithRakoon, Soikr, z-ffqq, and others for testing and development.
