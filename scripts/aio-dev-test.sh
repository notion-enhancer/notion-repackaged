#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh

log "Removing build directory..."

rm -rf ${WORKSPACE_BUILD_DIR}

source "${WORKSPACE_DIR}/notion-repackaged.sh"

${WORKSPACE_DIR}/scripts/download-exe.sh

log "Creating vanilla sources..."

${WORKSPACE_DIR}/scripts/extract-src.sh

if [ "${NOTION_REPACKAGED_AIO_SKIP_ENHANCED}" != true ]; then
  log "Creating enhanced sources..."

  ${WORKSPACE_DIR}/scripts/enhance-src.sh
fi

log "Building vanilla edition..."

export NOTION_REPACKAGED_EDITION=vanilla

${WORKSPACE_DIR}/scripts/build-locally.sh --linux dir &

if [ "${NOTION_REPACKAGED_AIO_SKIP_ENHANCED}" != true ]; then
  log "Building enhanced edition..."

  export NOTION_REPACKAGED_EDITION=enhanced 
  
  ${WORKSPACE_DIR}/scripts/build-locally.sh --linux dir
fi

fg > /dev/null 2>&1 || true
log "All build steps have successfully finished."
