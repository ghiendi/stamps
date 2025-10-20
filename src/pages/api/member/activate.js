import { db_write, db_read, db_transaction } from '@/lib/db';
import { send_email } from '@/lib/send_email';
import { send_telegram_message } from '@/lib/send_telegram';
import { get_welcome_email } from '@/email/welcome_email';
import crypto from 'crypto';

export default async function handler(req, res) {
  const { token } = req.query;
  if (!token) {
    res.status(400).json({ error: 'Missing token' });
    return;
  }
  // Hash incoming raw token and match against stored hash in DB
  const token_hash = crypto.createHash('sha256').update(String(token)).digest('hex');

  // Find token
  const rows = await db_read(
    'SELECT mt.id, mt.member_id, mt.expires_at, mt.is_used, m.email, m.fullname, m.nickname, m.status FROM member_tokens mt JOIN members m ON mt.member_id = m.id WHERE mt.token_value = ? AND mt.token_type = ? LIMIT 1',
    [token_hash, 'ACTIVATION']
  );
  // Get IP address
  const ip_address = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';

  if (rows.length === 0) {
    // Do not log with NULL member_id to avoid FK violation; just respond error
    res.status(400).json({ error: 'Invalid or expired token' });
    return;
  }
  const row = rows[0];
  if (row.is_used || row.status === 'ACTIVE') {
    // Log without exposing raw token
    await db_write(
      'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
      [row.member_id, 'ACTIVATION_FAILED', JSON.stringify({ reason: 'token_used_or_active' }), ip_address]
    );
    res.status(400).json({ error: 'Token already used or account already active' });
    return;
  }
  if (new Date(row.expires_at) < new Date()) {
    // Log without exposing raw token
    await db_write(
      'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
      [row.member_id, 'ACTIVATION_FAILED', JSON.stringify({ reason: 'token_expired' }), ip_address]
    );
    res.status(400).json({ error: 'Token expired' });
    return;
  }

  try {
    await db_transaction([
      {
        sql: 'UPDATE members SET status = ? WHERE id = ?',
        params: ['ACTIVE', row.member_id]
      },
      {
        sql: 'UPDATE member_tokens SET is_used = 1 WHERE id = ?',
        params: [row.id]
      },
      {
        sql: 'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
        params: [row.member_id, 'ACTIVATED', JSON.stringify({ email: row.email, fullname: row.fullname, nickname: row.nickname }), ip_address]
      }
    ]);
  } catch (err) {
    res.status(500).json({ error: 'Activation failed, please try again.' });
    return;
  }

  // Send welcome email and Telegram (outside transaction). Do not fail activation if these fail.
  try {
    const html = get_welcome_email({ fullname: row.fullname });
    await send_email({
      to: row.email,
      subject: 'Welcome to Stamps.Gallery',
      html,
    });
  } catch (err) {
    console.error('Welcome email error:', err);
  }
  try {
    await send_telegram_message(
      `A new member has activated their account:\nEmail: ${row.email}\nFullname: ${row.fullname}\nNickname: ${row.nickname || ''}`
    );
  } catch (err) {
    console.error('Telegram notify error:', err);
  }

  res.status(200).json({ success: true });
}
