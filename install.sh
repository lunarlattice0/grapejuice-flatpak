#!/bin/bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.freedesktop.Platform/x86_64/21.08
#org.freedesktop.Platform.Compat.i386/x86_64/21.08 org.freedesktop.Platform.GL32.default/x86_64/21.08
flatpak --user remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak --user install grapejuiceTest com.gitlab.brinkervii.grapejuice
