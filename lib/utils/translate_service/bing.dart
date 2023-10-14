import "package:dio/dio.dart";
import "package:metranslate/utils/init_dio.dart";

/// Bing 翻译
/// 存在 Bug, 无法翻译， 暂不启用
Future<String> translateByBing(String text, String from, String to) async {
  const String tokenUrl = "https://edge.microsoft.com/translate/auth";
  const Map<String, String> tokenHeaders = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42",
  };

  final Dio dio = initDio();

  final Response tokenResponse = await dio.get(
    tokenUrl,
    options: Options(
      headers: tokenHeaders,
      responseType: ResponseType.plain,
    ),
  );
  final String token = tokenResponse.data;
  // print(token);

  const String url =
      "https://api-edge.cognitive.microsofttranslator.com/translate";
  final Map<String, String> headers = {
    "accept": "*/*",
    "accept-language":
        "zh-TW,zh;q=0.9,ja;q=0.8,zh-CN;q=0.7,en-US;q=0.6,en;q=0.5",
    "authorization": "Bearer $token",
    "cache-control": "no-cache",
    "content-type": "application/json",
    "pragma": "no-cache",
    "sec-ch-ua":
        "'Microsoft Edge';v='113', 'Chromium';v='113', 'Not-A.Brand';v='24'",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "'Windows'",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "Referer": "https://github.com/",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42",
  };
  final Map<String, String> query = {
    "from": from,
    "to": to,
    "api-version": "3.0",
    "includeSentenceLength": "true",
  };
  final Map<String, dynamic> data = {
    "type": "Json",
    "payload": [
      {"Text": text}
    ]
  };

  final Response response = await dio.post(
    url,
    queryParameters: query,
    data: data,
    options: Options(headers: headers),
  );
  // print(response);

  return response.data;
}
