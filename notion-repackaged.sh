#
# This file should only contain variables neccessary for notion-repackaged builds
# To bring these variables to your shell, run "source notion-repackaged.sh"
#

# Version of the original Notion App installer to repackage
export NOTION_VERSION=2.0.41

# The version of electron in the original build
export NOTION_ELECTRON_VERSION=19.1.9

# Revision of the current version
export NOTION_REPACKAGED_REVISION=1

# The sha512 hash of the downloaded .exe for the installer
export NOTION_DOWNLOAD_CHECKSUM=47f08445c5a614de35d8870ac0ba46f11756b1398589c9c539f4b965e8e12fe6ed6b756d68606e24a524b9f96ce9d1ecab8f756f05619b67efe90d245a3a668c

# The commit of notion-enhancer/desktop to target
export NOTION_ENHANCER_DESKTOP_COMMIT=8e809d42339f9e6c59b3d70ba9be40f8292abed9
