#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
check-debug-expands
workspace-dir-pushd

check-cmd 7z jq convert
check-env NOTION_VERSION NOTION_REPACKAGED_REVISION

if [ -d "${NOTION_EXTRACTED_EXE_NAME}" ]; then
  log "Removing already extracted exe contents..."
  rm -r "${NOTION_EXTRACTED_EXE_NAME}"
fi

export NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"
log "Extracting Windows installer contents..."

7z x -y "${NOTION_DOWNLOADED_NAME}" \
  -o"${NOTION_EXTRACTED_EXE_NAME}" > /dev/null

if [ -d "${NOTION_EXTRACTED_APP_NAME}" ]; then
  log "Removing already extracted app contents..."
  rm -r "${NOTION_EXTRACTED_APP_NAME}"
fi

log "Extracting Windows app resources..."
7z x -y "${NOTION_EXTRACTED_EXE_NAME}/\$PLUGINSDIR/app-64.7z" \
  -o"${NOTION_EXTRACTED_APP_NAME}" > /dev/null

if [ -d "${NOTION_VANILLA_SRC_NAME}" ]; then
  log "Removing already extracted app sources..."
  rm -r "${NOTION_VANILLA_SRC_NAME}"
fi

log "Copying original app resources..."
mkdir -p "${NOTION_VANILLA_SRC_NAME}"
cp -r "${NOTION_EXTRACTED_APP_NAME}/resources/app/"* "${NOTION_VANILLA_SRC_NAME}"

pushd "${NOTION_VANILLA_SRC_NAME}" > /dev/null

export NOTION_REPACKAGED_VERSION_REV="${NOTION_VERSION}-${NOTION_REPACKAGED_REVISION}"

log "Patching source for fixes..."
sed -i 's|process.platform === "win32"|process.platform !== "darwin"|g' main/main.js
PATCHED_PACKAGE_JSON=$(jq \
  --arg homepage "${NOTION_REPACKAGED_HOMEPAGE}" \
  --arg repo "${NOTION_REPACKAGED_REPO}" \
  --arg author "${NOTION_REPACKAGED_AUTHOR}" \
  --arg version "${NOTION_REPACKAGED_VERSION_REV}" \
  '.dependencies.cld="2.7.0" | 
  .name="notion-app" | 
  .homepage=$homepage | 
  .repository=$repo | 
  .author=$author | 
  .version=$version' package.json
)
echo "${PATCHED_PACKAGE_JSON}" > package.json

log "Removing package node_modules..."
rm -r node_modules

log "Converting app icon to png..."
convert "icon.ico[0]" "icon.png"

popd > /dev/null
