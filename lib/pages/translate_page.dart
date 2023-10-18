import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:metranslate/global.dart";
import "package:metranslate/modules/history_item.dart";
import 'package:metranslate/utils/check_api.dart';
import 'package:metranslate/utils/languages.dart';
import 'package:metranslate/utils/service_map.dart';
import 'package:metranslate/utils/translate_service/baidu.dart';
import 'package:metranslate/utils/translate_service/bing.dart';
import 'package:metranslate/utils/translate_service/caiyun.dart';
import 'package:metranslate/utils/translate_service/deepl_free.dart';
import 'package:metranslate/utils/translate_service/google.dart';
import 'package:metranslate/utils/translate_service/minimax.dart';
import 'package:metranslate/utils/translate_service/niutrans.dart';
import 'package:metranslate/utils/translate_service/volcengine.dart';
import 'package:metranslate/utils/translate_service/volcengine_free.dart';
import 'package:metranslate/utils/translate_service/yandex.dart';
import 'package:metranslate/utils/translate_service/youdao.dart';
import 'package:metranslate/utils/translate_service/zhipuai.dart';

/// 翻译页面
class TranslatePage extends StatefulWidget {
  const TranslatePage({
    Key? key,
    this.selectedText,
  }) : super(key: key);

  // 选中的文本
  final String? selectedText;

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  // 输入框控制器
  final _inputController = TextEditingController();
  // 输出框控制器
  late Map<String, TextEditingController> _outputControllers;
  // 输出框文字颜色
  late Map<String, Color?> _outputTextColor;
  // 翻译语言
  final List<String> _languages = prefs.getStringList("enabledLanguages") ??
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
  // 翻译服务
  late List<String> _useService;
  // 是否正在翻译
  late Map<String, bool> _isOnTranslation;
  // 原文语言
  String _fromLanguage = initFromLanguage();
  // 目标语言
  String _toLanguage = initToLanguage();

