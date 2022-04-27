#!/bin/bash
flatpak-builder build-dir/ com.gitlab.brinkervii.grapejuice.yml
flatpak-builder --user --install --force-clean build-dir com.gitlab.brinkervii.grapejuice.yml
echo "Done building"
