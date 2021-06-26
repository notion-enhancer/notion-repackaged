#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
check-debug-expands
workspace-dir-pushd

check-cmd jq
check-cmd git

if [ ! -d "${NOTION_ENHANCED_SRC_NAME}" ]; then
  log "Sources do not seem to have been made..."
  exit 1
fi

pushd "${NOTION_ENHANCED_SRC_NAME}" > /dev/null

log "Install dependencies including electron-builder..."
npm install electron@11 electron-builder --save-dev

log "Running electron-builder..."
node_modules/.bin/electron-builder \
  --linux deb rpm AppImage pacman \
  --config $WORKSPACE_DIR/electron-builder.yaml

popd > /dev/null
