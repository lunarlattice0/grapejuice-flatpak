#!/bin/bash
flatpak-builder --gpg-sign=628330EA01133645E2E4189C6CC7E205088B5BA4 --repo=GJTestRepo --force-clean build-dir com.gitlab.brinkervii.grapejuice.yml
