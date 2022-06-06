#!/bin/bash
flatpak --user remote-add --no-gpg-verify grapejuiceTest GJTestRepo
flatpak --user install grapejuiceTest com.gitlab.brinkervii.grapejuice
