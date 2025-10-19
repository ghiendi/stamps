import { db_write, db_read } from '@/lib/db';
import rate_limit from '@/lib/rate_limit';
import { send_email } from '@/lib/send_email';
import { get_activation_email } from '@/email/activation_email';
import crypto from 'crypto';

const LIMIT = parseInt(process.env.RL_REGISTER_LIMIT || '5', 10);
const WINDOW = parseInt(process.env.RL_REGISTER_WINDOW || '900', 10);
const TOKEN_TTL_HOURS = parseInt(process.env.TOKEN_ACTIVATION_TTL_HOURS || '24', 10);
const APP_BASE_URL = process.env.APP_BASE_URL;

const apply_rate_limit = rate_limit({ limit: LIMIT, window: WINDOW });

export default async function handler(req, res) {
  let finished = false;
  await new Promise(resolve => {
    apply_rate_limit(req, res, () => {
      finished = true;
      resolve();
    });
  });
  if (!finished) return;

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { email, fullname, nickname, password, password_confirm, agree_terms, turnstile_token } = req.body;

  // Validate fields
  if (!email || !fullname || !password || !password_confirm || !agree_terms || !turnstile_token) {
    res.status(400).json({ error: 'Missing required fields' });
    return;
  }
  if (password !== password_confirm) {
    res.status(400).json({ error: 'Passwords do not match' });
    return;
  }
  if (!/^.{8,}$/.test(password) || !/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/[0-9]/.test(password)) {
    res.status(400).json({ error: 'Password does not meet requirements' });
    return;
  }

  // Verify Turnstile
  const verify_url = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';
  const secret_key = process.env.TURNSTILE_SECRET_KEY;
  const remoteip = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';
  const verify_resp = await fetch(verify_url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `secret=${secret_key}&response=${turnstile_token}&remoteip=${remoteip}`
  });
  const verify_json = await verify_resp.json();
  if (!verify_json.success) {
    res.status(400).json({ error: 'Failed captcha verification' });
    return;
  }

  // Check if email already exists
  const existing = await db_read('SELECT id FROM members WHERE email = ?', [email]);
  if (existing.length > 0) {
    res.status(400).json({ error: 'Email already registered' });
    return;
  }

  // Hash password
  const password_hash = crypto.createHash('sha256').update(password).digest('hex');

  // Insert member
  const result = await db_write(
    'INSERT INTO members (email, fullname, nickname, password_hash, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())',
    [email, fullname, nickname || null, password_hash, 'INACTIVE']
  );
  const member_id = result.insertId;

  // Get IP address
  const ip_address = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';

  // Log REGISTERED event
  await db_write(
    'INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)',
    [member_id, 'REGISTERED', JSON.stringify({ email, fullname, nickname }), ip_address]
  );

  // Create activation token
  const token_value = crypto.randomBytes(32).toString('hex');
  const expires_at = new Date(Date.now() + TOKEN_TTL_HOURS * 3600 * 1000);
  await db_write(
    'INSERT INTO member_tokens (member_id, token_type, token_value, expires_at, created_at, is_used) VALUES (?, ?, ?, ?, NOW(), 0)',
    [member_id, 'ACTIVATION', token_value, expires_at]
  );

  // Send activation email
  const activation_link = `${APP_BASE_URL}/v/${token_value}`;
  const html = get_activation_email({ fullname, activation_link });
  await send_email({
    to: email,
    subject: 'Activate your Stamps.Gallery account',
    html,
  });

  res.status(200).json({ success: true });
}
