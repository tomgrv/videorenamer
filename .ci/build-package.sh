#!/bin/bash
# Copyright (c) 2000-2021 Tomgrv All rights reserved.

# load toolchain
source /toolkit/pkgscripts-ng/include/pkg_util.sh

# init names
[ -n "$1" ]
SPK_PACKAGE_NAME=$1

[ -n "$2" ]
SPK_PACKAGE_VERSION=$2

# set include projects to install into this package
DSM_DIR="/tmp/_${SPK_PACKAGE_NAME}"      # temp folder for dsm files
PKG_DIR="/tmp/_${SPK_PACKAGE_NAME}_pkg"   # temp folder for package files
OUT_DIR="./.spk"   # temp folder for package archive

# prepare install and package dir
for dir in $DSM_DIR $PKG_DIR; do
        rm -rf "$dir"
done
for dir in $DSM_DIR $PKG_DIR $OUT_DIR; do
        mkdir -p "$dir" # use default mask
done

[ -d $DSM_DIR/ui ] || install -d $DSM_DIR/ui
cp -a ui/* $DSM_DIR/ui

[ -d $DSM_DIR/app ] || install -d $DSM_DIR/app
cp -a app/* $DSM_DIR/app

[ -d $PKG_DIR ] || install -d $PKG_DIR
[ -d $PKG_DIR/scripts ] || install -d $PKG_DIR/scripts
cp -a conf $PKG_DIR
cp -a scripts/* $PKG_DIR/scripts
chmod 755 $PKG_DIR/scripts/*

cp -av PACKAGE_ICON*.PNG $PKG_DIR

# force LF
find $PKG_DIR -type 'f' -exec dos2unix {} \;
find ./package -type 'f' -exec dos2unix {} \;

# create INFO
source ./INFO.env >/dev/null
pkg_dump_info > ${PKG_DIR}/INFO

# pack
pkg_make_package ./package ${PKG_DIR}
pkg_make_spk ${PKG_DIR} ${OUT_DIR} ${SPK_PACKAGE_NAME}_${SPK_PACKAGE_VERSION}.spk

