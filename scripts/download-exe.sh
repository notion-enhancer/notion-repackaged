#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
workdir ${WORKSPACE_BUILD_DIR}

check-cmd curl sha512sum
check-env NOTION_VERSION NOTION_DOWNLOAD_CHECKSUM

export NOTION_DOWNLOAD_URL="https://desktop-release.notion-static.com/Notion%20Setup%20${NOTION_VERSION}.exe"
export NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"

if [ -f "${NOTION_DOWNLOADED_NAME}" ]; then
  log "Removing already downloaded file..."
  rm "${NOTION_DOWNLOADED_NAME}"
fi

log "Downloading Notion Windows package..."
curl "${NOTION_DOWNLOAD_URL}" --output "${NOTION_DOWNLOADED_NAME}"

log "Verifying downloaded package checksum..."
log "Checksum of downloaded file: `sha512sum ${NOTION_DOWNLOADED_NAME} | awk NF=1`"
echo "${NOTION_DOWNLOAD_CHECKSUM}  ${NOTION_DOWNLOADED_NAME}" | sha512sum --check -

popd > /dev/null
