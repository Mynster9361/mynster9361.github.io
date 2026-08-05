import React, {useState, useRef, useEffect} from 'react';
import clsx from 'clsx';
import Translate from '@docusaurus/Translate';
import Link from '@docusaurus/Link';
import {ThemeClassNames} from '@docusaurus/theme-common';
import {
  useDocsVersion,
  useVersions,
  useActiveDocContext,
  useDocsPreferredVersion,
} from '@docusaurus/plugin-content-docs/client';
import styles from './styles.module.css';

function getVersionMainDoc(version) {
  return version.docs.find((doc) => doc.id === version.mainDocId);
}

function getVersionTargetDoc(version, activeDocContext) {
  // Link to the same doc in the other version when possible, otherwise fall
  // back to that version's main/index doc.
  return (
    activeDocContext.alternateDocVersions[version.name] ??
    getVersionMainDoc(version)
  );
}

export default function DocVersionBadge({className}) {
  const versionMetadata = useDocsVersion();
  const versions = useVersions(versionMetadata.pluginId);
  const activeDocContext = useActiveDocContext(versionMetadata.pluginId);
  const {savePreferredVersionName} = useDocsPreferredVersion(
    versionMetadata.pluginId,
  );
  const [showDropdown, setShowDropdown] = useState(false);
  const containerRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        !containerRef.current ||
        containerRef.current.contains(event.target)
      ) {
        return;
      }
      setShowDropdown(false);
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (!versionMetadata.badge) {
    return null;
  }

  const canSwitch = versions.length > 1;

  return (
    <div ref={containerRef} className={styles.versionBadgeContainer}>
      <span
        role={canSwitch ? 'button' : undefined}
        tabIndex={canSwitch ? 0 : undefined}
        aria-haspopup={canSwitch ? 'true' : undefined}
        aria-expanded={canSwitch ? showDropdown : undefined}
        onClick={canSwitch ? () => setShowDropdown((prev) => !prev) : undefined}
        onKeyDown={
          canSwitch
            ? (event) => {
                if (event.key === 'Enter' || event.key === ' ') {
                  event.preventDefault();
                  setShowDropdown((prev) => !prev);
                }
              }
            : undefined
        }
        className={clsx(
          className,
          ThemeClassNames.docs.docVersionBadge,
          'badge badge--secondary',
          canSwitch && styles.versionBadgeClickable,
        )}>
        <Translate
          id="theme.docs.versionBadge.label"
          values={{versionLabel: versionMetadata.label}}>
          {'Version: {versionLabel}'}
        </Translate>
        {canSwitch && <span className={styles.versionBadgeCaret}>▾</span>}
      </span>
      {canSwitch && showDropdown && (
        <ul className={styles.versionDropdownMenu}>
          {versions.map((version) => {
            const targetDoc = getVersionTargetDoc(version, activeDocContext);
            const isActive = version === activeDocContext.activeVersion;
            return (
              <li key={version.name}>
                <Link
                  to={targetDoc.path}
                  className={clsx(
                    styles.versionDropdownLink,
                    isActive && styles.versionDropdownLinkActive,
                  )}
                  onClick={() => {
                    savePreferredVersionName(version.name);
                    setShowDropdown(false);
                  }}>
                  {version.label}
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
