#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh

# Relevant variables to use in development:
# NOTION_REPACKAGED_AIO_DIRTY (by default unset, can set to true)
# NOTION_REPACKAGED_AIO_SKIP_VANILLA (by default unset, can set to true)
# NOTION_REPACKAGED_AIO_SKIP_ENHANCED (by default unset, can set to true)
# NOTION_REPACKAGED_AIO_BUILD_PARAMS (by default --linux dir, check this https://www.electron.build/cli)

source "${WORKSPACE_DIR}/notion-repackaged.sh"

if [ "${NOTION_REPACKAGED_AIO_DIRTY}" != true ]; then

  log "Removing build directory..."

  rm -rf ${WORKSPACE_BUILD_DIR}

  ${WORKSPACE_DIR}/scripts/download-exe.sh

  log "Creating vanilla sources..."

  ${WORKSPACE_DIR}/scripts/extract-src.sh

  if [ "${NOTION_REPACKAGED_AIO_SKIP_ENHANCED}" != true ]; then
    log "Creating enhanced sources..."

    ${WORKSPACE_DIR}/scripts/enhance-src.sh
  fi
fi

if [ "${NOTION_REPACKAGED_AIO_SKIP_VANILLA}" != true ]; then
  log "Building vanilla edition..."

  export NOTION_REPACKAGED_EDITION=vanilla

  ${WORKSPACE_DIR}/scripts/build-locally.sh ${NOTION_REPACKAGED_AIO_BUILD_PARAMS}
fi

if [ "${NOTION_REPACKAGED_AIO_SKIP_ENHANCED}" != true ]; then
  log "Building enhanced edition..."

  export NOTION_REPACKAGED_EDITION=enhanced 
  
  ${WORKSPACE_DIR}/scripts/build-locally.sh ${NOTION_REPACKAGED_AIO_BUILD_PARAMS}
fi

# fg > /dev/null 2>&1 || true
log "All build steps have successfully finished."
