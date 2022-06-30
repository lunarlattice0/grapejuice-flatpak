#!/bin/bash
flatpak remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak install flathub org.freedesktop.Platform.Compat.i386 org.freedesktop.Platform.GL32.default
flatpak install grapejuiceTest com.gitlab.brinkervii.grapejuice
