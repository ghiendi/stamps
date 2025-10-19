
import React from 'react';
import Link from 'next/link';
import dayjs from 'dayjs';
import styles from './footer.module.css';

const FooterBar = () => (
  <div className={styles.main}>
    <div className={styles.info}>
      <div className={styles.left}>
        &copy;2024{dayjs().format('YYYY') != '2024' ? ` - ${dayjs().format('YYYY')}` : ''}&nbsp;
        <span className='logo1'>Stamps</span><span className='logo2'>.Gallery</span>. All rights reserved.
      </div>
      <div className={styles.right}>
        <Link href={`/docs/terms-of-use`} target='_blank'>Terms</Link>
        <Link href={`/docs/privacy-policy`} target='_blank'>Privacy</Link>
        <Link href={`/docs/dmca`} target='_blank'>DMCA</Link>
      </div>
    </div>
    <div className={styles.disclaimer}>
      <div>Disclaimer: Stamp images are for philatelic reference only. Copyright remains with respective postal authorities. This site may contain ads or membership fees, but images are not commercialized.</div>
      <div>DMCA Notice: Content is for educational use. Rights belong to original issuers. Report issues via email <Link href={'mailto:support@stamps.gallery'}>support@stamps.gallery</Link>.</div>
    </div>
  </div>
);

export default FooterBar;
