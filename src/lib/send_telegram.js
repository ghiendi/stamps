import axios from 'axios';

const TELEGRAM_ENABLE = process.env.TELEGRAM_ENABLE === 'true';
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID;

export async function send_telegram_message(text) {
  if (!TELEGRAM_ENABLE) return;
  if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) return;
  const url = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`;
  await axios.post(url, {
    chat_id: TELEGRAM_CHAT_ID,
    text,
    parse_mode: 'HTML',
  });
}
