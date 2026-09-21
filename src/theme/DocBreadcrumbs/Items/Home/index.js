import React from 'react';
import Link from '@docusaurus/Link';
import useBaseUrl from '@docusaurus/useBaseUrl';
import {translate} from '@docusaurus/Translate';
import IconHome from '@theme/Icon/Home';
import styles from './styles.module.css';

// Swizzled: the default theme always points this at the site root ('/').
// On this site everything under /docs lives under the "PowerShell Modules"
// section, so the docs breadcrumb's home icon should go there instead of
// back out to the blog.
export default function HomeBreadcrumbItem() {
  const homeHref = useBaseUrl('/docs/modules');
  return (
    <li className="breadcrumbs__item">
      <Link
        aria-label={translate({
          id: 'theme.docs.breadcrumbs.home',
          message: 'Home page',
          description: 'The ARIA label for the home page in the breadcrumbs',
        })}
        className="breadcrumbs__link"
        href={homeHref}>
        <IconHome className={styles.breadcrumbHomeIcon} />
      </Link>
    </li>
  );
}
