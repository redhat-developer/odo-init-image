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
    DWN=$1
    TGT=$2
    NM=$3
    rm -rf $TGT/*
    pushd $TGT
    curl -sL $DWN | tar xzv
    mv -f $NM/* $TGT
    rm -rf $NM
    popd
}

update_dumb_init() {
    echo "Downloading dump init src"
    DUMBINIT_TARGET="${REQUIREMENTS_DIR}/dumb-init";
    DUMBINIT_DOWNLOAD="https://github.com/Yelp/dumb-init/archive/${VDUMBINIT_VERSION}.tar.gz";
    DUMBINIT_NM="dumb-init-${DUMBINIT_VERSION}"
    download_tar $DUMBINIT_DOWNLOAD $DUMBINIT_TARGET $DUMBINIT_NM
}

update_supervisord() {
    echo "Downloading supervisord src"
    SUPERVISORD_MOD_NAME="github.com/ochinchina/supervisord"
    SUPERVISORD_TARGET="${REQUIREMENTS_DIR}/supervisord";
    SUPERVISORD_DOWNLOAD="https://${SUPERVISORD_MOD_NAME}/archive/${VSUPERVISORD_VERSION}.tar.gz"
    SUPERVISORD_NM="supervisord-${SUPERVISORD_VERSION}"
    download_tar $SUPERVISORD_DOWNLOAD $SUPERVISORD_TARGET $SUPERVISORD_NM
    echo "Vendoring supervisord"
    pushd $SUPERVISORD_TARGET
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
