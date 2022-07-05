#!/bin/bash
cd $PWD/..
flatpak-builder build-dir/ net.brinkervii.grapejuice.yml
flatpak-builder --user --install --force-clean build-dir net.brinkervii.grapejuice.yml
echo "Done building"
