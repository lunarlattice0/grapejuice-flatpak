#!/bin/bash
flatpak remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak install grapejuiceTest com.gitlab.brinkervii.grapejuice
