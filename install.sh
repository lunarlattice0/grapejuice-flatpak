#!/bin/bash
flatpak remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak install flathub org.freedesktop.Platform.Compat.i386/x86_64/21.08 org.freedesktop.Platform.GL32.default/x86_64/21.08
flatpak install grapejuiceTest com.gitlab.brinkervii.grapejuice
