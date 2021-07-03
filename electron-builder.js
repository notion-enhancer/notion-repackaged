const editionEnv = process.env.NOTION_REPACKAGED_EDITION || 'vanilla';

module.exports = {
  asar: editionEnv === 'vanilla',
  productName: editionEnv === 'vanilla' ? 'Notion' : 'Notion Enhanced',
  appId: 'com.github.notion-repackaged',
  protocols: [{ name: 'Notion', schemes: ['notion'] }],
  win: {
    target: ['nsis', 'zip'],
  },
  mac: {
    category: 'public.app-category.productivity',
    target: ['dmg', 'zip'],
  },
  nsis: {
    oneClick: false,
    perMachine: false,
  },
  linux: {
    category: 'Office;Utility;',
    maintainer: 'jaime@jamezrin.name',
    mimeTypes: ['x-scheme-handler/notion'],
    desktop: {
      StartupNotify: 'true',
    },
    description:
      editionEnv === 'vanilla'
        ? 'The all-in-one workspace for your notes and tasks'
        : 'The all-in-one workspace for your notes and tasks, but enhanced',
    target: ['AppImage', 'deb', 'rpm', 'pacman', 'zip'],
  },
  publish: ['github'],
};
