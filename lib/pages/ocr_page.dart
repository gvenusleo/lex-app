import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lex/global.dart';
import 'package:lex/services/ocr/tesseract.dart';
import 'package:lex/utils/service_map.dart';
import 'package:lex/widgets/selected_button.dart';

/// 文字识别页面
class OcrPage extends StatefulWidget {
  // 识别图片的路径
  final String imagePath;

  const OcrPage({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  /// 文字识别结果控制器
  final _controller = TextEditingController();

  /// 启用的 OCR 服务
  final List<String> _enabledOcrServices =
      prefs.getStringList("enabledOcrServices") ?? [];

  /// 识别语言
  String _language = "中文";

  @override
  void initState() {
    ocr();
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
                                ),
                              )
                              .toList(),
                          child:
                              Text(ocrServiceMap()[_enabledOcrServices.first]!),
                        ),
                        SelectedButton(
                          items: ["中文", "英语"]
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
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                            isDense: true,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
    TesseractOcr.ocr(widget.imagePath, language: _language).then((value) {
      if (prefs.getBool("deleteOcrLineBreak") ?? false) {
        _controller.text = value.replaceAll("\n", "");
      } else {
        _controller.text = value;
      }
    });
    if (prefs.getBool("autoCopyOcrResult") ?? false) {
      Clipboard.setData(ClipboardData(text: _controller.text));
    }
  }
}
