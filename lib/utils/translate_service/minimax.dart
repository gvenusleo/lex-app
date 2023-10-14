import 'package:dio/dio.dart';
import 'package:metranslate/global.dart';
import 'package:metranslate/utils/init_dio.dart';

/// 使用 MiniMax 翻译
/// https://api.minimax.chat/document/guides/chat-pro?id=64b79fa3e74cddc5215939f4
Future<String> translateByMiniMax(String text, String to) async {
  final String groupID = prefs.getString("minimaxGroupID") ?? "";
  final String apiKey = prefs.getString("minimaxApiKey") ?? "";
  final String botName = prefs.getString("minimaxBotName") ?? "MM翻译专家";
  final String botContent = prefs.getString("minimaxBotContent") ??
      "你是由MiniMax驱动的智能翻译机器人，请将我给你的文本翻译成口语化、专业化、优雅流畅的内容，不要有机器翻译的风格。你必须只返回文本内容的翻译结果，不要解释文本内容。";
  const String url = "https://api.minimax.chat/v1/text/chatcompletion_pro";
  final double temperature = prefs.getDouble("minimaxTemperature") ?? 0.8;
  final List<String> prompts = prefs.getStringList("minimaxPrompts") ??
      [
        "将下面的文本翻译为中文：hello",
        "你好",
        "将下面的文本翻译为{to}：{text}",
      ];
  final Map<String, String> query = {
    "GroupId": groupID,
  };
  final Map<String, String> headers = {
    "Authorization": "Bearer $apiKey",
    "Content-Type": "application/json"
  };
  final List<Map<String, String>> promptList = [];
  for (int index = 0; index < prompts.length; index++) {
    String content = prompts[index];
    content = content.replaceAll("{to}", to);
    content = content.replaceAll("{text}", text);
    promptList.add({
      "sender_type": index % 2 == 0 ? "USER" : "BOT",
      "sender_name": index % 2 == 0 ? "用户" : botName,
      "text": content,
    });
  }
  final Map<String, dynamic> data = {
    "model": "abab5.5-chat",
    "temperature": temperature,
    "stream": false,
    "reply_constraints": {"sender_type": "BOT", "sender_name": botName},
    "bot_setting": [
      {
        "bot_name": botName,
        "content": botContent,
      }
    ],
    "messages": promptList,
  };

  final Dio dio = initDio();
  final Response response = await dio.post(
    url,
    queryParameters: query,
    data: data,
    options: Options(headers: headers),
  );
  return response.data["reply"] ?? "";
}
