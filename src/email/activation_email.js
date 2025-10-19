import { EMAIL_FOOTER } from './footer';

export function get_activation_email({ fullname, activation_link }) {
  return `
    <div style="font-size:15px;">
      Hello ${fullname},<br/><br/>
      Thank you for registering at Stamps.Gallery.<br/>
      Please activate your account by clicking the link below:<br/>
      <a href="${activation_link}" style="color:#1976d2;">Activate Account</a><br/><br/>
      If you did not request this, please ignore this email.<br/>
    </div>
    ${EMAIL_FOOTER}
  `;
}
