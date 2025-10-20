import dynamic from 'next/dynamic';

const ResendTokenForm = dynamic(() => import('@/components/member/resend_token_form'), { ssr: false });

export default function ResendTokenPage() {
  return <ResendTokenForm />;
}
