import 'package:dio/dio.dart';
import 'package:metranslate/utils/init_dio.dart';

/// 剑桥词典
Future<Map> translateByCambridgeDict(
  String text,
  String from,
  String to,
) async {
  try {
    from = cambridgeDictSupportLanguage()[from]!;
    to = cambridgeDictSupportLanguage()[to]!;
  } catch (_) {
    return {"error": "不支持的语言"};
  }
  const String url = "https://dictionary.cambridge.org/search/direct/";
  const Map<String, String> headers = {
    "Content-Type": "text/html;charset=UTF-8",
  };
  final Map<String, String> quer = {
    "datasetsearch": "$from-$to",
    "q": text,
  };

  final Dio dio = initDio();
  final Response response = await dio.get(
    url,
    queryParameters: quer,
    options: Options(headers: headers),
  );
  print(response.data);
  return {};
}

Map<String, String> cambridgeDictSupportLanguage() {
  return {
    // "自动": "auto",
    "英文": "english",
    "中文": "chinese-simplified",
    "繁体中文": "chinese-traditional",
  };
}
