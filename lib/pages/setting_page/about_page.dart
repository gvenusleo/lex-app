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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    "Lex 是一款开源划词翻译翻译软件，"
                    "目前已经接入 Deepl、Google、Bing、"
                    "百度翻译、彩云小译、有道翻译、MiniMax、"
                    "智谱 AI 等十余种翻译和 AI 大模型服务。"
                    "现已支持 Windows、macOS、Linux 平台，"
                    "响应迅速，使用方便。",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "软件主页：",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        child: const Text(
                          "https://lex-app.cn",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          launchUrlString(
                            "https://lex-app.cn",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "开源地址：",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        child: const Text(
                          "https://github.com/gvenusleo/lex-app",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          launchUrlString(
                            "https://github.com/gvenusleo/lex-app",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "开源协议：",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        child: const Text(
                          "GUN GPL-3.0",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          launchUrlString(
                            "https://github.com/gvenusleo/lex-app/blob/main/LICENSE",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "联系作者：",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        child: const Text(
                          "https://jike.city/gvenusleo",
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          launchUrlString(
                            "https://jike.city/gvenusleo",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
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