  @override
  void initState() {
    _useService = prefs.getStringList("useService") ??
        [
          "bing",
          "deeplFree",
          "google",
          "yandex",
          "volcengineFree",
        ];
    _outputControllers = Map.fromEntries(
      _useService.map(
        (e) => MapEntry(e, TextEditingController()),
      ),
    );
    _outputTextColor = Map.fromEntries(
      _useService.map((e) => MapEntry(e, null)),
    );
    _isOnTranslation = Map.fromEntries(
      _useService.map((e) => MapEntry(e, false)),
    );
    if (widget.selectedText != null) {
      _inputController.text = widget.selectedText!;
      List<Future> futures = [];
      for (String service in _useService) {
        futures.add(_translateFunc(service));
      }
      Future.wait(futures).then((_) => _autoCopyFunc());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 输入框
          Card(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Column(
              children: [
                TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 100,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  onSubmitted: (value) {
                    List<Future> futures = [];
                    for (String service in _useService) {
                      futures.add(_translateFunc(service));
                    }
                    Future.wait(futures).then((_) => _autoCopyFunc());
                  },
                  textInputAction: TextInputAction.done,
                ),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        _inputController.clear();
                      },
                      icon: const Icon(Icons.backspace_outlined, size: 20),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      // tooltip: "清空",
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.getData("text/plain").then((value) {
                          if (value != null) {
                            _inputController.text = value.text!;
                          }
                        });
                      },
                      icon: const Icon(Icons.paste_outlined, size: 20),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      // tooltip: "粘贴",
                    ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () {
                        List<Future> futures = [];
                        for (String service in _useService) {
                          futures.add(_translateFunc(service));
                        }
                        Future.wait(futures).then((_) => _autoCopyFunc());
                      },
                      child: const Text("翻译"),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // 翻译语言
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  selectLanguageFunc("from", _fromLanguage);
                },
                child: Text(_fromLanguage),
              ),
              IconButton(
                onPressed: _swapLanguageFunc,
                icon: const Icon(Icons.swap_horiz_outlined),
                padding: const EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
                // tooltip: "交换语言",
              ),
              TextButton(
                onPressed: () async {
                  selectLanguageFunc("to", _toLanguage);
                },
                child: Text(_toLanguage),
              ),
            ],
          ),
          // 输出框
          for (String service in _useService)
            Card(
              margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _outputControllers[service],
                    minLines: 1,
                    maxLines: 100,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                      isDense: true,
                    ),
                    style: TextStyle(
                      color: _outputTextColor[service],
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Image.asset(
                        serviceLogoMap()[service]!,
                        width: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        serviceMap()[service]!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _outputControllers[service]!.clear();
                        },
                        icon: const Icon(Icons.backspace_outlined, size: 20),
                        padding: const EdgeInsets.all(0),
                        visualDensity: VisualDensity.compact,
                        // tooltip: "清空",
                      ),
                      IconButton(
                        onPressed: () => _copyResultFunc(service),
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        padding: const EdgeInsets.all(0),
                        visualDensity: VisualDensity.compact,
                        // tooltip: "复制",
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 翻译
  Future<void> _translateFunc(String service, {String? text}) async {
    text ??= _inputController.text;
    if (text.isEmpty) {
      return;
    }
    if (!checkAPI(service)) {
      _outputControllers[service]!.text = "请先设置 API 接口";
      setState(() {
        _outputTextColor[service] = Colors.red;
      });
      return;
    }
    setState(() {
      _outputTextColor[service] = null;
      _isOnTranslation[service] = true;
    });
    _outputAnimationFunc(service);
    switch (service) {
      case "bing":
        try {
          // 通过 Bing 翻译
          String result = await translateByBing(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["bing"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["bing"] = Colors.red;
              });
              _outputControllers["bing"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["bing"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "bing"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["bing"] = false;
            _outputTextColor["bing"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["bing"]!.text = "翻译失败，请检查网络状态";
        }
      case "deeplFree":
        try {
          // 通过 DeepL Free 翻译
          String result = await translateByDeeplFree(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["deeplFree"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["deeplFree"] = Colors.red;
              });
              _outputControllers["deeplFree"]!.text = result.split(":").last;
            } else {
              _outputControllers["deeplFree"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "deeplFree"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["deeplFree"] = false;
            _outputTextColor["deeplFree"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["deeplFree"]!.text = "翻译失败，请检查网络状态";
        }
      case "google":
        try {
          // 通过 Google 翻译
          String result = await translateByGoogle(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["google"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["google"] = Colors.red;
              });
              _outputControllers["google"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["google"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "google"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["google"] = false;
            _outputTextColor["google"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["google"]!.text = "翻译失败，请检查网络状态";
        }
      case "yandex":
        try {
          // 通过 Yandex 翻译
          final String result = await translateByYandex(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["yandex"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["yandex"] = Colors.red;
              });
              _outputControllers["yandex"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["yandex"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "yandex"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["yandex"] = false;
            _outputTextColor["yandex"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["yandex"]!.text = "翻译失败，请检查网络状态";
        }
      case "volcengineFree":
        try {
          // 通过火山翻译 Free 翻译
          final String result = await translateByVolcengineFree(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["volcengineFree"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["volcengineFree"] = Colors.red;
              });
              _outputControllers["volcengineFree"]!.text =
                  result.split(":").last;
              return;
            } else {
              _outputControllers["volcengineFree"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "volcengineFree"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["volcengineFree"] = false;
            _outputTextColor["volcengineFree"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["volcengineFree"]!.text = "翻译失败，请检查网络状态";
        }
      case "baidu":
        try {
          // 通过百度翻译
          String result = await translateByBaidu(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["baidu"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["baidu"] = Colors.red;
              });
              _outputControllers["baidu"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["baidu"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "baidu"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["baidu"] = false;
            _outputTextColor["baidu"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["baidu"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
        break;
      case "caiyun":
        try {
          // 通过彩云小译翻译
          String result =
              await translateByCaiyun(text, _fromLanguage, _toLanguage);
          setState(() {
            _isOnTranslation["caiyun"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["caiyun"] = Colors.red;
              });
              _outputControllers["caiyun"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["caiyun"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "caiyun"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["caiyun"] = false;
            _outputTextColor["caiyun"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["caiyun"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
        break;
      case "niutrans":
        try {
          // 通过「小牛翻译」翻译
          final String result = await translateByNiutrans(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["niutrans"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["niutrans"] = Colors.red;
              });
              _outputControllers["niutrans"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["niutrans"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "niutrans"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["niutrans"] = false;
            _outputTextColor["niutrans"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["niutrans"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
      case "volcengine":
        try {
          // 使用「火山翻译」翻译
          final String result = await translateByVolcengine(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["volcengine"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["volcengine"] = Colors.red;
              });
              _outputControllers["volcengine"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["volcengine"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "volcengine"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["volcengine"] = false;
            _outputTextColor["volcengine"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["volcengine"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
      case "youdao":
        try {
          // 使用「有道翻译」翻译
          final String result = await translateByYoudao(
            text,
            _fromLanguage,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["youdao"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          if (result.isNotEmpty) {
            if (result == "error:不支持的语言") {
              setState(() {
                _outputTextColor["youdao"] = Colors.red;
              });
              _outputControllers["youdao"]!.text = result.split(":").last;
              return;
            } else {
              _outputControllers["youdao"]!.text = result;
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = result
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "youdao"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _isOnTranslation["youdao"] = false;
            _outputTextColor["youdao"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["youdao"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
      case "minimax":
        try {
          // 通过 MiniMax 翻译
          String result = await translateByMiniMax(
            text,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["minimax"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["minimax"]!.text = result;
          // 保存历史记录
          final HistoryItem item = HistoryItem()
            ..text = text
            ..result = result
            ..from = _fromLanguage
            ..to = _toLanguage
            ..service = "minimax"
            ..time = DateTime.now();
          await isar.writeTxn(() async {
            await isar.historyItems.put(item);
          });
        } catch (e) {
          setState(() {
            _isOnTranslation["minimax"] = false;
            _outputTextColor["minimax"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["minimax"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
      case "zhipuai":
        try {
          // 通过智谱 AI 翻译
          String result = await translateByZhipuai(
            text,
            _toLanguage,
          );
          setState(() {
            _isOnTranslation["zhipuai"] = false;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["zhipuai"]!.text = result;
          // 保存历史记录
          final HistoryItem item = HistoryItem()
            ..text = text
            ..result = result
            ..from = _fromLanguage
            ..to = _toLanguage
            ..service = "zhipuai"
            ..time = DateTime.now();
          await isar.writeTxn(() async {
            await isar.historyItems.put(item);
          });
        } catch (e) {
          setState(() {
            _isOnTranslation["zhipuai"] = false;
            _outputTextColor["zhipuai"] = Colors.red;
          });
          await Future.delayed(const Duration(milliseconds: 250));
          _outputControllers["zhipuai"]!.text = "翻译失败，请检查网络状态和接口设置";
        }
    }
  }

  /// 自动复制
  Future<void> _autoCopyFunc() async {
    switch (prefs.getString("autoCopy")) {
      case "close":
        return;
      case "source":
        Clipboard.setData(
          ClipboardData(text: _inputController.text),
        );
        return;
      case "result":
        String result = "";
        for (String service in _useService) {
          result +=
              "${serviceMap()[service]!}：${_outputControllers[service]!.text}\n\n";
        }
        Clipboard.setData(
          ClipboardData(text: result),
        );
        return;
      case "both":
        String result = "原文：${_inputController.text}";
        for (String service in _useService) {
          result +=
              "${serviceMap()[service]!}：${_outputControllers[service]!.text}\n\n";
        }
        Clipboard.setData(
          ClipboardData(text: result),
        );
        return;
    }
  }

  /// 选择语言
  Future<void> selectLanguageFunc(String mode, String init) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //icon: const Icon(Icons.language_outlined),
          title: Text(mode == "from" ? "原文语言" : "目标语言"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _languages
                .map(
                  (e) => RadioListTile(
                    value: e,
                    groupValue: init,
                    title: Text(e),
                    onChanged: (value) {
                      if (mode == "from") {
                        setState(() {
                          _fromLanguage = e;
                          if (_fromLanguage == _toLanguage) {
                            if (_fromLanguage == "英语") {
                              _toLanguage = "中文";
                            }
                            if (_fromLanguage == "中文") {
                              _toLanguage = "英语";
                            }
                          }
                        });
                      } else {
                        setState(() {
                          _toLanguage = e;
                          if (_fromLanguage == _toLanguage) {
                            if (_toLanguage == "英语") {
                              _fromLanguage = "中文";
                            }
                            if (_toLanguage == "中文") {
                              _fromLanguage = "英语";
                            }
                          }
                          List<Future> futures = [];
                          for (String service in _useService) {
                            futures.add(_translateFunc(service));
                          }
                          Future.wait(futures).then((_) => _autoCopyFunc());
                        });
                        if (prefs.getBool("rememberToLanguage") ?? true) {
                          prefs.setString("toLanguage", _toLanguage);
                        }
                      }
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList()
                .sublist(mode == "from" && _languages.first == "自动" ? 0 : 1),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("取消"),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          scrollable: true,
        );
      },
    );
  }

  /// 交换原文语言与目标语言
  void _swapLanguageFunc() {
    if (_fromLanguage == "自动") {
      return;
    } else {
      String temp = _fromLanguage;
      setState(() {
        _fromLanguage = _toLanguage;
        _toLanguage = temp;
      });
      List<Future> futures = [];
      for (String service in _useService) {
        futures.add(_translateFunc(service));
      }
      Future.wait(futures).then((_) => _autoCopyFunc());
      if (prefs.getBool("rememberToLanguage") ?? true) {
        prefs.setString("toLanguage", _toLanguage);
      }
    }
  }

  /// 复制翻译结果
  Future<void> _copyResultFunc(String service) async {
    if (_outputControllers[service]!.text.isEmpty) return;
    Clipboard.setData(
      ClipboardData(text: _outputControllers[service]!.text),
    );
  }

  /// 翻译过程中输出框显示动画
  Future<void> _outputAnimationFunc(String service) async {
    _outputControllers[service]!.clear();
    while (_isOnTranslation[service]!) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      if (_outputControllers[service]!.text.endsWith("......")) {
        _outputControllers[service]!.clear();
      } else {
        _outputControllers[service]!.text += ".";
      }
    }
  }
}
