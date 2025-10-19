import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { Spin, Result, Button } from 'antd';

export default function ActivationPage() {
  const router = useRouter();
  const { token } = router.query;
  const [status, setStatus] = useState('pending'); // 'pending', 'success', 'error'
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (!token) return;
    (async () => {
      try {
        const resp = await fetch(`/api/member/activate?token=${token}`);
        const data = await resp.json();
        if (resp.ok && data.success) {
          setStatus('success');
        } else {
          setStatus('error');
          setMessage(data.error || 'Activation failed');
        }
      } catch (err) {
        setStatus('error');
        setMessage('Activation failed');
      }
    })();
  }, [token]);

  if (status === 'pending') {
    return <div style={{ textAlign: 'center', marginTop: 80 }}><Spin size="large" /></div>;
  }

  if (status === 'success') {
    return (
      <Result
        status="success"
        title="Account activated!"
        subTitle="Your account has been activated. You can now log in."
        extra={<Button type="primary" href="/member/login">Go to Login</Button>}
      />
    );
  }

  return (
    <Result
      status="error"
      title="Activation failed"
      subTitle={message || 'Invalid or expired activation link.'}
      extra={<Button type="primary" href="/member/register">Register again</Button>}
    />
  );
}
