import 'package:audioplayers/audioplayers.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:metranslate/global.dart";
import "package:metranslate/modules/history_item.dart";
import 'package:metranslate/utils/check_api.dart';
import 'package:metranslate/utils/languages.dart';
import 'package:metranslate/utils/ocr_service/tesseract.dart';
import 'package:metranslate/utils/service_map.dart';
import 'package:metranslate/utils/translate_service/baidu.dart';
import 'package:metranslate/utils/translate_service/bing.dart';
import 'package:metranslate/utils/translate_service/caiyun.dart';
import 'package:metranslate/utils/translate_service/cambridge_dict.dart';
import 'package:metranslate/utils/translate_service/deepl_free.dart';
import 'package:metranslate/utils/translate_service/google.dart';
import 'package:metranslate/utils/translate_service/minimax.dart';
import 'package:metranslate/utils/translate_service/niutrans.dart';
import 'package:metranslate/utils/translate_service/volcengine.dart';
import 'package:metranslate/utils/translate_service/volcengine_free.dart';
import 'package:metranslate/utils/translate_service/yandex.dart';
import 'package:metranslate/utils/translate_service/youdao.dart';
import 'package:metranslate/utils/translate_service/zhipuai.dart';
import 'package:metranslate/widgets/loading_skeleton.dart';

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
  // 翻译输出
  late Map<String, Widget> _outputs;
  // 翻译服务
  late List<String> _useService;
  // 原文语言
  String _fromLanguage = initFromLanguage();
  // 目标语言
  String _toLanguage = initToLanguage();
  // 翻译结果
  final Map<String, String> _result = {};

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
    _outputs = Map.fromEntries(_useService.map((e) => MapEntry(
        e,
        RichText(
          text: const TextSpan(text: ""),
        ))));
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
    return ReorderableListView.builder(
      itemCount: _useService.length,
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: 4),
      header: Column(
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
                  style: Theme.of(context).textTheme.bodyLarge,
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
                      onPressed: () async {
                        try {
                          String ocrResult = await ocrByTesseract();
                          _inputController.text = ocrResult;
                        } catch (_) {
                          return;
                        }
                      },
                      icon: const Icon(Icons.crop_free_outlined, size: 20),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
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
                    IconButton(
                      onPressed: () {
                        _inputController.clear();
                      },
                      icon: const Icon(Icons.backspace_outlined, size: 20),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      // tooltip: "清空",
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
        ],
      ),
      itemBuilder: (context, index) {
        return Card(
          key: ValueKey(_useService[index]),
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _outputs[_useService[index]]!,
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Image.asset(
                          serviceLogoMap()[_useService[index]]!,
                          width: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          serviceMap()[_useService[index]]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            height: 24,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyResultFunc(_useService[index]),
                          icon: const Icon(Icons.copy_outlined, size: 20),
                          padding: const EdgeInsets.all(0),
                          visualDensity: VisualDensity.compact,
                          // tooltip: "复制",
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Container(
                      height: 4,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final String item = _useService.removeAt(oldIndex);
          _useService.insert(newIndex, item);
        });
        prefs.setStringList("useService", _useService);
      },
    );
  }

  /// 翻译
  Future<void> _translateFunc(String service, {String? text}) async {
    text ??= _inputController.text;
    if (text.isEmpty) {
      return;
    }
    if (!checkAPI(service)) {
      setState(
        () {
          _outputs[service] = SelectableText.rich(
            const TextSpan(
              text: "请先设置 API 接口",
            ),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.red,
                ),
          );
        },
      );
      return;
    }
    switch (service) {
      case "bing":
        try {
          // 通过 Bing 翻译
          setState(() {
            _outputs["bing"] = const LoadingSkeleton();
          });
          String result = await translateByBing(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(
                () {
                  _outputs["bing"] = SelectableText.rich(
                    TextSpan(
                      text: result.split(":").last,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  );
                },
              );
              return;
            } else {
              setState(() {
                _outputs["bing"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["bing"] = result;
              });
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
            _outputs["bing"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "deeplFree":
        try {
          // 通过 DeepL Free 翻译
          setState(() {
            _outputs["deeplFree"] = const LoadingSkeleton();
          });
          String result = await translateByDeeplFree(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["deeplFree"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["deeplFree"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["deeplFree"] = result;
              });
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
            _outputs["deeplFree"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "google":
        try {
          // 通过 Google 翻译
          setState(() {
            _outputs["google"] = const LoadingSkeleton();
          });
          String result = await translateByGoogle(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["google"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["google"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["google"] = result;
              });
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
            _outputs["google"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "yandex":
        try {
          // 通过 Yandex 翻译
          setState(() {
            _outputs["yandex"] = const LoadingSkeleton();
          });
          final String result = await translateByYandex(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["yandex"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["yandex"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["yandex"] = result;
              });
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
            _outputs["yandex"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "volcengineFree":
        try {
          // 通过火山翻译 Free 翻译
          setState(() {
            _outputs["volcengineFree"] = const LoadingSkeleton();
          });
          final String result = await translateByVolcengineFree(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["volcengineFree"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["volcengineFree"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["volcengineFree"] = result;
              });
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
            _outputs["volcengineFree"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "cambridgeDict":
        try {
          // 通过剑桥词典翻译
          setState(() {
            _outputs["cambridgeDict"] = const LoadingSkeleton();
          });
          setState(() {
            _outputs["cambridgeDict"] = const LoadingSkeleton();
          });
          final Map result = await translateByCambridgeDict(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.keys.first == "error") {
              setState(() {
                _outputs["cambridgeDict"] = SelectableText.rich(
                  TextSpan(
                    text: result.values.first,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              List<Map<String, dynamic>> translation = result["translation"];
              String translationString = "";
              for (Map<String, dynamic> item in translation) {
                translationString +=
                    item["pos"] + item["tran"].join("，") + "\n";
              }
              setState(() {
                _outputs["cambridgeDict"] = SelectableText.rich(
                  TextSpan(
                    children: [
                      for (Map<String, dynamic> item in translation) ...[
                        TextSpan(
                          text: item["pos"] + "    ",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextSpan(
                          text: item["tran"].join("。") + "\n",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text: "\n",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(height: 0.1),
                        ),
                      ],
                      WidgetSpan(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "US  ${result["pronunciation"]["us"]["ipa"]}  ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  final player = AudioPlayer();
                                  player.play(
                                    UrlSource(
                                      result["pronunciation"]["us"]["mp3"],
                                    ),
                                  );
                                } catch (_) {
                                  return;
                                }
                              },
                              icon: const Icon(Icons.volume_up_outlined,
                                  size: 20),
                              padding: const EdgeInsets.all(0),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      const TextSpan(text: "\n"),
                      WidgetSpan(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "UK  ${result["pronunciation"]["uk"]["ipa"]}  ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  final player = AudioPlayer();
                                  player.play(
                                    UrlSource(
                                      result["pronunciation"]["uk"]["mp3"],
                                    ),
                                  );
                                } catch (_) {
                                  return;
                                }
                              },
                              icon: const Icon(Icons.volume_up_outlined,
                                  size: 20),
                              padding: const EdgeInsets.all(0),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["cambridgeDict"] = translationString;
              });
              // 保存历史记录
              final HistoryItem item = HistoryItem()
                ..text = text
                ..result = translationString
                ..from = _fromLanguage
                ..to = _toLanguage
                ..service = "cambridgeDict"
                ..time = DateTime.now();
              await isar.writeTxn(() async {
                await isar.historyItems.put(item);
              });
            }
          }
        } catch (e) {
          setState(() {
            _outputs["cambridgeDict"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "baidu":
        try {
          // 通过百度翻译
          setState(() {
            _outputs["baidu"] = const LoadingSkeleton();
          });
          String result = await translateByBaidu(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["baidu"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["baidu"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["baidu"] = result;
              });
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
            _outputs["baidu"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
        break;
      case "caiyun":
        try {
          // 通过彩云小译翻译
          setState(() {
            _outputs["caiyun"] = const LoadingSkeleton();
          });
          String result =
              await translateByCaiyun(text, _fromLanguage, _toLanguage);
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["caiyun"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["caiyun"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["caiyun"] = result;
              });
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
            _outputs["caiyun"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
        break;
      case "niutrans":
        try {
          // 通过「小牛翻译」翻译
          setState(() {
            _outputs["niutrans"] = const LoadingSkeleton();
          });
          final String result = await translateByNiutrans(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["niutrans"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["niutrans"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["niutrans"] = result;
              });
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
            _outputs["niutrans"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "volcengine":
        try {
          // 使用「火山翻译」翻译
          setState(() {
            _outputs["volcengine"] = const LoadingSkeleton();
          });
          final String result = await translateByVolcengine(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["volcengine"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["volcengine"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["volcengine"] = result;
              });
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
            _outputs["volcengine"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "youdao":
        try {
          // 使用「有道翻译」翻译
          setState(() {
            _outputs["youdao"] = const LoadingSkeleton();
          });
          final String result = await translateByYoudao(
            text,
            _fromLanguage,
            _toLanguage,
          );
          if (result.isNotEmpty) {
            if (result.startsWith("error:")) {
              setState(() {
                _outputs["youdao"] = SelectableText.rich(
                  TextSpan(
                    text: result.split(":").last,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                );
              });
              return;
            } else {
              setState(() {
                _outputs["youdao"] = SelectableText.rich(
                  TextSpan(
                    text: result,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
                _result["youdao"] = result;
              });
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
            _outputs["youdao"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "minimax":
        try {
          // 通过 MiniMax 翻译
          setState(() {
            _outputs["minimax"] = const LoadingSkeleton();
          });
          String result = await translateByMiniMax(
            text,
            _toLanguage,
          );
          setState(() {
            _outputs["minimax"] = SelectableText.rich(
              TextSpan(
                text: result,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            );
            _result["minimax"] = result;
          });
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
            _outputs["minimax"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
      case "zhipuai":
        try {
          // 通过智谱 AI 翻译
          setState(() {
            _outputs["zhipu"] = const LoadingSkeleton();
          });
          String result = await translateByZhipuai(
            text,
            _toLanguage,
          );
          setState(() {
            _outputs["zhipuai"] = SelectableText.rich(
              TextSpan(
                text: result,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            );
            _result["zhipuai"] = result;
          });
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
            _outputs["zhipuai"] = SelectableText.rich(
              const TextSpan(
                text: "翻译失败，请检查网络状态和接口设置",
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ),
            );
          });
        }
    }
  }

  /// 选择语言
  Future<void> selectLanguageFunc(String mode, String init) async {
    final List<String> languages = prefs.getStringList("enabledLanguages") ??
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
    if (mode == "from") {
      languages.insert(0, "自动");
    }
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
            children: languages
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
                .toList(),
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
    if (_result[service] == null) return;
    Clipboard.setData(
      ClipboardData(text: _result[service]!),
    );
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
          if (_result[service] != null) {
            result += "${serviceMap()[service]!}：${_result[service]!}\n\n";
          }
        }
        Clipboard.setData(
          ClipboardData(text: result),
        );
        return;
      case "both":
        String result = "原文：${_inputController.text}\n\n";
        for (String service in _useService) {
          if (_result[service] != null) {
            result += "${serviceMap()[service]!}：${_result[service]!}\n\n";
          }
        }
        Clipboard.setData(
          ClipboardData(text: result),
        );
        return;
    }
  }
}
