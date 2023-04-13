#!/usr/bin/env bash
set -e

source `dirname $0`/_utils.sh
workdir ${WORKSPACE_BUILD_DIR}

check-cmd jq git convert png2icns node sponge
check-env NOTION_ENHANCER_DESKTOP_COMMIT

if [ -d "${NOTION_ENHANCED_SRC_DIRNAME}" ]; then
  log "Removing already enhanced sources..."
  rm -rf "${NOTION_ENHANCED_SRC_DIRNAME}"
fi

if [ ! -d "${NOTION_VANILLA_SRC_DIRNAME}" ]; then
  log "Could not find vanilla sources directory"
  exit -1
fi

cp -r "${NOTION_VANILLA_SRC_DIRNAME}" "${NOTION_ENHANCED_SRC_DIRNAME}"

pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null

log "Patching package.json for being enhanced..."

jq '.name="notion-app-enhanced"' package.json | sponge package.json

popd > /dev/null

if [ ! -d "${NOTION_ENHANCER_REPO_DIRNAME}" ]; then
  log "Cloning enhancer desktop repo..."
  git clone "${NOTION_ENHANCER_REPO_URL}" "${NOTION_ENHANCER_REPO_DIRNAME}"
fi

pushd "${NOTION_ENHANCER_REPO_DIRNAME}" > /dev/null

log "Checking out enhancer desktop..."
git fetch
git checkout ${NOTION_ENHANCER_DESKTOP_COMMIT}
git submodule update --init --recursive

log "Installing enhancer desktop dependencies..."
npm install

log "Applying enhancer to the sources..."
NOTION_ENHANCED_SRC="${WORKSPACE_BUILD_DIR}/${NOTION_ENHANCED_SRC_DIRNAME}"

# sources do not have node_modules yet, so just make an empty one
mkdir -p "${NOTION_ENHANCED_SRC}/node_modules"

# hack for simulating the resources/app directory of electron
ln -s "${NOTION_ENHANCED_SRC}" "${NOTION_ENHANCED_SRC}/app"

# call the CLI of notion-enhancer directly, simulating resources dir
node bin.mjs apply -y --no-backup --path="${NOTION_ENHANCED_SRC}"

# undo the hack after applying the enhancer
rm -vf "${NOTION_ENHANCED_SRC}/app"

popd > /dev/null

pushd "${NOTION_ENHANCED_SRC_DIRNAME}" > /dev/null

# fix for enhancer module getting removed when installing dependencies
mv node_modules/notion-enhancer shared/ && rmdir node_modules
jq '.dependencies += {"notion-enhancer": "file:shared/notion-enhancer"}' package.json | sponge package.json

log "Swapping out icons..."
rm -vf icon.icns icon.png icon.ico 

NOTION_ENHANCER_ICONS="shared/notion-enhancer/assets"

cp "${NOTION_ENHANCER_ICONS}/colour-x512.png" icon.png

log "Converting icon to multi-size ico for Windows"
# http://www.imagemagick.org/Usage/thumbnails/#favicon
convert "${NOTION_ENHANCER_ICONS}/colour-x512.png" \
  -debug all \
  -resize 256x256 \
  -define icon:auto-resize="256,128,96,64,48,32,16" \
  icon.ico

log "Converting icon to multi-size icns for Mac and Linux"
# https://askubuntu.com/questions/223215/how-can-i-convert-a-png-file-to-icns
png2icns icon.icns \
  "${NOTION_ENHANCER_ICONS}/colour-x512.png" \
  "${NOTION_ENHANCER_ICONS}/colour-x256.png" \
  "${NOTION_ENHANCER_ICONS}/colour-x128.png" \
  "${NOTION_ENHANCER_ICONS}/colour-x32.png" \
  "${NOTION_ENHANCER_ICONS}/colour-x16.png"

popd > /dev/null
