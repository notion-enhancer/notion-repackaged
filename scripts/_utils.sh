
WORKSPACE_DIR=`realpath $(dirname $0)/..`

NOTION_VERSION="${NOTION_VERSION:-2.0.16}"
NOTION_DOWNLOAD_HASH="${NOTION_DOWNLOAD_HASH:-9f72284086cda3977f7f569dff3974d5}"
NOTION_DOWNLOAD_URL="https://desktop-release.notion-static.com/Notion%20Setup%20${NOTION_VERSION}.exe"
NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"

NOTION_ENHANCER_COMMIT="${NOTION_ENHANCER_COMMIT:-b248ffa3bac393f267a4600d4e951aba8565f31e}"
NOTION_ENHANCER_REPO_URL="https://github.com/notion-enhancer/notion-enhancer"

NOTION_EXTRACTED_EXE_NAME="extracted-exe"
NOTION_EXTRACTED_APP_NAME="extracted-app"
NOTION_VANILLA_SRC_NAME="vanilla-src"
NOTION_ENHANCED_SRC_NAME="enhanced-src"
NOTION_EMBEDDED_NAME="embedded_enhancer"

function log() {
  caller=`basename "$0"`
  echo "[${caller%.*}]: $@"
}

function check-cmd() {
  if ! command -v $1 > /dev/null; then
    log "Missing required command dependency: $1"
    exit -1
  fi
}

function workspace-dir-pushd() {
  mkdir -p "${WORKSPACE_DIR}/build"
  pushd "${WORKSPACE_DIR}/build" > /dev/null
}

function check-debug-expands() {
  if [ "${NOTION_REPACKAGER_DEBUG}" = true ]; then
    set -x
  fi
}
