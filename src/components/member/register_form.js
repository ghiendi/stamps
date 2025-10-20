import { Input } from 'antd';
import { Form, Checkbox, Button, message } from 'antd';
import Script from 'next/script';
import React, { useState } from 'react';

// Antd message workaround for React 19
message.config({
  top: 80,
  duration: 3,
  maxCount: 2,
});

// Fallback toast using browser API
function showToast(content, type = 'info') {
  if (typeof window !== 'undefined') {
    const toast = document.createElement('div');
    toast.textContent = content;
    toast.style.position = 'fixed';
    toast.style.zIndex = 9999;
    toast.style.left = '50%';
    toast.style.top = '100px';
    toast.style.transform = 'translateX(-50%)';
    toast.style.background = type === 'error' ? '#ff4d4f' : (type === 'success' ? '#52c41a' : '#1890ff');
    toast.style.color = '#fff';
    toast.style.padding = '12px 24px';
    toast.style.borderRadius = '6px';
    toast.style.boxShadow = '0 2px 8px rgba(0,0,0,0.15)';
    toast.style.fontSize = '16px';
    document.body.appendChild(toast);
    setTimeout(() => {
      toast.remove();
    }, 3000);
  }
}

function RegisterForm() {
  const [success, setSuccess] = useState(false);
  const [loading, setLoading] = useState(false);
  const [turnstileToken, setTurnstileToken] = useState('');

  const TURNSTILE_SITE_KEY = process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY;

  const showMessage = (type, content) => {
    // Antd message API workaround for React 19
    if (typeof window !== 'undefined' && message) {
      try {
        message.open({ type, content });
      } catch (e) {
        showToast(content, type);
      }
    } else {
      showToast(content, type);
    }
  };

  const onFinish = async (values) => {
    if (!turnstileToken) {
      showMessage('error', 'Please verify you are human.');
      return;
    }
    setLoading(true);
    try {
      const resp = await fetch('/api/member/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...values, turnstile_token: turnstileToken }),
      });
      let data = {};
      let errorText = '';
      try {
        data = await resp.json();
      } catch (jsonErr) {
        errorText = await resp.text();
      }
      if (!resp.ok) {
        showMessage('error', data.error || errorText || `Registration failed (${resp.status})`);
        return;
      }
      setSuccess(true);
      showMessage('success', 'Registration successful! Please check your email to activate your account.');
    } catch (err) {
      showMessage('error', err.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  // Cloudflare Turnstile callback
  function handleTurnstile(token) {
    setTurnstileToken(token);
  }

  // Expose setter for Turnstile
  React.useEffect(() => {
    window.__turnstile_setter = handleTurnstile;
    return () => { window.__turnstile_setter = null; };
  }, []);

  if (success) {
    return (
      <div style={{ maxWidth: 400, margin: '32px auto', textAlign: 'center' }}>
        <h2>Registration successful!</h2>
        <p>
          Please check your email to activate your account.<br />
          <span style={{ color: '#888', fontSize: 14 }}>
            Didn&apos;t receive the email? <a href="/member/resend-token">Resend activation email</a>
          </span>
        </p>
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
        initialValues={{ agree_terms: false }}
      >
        <h2 style={{ marginBottom: 16 }}>Register</h2>
        <Form.Item label="Email" name="email" rules={[{ required: true, type: 'email', message: 'Please enter a valid email' }]}>
          <Input autoComplete="email" />
        </Form.Item>
        <Form.Item label="Full name" name="fullname" rules={[{ required: true, message: 'Please enter your full name' }]}>
          <Input autoComplete="name" />
        </Form.Item>
        <Form.Item label="Nickname (optional)" name="nickname">
          <Input autoComplete="nickname" />
        </Form.Item>
        <Form.Item label="Password" name="password" rules={[{ required: true, message: 'Please enter your password' }, { min: 8, message: 'At least 8 characters' }, { pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/, message: 'Include uppercase, lowercase, and number' }]}>
          <Input.Password autoComplete="new-password" />
        </Form.Item>
        <Form.Item label="Confirm password" name="password_confirm" dependencies={["password"]} rules={[{ required: true, message: 'Please confirm your password' }, ({ getFieldValue }) => ({ validator(_, value) { if (!value || getFieldValue('password') === value) { return Promise.resolve(); } return Promise.reject(new Error('Passwords do not match')); } })]}>
          <Input.Password autoComplete="new-password" />
        </Form.Item>
        <Form.Item name="agree_terms" valuePropName="checked" rules={[{ validator: (_, value) => value ? Promise.resolve() : Promise.reject(new Error('You must agree to the terms')) }]}>
          <Checkbox>I agree to the terms and conditions</Checkbox>
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
            Register
          </Button>
        </Form.Item>
        <div style={{ marginTop: 16, fontSize: 14 }}>
          Already have an account? <a href="/member/login">Login</a>
        </div>
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

export default RegisterForm;

// Expose setTurnstileToken for callback
if (typeof window !== 'undefined') {
  window.__setTurnstileToken = token => {
    if (window.__turnstile_setter) {
      window.__turnstile_setter(token);
    }
  };
}
