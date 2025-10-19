import "@/styles/globals.css";
import "antd/dist/reset.css";
import { Layout, ConfigProvider } from "antd";
import themeConfig from "@/styles/theme";
import HeaderBar from "@/components/header/header";
import MenuBar from "@/components/menu/menu";
import ContentSection from "@/components/content/content";
import FooterBar from "@/components/footer/footer";

export default function App({ Component, pageProps }) {
  return (
    <ConfigProvider theme={themeConfig}>
      <div className="main-wrapper">
        <Layout>
          <HeaderBar />
          <MenuBar />
          <ContentSection>
            <Component {...pageProps} />
          </ContentSection>
          <FooterBar />
        </Layout>
      </div>
    </ConfigProvider>
  );
}
