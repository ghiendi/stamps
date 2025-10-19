import { db_read } from '@/lib/db';

export default async function handler(req, res) {
  const { slug, year } = req.query;
  const sql = `
    SELECT
      s.id, s.slug, s.caption_base, s.image_url, s.release_date, s.release_date_type,
      a.name_base AS issuing_authority_base, a.slug AS issuing_authority_slug,
      i.id AS issue_id, i.name_base AS issue_name_base, i.release_date AS issue_release_date, i.release_type AS issue_release_type,
      se.id AS series_id, se.name_base AS series_name_base, se.start_year, se.end_year, se.special_type AS series_special_type,
      (
        SELECT COUNT(*) FROM stamps s2
        JOIN issue i2 ON s2.issue_id = i2.id
        WHERE i2.series_id = se.id
      ) AS series_total_stamps,
      (
        SELECT COUNT(*) FROM stamps s3 WHERE s3.issue_id = i.id
      ) AS issue_total_stamps
    FROM stamps s
    JOIN issue i ON s.issue_id = i.id
    JOIN issuing_authority a ON i.issuing_authority_id = a.id
    LEFT JOIN series se ON i.series_id = se.id
    WHERE a.slug = ? AND YEAR(s.release_date) = ?
    ORDER BY s.release_date DESC, s.id ASC
  `;
  let stamps = await db_read(sql, [slug, year]);

  // Lấy danh sách issue_id và series_id duy nhất
  const issueIds = [...new Set(stamps.map(s => s.issue_id))];
  const seriesIds = [...new Set(stamps.map(s => s.series_id).filter(Boolean))];

  // Truy vấn các philatelic items liên quan đến các issue này
  let philatelicItemsByIssue = {};
  if (issueIds.length > 0) {
    const placeholders = issueIds.map(() => '?').join(',');
    const piSql = `
      SELECT pii.issue_id, pi.id, pi.slug, pi.name_base, pi.item_type
      FROM philatelic_item_issue pii
      JOIN philatelic_item pi ON pii.item_id = pi.id
      WHERE pii.issue_id IN (${placeholders})
    `;
    const piRows = await db_read(piSql, issueIds);
    // Gom nhóm theo issue_id
    piRows.forEach(row => {
      if (!philatelicItemsByIssue[row.issue_id]) philatelicItemsByIssue[row.issue_id] = [];
      philatelicItemsByIssue[row.issue_id].push({
        id: row.id,
        slug: row.slug,
        name_base: row.name_base,
        item_type: row.item_type
      });
    });
  }

  // Đếm philatelic items cho mỗi series
  let philatelicItemsCountBySeries = {};
  if (seriesIds.length > 0) {
    const placeholders = seriesIds.map(() => '?').join(',');
    const countSql = `
      SELECT se.id AS series_id, COUNT(DISTINCT pii.item_id) AS philatelic_items_count
      FROM series se
      JOIN issue i ON i.series_id = se.id
      JOIN philatelic_item_issue pii ON pii.issue_id = i.id
      WHERE se.id IN (${placeholders})
      GROUP BY se.id
    `;
    const countRows = await db_read(countSql, seriesIds);
    countRows.forEach(row => {
      philatelicItemsCountBySeries[row.series_id] = Number(row.philatelic_items_count);
    });
  }
  // Convert BigInt to string recursively
  function convertBigInt(obj) {
    if (Array.isArray(obj)) return obj.map(convertBigInt);
    if (obj && typeof obj === 'object') {
      const out = {};
      for (const k in obj) {
        if (typeof obj[k] === 'bigint') {
          out[k] = obj[k].toString();
        } else if (typeof obj[k] === 'object') {
          out[k] = convertBigInt(obj[k]);
        } else {
          out[k] = obj[k];
        }
      }
      return out;
    }
    return obj;
  }
  stamps = stamps.map(stamp => ({
    ...stamp,
    release_date: stamp.release_date
      ? (typeof stamp.release_date === 'string'
        ? stamp.release_date
        : (typeof stamp.release_date.toISOString === 'function'
          ? stamp.release_date.toISOString().slice(0, 10)
          : String(stamp.release_date)))
      : '',
    issue_release_date: stamp.issue_release_date
      ? (typeof stamp.issue_release_date === 'string'
        ? stamp.issue_release_date
        : (typeof stamp.issue_release_date.toISOString === 'function'
          ? stamp.issue_release_date.toISOString().slice(0, 10)
          : String(stamp.issue_release_date)))
      : '',
  philatelic_items: philatelicItemsByIssue[stamp.issue_id] || [],
  series_philatelic_items_count: philatelicItemsCountBySeries[stamp.series_id] || 0
  }));
  stamps = convertBigInt(stamps);
  res.status(200).json({ stamps });
}
