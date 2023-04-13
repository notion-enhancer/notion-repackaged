export WORKSPACE_DIR=`realpath $(dirname $0)/..`
export WORKSPACE_BUILD_DIR="${WORKSPACE_DIR}/build"

function log() {
  caller=`basename "$0"`
  echo "[${caller%.*}]: $@"
}

function check-cmd() {
  for cmd_name in "$@"; do
    if ! command -v ${cmd_name} > /dev/null; then
      log "Missing required command dependency: $cmd_name"
      exit -1
    fi
  done
}

function check-env() {
  for var_name in "$@"; do
    if [ -z "${!var_name}" ]; then
      log "Missing required environment variable: $var_name"
      exit -1
    fi
  done
}

function workdir() {
  mkdir -p "$1"
  pushd "$1" > /dev/null
}

if [ "${NOTION_REPACKAGED_DEBUG}" = true ]; then
  set -x
fi

export NOTION_EXTRACTED_EXE_DIRNAME="extracted-exe"
export NOTION_EXTRACTED_APP_DIRNAME="extracted-app"
export NOTION_VANILLA_SRC_DIRNAME="vanilla-src"
export NOTION_ENHANCED_SRC_DIRNAME="enhanced-src"

export NOTION_ENHANCER_REPO_URL="https://github.com/notion-enhancer/notion-enhancer"
export NOTION_ENHANCER_REPO_DIRNAME="notion-enhancer"

export NOTION_REPACKAGED_REPO_URL_DEFAULT="https://github.com/notion-enhancer/notion-repackaged"
export NOTION_REPACKAGED_REPO_URL=${NOTION_REPACKAGED_REPO_URL:-${NOTION_REPACKAGED_REPO_URL_DEFAULT}}
export NOTION_REPACKAGED_AUTHOR="Notion Repackaged"

export NOTION_REPACKAGED_AIO_BUILD_PARAMS_DEFAULT="--linux dir"
export NOTION_REPACKAGED_AIO_BUILD_PARAMS=${NOTION_REPACKAGED_AIO_BUILD_PARAMS:-${NOTION_REPACKAGED_AIO_BUILD_PARAMS_DEFAULT}}
