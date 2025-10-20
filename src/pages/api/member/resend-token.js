import { db_read, db_transaction } from '@/lib/db';
import { send_email } from '@/lib/send_email';
import { get_activation_email } from '@/email/activation_email';
import crypto from 'crypto';
import rate_limit from '@/lib/rate_limit';

const TOKEN_TTL_HOURS = parseInt(process.env.TOKEN_ACTIVATION_TTL_HOURS || '24', 10);
const APP_BASE_URL = process.env.APP_BASE_URL;
const TURNSTILE_SECRET_KEY = process.env.TURNSTILE_SECRET_KEY;
const LIMIT = parseInt(process.env.RL_RESEND_LIMIT || '5', 10);
const WINDOW = parseInt(process.env.RL_RESEND_WINDOW || '900', 10);
const apply_rate_limit = rate_limit({ limit: LIMIT, window: WINDOW });

export default async function handler(req, res) {
  // Rate limit
  let finished = false;
  await new Promise(resolve => {
    apply_rate_limit(req, res, () => { finished = true; resolve(); });
  });
  if (!finished) return;

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  let { email, turnstile_token } = req.body;
  if (typeof email === 'string') email = email.trim().toLowerCase();
  // Always return generic error for missing input
  if (!email || !turnstile_token) {
    res.status(400).json({ error: 'Unable to process your request. Please try again.' });
    return;
  }
  // Verify Turnstile
  try {
    const verifyResp = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `secret=${encodeURIComponent(TURNSTILE_SECRET_KEY)}&response=${encodeURIComponent(turnstile_token)}`,
    });
    const verifyData = await verifyResp.json();
    if (!verifyData.success) {
      res.status(400).json({ error: 'Unable to process your request. Please try again.' });
      return;
    }
  } catch (e) {
    res.status(400).json({ error: 'Unable to process your request. Please try again.' });
    return;
  }
  // Tìm member chưa active
  const members = await db_read('SELECT id, fullname, status FROM members WHERE email = ?', [email]);
  if (members.length === 0) {
    // Always generic response
    res.status(200).json({ success: true });
    return;
  }
  const member = members[0];
  if (member.status === 'ACTIVE') {
    // Always generic response
    res.status(200).json({ success: true });
    return;
  }
  const token_raw = crypto.randomBytes(32).toString('hex');
  const token_hash = crypto.createHash('sha256').update(token_raw).digest('hex');
  const expires_at = new Date(Date.now() + TOKEN_TTL_HOURS * 3600 * 1000);
  const ip_address = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';
  try {
    await db_transaction([
      {
        sql: 'UPDATE member_tokens SET is_used = 1 WHERE member_id = ? AND token_type = ? AND is_used = 0',
        params: [member.id, 'ACTIVATION']
      },
      {
        sql: 'INSERT INTO member_tokens (member_id, token_type, token_value, expires_at, created_at, is_used) VALUES (?, ?, ?, ?, NOW(), 0)',
        params: [member.id, 'ACTIVATION', token_hash, expires_at]
      },
      {
        sql: 'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
        params: [member.id, 'RESEND_ACTIVATION_EMAIL', JSON.stringify({ email, fullname: member.fullname }), ip_address]
      }
    ]);
  } catch (err) {
    res.status(500).json({ error: 'Could not process request. Please try again.' });
    return;
  }
  // Gửi lại email kích hoạt (ngoài transaction)
  try {
    const baseUrl = APP_BASE_URL || `${(req.headers['x-forwarded-proto'] || 'https')}://${req.headers.host}`;
    const activation_link = `${baseUrl}/v/${token_raw}`;
    const html = get_activation_email({ fullname: member.fullname, activation_link });
    await send_email({
      to: email,
      subject: 'Activate your Stamps.Gallery account',
      html,
    });
  } catch (err) {
    res.status(500).json({ error: 'Could not send activation email. Please contact support.' });
    return;
  }
  res.status(200).json({ success: true });
}
