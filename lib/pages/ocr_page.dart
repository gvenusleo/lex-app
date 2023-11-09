import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lex/global.dart";
import "package:lex/modules/ocr_item.dart";
import "package:lex/services/ocr/baidu.dart";
import "package:lex/services/ocr/tesseract.dart";
import "package:lex/utils/languages.dart";
import "package:lex/utils/service_map.dart";
import "package:lex/widgets/selected_button.dart";

/// 文字识别页面
class OcrPage extends StatefulWidget {
  // 识别图片的路径
  final String imagePath;

  const OcrPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  /// 文字识别结果控制器
  final _controller = TextEditingController();

  /// 启用的 OCR 服务
  final List<String> _enabledOcrServices =
      prefs.getStringList("enabledOcrServices") ?? [];

  // 当前使用的 OCR 服务
  String _currentOcrService = "";
  // 所有语言
  Map<String, String> _allLanguages = {};
  // 识别语言
  String _language = "";
  // 是否正在识别
  bool _isOcring = true;
  // 是否出现错误
  bool _isError = false;

  Future<void> initData() async {
    final Map<String, String> allLanguages =
        await ocrLanguages(_currentOcrService);
    setState(() {
      _allLanguages = allLanguages;
      _language = allLanguages.keys.first;
    });
    await ocr();
  }

  @override
  void initState() {
    _currentOcrService = _enabledOcrServices.first;
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 0),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.file(
                          File(widget.imagePath),
                          width: MediaQuery.of(context).size.width / 2 * 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        SelectedButton(
                          items: _enabledOcrServices
                              .map(
                                (e) => PopupMenuItem(
                                  child: Text(ocrServiceMap()[e]!),
                                  onTap: () {
                                    setState(() {
                                      _currentOcrService = e;
                                    });
                                    initData();
                                  },
                                ),
                              )
                              .toList(),
                          child: Text(ocrServiceMap()[_currentOcrService]!),
                        ),
                        SelectedButton(
                          items: _allLanguages.keys
                              .map(
                                (e) => PopupMenuItem(
                                  child: Text(e),
                                  onTap: () {
                                    if (e != _language) {
                                      setState(() {
                                        _language = e;
                                      });
                                      ocr();
                                    }
                                  },
                                ),
                              )
                              .toList(),
                          child: Text(_language),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const VerticalDivider(width: 0),
              Expanded(
                flex: 1,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: _isError
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_outlined,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "识别失败，请检查网络或重试！",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (_isOcring
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : TextField(
                                    controller: _controller,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(8),
                                      isDense: true,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  )),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _controller.text));
                            },
                            icon: const Icon(Icons.copy_outlined, size: 20),
                            padding: const EdgeInsets.all(0),
                            visualDensity: VisualDensity.compact,
                            tooltip: "复制结果",
                          ),
                          IconButton(
                            onPressed: () {
                              _controller.text =
                                  _controller.text.replaceAll("\n", "");
                              if (prefs.getBool("autoCopyOcrResult") ?? false) {
                                Clipboard.setData(
                                    ClipboardData(text: _controller.text));
                              }
                            },
                            icon:
                                const Icon(Icons.wrap_text_outlined, size: 20),
                            padding: const EdgeInsets.all(0),
                            visualDensity: VisualDensity.compact,
                            tooltip: "删除换行",
                          ),
                          const Spacer(),
                          FilledButton.tonal(
                            onPressed: ocr,
                            child: const Text("重新识别"),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 文字识别
  Future<void> ocr() async {
    setState(() {
      _isError = false;
      _isOcring = true;
    });
    String result = "";
    try {
      switch (_currentOcrService) {
        case "tesseract":
          result = await TesseractOcr.ocr(
            widget.imagePath,
            language: _allLanguages[_language]!,
          );
          break;
        case "baidu":
          result = await BaiduOcr.ocr(
            widget.imagePath,
            _allLanguages[_language]!,
          );
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isOcring = false;
      });
      return;
    }
    if (prefs.getBool("deleteOcrLineBreak") ?? false) {
      _controller.text = result.replaceAll("\n", "");
    } else {
      _controller.text = result;
    }
    if (prefs.getBool("autoCopyOcrResult") ?? false) {
      Clipboard.setData(ClipboardData(text: _controller.text));
    }
    setState(() {
      _isOcring = false;
    });
    if (result.isNotEmpty) {
      // 保存识别记录
      final OcrItem item = OcrItem()
        ..image = widget.imagePath
        ..result = result
        ..language = _language
        ..service = _currentOcrService
        ..time = DateTime.now();
      await isar.writeTxn(() async {
        await isar.ocrItems.put(item);
      });
    }
  }
}
