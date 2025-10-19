// Header component: logo left, global search right

import React from 'react';
import Link from 'next/link';
import styles from './header.module.css';

const HeaderBar = () => (
  <div className={styles.main}>
    <div>
      <Link href='/stamp'>
        <img className={styles.logo} src={'/images/logo_v2.svg'} alt='Logo' />
      </Link>
    </div>
  </div>
);

export default HeaderBar;
