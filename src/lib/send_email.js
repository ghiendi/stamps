import nodemailer from 'nodemailer';

const smtp_host = process.env.SMTP_HOST;
const smtp_port = parseInt(process.env.SMTP_PORT, 10);
const smtp_user = process.env.SMTP_USER;
const smtp_pass = process.env.SMTP_PASS;
const smtp_from = process.env.SMTP_FROM;

const transporter = nodemailer.createTransport({
  host: smtp_host,
  port: smtp_port,
  secure: smtp_port === 465,
  auth: {
    user: smtp_user,
    pass: smtp_pass,
  },
});

export async function send_email({ to, subject, html }) {
  return transporter.sendMail({
    from: smtp_from,
    to,
    subject,
    html,
  });
}
