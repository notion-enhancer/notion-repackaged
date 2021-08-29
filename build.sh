#!/usr/bin/env bash
set -e

source env.sh

if [ "${NOTION_REPACKAGED_DEBUG}" = true ]; then
  set -x
fi


function log() {
  echo "[$1]: ${@:2}"
}

function check-cmd() {
  for cmd_name in "$@"; do
    if ! command -v ${cmd_name} > /dev/null; then
      log "dependency-check" "missing required command dependency: $1"
      exit -1
    fi
  done
}

# sudo apt install curl p7zip-full coreutils jq git imagemagick icnsutils

check-cmd npm

reset_build=false
enhance_build=true

compile_vanilla=false
compile_enhanced=false

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --reset)
      reset_build=true
      shift
      ;;
    --skip-enhance)
      enhance_build=false
      shift
      ;;
    --compile-vanilla)
      compile_vanilla=true
      shift
      ;;
    --compile-enhanced)
      compile_enhanced=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if $reset_build && [ -d "${WORKSPACE_DIR}/build" ]; then
  log "reset" "removing previous build artifacts..."
  rm -rf "${WORKSPACE_DIR}/build"
fi

if ! [ -d "${WORKSPACE_DIR}/build" ]; then
  mkdir "${WORKSPACE_DIR}/build"
  pushd "${WORKSPACE_DIR}/build" > /dev/null

  # download

  log "download" "downloading notion.exe..."
  curl "${NOTION_DOWNLOAD_URL}" --output "${NOTION_DOWNLOADED_NAME}"

  log "download" "verifying package checksum..."
  echo "${NOTION_DOWNLOAD_HASH}  ${NOTION_DOWNLOADED_NAME}" | md5sum --check -


  # extract

  log "extract" "extracting notion.exe..."

  7z x -y "${NOTION_DOWNLOADED_NAME}" \
    -o"${NOTION_EXTRACTED_EXE_DIRNAME}" > /dev/null

  log "extract" "extracting app.asar..."
  7z x -y "${NOTION_EXTRACTED_EXE_DIRNAME}/\$PLUGINSDIR/app-64.7z" \
    -o"${NOTION_EXTRACTED_APP_DIRNAME}" > /dev/null

  log "extract" "copying vanilla src..."
  mkdir -p "${NOTION_VANILLA_SRC_DIRNAME}"
  cp -r "${NOTION_EXTRACTED_APP_DIRNAME}/resources/app/"* "${NOTION_VANILLA_SRC_DIRNAME}"

  log "extract" "removing old node_modules to ensure platform compatibility..."
  rm -rf "${NOTION_VANILLA_SRC_DIRNAME}/node_modules"

  log "extract" "adding fields to package.json to prepare for compiling..."
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
    .version=$version' "${NOTION_VANILLA_SRC_DIRNAME}/package.json"
  )
  echo "${PATCHED_PACKAGE_JSON}" > "${NOTION_VANILLA_SRC_DIRNAME}/package.json"

fi

if $enhance_build; then

  # enhance

  if [ -d "${NOTION_ENHANCED_SRC_DIRNAME}" ]; then
    log "enhance" "removing previous enhanced src copy..."
    rm -rf "${NOTION_ENHANCED_SRC_DIRNAME}"
  fi

  log "enhance" "copying enhanced src..."
  cp -r "${NOTION_VANILLA_SRC_DIRNAME}" "${NOTION_ENHANCED_SRC_DIRNAME}"

  log "enhance" "adding enhancer dependencies to package.json..."
  PATCHED_PACKAGE_JSON=$(jq '
    .dependencies += {"keyboardevent-from-electron-accelerator": "^2.0.0"} |
    .name="notion-app-enhanced"' "${NOTION_ENHANCED_SRC_DIRNAME}/package.json")
  echo "${PATCHED_PACKAGE_JSON}" > "${NOTION_ENHANCED_SRC_DIRNAME}/package.json"

  log "enhance" "injecting enhancer loader..."
  pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null
  for patchable_file in $(find . -name '*.js'); do
    patchable_file_dir=$(dirname $patchable_file)
    rel_loader_path="$(realpath "${NOTION_EMBEDDED_DIRNAME}" --relative-to "$patchable_file_dir")/pkg/loader.js"
    [ $patchable_file_dir = '.' ] && rel_loader_path="./"$rel_loader_path
    rel_loader_require="require('${rel_loader_path}')(__filename, exports);"

    echo -e "\n\n" >> $patchable_file
    echo "//notion-enhancer" >> $patchable_file
    echo "${rel_loader_require}" >> $patchable_file
  done

  log "enhance" "downloading enhancer src..."

  git clone "${NOTION_ENHANCER_REPO_URL}" "${NOTION_EMBEDDED_DIRNAME}"

  pushd "${NOTION_EMBEDDED_DIRNAME}" > /dev/null
  git reset "${NOTION_ENHANCER_COMMIT}" --hard
  rm -rf .git

  # patch

  log "patch" "applying notion patches..."
  pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null
  sed -i 's|process.platform === "win32"|process.platform !== "darwin"|g' main/main.js
  find "${WORKSPACE_DIR}/patches/notion" -type f -wholename "*.patch" -print0 | while IFS= read -r -d '' file; do
      patch -p0 --binary < "$file"
  done

  log "patch" "applying enhancer patches..."
  pushd "${NOTION_EMBEDDED_DIRNAME}" > /dev/null
  find "${WORKSPACE_DIR}/patches/enhancer" -type f -wholename "*.patch" -print0 | while IFS= read -r -d '' file; do
      patch -p0 --binary < "$file"
  done

  log "patch" "converting app icon to png..."
  pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null
  convert "icon.ico[0]" "icon.png"

  log "patch" "swapping out vanilla icons..."
  mkdir -p vanilla
  mv icon.icns vanilla/icon.icns
  mv icon.png vanilla/icon.png
  mv icon.ico vanilla/icon.ico

  enhancer_icons="${WORKSPACE_DIR}/assets/enhancer-icons"

  cp "${enhancer_icons}/512x512.png" icon.png

  log "patch" "converting icon to multi-size ico for windows"
  # http://www.imagemagick.org/Usage/thumbnails/#favicon
  convert "${enhancer_icons}/512x512.png" -resize 256x256 \
    -define icon:auto-resize="256,128,96,64,48,32,16" \
    icon.ico

  log "patch" "converting icon to multi-size for mac and linux"
  # https://askubuntu.com/questions/223215/how-can-i-convert-a-png-file-to-icns
  png2icns icon.icns \
    "${enhancer_icons}/512x512.png" \
    "${enhancer_icons}/256x256.png" \
    "${enhancer_icons}/128x128.png" \
    "${enhancer_icons}/32x32.png" \
    "${enhancer_icons}/16x16.png"

fi


if $compile_vanilla; then
  pushd "${NOTION_VANILLA_SRC_DIRNAME}" > /dev/null
fi
if $compile_enhanced; then
  pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null
fi

if $compile_vanilla || $compile_enhanced; then
  log "compile" "installing dependencies..."
  npm install

  log "compile" "install electron and electron-builder..."
  npm install electron@11 electron-builder --save-dev

  log "compile" "running electron-builder..."
  node_modules/.bin/electron-builder \
    -c $WORKSPACE_DIR/electron-builder.js
fi

