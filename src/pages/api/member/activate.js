import { db_write, db_read } from '@/lib/db';
import { send_email } from '@/lib/send_email';
import { send_telegram_message } from '@/lib/send_telegram';
import { get_welcome_email } from '@/email/welcome_email';

export default async function handler(req, res) {
  const { token } = req.query;
  if (!token) {
    res.status(400).json({ error: 'Missing token' });
    return;
  }

  // Find token
  const rows = await db_read(
    'SELECT mt.id, mt.member_id, mt.expires_at, mt.is_used, m.email, m.fullname, m.nickname, m.status FROM member_tokens mt JOIN members m ON mt.member_id = m.id WHERE mt.token_value = ? AND mt.token_type = ? LIMIT 1',
    [token, 'ACTIVATION']
  );
  if (rows.length === 0) {
    res.status(400).json({ error: 'Invalid or expired token' });
    return;
  }
  const row = rows[0];
  if (row.is_used || row.status === 'ACTIVE') {
    res.status(400).json({ error: 'Token already used or account already active' });
    return;
  }
  if (new Date(row.expires_at) < new Date()) {
    res.status(400).json({ error: 'Token expired' });
    return;
  }

  // Activate member
  await db_write('UPDATE members SET status = ? WHERE id = ?', ['ACTIVE', row.member_id]);
  await db_write('UPDATE member_tokens SET is_used = 1 WHERE id = ?', [row.id]);

  // Get IP address
  const ip_address = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';

  // Log ACTIVATED event
  await db_write(
    'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
    [row.member_id, 'ACTIVATED', JSON.stringify({ email: row.email, fullname: row.fullname, nickname: row.nickname }), ip_address]
  );

  // Send welcome email
  const html = get_welcome_email({ fullname: row.fullname });
  await send_email({
    to: row.email,
    subject: 'Welcome to Stamps.Gallery',
    html,
  });

  // Send Telegram notification
  await send_telegram_message(
    `A new member has activated their account:\nEmail: ${row.email}\nFullname: ${row.fullname}\nNickname: ${row.nickname || ''}`
  );

  res.status(200).json({ success: true });
}
