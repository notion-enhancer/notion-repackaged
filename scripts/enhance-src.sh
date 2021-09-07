#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
check-debug-expands
workspace-dir-pushd

check-cmd jq git convert png2icns
check-env NOTION_ENHANCER_COMMIT

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
patch -p0 --binary < "${WORKSPACE_DIR}/patches/notion-protocol-handle-enhancer.patch"
find "${WORKSPACE_DIR}/patches/notion" -type f -wholename "*.patch" -print0 | while IFS= read -r -d '' file; do
    patch -p0 --binary < "$file"
done

log "Fetching enhancer sources..."

export NOTION_ENHANCER_REPO_URL="https://github.com/notion-enhancer/notion-enhancer"
git clone "${NOTION_ENHANCER_REPO_URL}" "${NOTION_EMBEDDED_NAME}"

pushd "${NOTION_EMBEDDED_NAME}" > /dev/null
git reset "${NOTION_ENHANCER_COMMIT}" --hard
rm -rf .git

log "Applying enhancer patches..."
find "${WORKSPACE_DIR}/patches/enhancer" -type f -wholename "*.patch" -print0 | while IFS= read -r -d '' file; do
    patch -p0 --binary < "$file"
done
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

log "Swapping out vanilla icons..."
mkdir -p vanilla
mv icon.icns vanilla/icon.icns
mv icon.png vanilla/icon.png
mv icon.ico vanilla/icon.ico

enhancer_icons="${WORKSPACE_DIR}/assets/enhancer-icons"

cp "${enhancer_icons}/512x512.png" icon.png

log "Converting icon to multi-size ico for Windows"
# http://www.imagemagick.org/Usage/thumbnails/#favicon
convert "${enhancer_icons}/512x512.png" -resize 256x256 \
  -define icon:auto-resize="256,128,96,64,48,32,16" \
  icon.ico

log "Converting icon to multi-size for Mac and Linux"
# https://askubuntu.com/questions/223215/how-can-i-convert-a-png-file-to-icns
png2icns icon.icns \
  "${enhancer_icons}/512x512.png" \
  "${enhancer_icons}/256x256.png" \
  "${enhancer_icons}/128x128.png" \
  "${enhancer_icons}/32x32.png" \
  "${enhancer_icons}/16x16.png"

popd > /dev/null
