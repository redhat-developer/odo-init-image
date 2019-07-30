#!/bin/bash

set +e

# Variables for version updates
DUMBINIT_VERSION="v1.2.2"
SUPERVISORD_VERSION="v0.5"

REQUIREMENTS_DIR="$(pwd)/requirements"

update_fix_permissions() {
    echo "Downloading fix permissions script"
    FIX_PERMISSIONS_SCRIPT="${REQUIREMENTS_DIR}/fix-permissions";
    curl -o $FIX_PERMISSIONS_SCRIPT https://raw.githubusercontent.com/sclorg/s2i-base-container/master/core/root/usr/bin/fix-permissions;
    chmod +x $FIX_PERMISSIONS_SCRIPT;
}

update_dumb_init() {
    echo "Downloading dump init src"
    DUMBINIT_TARGET="${REQUIREMENTS_DIR}/dumb-init/dumb-init-src.tar.gz";
    DUMBINIT_DOWNLOAD="https://github.com/Yelp/dumb-init/archive/${DUMBINIT_VERSION}.tar.gz"
    curl -sLo $DUMBINIT_TARGET $DUMBINIT_DOWNLOAD
}

update_supervisord() {
    echo "Downloading supervisord src"
    SUPERVISORD_TARGET="${REQUIREMENTS_DIR}/supervisord/supervisord-src.tar.gz";
    SUPERVISORD_DOWNLOAD="https://github.com/ochinchina/supervisord/archive/${SUPERVISORD_VERSION}.tar.gz"
    curl -sLo $SUPERVISORD_TARGET $SUPERVISORD_DOWNLOAD
}

update_fix_permissions
update_dumb_init
update_supervisord