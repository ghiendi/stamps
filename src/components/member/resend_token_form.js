import React, { useState } from 'react';
import { Form, Input, Button, message } from 'antd';
import Script from 'next/script';


function ResendTokenForm() {
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [turnstileToken, setTurnstileToken] = useState('');

  const TURNSTILE_SITE_KEY = process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY;

  // Cloudflare Turnstile callback integration
  React.useEffect(() => {
    window.__setTurnstileToken = (token) => {
      setTurnstileToken(token);
    };
    return () => { window.__setTurnstileToken = null; };
  }, []);

  const onFinish = async (values) => {
    if (!turnstileToken) {
      message.error('Please verify you are human.');
      return;
    }
    setLoading(true);
    try {
      const resp = await fetch('/api/member/resend-token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: values.email, turnstile_token: turnstileToken }),
      });
      let data = {};
      let errorText = '';
      try {
        data = await resp.json();
      } catch (jsonErr) {
        errorText = await resp.text();
      }
      if (!resp.ok) {
        message.error('Unable to process your request. Please try again.');
        return;
      }
      setSuccess(true);
      message.success('If your email is registered and not yet activated, a new activation email has been sent.');
      setTurnstileToken(''); // clear token after submit
    } catch (err) {
      message.error('Unable to process your request. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div style={{ maxWidth: 400, margin: '32px auto', textAlign: 'center' }}>
        <h2>Activation email sent!</h2>
        <p>If your email is registered and not yet activated, please check your inbox and spam folder.</p>
      </div>
    );
  }

  return (
    <>
      <Script src="https://challenges.cloudflare.com/turnstile/v0/api.js" strategy="afterInteractive" />
      <Form
        layout="vertical"
        style={{ maxWidth: 400, margin: '32px auto', padding: 24, border: '1px solid #eee', borderRadius: 8 }}
        onFinish={onFinish}
      >
        <h2 style={{ marginBottom: 16 }}>Resend Activation Email</h2>
        <Form.Item label="Email" name="email" rules={[{ required: true, type: 'email', message: 'Please enter your registered email' }]}> 
          <Input autoComplete="email" />
        </Form.Item>
        <div style={{ marginBottom: 16 }}>
          <div
            className="cf-turnstile"
            data-sitekey={TURNSTILE_SITE_KEY}
            data-callback="onTurnstileCallback"
            data-theme="light"
            style={{ margin: '0 auto' }}
          />
        </div>
        <Form.Item>
          <Button type="primary" htmlType="submit" block loading={loading}>
            Resend Email
          </Button>
        </Form.Item>
      </Form>
      <Script id="turnstile-callback" strategy="afterInteractive">
        {`
          window.onTurnstileCallback = function(token) {
            const evt = new CustomEvent('turnstile-token', { detail: token });
            window.dispatchEvent(evt);
          };
        `}
      </Script>
      <Script id="turnstile-listener" strategy="afterInteractive">
        {`
          window.addEventListener('turnstile-token', function(e) {
            if (typeof window.__setTurnstileToken === 'function') {
              window.__setTurnstileToken(e.detail);
            }
          });
        `}
      </Script>
    </>
  );
}

export default ResendTokenForm;
