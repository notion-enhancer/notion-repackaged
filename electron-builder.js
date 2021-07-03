const editionEnv = process.env.NOTION_REPACKAGED_EDITION || 'vanilla';

module.exports = {
  asar: editionEnv === 'vanilla',
  productName: editionEnv === 'vanilla' ? 'Notion' : 'Notion Enhanced',
  extraMetadata: {
    description:
      editionEnv === 'vanilla'
        ? 'The all-in-one workspace for your notes and tasks'
        : 'The all-in-one workspace for your notes and tasks, but enhanced',
  },
  appId: 'com.github.notion-repackaged',
  protocols: [{ name: 'Notion', schemes: ['notion'] }],
  win: {
    icon: 'icon.ico',
    target: ['nsis', 'zip'],
  },
  nsis: {
    installerIcon: 'icon.ico',
    oneClick: false,
    perMachine: false,
  },
  mac: {
    icon: 'icon.icns',
    category: 'public.app-category.productivity',
    target: [
      {
        target: 'dmg',
        arch: ['x64', 'arm64'],
      },
      {
        target: 'zip',
        arch: ['x64', 'arm64'],
      },
    ],
  },
  linux: {
    icon: 'icon.icns',
    category: 'Office;Utility;',
    maintainer: 'jaime@jamezrin.name',
    mimeTypes: ['x-scheme-handler/notion'],
    desktop: {
      StartupNotify: 'true',
    },
    target: ['AppImage', 'deb', 'rpm', 'pacman', 'zip'],
  },
  publish: ['github'],
};
