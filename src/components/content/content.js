// Content section wrapper
import React from 'react';
import { Layout } from 'antd';

const { Content } = Layout;

const ContentSection = ({ children }) => (
  <Content style={{ padding: '8px 0', background: '#fff', minHeight: 360 }}>
    {children}
  </Content>
);

export default ContentSection;
