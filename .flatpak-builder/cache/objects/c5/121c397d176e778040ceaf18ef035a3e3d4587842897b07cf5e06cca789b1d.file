title: Compiling Wine TKG
---

## About compiling Wine

Compiling Wine is generally for people who want extra control over their build, or people who do not trust the precompiled versions. If you just want to quickly get Roblox up and running, you can [install a precompiled version instead](Installing-Wine).

This guide will be using a [customized version of Wine TKG](https://github.com/TheComputerGuy96/wine-tkg-git).

## Downloading Wine TKG

First, clone the repository and go to it with the below commands:

```sh
git clone --depth=1 https://github.com/TheComputerGuy96/wine-tkg-git.git
cd wine-tkg-git/wine-tkg-git
```

## Installing dependencies

See [this page](https://wiki.winehq.org/Building_Wine#Satisfying_Build_Dependencies) for a list of required
dependencies. Make sure to install the dependencies marked as "Generally necessary" and "Needed for many applications".

## Compiling Wine TKG

Consider installing [ccache](https://ccache.dev/) to speed up compilation when you compile Wine TKG multiple times.

To start compiling Wine TKG, run the below command:

```sh
./non-makepkg-build.sh
```

This command may take a while to finish.

## Configuring Grapejuice

Find the path of the Wine home with `realpath non-makepkg-builds/wine-tkg-*`.

Edit `~/.config/brinkervii/grapejuice/user_settings.json` and replace all occurances of `"wine_home": "/usr",`
with `"wine_home": "[Insert path to the Wine home here]",`.

Afterwards, open Grapejuice, go to each wineprefix, select "Wine Apps", and click "Kill Wineserver".
This will close any applications currently running in that wineprefix.

## Troubleshooting

If Studio doesn't open, edit `customization.cfg` and replace

```ini
_childwindow_fix="true"
```

with

```
_childwindow_fix="false"
```

and repeat the steps in the "Compiling Wine TKG" section. Keep in mind that you won't be able to have
Studio use Vulkan for rendering with this solution.
