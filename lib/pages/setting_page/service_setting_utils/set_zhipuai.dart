import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置智谱 AI API Key
Future<void> setZhipuai(BuildContext context) async {
  final zhipuaiApiKeyController = TextEditingController();
  zhipuaiApiKeyController.text = prefs.getString("zhipuaiApiKey") ?? "";
  String model = prefs.getString("zhipuModel") ?? "chatglm_std";
  double temperature = prefs.getDouble("zhipuaiTemperature") ?? 0.8;
  List<String> prompts = prefs.getStringList("zhipuaiPrompts") ??
      [
        "你是一名翻译专家，请将我给你的文本翻译成口语化、专业化、优雅流畅的内容，不要有机器翻译的风格。你必须只返回文本内容的翻译结果，不要解释文本内容。",
        "好的，我只翻译文字内容，不会解释。",
        "将下面的文本翻译为中文：hello",
        "你好",
        "将下面的文本翻译为{to}：{text}",
      ];
  List<TextEditingController> promptControllers = List.generate(
    prompts.length,
    (index) => TextEditingController(text: prompts[index]),
  );
  const Map<String, String> modelName = {
    "chatglm_pro": "ChatGLM-Pro",
    "chatglm_std": "ChatGLM-Std",
    "chatglm_lite": "ChatGLM-Lite",
  };
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            icon: Image.asset(
              "assets/service/zhipuai.png",
              width: 40,
              height: 40,
            ),
            title: const Text("智谱 AI"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      child: Text(
                        "查看配置指南 >>",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onTap: () {
                        launchUrlString(
                          "https://www.metranslate.top/guide/zhipuai.html",
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: zhipuaiApiKeyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "API Key",
                    hintText: "输入智谱 AI API Key",
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: const Text("语言模型"),
                  subtitle: const Text("采用的对话模型"),
                  trailing: DropdownButton<String>(
                    value: model,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          model = newValue;
                        });
                      }
                    },
                    items: modelName.entries.map<DropdownMenuItem<String>>(
                      (MapEntry<String, String> entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      },
                    ).toList(),
                    dropdownColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 1,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: const Text("采样温度"),
                  subtitle: const Text("控制输出的随机性"),
                  trailing: SizedBox(
                    width: 160,
                    child: Slider(
                      value: temperature,
                      min: 0.1,
                      max: 1.0,
                      divisions: 18,
                      label: temperature.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() {
                          temperature = value;
                        });
                      },
                    ),
                  ),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text("Prompt"),
                  subtitle:
                      Text(r"通过 Prompt 控制 AI 的行为，{text}, {to} 将被替换为原文和目标语言"),
                ),
                for (int index = 0; index < prompts.length; index++)
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    clipBehavior: Clip.antiAlias,
                    child: TextField(
                      controller: promptControllers[index],
                      minLines: 1,
                      maxLines: 100,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        isDense: true,
                        prefixText: index % 2 == 0 ? "用户：" : "机器人：",
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              prompts.removeAt(index);
                              promptControllers.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      prompts.add("");
                      promptControllers.add(TextEditingController());
                    });
                  },
                  child: const Text("添加 Prompt"),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"),
              ),
              FilledButton(
                onPressed: () {
                  prefs.setString(
                      "zhipuaiApiKey", zhipuaiApiKeyController.text);
                  prefs.setString("zhipuModel", model);
                  prefs.setDouble("zhipuaiTemperature", temperature);
                  prefs.setStringList(
                    "zhipuaiPrompts",
                    promptControllers.map((e) => e.text).toList(),
                  );
                  Navigator.pop(context);
                },
                child: const Text("保存"),
              ),
            ],
            scrollable: true,
          );
        },
      );
    },
  );
}
