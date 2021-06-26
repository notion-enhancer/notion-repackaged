#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
check-debug-expands
workspace-dir-pushd

check-cmd jq
check-cmd git
check-cmd convert

if [ -d "${NOTION_ENHANCED_SRC_NAME}" ]; then
  log "Removing already enhanced sources..."
  rm -rf "${NOTION_ENHANCED_SRC_NAME}"
fi

cp -r "${NOTION_VANILLA_SRC_NAME}" "${NOTION_ENHANCED_SRC_NAME}"

pushd "${NOTION_ENHANCED_SRC_NAME}" > /dev/null

log "Patching package.json for being enhanced"
PATCHED_PACKAGE_JSON=$(jq '
  .dependencies += {"keyboardevent-from-electron-accelerator": "^2.0.0"} |
  .name="notion-app-enhanced"' package.json)
echo "${PATCHED_PACKAGE_JSON}" > package.json

log "Applying additional notion patches..."
patch -p0 --binary < "${WORKSPACE_DIR}/patches/notion-check-relativeurl.patch"

log "Fetching enhancer sources..."

git clone "${NOTION_ENHANCER_REPO_URL}" "${NOTION_EMBEDDED_NAME}"

pushd "${NOTION_EMBEDDED_NAME}" > /dev/null
git reset "${NOTION_ENHANCER_COMMIT}" --hard
rm -rf .git

log "Applying enhancer patches..."
patch -p0 --binary < "${WORKSPACE_DIR}/patches/enhancer-query-selector-fix.patch"
patch -p0 --binary < "${WORKSPACE_DIR}/patches/enhancer-urlhelper-fix.patch"
patch -p0 --binary < "${WORKSPACE_DIR}/patches/enhancer-paths.patch"
popd > /dev/null

log "Injecting enhancer loader..."
for patchable_file in $(find . -type d \( -path ./${NOTION_EMBEDDED_NAME} -o -path ./node_modules \) -prune -false -o -name '*.js'); do
  patchable_file_dir=$(dirname $patchable_file)
  rel_loader_path=$(realpath ${NOTION_EMBEDDED_NAME}/pkg/loader.js --relative-to $patchable_file_dir) 
  [ $patchable_file_dir = '.' ] && rel_loader_path="./"$rel_loader_path
  rel_loader_require="require('${rel_loader_path}')(__filename, exports);"

  echo -e "\n\n" >> $patchable_file
  echo "//notion-enhancer" >> $patchable_file
  echo "${rel_loader_require}" >> $patchable_file
done

log "Swapping the original icon with the enhancer's one..."
mkdir -p vanilla
mv icon.icns vanilla/icon.icns
mv icon.png vanilla/icon.png
mv icon.ico vanilla/icon.ico

enhancer_icon_path="mods/core/icons/mac+linux.png"
convert "${NOTION_EMBEDDED_NAME}/${enhancer_icon_path}" \
  -resize 512x512 "icon.png"

popd > /dev/null
