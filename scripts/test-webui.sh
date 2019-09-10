#!/bin/sh -eu

[ -d "$DPPM_WEBUI_DIR" ] || git clone $DPPM_WEBUI_GIT $DPPM_WEBUI_DIR
cd $DPPM_WEBUI_DIR

yarn install
yarn dev
