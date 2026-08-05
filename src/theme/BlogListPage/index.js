import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import {PageMetadata, HtmlClassNameProvider, ThemeClassNames} from '@docusaurus/theme-common';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import BlogPostItems from '@theme/BlogPostItems';
import BlogListPaginator from '@theme/BlogListPaginator';
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
    <aside className={styles.tagsPanel} aria-label="Blog tags">
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

function BlogListPageMetadata({metadata}) {
  const {
    siteConfig: {title: siteTitle},
  } = useDocusaurusContext();
  const {blogDescription, blogTitle, permalink} = metadata;
  const isBlogOnlyMode = permalink === '/';
  const title = isBlogOnlyMode ? siteTitle : blogTitle;

  return (
    <>
      <PageMetadata title={title} description={blogDescription} />
    </>
  );
}

function BlogListPageContent({metadata, items, sidebar}) {
  const hasSidebar = Boolean(sidebar && sidebar.items.length > 0);

  return (
    <Layout>
      <div className="container margin-vert--lg blog-wrapper">
        <div className={styles.blogGrid}>
          <main className={styles.blogContent}>
            <BlogPostItems items={items} />
            <BlogListPaginator metadata={metadata} />
          </main>
          {hasSidebar ? <BlogTagsPanel /> : null}
        </div>
      </div>
    </Layout>
  );
}

export default function BlogListPage(props) {
  return (
    <HtmlClassNameProvider
      className={clsx(
        ThemeClassNames.wrapper.blogPages,
        ThemeClassNames.page.blogListPage,
      )}>
      <BlogListPageMetadata metadata={props.metadata} />
      <BlogListPageContent {...props} />
    </HtmlClassNameProvider>
  );
}
