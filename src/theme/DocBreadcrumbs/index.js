import React from 'react';
import clsx from 'clsx';
import {ThemeClassNames} from '@docusaurus/theme-common';
import {
  useSidebarBreadcrumbs,
  useActivePlugin,
} from '@docusaurus/plugin-content-docs/client';
import {useHomePageRoute} from '@docusaurus/theme-common/internal';
import Link from '@docusaurus/Link';
import useBaseUrl from '@docusaurus/useBaseUrl';
import {translate} from '@docusaurus/Translate';
import HomeBreadcrumbItem from '@theme/DocBreadcrumbs/Items/Home';
import DocBreadcrumbsStructuredData from '@theme/DocBreadcrumbs/StructuredData';
import styles from './styles.module.css';

// The id of the plugin instance backing the top-level /docs section (the
// "PowerShell Modules" overview page). Every module gets its own separate
// versioned docs plugin instance (see docusaurus.config.ts), so a doc's
// sidebar breadcrumbs never naturally include that overview page.
const MODULES_OVERVIEW_PLUGIN_ID = 'default';
const MODULES_OVERVIEW_PATH = '/docs/modules';

// TODO move to design system folder
function BreadcrumbsItemLink({children, href, isLast}) {
  const className = 'breadcrumbs__link';
  if (isLast) {
    return <span className={className}>{children}</span>;
  }
  return href ? (
    <Link className={className} href={href}>
      <span>{children}</span>
    </Link>
  ) : (
    <span className={className}>{children}</span>
  );
}
// TODO move to design system folder
function BreadcrumbsItem({children, active}) {
  return (
    <li
      className={clsx('breadcrumbs__item', {
        'breadcrumbs__item--active': active,
      })}>
      {children}
    </li>
  );
}

// Swizzled: inserted right after the Home icon, so a page inside a module's
// own docs plugin instance (e.g. /docs/modules/actionablemessages/...) shows
// its way back to the shared "PowerShell Modules" overview page, not just
// straight from Home to the leaf page.
function ModulesOverviewBreadcrumbItem() {
  const href = useBaseUrl(MODULES_OVERVIEW_PATH);
  return (
    <BreadcrumbsItem>
      <BreadcrumbsItemLink href={href} isLast={false}>
        {translate({
          id: 'theme.docs.breadcrumbs.modulesOverview',
          message: 'PowerShell Modules',
          description:
            'Breadcrumb label linking back to the PowerShell Modules overview page',
        })}
      </BreadcrumbsItemLink>
    </BreadcrumbsItem>
  );
}

export default function DocBreadcrumbs() {
  const breadcrumbs = useSidebarBreadcrumbs();
  const homePageRoute = useHomePageRoute();
  const activePlugin = useActivePlugin();
  const showModulesOverviewCrumb =
    activePlugin && activePlugin.pluginId !== MODULES_OVERVIEW_PLUGIN_ID;
  if (!breadcrumbs) {
    return null;
  }
  return (
    <>
      <DocBreadcrumbsStructuredData breadcrumbs={breadcrumbs} />
      <nav
        className={clsx(
          ThemeClassNames.docs.docBreadcrumbs,
          styles.breadcrumbsContainer,
        )}
        aria-label={translate({
          id: 'theme.docs.breadcrumbs.navAriaLabel',
          message: 'Breadcrumbs',
          description: 'The ARIA label for the breadcrumbs',
        })}>
        <ul className="breadcrumbs">
          {homePageRoute && <HomeBreadcrumbItem />}
          {showModulesOverviewCrumb && <ModulesOverviewBreadcrumbItem />}
          {breadcrumbs.map((item, idx) => {
            const isLast = idx === breadcrumbs.length - 1;
            const href =
              item.type === 'category' && item.linkUnlisted
                ? undefined
                : item.href;
            return (
              <BreadcrumbsItem key={idx} active={isLast}>
                <BreadcrumbsItemLink href={href} isLast={isLast}>
                  {item.label}
                </BreadcrumbsItemLink>
              </BreadcrumbsItem>
            );
          })}
        </ul>
      </nav>
    </>
  );
}
