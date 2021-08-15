export WORKSPACE_DIR=`realpath $(dirname $0)/..`

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

function check-env() {
  for var_name in "$@"; do
    if [ -z "${!var_name}" ]; then
      log "Required environment variable $var_name is not set"
      exit -1
    fi
  done
}

function workspace-dir-pushd() {
  mkdir -p "${WORKSPACE_DIR}/build"
  pushd "${WORKSPACE_DIR}/build" > /dev/null
}

function check-debug-expands() {
  if [ "${NOTION_REPACKAGED_DEBUG}" = true ]; then
    set -x
  fi
}

check-env NOTION_VERSION NOTION_REPACKAGED_REVISION NOTION_DOWNLOAD_HASH NOTION_ENHANCER_COMMIT

export NOTION_DOWNLOAD_URL="https://desktop-release.notion-static.com/Notion%20Setup%20${NOTION_VERSION}.exe"
export NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"


export NOTION_ENHANCER_REPO_URL="https://github.com/notion-enhancer/notion-enhancer"
export NOTION_EXTRACTED_EXE_NAME="extracted-exe"
export NOTION_EXTRACTED_APP_NAME="extracted-app"
export NOTION_VANILLA_SRC_NAME="vanilla-src"
export NOTION_ENHANCED_SRC_NAME="enhanced-src"
export NOTION_EMBEDDED_NAME="embedded_enhancer"

export NOTION_REPACKAGED_VERSION_REV="${NOTION_VERSION}-${NOTION_REPACKAGED_REVISION}"
export NOTION_REPACKAGED_HOMEPAGE="https://github.com/jamezrin/notion-repackaged"
export NOTION_REPACKAGED_REPO=${NOTION_REPACKAGED_REPO:-${NOTION_REPACKAGED_HOMEPAGE}}
export NOTION_REPACKAGED_AUTHOR="Notion Repackaged"
