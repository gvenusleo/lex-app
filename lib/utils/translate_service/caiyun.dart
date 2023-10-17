import "package:dio/dio.dart";
import "package:metranslate/global.dart";
import "package:metranslate/utils/init_dio.dart";

/// 彩云小译
/// https://docs.caiyunapp.com/blog/2018/09/03/lingocloud-api/
Future<String> translateByCaiyun(String text, String from, String to) async {
  try {
    from = caiyunSupportLanguage()[from]!;
    to = caiyunSupportLanguage()[to]!;
  } catch (_) {
    return "不支持的语言";
  }
  final String token = (prefs.getString("caiyunToken") ?? "").trim();
  const String url = "http://api.interpreter.caiyunai.com/v1/translator";
  final String direction = "${from}2$to";
  final Map<String, String> query = {
    "source": text,
    "trans_type": direction,
    "request_id": "metranslate",
    "detect": "true",
  };
  final Map<String, dynamic> headers = {
    "content-type": "application/json",
    "x-authorization": "token $token",
  };

  final Dio dio = initDio();
  final Response response = await dio.post(
    url,
    data: query,
    options: Options(headers: headers),
  );
  return response.data["target"];
}

/// 彩云小译支持语言
/// https://docs.caiyunapp.com/blog/2018/09/03/lingocloud-api/
Map<String, String> caiyunSupportLanguage() {
  return {
    "自动": "auto",
    "中文": "zh",
    "英语": "en",
    "日语": "ja",
  };
}
