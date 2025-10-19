import { db_read } from '@/lib/db';

export default async function handler(req, res) {
  const { slug, year } = req.query;
  const sql = `
    SELECT s.id, s.slug, s.caption_base, s.image_url, s.release_date, s.release_date_type, a.name_base AS issuing_authority_base, a.slug AS issuing_authority_slug
    FROM stamps s
    JOIN issue i ON s.issue_id = i.id
    JOIN issuing_authority a ON i.issuing_authority_id = a.id
    WHERE a.slug = ? AND YEAR(s.release_date) = ?
    ORDER BY s.release_date ASC, s.id ASC
  `;
  let stamps = await db_read(sql, [slug, year]);
  stamps = stamps.map(stamp => ({
    ...stamp,
    release_date: stamp.release_date ? (typeof stamp.release_date === 'string' ? stamp.release_date : stamp.release_date.toISOString().slice(0, 10)) : ''
  }));
  res.status(200).json({ stamps });
}
