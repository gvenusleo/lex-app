import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:metranslate/global.dart';
import 'package:metranslate/utils/init_dio.dart';

/// 使用智谱 AI 翻译
/// https://open.bigmodel.cn/dev/api#http
Future<String> translateByZhipuai(String text, String to) async {
  final String apiKey = (prefs.getString("zhipuaiApiKey") ?? "").trim();
  final String model = prefs.getString("zhipuModel") ?? "chatglm_std";
  final double temperature = prefs.getDouble("zhipuaiTemperature") ?? 0.8;
  final List<String> prompts = prefs.getStringList("zhipuaiPrompts") ??
      [
        "你是一名翻译专家，请将我给你的文本翻译成口语化、专业化、优雅流畅的内容，不要有机器翻译的风格。你必须只返回文本内容的翻译结果，不要解释文本内容。",
        "好的，我只翻译文字内容，不会解释。",
        "将下面的文本翻译为中文：hello",
        "你好",
        "将下面的文本翻译为{to}：{text}",
      ];
  final String url =
      "https://open.bigmodel.cn/api/paas/v3/model-api/$model/invoke";
  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": getJwt(apiKey),
  };
  final List<Map<String, String>> promptList = [];
  for (int index = 0; index < prompts.length; index++) {
    String content = prompts[index];
    content = content.replaceAll("{to}", to);
    content = content.replaceAll("{text}", text);
    promptList.add({
      "role": index % 2 == 0 ? "user" : "assistant",
      "content": content,
    });
  }
  final Map<String, dynamic> data = {
    "prompt": promptList,
    "temperature": temperature,
  };

  final Dio dio = initDio();
  final Response response = await dio.post(
    url,
    data: data,
    options: Options(headers: headers),
  );
  String result = response.data["data"]["choices"][0]["content"];
  if (result.startsWith('" ')) {
    result = result.substring(2);
  }
  if (result.endsWith('"')) {
    result = result.substring(0, result.length - 1);
  }
  return result;
}

/// JWT 组装
String getJwt(String apiKey) {
  final String id = apiKey.split(".").first;
  final String secret = apiKey.split(".").last;
  const Map<String, String> headers = {
    "alg": "HS256",
    "sign_type": "SIGN",
  };
  final Map<String, dynamic> payload = {
    "api_key": id,
    "exp": DateTime.now().millisecondsSinceEpoch + 10000,
    "timestamp": DateTime.now().millisecondsSinceEpoch,
  };
  final encodedHeader = base64Encode(utf8.encode(jsonEncode(headers)));
  final encodedPayload = base64Encode(utf8.encode(jsonEncode(payload)));
  final hmacSha256 = Hmac(sha256, utf8.encode(secret));
  final signature = base64Encode(
      hmacSha256.convert(utf8.encode('$encodedHeader.$encodedPayload')).bytes);
  return '$encodedHeader.$encodedPayload.$signature';
}
