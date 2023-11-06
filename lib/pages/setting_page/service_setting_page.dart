import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/services/ocr/baidu.dart";
import "package:lex/services/ocr/tesseract.dart";
import "package:lex/services/translation/baidu.dart";
import "package:lex/services/translation/caiyun.dart";
import "package:lex/services/translation/minimax.dart";
import "package:lex/services/translation/niutrans.dart";
import "package:lex/services/translation/volcengine.dart";
import "package:lex/services/translation/youdao.dart";
import "package:lex/services/translation/zhipuai.dart";
import "package:lex/utils/service_map.dart";
import "package:lex/widgets/list_tile_group_title.dart";
import "package:local_notifier/local_notifier.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 翻译模型设置页面
class ServiceSettingPage extends StatefulWidget {
  const ServiceSettingPage({super.key});

  @override
  State<ServiceSettingPage> createState() => _ServiceSettingPageState();
}

class _ServiceSettingPageState extends State<ServiceSettingPage>
    with TickerProviderStateMixin {
  final List<String> _enabledTranslationServices =
      prefs.getStringList("enabledTranslationServices") ??
          [
            "bing",
            "deeplFree",
            "google",
            "yandex",
            "volcengineFree",
          ];
  final List<String> _enabledOcrServices =
      prefs.getStringList("enabledOcrServices") ?? [];
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("服务设置"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          splashBorderRadius: BorderRadius.circular(8),
          tabs: const [
            Tab(
              text: "翻译服务",
            ),
            Tab(
              text: "文字识别",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTranslationServices(),
          buildOcrServices(),
        ],
      ),
    );
  }

  /// 翻译服务列表
  Widget buildTranslationServices() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: [
        const ListTileGroupTitle(title: "无需配置"),
        // Bing 翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["bing"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("Bing 翻译"),
          subtitle: const Text("开箱即用"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("bing"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("bing")) {
                setState(() {
                  _enabledTranslationServices.remove("bing");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("bing");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        // Deepl 翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["deeplFree"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("DeepL 翻译"),
          subtitle: const Text("开箱即用"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("deeplFree"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("deeplFree")) {
                setState(() {
                  _enabledTranslationServices.remove("deeplFree");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("deeplFree");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        // Google 翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["google"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("Google 翻译"),
          subtitle: const Text("可能需要使用代理"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("google"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("google")) {
                setState(() {
                  _enabledTranslationServices.remove("google");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("google");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        // Yandex 翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["yandex"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("Yandex 翻译"),
          subtitle: const Text("开箱即用"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("yandex"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("yandex")) {
                setState(() {
                  _enabledTranslationServices.remove("yandex");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("yandex");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        // 火山翻译 Free
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["volcengineFree"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("火山翻译 Free"),
          subtitle: const Text("开箱即用"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("volcengineFree"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("volcengineFree")) {
                setState(() {
                  _enabledTranslationServices.remove("volcengineFree");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("volcengineFree");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        // 剑桥词典
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["cambridgeDict"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("剑桥词典"),
          subtitle: const Text("开箱即用"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("cambridgeDict"),
            onChanged: (value) {
              if (_enabledTranslationServices.contains("cambridgeDict")) {
                setState(() {
                  _enabledTranslationServices.remove("cambridgeDict");
                });
              } else {
                setState(() {
                  _enabledTranslationServices.add("cambridgeDict");
                });
              }
              prefs.setStringList(
                  "enabledTranslationServices", _enabledTranslationServices);
            },
          ),
        ),
        const ListTileGroupTitle(title: "需要配置"),
        // 百度翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["baidu"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("百度翻译"),
          subtitle: const Text("设置百度翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("baidu"),
            onChanged: (value) {
              if (!BaiduTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "百度翻译接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  BaiduTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("baidu")) {
                  setState(() {
                    _enabledTranslationServices.remove("baidu");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("baidu");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            BaiduTranslation.setApi(context);
          },
        ),
        // 彩云小译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["caiyun"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("彩云小译"),
          subtitle: const Text("设置彩云小译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("caiyun"),
            onChanged: (value) {
              if (!CaiyunTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "彩云小译接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  CaiyunTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("caiyun")) {
                  setState(() {
                    _enabledTranslationServices.remove("caiyun");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("caiyun");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            CaiyunTranslation.setApi(context);
          },
        ),
        // 火山翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["volcengine"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("火山翻译"),
          subtitle: const Text("设置火山翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("volcengine"),
            onChanged: (value) {
              if (!VolcengineTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "火山翻译接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  VolcengineTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("volcengine")) {
                  setState(() {
                    _enabledTranslationServices.remove("volcengine");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("volcengine");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            VolcengineTranslation.setApi(context);
          },
        ),
        // 小牛翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["niutrans"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("小牛翻译"),
          subtitle: const Text("设置小牛翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("niutrans"),
            onChanged: (value) {
              if (!NiutransTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "小牛翻译接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  NiutransTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("niutrans")) {
                  setState(() {
                    _enabledTranslationServices.remove("niutrans");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("niutrans");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            NiutransTranslation.setApi(context);
          },
        ),
        // 有道翻译
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["youdao"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("有道翻译"),
          subtitle: const Text("设置有道翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("youdao"),
            onChanged: (value) {
              if (!YoudaoTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "有道翻译接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  YoudaoTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("youdao")) {
                  setState(() {
                    _enabledTranslationServices.remove("youdao");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("youdao");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            YoudaoTranslation.setApi(context);
          },
        ),
        const ListTileGroupTitle(title: "AI 大模型"),
        // MiniMax
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["minimax"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("MiniMax"),
          subtitle: const Text("设置 MiniMax 接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("minimax"),
            onChanged: (value) {
              if (!MiniMaxTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "MiniMax 接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  MiniMaxTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("minimax")) {
                  setState(() {
                    _enabledTranslationServices.remove("minimax");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("minimax");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            MiniMaxTranslation.setApi(context);
          },
        ),
        // 智谱 AI
        ListTile(
          leading: Image.asset(
            translationServiceLogoMap()["zhipuai"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("智谱 AI"),
          subtitle: const Text("设置智谱 AI 接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("zhipuai"),
            onChanged: (value) async {
              if (!ZhipuaiTranslation.checkApi()) {
                LocalNotification notification = LocalNotification(
                  title: "Lex",
                  body: "智谱 AI 接口未设置！",
                  actions: [
                    LocalNotificationAction(
                      text: "现在设置",
                    ),
                  ],
                );
                notification.onClickAction = (actionIndex) {
                  ZhipuaiTranslation.setApi(context);
                };
                notification.show();
              } else {
                if (_enabledTranslationServices.contains("zhipuai")) {
                  setState(() {
                    _enabledTranslationServices.remove("zhipuai");
                  });
                } else {
                  setState(() {
                    _enabledTranslationServices.add("zhipuai");
                  });
                }
                prefs.setStringList(
                    "enabledTranslationServices", _enabledTranslationServices);
              }
            },
          ),
          onTap: () async {
            ZhipuaiTranslation.setApi(context);
          },
        ),
      ],
    );
  }

  /// 文字识别服务列表
  Widget buildOcrServices() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: [
        const ListTileGroupTitle(title: "本地服务"),
        ListTile(
          leading: Image.asset(
            ocrServiceLogoMap()["tesseract"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("Teseract"),
          subtitle: const Text("基于本地的 OCR 服务"),
          trailing: Checkbox(
            value: _enabledOcrServices.contains("tesseract"),
            onChanged: (value) async {
              if (_enabledOcrServices.contains("tesseract")) {
                setState(() {
                  _enabledOcrServices.remove("tesseract");
                });
                prefs.setStringList(
                  "enabledOcrServices",
                  _enabledOcrServices,
                );
              } else {
                if (await TesseractOcr.isInstalled()) {
                  setState(() {
                    _enabledOcrServices.add("tesseract");
                  });
                  prefs.setStringList(
                      "enabledOcrServices", _enabledOcrServices);
                } else {
                  if (!mounted) return;
                  LocalNotification notification = LocalNotification(
                    title: "Lex",
                    body: "Tesseract 未安装！",
                    actions: [
                      LocalNotificationAction(
                        text: "现在安装",
                      ),
                    ],
                  );
                  notification.onClickAction = (actionIndex) {
                    launchUrlString(
                      "https://tesseract-ocr.github.io/tessdoc/Installation.html",
                      mode: LaunchMode.externalApplication,
                    );
                  };
                  notification.show();
                }
              }
            },
          ),
        ),
        const ListTileGroupTitle(title: "联网服务"),
        ListTile(
          leading: Image.asset(
            ocrServiceLogoMap()["baidu"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("百度文字识别"),
          subtitle: const Text("百度通用高精度文字识别"),
          trailing: Checkbox(
            value: _enabledOcrServices.contains("baidu"),
            onChanged: (value) async {
              if (_enabledOcrServices.contains("baidu")) {
                setState(() {
                  _enabledOcrServices.remove("baidu");
                });
                prefs.setStringList(
                  "enabledOcrServices",
                  _enabledOcrServices,
                );
              } else {
                if (!BaiduOcr.checkApi()) {
                  LocalNotification notification = LocalNotification(
                    title: "Lex",
                    body: "百度文字识别接口未设置！",
                    actions: [
                      LocalNotificationAction(
                        text: "现在设置",
                      ),
                    ],
                  );
                  notification.onClickAction = (actionIndex) {
                    BaiduOcr.setApi(context);
                  };
                  notification.show();
                } else {
                  setState(() {
                    _enabledOcrServices.add("baidu");
                  });
                  prefs.setStringList(
                    "enabledOcrServices",
                    _enabledOcrServices,
                  );
                }
              }
            },
          ),
          onTap: () async {
            BaiduOcr.setApi(context);
          },
        ),
      ],
    );
  }
}
