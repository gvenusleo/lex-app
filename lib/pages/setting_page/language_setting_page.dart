import 'package:flutter/material.dart';
import 'package:metranslate/global.dart';
import 'package:metranslate/utils/languages.dart';

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({Key? key}) : super(key: key);

  @override
  State<LanguageSettingPage> createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  // 已启用的语言
  late List<String> _enabledLanguages;
  // 全部受支持语言
  late Map<String, List<String>> _allLanguages;
  // 列表显示的语言
  late Map<String, List<String>> _showLanguages;
  // late Map<String, List<String>>
  // 是否正在搜索
  bool _onSearch = false;

  @override
  void initState() {
    _enabledLanguages = prefs.getStringList("enabledLanguages") ??
        [
          "自动",
          "中文",
          "英语",
          "日语",
          "韩语",
          "法语",
          "德语",
          "俄语",
          "意大利语",
          "葡萄牙语",
          "繁体中文",
        ];
    _allLanguages = allLanguages();
    _showLanguages = _allLanguages;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("内置语言"),
        actions: [
          // 搜索语言
          IconButton(
            onPressed: () {
              setState(() {
                _showLanguages = _allLanguages;
                _onSearch = !_onSearch;
              });
            },
            icon: const Icon(Icons.search_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          buildSearchWidget(),
          Expanded(
            child: ListView.builder(
              itemCount: _showLanguages.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: _enabledLanguages
                      .contains(_showLanguages.keys.toList()[index]),
                  title: Text(_showLanguages.keys.toList()[index]),
                  subtitle: Text(
                      _showLanguages[_showLanguages.keys.toList()[index]]!
                          .join("、")),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(
                      () {
                        if (value) {
                          _enabledLanguages
                              .add(_showLanguages.keys.toList()[index]);
                        } else {
                          _enabledLanguages
                              .remove(_showLanguages.keys.toList()[index]);
                        }
                        prefs.setStringList(
                            "enabledLanguages", _enabledLanguages);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 搜索框
  Widget buildSearchWidget() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      },
      child: _onSearch
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "搜索语言",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48)),
                    borderSide: BorderSide(width: 0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Icon(
                      Icons.search_outlined,
                      size: 24,
                    ),
                  ),
                ),
                onChanged: (value) {
                  Map<String, List<String>> temp = {};
                  for (String language in _allLanguages.keys) {
                    if (language.contains(value)) {
                      temp[language] = _allLanguages[language]!;
                    }
                  }
                  setState(() {
                    _showLanguages = temp;
                  });
                },
              ),
            )
          : const SizedBox(),
    );
  }
}
