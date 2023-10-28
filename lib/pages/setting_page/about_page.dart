import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 关于页面
class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

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
                width: 84,
              ),
              const SizedBox(width: 12),
              Text(
                "质感翻译\n$version",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.public_outlined),
            title: const Text("软件官网"),
            onTap: () {
              launchUrlString(
                "https://metranslate.top",
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: const Text("使用指南"),
            onTap: () {
              launchUrlString(
                "https://metranslate.top/guide/intro.html",
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.update_outlined),
            title: const Text("更新日志"),
            onTap: () {
              launchUrlString(
                "https://metranslate.top/changelog.html",
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("联系作者"),
            onTap: () {
              launchUrlString(
                "https://jike.city/gvenusleo",
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text("开源地址"),
            onTap: () {
              launchUrlString(
                "https://github.com/gvenusleo/MeTranslate",
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}
