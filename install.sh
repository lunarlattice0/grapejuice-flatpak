#!/bin/bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak --user install grapejuiceTest com.gitlab.brinkervii.grapejuice
