import "package:flutter/material.dart";
import "package:lex/pages/setting_page/history_page.dart";
import "package:lex/pages/setting_page/about_page.dart";
import "package:lex/pages/setting_page/app_setting_page.dart";
import "package:lex/pages/setting_page/hot_key_setting_page.dart";
import "package:lex/pages/setting_page/language_setting_page.dart";
import "package:lex/pages/setting_page/ocr_setting.dart";
import "package:lex/pages/setting_page/service_setting_page.dart";
import "package:lex/pages/setting_page/translationg_setting_page.dart";
import "package:lex/widgets/setting_group_card.dart";

/// 设置页面主体
class SettingsPage extends StatefulWidget {
  final String focusedItem;

  const SettingsPage({
    super.key,
    this.focusedItem = "应用设置",
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedItem;
  final Map<String, Widget> _pages = {
    "应用设置": const AppSettingPage(),
    "服务设置": const ServiceSettingPage(),
    "翻译设置": const TranslationSettingPage(),
    "文字识别": const OcrSettingPage(),
    "内置语言": const LanguageSettingPage(),
    "热键设置": const HotKeySettingPage(),
    "历史记录": const HistoryPage(),
    "关于应用": const AboutPage(),
  };
  final Map<String, Icon> _icons = {
    "应用设置": const Icon(Icons.laptop_windows_outlined),
    "服务设置": const Icon(Icons.dashboard_outlined),
    "翻译设置": const Icon(Icons.translate_outlined),
    "文字识别": const Icon(Icons.crop_free_outlined),
    "内置语言": const Icon(Icons.language_outlined),
    "热键设置": const Icon(Icons.keyboard_outlined),
    "历史记录": const Icon(Icons.history_outlined),
    "关于应用": const Icon(Icons.info_outline),
  };

  @override
  void initState() {
    _selectedItem = widget.focusedItem;
    super.initState();
  }

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
                      vertical: 24,
                      horizontal: 12,
                    ),
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        width: 52,
                        height: 52,
                      ),
                      const SizedBox(height: 24),
                      ..._pages.cast<String, Widget>().keys.map(
                            (e) => SettingGroupCard(
                              icon: _icons[e]!,
                              title: e,
                              selected: _selectedItem == e,
                              onTap: () {
                                setState(() {
                                  _selectedItem = e;
                                });
                              },
                            ),
                          ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _pages[_selectedItem]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
