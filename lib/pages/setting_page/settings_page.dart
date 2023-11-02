import "package:flutter/material.dart";
import "package:lex/pages/setting_page/history_page.dart";
import "package:lex/pages/setting_page/about_page.dart";
import "package:lex/pages/setting_page/app_setting_page.dart";
import "package:lex/pages/setting_page/hot_key_setting_page.dart";
import "package:lex/pages/setting_page/language_setting_page.dart";
import "package:lex/pages/setting_page/ocr_setting.dart";
import "package:lex/pages/setting_page/service_setting_page.dart";
import 'package:lex/pages/setting_page/translationg_setting_page.dart';
import "package:lex/widgets/setting_group_card.dart";

/// 设置页面主体
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedItem = "应用设置";
  Widget _selectedPage = const AppSettingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Divider(height: 0),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        width: 64,
                        height: 64,
                      ),
                      const SizedBox(height: 18),
                      SettingGroupCard(
                        icon: const Icon(Icons.laptop_windows_outlined),
                        title: "应用设置",
                        selected: _selectedItem == "应用设置",
                        onTap: () {
                          setState(() {
                            _selectedItem = "应用设置";
                            _selectedPage = const AppSettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.dashboard_outlined),
                        title: "服务设置",
                        selected: _selectedItem == "服务设置",
                        onTap: () {
                          setState(() {
                            _selectedItem = "服务设置";
                            _selectedPage = const ServiceSettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.translate_outlined),
                        title: "翻译设置",
                        selected: _selectedItem == "翻译设置",
                        onTap: () {
                          setState(() {
                            _selectedItem = "翻译设置";
                            _selectedPage = const TranslationSettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.crop_free_outlined),
                        title: "文字识别",
                        selected: _selectedItem == "文字识别",
                        onTap: () {
                          setState(() {
                            _selectedItem = "文字识别";
                            _selectedPage = const OcrSettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.language_outlined),
                        title: "内置语言",
                        selected: _selectedItem == "内置语言",
                        onTap: () {
                          setState(() {
                            _selectedItem = "内置语言";
                            _selectedPage = const LanguageSettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.keyboard_outlined),
                        title: "热键设置",
                        selected: _selectedItem == "热键设置",
                        onTap: () {
                          setState(() {
                            _selectedItem = "热键设置";
                            _selectedPage = const HotKeySettingPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.history_outlined),
                        title: "历史记录",
                        selected: _selectedItem == "历史记录",
                        onTap: () {
                          setState(() {
                            _selectedItem = "历史记录";
                            _selectedPage = const HistoryPage();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingGroupCard(
                        icon: const Icon(Icons.info_outline),
                        title: "关于应用",
                        selected: _selectedItem == "关于应用",
                        onTap: () {
                          setState(() {
                            _selectedItem = "关于应用";
                            _selectedPage = const AboutPage();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _selectedPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
