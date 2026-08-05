import React from 'react';
import Link from '@docusaurus/Link';
import {translate} from '@docusaurus/Translate';
import {PageMetadata} from '@docusaurus/theme-common';
import {useDateTimeFormat} from '@docusaurus/theme-common/internal';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

function Year({year, posts}) {
  const dayFormat = useDateTimeFormat({day: '2-digit', timeZone: 'UTC'});
  const monthFormat = useDateTimeFormat({month: 'short', timeZone: 'UTC'});

  return (
    <section className={styles.yearSection}>
      <time className={styles.yearHeading}>{year}</time>
      <ul className={styles.postList}>
        {posts.map((post) => {
          const date = new Date(post.metadata.date);
          return (
            <li key={post.metadata.date} className={styles.postItem}>
              <span className={styles.postDay}>{dayFormat.format(date)}</span>
              <span className={styles.postMonth}>
                {monthFormat.format(date)}
              </span>
              <Link to={post.metadata.permalink} className={styles.postLink}>
                {post.metadata.title}
              </Link>
            </li>
          );
        })}
      </ul>
    </section>
  );
}

function listPostsByYears(blogPosts) {
  const postsByYear = new Map();
  for (const post of blogPosts) {
    const year = post.metadata.date.split('-')[0];
    const yearPosts = postsByYear.get(year) ?? [];
    yearPosts.push(post);
    postsByYear.set(year, yearPosts);
  }
  return Array.from(postsByYear, ([year, posts]) => ({
    year,
    posts: [...posts].sort((a, b) =>
      a.metadata.date < b.metadata.date ? 1 : -1,
    ),
  })).sort((a, b) => (a.year < b.year ? 1 : -1));
}

export default function BlogArchive({archive}) {
  const title = translate({
    id: 'theme.blog.archive.title',
    message: 'Archive',
    description: 'The page & hero title of the blog archive page',
  });
  const description = translate({
    id: 'theme.blog.archive.description',
    message: '',
    description: 'The page & hero description of the blog archive page',
  });
  const years = listPostsByYears(archive.blogPosts);

  return (
    <>
      <PageMetadata title={title} description={description} />
      <Layout>
        <div className="container margin-vert--lg">
          <div className={styles.archiveHeader}>
            <Heading as="h1" className={styles.archiveTitle}>
              {title}
            </Heading>
            <p className={styles.archiveSubtitle}>{description}</p>
          </div>
          <main className={styles.archiveContent}>
            {years.length > 0 ? (
              years.map(({year, posts}) => (
                <Year key={year} year={year} posts={posts} />
              ))
            ) : (
              <p>No posts yet.</p>
            )}
          </main>
        </div>
      </Layout>
    </>
  );
}
