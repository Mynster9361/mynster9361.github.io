import React, {memo} from 'react';
import clsx from 'clsx';
import {translate} from '@docusaurus/Translate';
import {
  useVisibleBlogSidebarItems,
  BlogSidebarItemList,
} from '@docusaurus/plugin-content-blog/client';
import BlogSidebarContent from '@theme/BlogSidebar/Content';
import Link from '@docusaurus/Link';
import styles from './styles.module.css';
import tagStyles from './tagStyles.module.css';

// Sorted by post count desc — auto-derived from blog frontmatter.
const BLOG_TAGS = [
  {label: 'powershell', href: '/tags/powershell'},
  {label: 'msgraph', href: '/tags/msgraph'},
  {label: 'terraform', href: '/tags/terraform'},
  {label: 'adaptive cards', href: '/tags/adaptive-cards'},
  {label: 'azure', href: '/tags/azure'},
  {label: 'iac', href: '/tags/iac'},
  {label: 'infrastructure as code', href: '/tags/infrastructure-as-code'},
  {label: 'mail', href: '/tags/mail'},
  {label: 'actionable messages', href: '/tags/actionable-messages'},
  {label: 'speaker', href: '/tags/speaker'},
  {label: 'modules', href: '/tags/modules'},
  {label: 'security', href: '/tags/security'},
  {label: 'api', href: '/tags/api'},
  {label: 'authentication', href: '/tags/authentication'},
  {label: 'automation', href: '/tags/automation'},
  {label: 'ci/cd', href: '/tags/ci-cd'},
  {label: 'collaboration', href: '/tags/collaboration'},
  {label: 'devops', href: '/tags/devops'},
  {label: 'disclosure', href: '/tags/disclosure'},
  {label: 'github actions', href: '/tags/github-actions'},
  {label: 'microsoft graph', href: '/tags/microsoft-graph'},
  {label: 'native-testing', href: '/tags/native-testing'},
  {label: 'pester', href: '/tags/pester'},
  {label: 'remote state', href: '/tags/remote-state'},
  {label: 'state management', href: '/tags/state-management'},
  {label: 'testing', href: '/tags/testing'},
  {label: 'variables', href: '/tags/variables'},
];

const ListComponent = ({items}) => {
  return (
    <BlogSidebarItemList
      items={items}
      ulClassName={clsx(styles.sidebarItemList, 'clean-list')}
      liClassName={styles.sidebarItem}
      linkClassName={styles.sidebarItemLink}
      linkActiveClassName={styles.sidebarItemLinkActive}
    />
  );
};

function BlogSidebarDesktopWithTags({sidebar}) {
  const items = useVisibleBlogSidebarItems(sidebar.items);
  return (
    <aside className="col col--3">
      <nav
        className={clsx(styles.sidebar, 'thin-scrollbar')}
        aria-label={translate({
          id: 'theme.blog.sidebar.navAriaLabel',
          message: 'Blog recent posts navigation',
          description: 'The ARIA label for recent posts in the blog sidebar',
        })}>
        <div className={clsx(styles.sidebarItemTitle, 'margin-bottom--md')}>
          {sidebar.title}
        </div>
        <BlogSidebarContent
          items={items}
          ListComponent={ListComponent}
          yearGroupHeadingClassName={styles.yearGroupHeading}
        />
      </nav>
      <div className={tagStyles.tagsSection}>
        <div className={tagStyles.tagsHeading}>Tags</div>
        <div className={tagStyles.tagsList}>
          {BLOG_TAGS.map((tag) => (
            <Link key={tag.href} href={tag.href} className={tagStyles.tagBadge}>
              {tag.label}
            </Link>
          ))}
        </div>
      </div>
    </aside>
  );
}

export default memo(BlogSidebarDesktopWithTags);
