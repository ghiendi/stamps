import React from 'react';
import dayjs from 'dayjs';
import styles from './stamp_grid.module.css';

export default function StampGrid({ stamps, country_slug, year }) {
  if (!stamps || stamps.length === 0) return <div>No stamps found.</div>;
  return (
    <div className={styles.grid}>
      {stamps.map(stamp => (
        <div key={stamp.id} className={styles.item}>
          <div className={styles.thumb_wrapper}>
            <img
              src={
                stamp.image_url
                  ? `${process.env.NEXT_PUBLIC_ASSETS_URL}/stamp/${country_slug}/${year}/250/${stamp.image_url}`
                  : '/images/no-image.png'
              }
              alt={stamp.caption_base}
              className={styles.thumb}
            />
          </div>
          <div className={styles.caption}>{stamp.caption_base}</div>
          <div className={styles.date}>{stamp.release_date ? dayjs(stamp.release_date).format('YYYY-MM-DD') : ''}</div>
        </div>
      ))}
    </div>
  );
}
