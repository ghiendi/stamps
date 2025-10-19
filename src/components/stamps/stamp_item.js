import React from 'react';
import styles from './stamp_item.module.css';

export default function StampItem({ stamp }) {
  // Lấy năm phát hành, fallback nếu thiếu dữ liệu
  const year = stamp.release_date && typeof stamp.release_date === 'string' && stamp.release_date.length >= 4
    ? stamp.release_date.substring(0, 4)
    : 'unknown';

  // Xây dựng URL ảnh, fallback nếu thiếu dữ liệu
  const imageUrl = stamp.image_url && stamp.issuing_authority_slug && year !== 'unknown'
    ? `${process.env.NEXT_PUBLIC_ASSETS_URL}/stamp/${stamp.issuing_authority_slug}/${year}/240/${stamp.image_url}`
    : '/images/no-image.png';

  return (
    <div className={styles.item}>
      <img
        src={imageUrl}
        alt={stamp.caption_base || 'Stamp image'}
        className={styles.thumb}
      />
      <div className={styles.actions}>QV + WL + CO</div>
    </div>
  );
}
