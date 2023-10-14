import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  lang: "zh-CN",
  title: "质感翻译",
  // titleTemplate: false,
  description: "快速、方便的跨平台划词翻译软件，支持多个翻译服务和 AI 大模型",
  appearance: true,
  lastUpdated: true,

  cleanUrls: false,

  sitemap: {
    hostname: "https://vitepress.dev",
    transformItems(items) {
      return items.filter((item) => !item.url.includes("migration"));
    },
  },

  head: [
    ["link", { rel: "icon", href: "/logo.svg" }],
    ["meta", { name: "theme-color", content: "#0788FF" }],
  ],

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: "/logo.svg",
    siteTitle: "质感翻译",

    outline: {
      level: [2, 3],
      label: "页面大纲",
    },

    nav: [
      { text: "主页", link: "/" },
      { text: "使用指南", link: "/guide/intro", activeMatch: "/guide/" },
      { text: "更新日志", link: "/changelog" },
      { text: "关于作者", link: "/about" },
    ],

    sidebar: {
      "/guide": [
        {
          text: "快速开始",
          collapsed: false,
          items: [
            { text: "软件介绍", link: "/guide/intro" },
            { text: "下载安装", link: "/guide/install" },
          ],
        },
        {
          text: "软件配置",
          collapsed: false,
          items: [
            { text: "应用设置", link: "/guide/app_setting" },
            { text: "全局字体", link: "/guide/font_setting" },
            { text: "翻译服务", link: "/guide/service" },
            { text: "翻译设置", link: "/guide/translate_setting" },
            { text: "热键设置", link: "/guide/hotkey_setting" },
            { text: "历史记录", link: "/guide/history" },
          ],
        },
        {
          text: "API 接入",
          collapsed: false,
          items: [
            { text: "百度翻译", link: "/guide/baidu" },
            { text: "彩云小译", link: "/guide/caiyun" },
            { text: "火山翻译", link: "/guide/volcengine" },
            { text: "小牛翻译", link: "/guide/niutrans" },
            { text: "有道翻译", link: "/guide/youdao" },
            { text: "MiniMax", link: "/guide/minimax" },
            { text: "智谱 AI", link: "/guide/zhipuai" },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/gvenusleo/MeTranslate" },
    ],

    footer: {
      message: "Released under the GUN GPL-3.0 License.",
      copyright: "Copyright © 2023-present liuyuxin",
    },

    lastUpdated: {
      text: "更新时间",
      formatOptions: {
        dateStyle: "full",
        timeStyle: "medium",
      },
    },

    docFooter: {
      prev: "上一页",
      next: "下一页",
    },

    search: {
      provider: "local",
    },

    darkModeSwitchLabel: "切换主题",
    sidebarMenuLabel: "目录",
    returnToTopLabel: "返回顶部",
  },
});
