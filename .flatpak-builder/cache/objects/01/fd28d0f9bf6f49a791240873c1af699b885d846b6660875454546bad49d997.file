#!/usr/bin/bash

SCRIPT=$(readlink -f "$0")
HERE=$(dirname "$SCRIPT")
PROJECT_ROOT=$(dirname "$HERE")

pushd "$HERE/signing_keys" || exit
openssl aes-256-cbc -d -pbkdf2 -in private_key.gpg.enc -out private_key.gpg -pass pass:$PACKAGE_SIGNING_KEY_KEY
gpg2 --import public_key.gpg && gpg2 --import private_key.gpg
expect -c "spawn gpg2 --edit-key 54F9A23FAD1F5ACACE3D313E8C215E86647988DA trust quit; send \"5\ry\r\"; expect eof"
popd || exit

REPOSITORIES=$PROJECT_ROOT/public/repositories
DEBIAN_REPOSITORY=$REPOSITORIES/debian
DEBIAN_DISTRIBUTION=universal

pushd "$PROJECT_ROOT" || exit
mkdir -p "$DEBIAN_REPOSITORY/conf" || exit
touch "$DEBIAN_REPOSITORY/conf/"{option,distributions}
echo "Codename: $DEBIAN_DISTRIBUTION" >>"$DEBIAN_REPOSITORY/conf/distributions"
echo 'Components: main' >>"$DEBIAN_REPOSITORY/conf/distributions"
echo 'Architectures: amd64 i386' >>"$DEBIAN_REPOSITORY/conf/distributions"
echo 'SignWith: 8C215E86647988DA' >>"$DEBIAN_REPOSITORY/conf/distributions"

reprepro -V -b "$DEBIAN_REPOSITORY" includedeb $DEBIAN_DISTRIBUTION artifacts/debian_package/*.deb

popd || exit
