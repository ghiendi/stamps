import { EMAIL_FOOTER } from './footer';

export function get_welcome_email({ fullname }) {
  return `
    <div style="font-size:15px;">
      Hello ${fullname},<br/><br/>
      Your account has been successfully activated.<br/>
      Welcome to Stamps.Gallery!<br/>
      You can now login and start using all features.<br/>
    </div>
    ${EMAIL_FOOTER}
  `;
}
