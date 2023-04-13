#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
workdir ${WORKSPACE_BUILD_DIR}

check-cmd 7z jq convert sponge
check-env NOTION_VERSION NOTION_REPACKAGED_REVISION

if [ -d "${NOTION_EXTRACTED_EXE_DIRNAME}" ]; then
  log "Removing already extracted exe contents..."
  rm -r "${NOTION_EXTRACTED_EXE_DIRNAME}"
fi

export NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"
log "Extracting Windows installer contents..."

7z x -y "${NOTION_DOWNLOADED_NAME}" \
  -o"${NOTION_EXTRACTED_EXE_DIRNAME}" > /dev/null

if [ -d "${NOTION_EXTRACTED_APP_DIRNAME}" ]; then
  log "Removing already extracted app contents..."
  rm -r "${NOTION_EXTRACTED_APP_DIRNAME}"
fi

log "Extracting Windows app resources..."
7z x -y "${NOTION_EXTRACTED_EXE_DIRNAME}/\$PLUGINSDIR/app-64.7z" \
  -o"${NOTION_EXTRACTED_APP_DIRNAME}" > /dev/null

if [ -d "${NOTION_VANILLA_SRC_DIRNAME}" ]; then
  log "Removing already extracted app sources..."
  rm -r "${NOTION_VANILLA_SRC_DIRNAME}"
fi

log "Copying original app resources..."
mkdir -p "${NOTION_VANILLA_SRC_DIRNAME}"
cp -r "${NOTION_EXTRACTED_APP_DIRNAME}/resources/app/"* "${NOTION_VANILLA_SRC_DIRNAME}"

export NOTION_REPACKAGED_VERSION_REV="${NOTION_VERSION}-${NOTION_REPACKAGED_REVISION}"

pushd "${NOTION_VANILLA_SRC_DIRNAME}" > /dev/null

log "Patching and cleaning source"

rm -r node_modules

# behave like Windows for OSes other than Mac (Windows and Linux)
# sed -i 's|process.platform === "win32"|process.platform !== "darwin"|g' main/main.js

# fix for issues #37, #65 of notion-repackaged (temporary fix)
# sed -i 's|sqliteServerEnabled: true|sqliteServerEnabled: false|g' renderer/preload.js

# fix for issue #63 of notion-repackaged
# sed -i 's|error.message.indexOf("/opt/notion-app/app.asar") !== -1|process.platform === "linux"|g' main/autoUpdater.js

# fix for issue #46 of notion-repackaged
# patch -p0 --binary < "${WORKSPACE_DIR}/patches/no-sandbox-flag.patch"

find . -type f -name "*.js.map" -exec rm {} +

log "Adapting package.json including fixes..."

jq \
  --arg homepage "${NOTION_REPACKAGED_REPO_URL_DEFAULT}" \
  --arg repo "${NOTION_REPACKAGED_REPO_URL}" \
  --arg author "${NOTION_REPACKAGED_AUTHOR}" \
  --arg version "${NOTION_REPACKAGED_VERSION_REV}" \
  '.name="notion-app" | 
  .homepage=$homepage | 
  .repository=$repo | 
  .author=$author | 
  .version=$version' \
  package.json | sponge package.json

log "Converting app icon to png..."

convert "icon.ico[0]" "icon.png"

popd > /dev/null
