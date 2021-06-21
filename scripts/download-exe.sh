#!/usr/bin/env bash
set -ex

source `dirname $0`/_utils.sh
workspace-dir-pushd

check-cmd curl

if [ -f "${NOTION_DOWNLOADED_NAME}" ]; then
  log "Removing already downloaded file..."
  rm "${NOTION_DOWNLOADED_NAME}"
fi

log "Downloading Notion Windows package..."
curl "${NOTION_DOWNLOAD_URL}" --output "${NOTION_DOWNLOADED_NAME}"

log "Verifying downloaded package checksum..."
echo "${NOTION_DOWNLOAD_HASH}  ${NOTION_DOWNLOADED_NAME}" | md5sum --check -

popd > /dev/null
