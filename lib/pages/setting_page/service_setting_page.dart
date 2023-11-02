import "dart:io";

import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_zhipuai.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_baidu.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_caiyun.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_minimax.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_niutrans.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_volcengine.dart";
import "package:lex/pages/setting_page/service_setting_utils/set_youdao.dart";
import "package:lex/widgets/list_tile_group_title.dart";
import "package:process_run/process_run.dart";

/// 翻译模型设置页面
class ServiceSettingPage extends StatefulWidget {
  const ServiceSettingPage({Key? key}) : super(key: key);

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
            "assets/service/bing.png",
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
            "assets/service/deepl.png",
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
            "assets/service/google.png",
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
            "assets/service/yandex.png",
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
            "assets/service/volcengine.png",
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
        // 火山翻译 Free
        ListTile(
          leading: Image.asset(
            "assets/service/cambridge_dict.png",
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
            "assets/service/baidu.png",
            width: 40,
            height: 40,
          ),
          title: const Text("百度翻译"),
          subtitle: const Text("设置百度翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("baidu"),
            onChanged: (value) {
              if ((prefs.getString("baiduAppID") ?? "").isEmpty ||
                  (prefs.getString("baiduAppKey") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置百度翻译接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setBaidu(context);
          },
        ),
        // 彩云小译
        ListTile(
          leading: Image.asset(
            "assets/service/caiyun.png",
            width: 40,
            height: 40,
          ),
          title: const Text("彩云小译"),
          subtitle: const Text("设置彩云小译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("caiyun"),
            onChanged: (value) {
              if ((prefs.getString("caiyunToken") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置彩云小译接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setCaiyun(context);
          },
        ),
        // 火山翻译
        ListTile(
          leading: Image.asset(
            "assets/service/volcengine.png",
            width: 40,
            height: 40,
          ),
          title: const Text("火山翻译"),
          subtitle: const Text("设置火山翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("volcengine"),
            onChanged: (value) {
              if ((prefs.getString("volcengineAccessKeyID") ?? "").isEmpty ||
                  (prefs.getString("volcengineSecretAccessKey") ?? "")
                      .isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置火山翻译接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setVolcengine(context);
          },
        ),
        // 小牛翻译
        ListTile(
          leading: Image.asset(
            "assets/service/niutrans.png",
            width: 40,
            height: 40,
          ),
          title: const Text("小牛翻译"),
          subtitle: const Text("设置小牛翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("niutrans"),
            onChanged: (value) {
              if ((prefs.getString("niutransApiKey") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置小牛翻译接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setNiutrans(context);
          },
        ),
        // 有道翻译
        ListTile(
          leading: Image.asset(
            "assets/service/youdao.png",
            width: 40,
            height: 40,
          ),
          title: const Text("有道翻译"),
          subtitle: const Text("设置有道翻译接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("youdao"),
            onChanged: (value) {
              if ((prefs.getString("youdaoAppKey") ?? "").isEmpty ||
                  (prefs.getString("youdaoAppID") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置有道翻译接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setYoudao(context);
          },
        ),
        const ListTileGroupTitle(title: "AI 大模型"),
        // MiniMax
        ListTile(
          leading: Image.asset(
            "assets/service/minimax.png",
            width: 40,
            height: 40,
          ),
          title: const Text("MiniMax"),
          subtitle: const Text("设置 MiniMax 接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("minimax"),
            onChanged: (value) {
              if ((prefs.getString("minimaxGroupID") ?? "").isEmpty ||
                  (prefs.getString("minimaxApiKey") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置 MiniMax 接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setMiniMax(context);
          },
        ),
        // 智谱 AI
        ListTile(
          leading: Image.asset(
            "assets/service/zhipuai.png",
            width: 40,
            height: 40,
          ),
          title: const Text("智谱 AI"),
          subtitle: const Text("设置智谱 AI 接口"),
          trailing: Checkbox(
            value: _enabledTranslationServices.contains("zhipuai"),
            onChanged: (value) {
              if ((prefs.getString("zhipuaiApiKey") ?? "").isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("请先设置智谱 AI 接口"),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
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
            setZhipuai(context);
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
            "assets/service/tesseract.png",
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
              } else {
                try {
                  var shell = Shell();
                  await shell.run(
                    "tesseract --version",
                  );
                  setState(() {
                    _enabledOcrServices.add("tesseract");
                  });
                  prefs.setStringList(
                      "enabledOcrServices", _enabledOcrServices);
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("请先安装 Tesseract"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
