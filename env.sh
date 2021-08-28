export NOTION_VERSION=2.0.16
export NOTION_DOWNLOAD_HASH=9f72284086cda3977f7f569dff3974d5
export NOTION_ENHANCER_COMMIT=b248ffa3bac393f267a4600d4e951aba8565f31e
export NOTION_ENHANCER_REPO_URL="https://github.com/notion-enhancer/notion-enhancer"

export NOTION_REPACKAGED_REVISION=3
export NOTION_REPACKAGED_EDITION=enhanced
export NOTION_REPACKAGED_VERSION_REV="${NOTION_VERSION}-${NOTION_REPACKAGED_REVISION}"

export WORKSPACE_DIR=`realpath .`

export NOTION_EXTRACTED_EXE_DIRNAME="${WORKSPACE_DIR}/build/extracted-exe"
export NOTION_EXTRACTED_APP_DIRNAME="${WORKSPACE_DIR}/build/extracted-app"
export NOTION_VANILLA_SRC_DIRNAME="${WORKSPACE_DIR}/build/vanilla-src"
export NOTION_ENHANCED_SRC_DIRNAME="${WORKSPACE_DIR}/build/enhanced-src"
export NOTION_EMBEDDED_DIRNAME="${WORKSPACE_DIR}/build/enhanced-src/embedded_enhancer"

export NOTION_DOWNLOAD_URL="https://desktop-release.notion-static.com/Notion%20Setup%20${NOTION_VERSION}.exe"
export NOTION_DOWNLOADED_NAME="Notion-${NOTION_VERSION}.exe"

export NOTION_REPACKAGED_HOMEPAGE="https://github.com/notion-enhancer/notion-repackaged"
export NOTION_REPACKAGED_REPO=${NOTION_REPACKAGED_REPO:-${NOTION_REPACKAGED_HOMEPAGE}}
export NOTION_REPACKAGED_AUTHOR="notion-enhancer"