// Menu component: Stamps, Collections, Member (submenu)
import { Menu } from 'antd';
import styles from './menu.module.css';
import { useRouter } from 'next/router';

const items = [
  { label: 'Stamps', key: '/stamps' },
  { label: 'Collections', key: '/collections' },
  {
    label: 'Member',
    key: 'member',
    children: [
      { label: 'Register', key: '/member/register' },
      { label: 'Login', key: '/member/login' },
    ],
  },
];

const MenuBar = () => {
  const router = useRouter();
  // Xác định key đang được chọn dựa vào pathname
  let selectedKey = router.pathname;
  // Nếu là trang member thì chọn đúng submenu
  if (selectedKey.startsWith('/member/')) {
    selectedKey = selectedKey;
  }
  return (
    <Menu
      mode='horizontal'
      items={items}
      className={styles.menu_bar}
      selectedKeys={[selectedKey]}
    />
  );
};

export default MenuBar;
