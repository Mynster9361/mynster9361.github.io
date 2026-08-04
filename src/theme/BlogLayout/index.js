import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import Layout from '@theme/Layout';
import BlogSidebar from '@theme/BlogSidebar';
import styles from './styles.module.css';

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

function BlogTagsPanel() {
  return (
    <aside className={clsx(styles.tagsPanel)} aria-label="Blog tags">
      <div className={styles.tagsSection}>
        <div className={styles.tagsHeading}>Tags</div>
        <div className={styles.tagsList}>
          {BLOG_TAGS.map((tag) => (
            <Link key={tag.href} href={tag.href} className={styles.tagBadge}>
              {tag.label}
            </Link>
          ))}
        </div>
      </div>
    </aside>
  );
}

export default function BlogLayout(props) {
  const {sidebar, toc, children, ...layoutProps} = props;
  const hasSidebar = Boolean(sidebar && sidebar.items.length > 0);
  const showTagsPanel = hasSidebar && !toc;

  return (
    <Layout {...layoutProps}>
      <div className="container margin-vert--lg blog-wrapper">
        <div className="blogGrid_ARw5">
          <BlogSidebar sidebar={sidebar} />
          <main
            className={clsx('col', {
              'col--7': hasSidebar,
              'col--9 col--offset-1': !hasSidebar,
            })}>
            {children}
          </main>
          {showTagsPanel ? <BlogTagsPanel /> : null}
          {toc && <div className="blogGrid_ARw5__toc">{toc}</div>}
        </div>
      </div>
    </Layout>
  );
}
