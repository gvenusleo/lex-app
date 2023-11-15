import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/utils/languages.dart";
import "package:lex/widgets/list_tile_group_title.dart";

class LanguageSettingPage extends StatefulWidget {
  const LanguageSettingPage({super.key});

  @override
  State<LanguageSettingPage> createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  // 已启用的语言
  List<String> _enabledLanguages = [];
  // 全部受支持语言
  Map<String, List<String>> _allLanguages = {};
  // 列表显示的语言
  Map<String, List<String>> _unabledLanguages = {};
  // 是否正在搜索
  bool _onSearch = false;

  @override
  void initState() {
    super.initState();
    initData();
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
                _onSearch = !_onSearch;
                if (!_onSearch) {
                  initData();
                }
              });
            },
            icon: const Icon(Icons.search_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: initData(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _enabledLanguages = snapshot.data!["enabledLanguages"];
            _allLanguages = snapshot.data!["allLanguages"];
            _unabledLanguages = snapshot.data!["unabledLanguages"];
            return Column(
              children: [
                buildSearchWidget(),
                Expanded(
                  child: ListView(
                    children: [
                      const ListTileGroupTitle(title: "已启用"),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        itemCount: _enabledLanguages.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            key: ValueKey(_enabledLanguages[index]),
                            value: true,
                            title: Text(_enabledLanguages[index]),
                            subtitle: Text(
                              _allLanguages[_enabledLanguages[index]]!
                                  .join("、"),
                            ),
                            secondary: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle_outlined),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              if (!value) {
                                setState(() {
                                  _unabledLanguages[_enabledLanguages[index]] =
                                      _allLanguages[_enabledLanguages[index]]!;
                                  _enabledLanguages.removeAt(index);
                                  prefs.setStringList(
                                      "enabledLanguages", _enabledLanguages);
                                });
                              }
                            },
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final String item =
                                _enabledLanguages.removeAt(oldIndex);
                            _enabledLanguages.insert(newIndex, item);
                            prefs.setStringList(
                                "enabledLanguages", _enabledLanguages);
                          });
                        },
                      ),
                      const ListTileGroupTitle(title: "未启用"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _unabledLanguages.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            value: false,
                            title: Text(_unabledLanguages.keys.toList()[index]),
                            subtitle: Text(
                              _unabledLanguages.values
                                  .toList()[index]
                                  .join("、")
                                  .toString(),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(
                                () {
                                  if (value) {
                                    _enabledLanguages.add(
                                        _unabledLanguages.keys.toList()[index]);
                                    _unabledLanguages.remove(
                                        _unabledLanguages.keys.toList()[index]);
                                    prefs.setStringList(
                                        "enabledLanguages", _enabledLanguages);
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
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
                decoration: InputDecoration(
                  hintText: "搜索语言",
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(48)),
                    borderSide: BorderSide(width: 0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  isDense: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Icon(
                      Icons.search_outlined,
                      size: 24,
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_outlined,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _onSearch = false;
                        });
                        initData();
                      },
                    ),
                  ),
                ),
                onChanged: (value) {
                  List<String> enabledLanguages =
                      prefs.getStringList("enabledLanguages") ??
                          [
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
                  Map<String, List<String>> unabledLanguages =
                      allTranslationLanguages();
                  unabledLanguages.removeWhere(
                      (key, value) => enabledLanguages.contains(key));
                  List<String> enableTemp = [];
                  Map<String, List<String>> unableTemp = {};
                  for (String language in enabledLanguages) {
                    if (language.contains(value)) {
                      enableTemp.add(language);
                    }
                  }
                  for (String language in unabledLanguages.keys) {
                    if (language.contains(value)) {
                      unableTemp[language] = unabledLanguages[language]!;
                    }
                  }
                  setState(() {
                    _enabledLanguages = enableTemp;
                    _unabledLanguages = unableTemp;
                  });
                },
              ),
            )
          : const SizedBox(),
    );
  }

  /// 初始化数据
  Future<Map<String, dynamic>> initData() async {
    List<String> enabledLanguages = prefs.getStringList("enabledLanguages") ??
        [
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
    Map<String, List<String>> allLanguages = allTranslationLanguages();
    Map<String, List<String>> unabledLanguages = allTranslationLanguages();
    unabledLanguages
        .removeWhere((key, value) => _enabledLanguages.contains(key));
    return {
      "enabledLanguages": enabledLanguages,
      "allLanguages": allLanguages,
      "unabledLanguages": unabledLanguages,
    };
  }
}
