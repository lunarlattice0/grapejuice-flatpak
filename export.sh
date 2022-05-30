#!/bin/bash
flatpak-builder --gpg-sign=B39B2B0F25BB843D5EB315B8A80327A9D7225985 --repo=GJTestRepo --force-clean build-dir com.gitlab.brinkervii.grapejuice.yml
