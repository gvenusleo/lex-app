import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置 MiniMax groupID 和 ApiKey
Future<void> setMiniMax(BuildContext context) async {
  final groupIDController = TextEditingController();
  final apiKeyController = TextEditingController();
  final botNameController = TextEditingController();
  final botContentController = TextEditingController();
  groupIDController.text = prefs.getString("minimaxGroupID") ?? "";
  apiKeyController.text = prefs.getString("minimaxApiKey") ?? "";
  botNameController.text = prefs.getString("minimaxBotName") ?? "MM翻译专家";
  botContentController.text = prefs.getString("minimaxBotContent") ??
      "你是由MiniMax驱动的智能翻译机器人，请将我给你的文本翻译成口语化、专业化、优雅流畅的内容，不要有机器翻译的风格。你必须只返回文本内容的翻译结果，不要解释文本内容。";
  double temperature = prefs.getDouble("minimaxTemperature") ?? 0.8;
  final List<String> prompts = prefs.getStringList("minimaxPrompts") ??
      [
        "将下面的文本翻译为中文：hello",
        "你好",
        "将下面的文本翻译为{to}：{text}",
      ];
  final List<TextEditingController> promptControllers = List.generate(
    prompts.length,
    (index) => TextEditingController(text: prompts[index]),
  );
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (BuildContext context, setState) {
        return AlertDialog(
          icon: Image.asset(
            "assets/service/minimax.png",
            width: 40,
            height: 40,
          ),
          title: const Text("MiniMax"),
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
                        "https://www.metranslate.top/guide/minimax.html",
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  const Spacer()
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: groupIDController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "group ID",
                  hintText: "输入 MiniMax group ID",
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "密钥",
                  hintText: "输入 MiniMax 密钥",
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
                title: Text("机器人设定"),
                subtitle: Text("对话机器人的设定"),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: Theme.of(context).colorScheme.secondaryContainer,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: botNameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 6),
                        isDense: true,
                        prefixText: "机器人名称：",
                      ),
                    ),
                    TextField(
                      controller: botContentController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(8, 6, 8, 12),
                        isDense: true,
                        prefixText: "机器人设定：",
                      ),
                    ),
                  ],
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
                prefs.setString("minimaxGroupID", groupIDController.text);
                prefs.setString("minimaxApiKey", apiKeyController.text);
                prefs.setString("minimaxBotName", botNameController.text);
                prefs.setString("minimaxBotContent", botContentController.text);
                prefs.setDouble("minimaxTemperature", temperature);
                prefs.setStringList(
                  "minimaxPrompts",
                  promptControllers.map((e) => e.text).toList(),
                );
                Navigator.pop(context);
              },
              child: const Text("保存"),
            ),
          ],
          scrollable: true,
        );
      });
    },
  );
}
