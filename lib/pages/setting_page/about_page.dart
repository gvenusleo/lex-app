import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 关于页面
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                width: 64,
                height: 64,
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text(
                    "Lex",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28),
                  ),
                  Text(
                    version,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    "Lex 是一款开源划词翻译软件，"
                    "目前已经接入 Deepl、Google、Bing、"
                    "百度翻译、彩云小译、有道翻译、MiniMax、"
                    "智谱 AI 等十余种翻译和 AI 大模型服务。"
                    "现已支持 Windows、macOS、Linux 平台，"
                    "响应迅速，使用方便。",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  LinkItem(
                    text: "软件主页：",
                    url: "https://lex-app.cn",
                  ),
                  LinkItem(
                    text: "开源地址：",
                    url: "https://github.com/gvenusleo/lex-app",
                  ),
                  LinkItem(
                    text: "开源协议：",
                    url:
                        "https://github.com/gvenusleo/lex-app/blob/main/LICENSE",
                    urlText: "GUN GPL-3.0",
                  ),
                  LinkItem(
                    text: "联系作者：",
                    url: "https://jike.city/gvenusleo",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LinkItem extends StatelessWidget {
  final String text;
  final String url;
  final String? urlText;

  const LinkItem({
    super.key,
    required this.text,
    required this.url,
    this.urlText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 16)),
        TextButton(
          child: Text(
            urlText ?? url,
            style: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            launchUrlString(
              url,
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    );
  }
}
