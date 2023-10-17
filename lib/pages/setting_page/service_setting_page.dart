import "package:flutter/material.dart";
import "package:metranslate/global.dart";
import 'package:metranslate/pages/setting_page/service_setting_utils/set_zhipuai.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_baidu.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_caiyun.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_minimax.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_niutrans.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_volcengine.dart';
import 'package:metranslate/pages/setting_page/service_setting_utils/set_youdao.dart';
import "package:metranslate/widgets/list_tile_group_title.dart";

/// 翻译模型设置页面
class ServiceSettingPage extends StatefulWidget {
  const ServiceSettingPage({Key? key}) : super(key: key);

  @override
  State<ServiceSettingPage> createState() => _ServiceSettingPageState();
}

class _ServiceSettingPageState extends State<ServiceSettingPage> {
  final List<String> _useService = prefs.getStringList("useService") ??
      [
        "deeplFree",
        "google",
        "yandex",
        "volcengineFree",
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("翻译服务"),
      ),
      body: ListView(
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
              value: _useService.contains("bing"),
              onChanged: (value) {
                if (_useService.contains("bing")) {
                  setState(() {
                    _useService.remove("bing");
                  });
                } else {
                  setState(() {
                    _useService.add("bing");
                  });
                }
                prefs.setStringList("useService", _useService);
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
              value: _useService.contains("deeplFree"),
              onChanged: (value) {
                if (_useService.contains("deeplFree")) {
                  setState(() {
                    _useService.remove("deeplFree");
                  });
                } else {
                  setState(() {
                    _useService.add("deeplFree");
                  });
                }
                prefs.setStringList("useService", _useService);
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
              value: _useService.contains("google"),
              onChanged: (value) {
                if (_useService.contains("google")) {
                  setState(() {
                    _useService.remove("google");
                  });
                } else {
                  setState(() {
                    _useService.add("google");
                  });
                }
                prefs.setStringList("useService", _useService);
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
              value: _useService.contains("yandex"),
              onChanged: (value) {
                if (_useService.contains("yandex")) {
                  setState(() {
                    _useService.remove("yandex");
                  });
                } else {
                  setState(() {
                    _useService.add("yandex");
                  });
                }
                prefs.setStringList("useService", _useService);
              },
            ),
          ),
          // 火山翻译
          ListTile(
            leading: Image.asset(
              "assets/service/volcengine.png",
              width: 40,
              height: 40,
            ),
            title: const Text("火山翻译 Free"),
            subtitle: const Text("开箱即用"),
            trailing: Checkbox(
              value: _useService.contains("volcengineFree"),
              onChanged: (value) {
                if (_useService.contains("volcengineFree")) {
                  setState(() {
                    _useService.remove("volcengineFree");
                  });
                } else {
                  setState(() {
                    _useService.add("volcengineFree");
                  });
                }
                prefs.setStringList("useService", _useService);
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
              value: _useService.contains("baidu"),
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
                  if (_useService.contains("baidu")) {
                    setState(() {
                      _useService.remove("baidu");
                    });
                  } else {
                    setState(() {
                      _useService.add("baidu");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("caiyun"),
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
                  if (_useService.contains("caiyun")) {
                    setState(() {
                      _useService.remove("caiyun");
                    });
                  } else {
                    setState(() {
                      _useService.add("caiyun");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("volcengine"),
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
                  if (_useService.contains("volcengine")) {
                    setState(() {
                      _useService.remove("volcengine");
                    });
                  } else {
                    setState(() {
                      _useService.add("volcengine");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("niutrans"),
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
                  if (_useService.contains("niutrans")) {
                    setState(() {
                      _useService.remove("niutrans");
                    });
                  } else {
                    setState(() {
                      _useService.add("niutrans");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("youdao"),
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
                  if (_useService.contains("youdao")) {
                    setState(() {
                      _useService.remove("youdao");
                    });
                  } else {
                    setState(() {
                      _useService.add("youdao");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("minimax"),
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
                  if (_useService.contains("minimax")) {
                    setState(() {
                      _useService.remove("minimax");
                    });
                  } else {
                    setState(() {
                      _useService.add("minimax");
                    });
                  }
                  prefs.setStringList("useService", _useService);
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
              value: _useService.contains("zhipuai"),
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
                  if (_useService.contains("zhipuai")) {
                    setState(() {
                      _useService.remove("zhipuai");
                    });
                  } else {
                    setState(() {
                      _useService.add("zhipuai");
                    });
                  }
                  prefs.setStringList("useService", _useService);
                }
              },
            ),
            onTap: () async {
              setZhipuai(context);
            },
          ),
        ],
      ),
    );
  }
}
