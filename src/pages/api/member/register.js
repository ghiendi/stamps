import { db_read, get_pool } from '@/lib/db';
import rate_limit from '@/lib/rate_limit';
import { send_email } from '@/lib/send_email';
import { get_activation_email } from '@/email/activation_email';
import crypto from 'crypto';
import bcrypt from 'bcryptjs';

const LIMIT = parseInt(process.env.RL_REGISTER_LIMIT || '5', 10);
const WINDOW = parseInt(process.env.RL_REGISTER_WINDOW || '900', 10);
const TOKEN_TTL_HOURS = parseInt(process.env.TOKEN_ACTIVATION_TTL_HOURS || '24', 10);
const APP_BASE_URL = process.env.APP_BASE_URL;
const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS || '12', 10);

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

  let { email, fullname, nickname, password, password_confirm, agree_terms, turnstile_token } = req.body;

  // Normalize email
  if (typeof email === 'string') email = email.trim().toLowerCase();

  // Validate fields (server-side)
  if (!email || typeof email !== 'string' || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    res.status(400).json({ error: 'Invalid email address' });
    return;
  }
  if (!fullname || typeof fullname !== 'string' || fullname.length < 2 || fullname.length > 100) {
    res.status(400).json({ error: 'Full name must be 2-100 characters' });
    return;
  }
  if (nickname && (typeof nickname !== 'string' || nickname.length > 50)) {
    res.status(400).json({ error: 'Nickname must be up to 50 characters' });
    return;
  }
  if (!password || typeof password !== 'string' || !password_confirm || typeof password_confirm !== 'string') {
    res.status(400).json({ error: 'Missing password fields' });
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
  if (!agree_terms) {
    res.status(400).json({ error: 'You must agree to the terms' });
    return;
  }
  if (!turnstile_token || typeof turnstile_token !== 'string') {
    res.status(400).json({ error: 'Missing captcha token' });
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
  const password_hash = bcrypt.hashSync(password, bcrypt.genSaltSync(BCRYPT_ROUNDS));
  const ip_address = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.connection?.remoteAddress || req.socket?.remoteAddress || '';
  // Generate raw token and store SHA-256 hash in DB
  const token_raw = crypto.randomBytes(32).toString('hex');
  const token_hash = crypto.createHash('sha256').update(token_raw).digest('hex');
  const expires_at = new Date(Date.now() + TOKEN_TTL_HOURS * 3600 * 1000);
  let member_id;
  try {
    // Manual transaction for correct member_id usage
    const pool = get_pool('DBW');
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
      const memberRes = await conn.query('INSERT INTO members (email, fullname, nickname, password_hash, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())', [email, fullname, nickname || null, password_hash, 'INACTIVE']);
      member_id = memberRes.insertId;
      await conn.query('INSERT INTO member_activity_log (member_id, activity_type, activity_time, activity_data, ip_address) VALUES (?, ?, NOW(), ?, ?)', [member_id, 'REGISTERED', JSON.stringify({ email, fullname, nickname }), ip_address]);
      await conn.query('INSERT INTO member_tokens (member_id, token_type, token_value, expires_at, created_at, is_used) VALUES (?, ?, ?, ?, NOW(), 0)', [member_id, 'ACTIVATION', token_hash, expires_at]);
      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  } catch (err) {
    // Handle duplicate email race condition
    if (err && (err.code === 'ER_DUP_ENTRY' || err.errno === 1062)) {
      res.status(400).json({ error: 'Email already registered' });
      return;
    }
    console.error('Registration error:', err);
    res.status(500).json({ error: 'Registration failed, please try again.' });
    return;
  }

  // Send activation email (outside transaction)
  try {
    const baseUrl = APP_BASE_URL || `${(req.headers['x-forwarded-proto'] || 'https')}://${req.headers.host}`;
    const activation_link = `${baseUrl}/v/${token_raw}`;
    const html = get_activation_email({ fullname, activation_link });
    await send_email({
      to: email,
      subject: 'Activate your Stamps.Gallery account',
      html,
    });
  } catch (err) {
    console.error('Activation email error:', err);
    res.status(500).json({ error: 'Could not send activation email. Please contact support.' });
    return;
  }

  res.status(200).json({ success: true });
}
