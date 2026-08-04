import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Mynster',
  tagline: 'Automation Specialist | PowerShell | Python | Terraform',
  favicon: 'assets/img/favicon.ico',

  url: 'https://mynster-it.dk',
  baseUrl: '/',

  organizationName: 'Mynster9361',
  projectName: 'mynster9361.github.io',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'warn',

  markdown: {
    format: 'detect',
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          path: 'docs',
          routeBasePath: '/docs',
          sidebarPath: './sidebars.ts',
        },
        blog: {
          routeBasePath: '/',
          blogSidebarTitle: 'Recent Posts',
          blogSidebarCount: 10,
          postsPerPage: 10,
          archiveBasePath: '/archives',
          feedOptions: {
            type: ['rss', 'atom'],
            title: 'Mynster Blog',
            description: 'A blog about automation, scripting, and homelabbing.',
            copyright: `Copyright © ${new Date().getFullYear()} Morten Mynster`,
          },
          showReadingTime: true,
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'assets/img/posts/me.png',
    navbar: {
      title: 'Mynster',
      logo: {
        alt: 'Mynster Logo',
        src: 'assets/img/posts/me.png',
        style: { borderRadius: '50%' },
      },
      items: [
        { to: '/', label: 'Blog', position: 'left' },
        { to: '/archives', label: 'Archives', position: 'left' },
        {
          type: 'docSidebar',
          sidebarId: 'modulesSidebar',
          position: 'left',
          label: 'PowerShell Modules',
        },
        { to: '/about', label: 'About', position: 'left' },
        {
          href: 'https://github.com/mynster9361',
          label: 'GitHub',
          position: 'right',
        },
        {
          href: 'https://www.linkedin.com/in/mortenmynster',
          label: 'LinkedIn',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Content',
          items: [
            { label: 'Blog', to: '/' },
            { label: 'Archives', to: '/archives' },
            { label: 'PowerShell Modules', to: '/docs/modules/actionablemessages' },
            { label: 'About', to: '/about' },
          ],
        },
        {
          title: 'Connect',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/mynster9361',
            },
            {
              label: 'LinkedIn',
              href: 'https://www.linkedin.com/in/mortenmynster',
            },
          ],
        },
        {
          title: 'Feeds',
          items: [
            { label: 'RSS', href: '/rss.xml' },
            { label: 'Atom', href: '/atom.xml' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Morten Mynster. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['powershell', 'bash', 'yaml', 'json', 'hcl'],
    },
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
