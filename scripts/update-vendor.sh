#!/bin/bash

set +eux

# Variables for version updates
DUMBINIT_VERSION="1.2.2"
SUPERVISORD_VERSION="0.5"
##
VDUMBINIT_VERSION="v${DUMBINIT_VERSION}"
VSUPERVISORD_VERSION="v${SUPERVISORD_VERSION}"
REQUIREMENTS_DIR="$(pwd)/vendor"

update_fix_permissions() {
    echo "Downloading fix permissions script"
    FIX_PERMISSIONS_SCRIPT="${REQUIREMENTS_DIR}/fix-permissions";
    curl -o $FIX_PERMISSIONS_SCRIPT https://raw.githubusercontent.com/sclorg/s2i-base-container/master/core/root/usr/bin/fix-permissions;
    chmod +x $FIX_PERMISSIONS_SCRIPT;
}

download_tar() {
    DOWNLOAD_URL=$1
    DOWNLOAD_TO=$2
    TARBALL_NAME=$3
    rm -rf $DOWNLOAD_TO/*
    pushd $DOWNLOAD_TO
    curl -sL $DOWNLOAD_URL | tar xzv
    mv -f $TARBALL_NAME/* $DOWNLOAD_TO
    rm -rf $TARBALL_NAME
    popd
}

update_dumb_init() {
    echo "Downloading dump init src"
    DUMBINIT_DOWNLOAD_TARGET="${REQUIREMENTS_DIR}/dumb-init";
    DUMBINIT_DOWNLOAD="https://github.com/Yelp/dumb-init/archive/${VDUMBINIT_VERSION}.tar.gz";
    DUMBINIT_TARBALL_NAME="dumb-init-${DUMBINIT_VERSION}"
    download_tar $DUMBINIT_DOWNLOAD $DUMBINIT_DOWNLOAD_TARGET $DUMBINIT_TARBALL_NAME
}

update_supervisord() {
    echo "Downloading supervisord src"
    SUPERVISORD_MOD_NAME="github.com/ochinchina/supervisord"
    SUPERVISORD_DOWNLOAD_TARGET="${REQUIREMENTS_DIR}/supervisord";
    SUPERVISORD_DOWNLOAD="https://${SUPERVISORD_MOD_NAME}/archive/${VSUPERVISORD_VERSION}.tar.gz"
    SUPERVISORD_TARBALL_NAME="supervisord-${SUPERVISORD_VERSION}"
    download_tar $SUPERVISORD_DOWNLOAD $SUPERVISORD_DOWNLOAD_TARGET $SUPERVISORD_TARBALL_NAEM
    echo "Vendoring supervisord"
    pushd $SUPERVISORD_DOWNLOAD_TARGET
    if [ ! -f "./go.mod" ]; then
        go mod init $SUPERVISORD_MOD_NAME
        go mod vendor
        rm -rf go.mod go.sum
    fi
    popd
}

# MAIN
update_fix_permissions
update_dumb_init
update_supervisord
