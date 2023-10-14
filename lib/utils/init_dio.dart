import "dart:io";

import "package:dio/dio.dart";
import "package:dio/io.dart";
import "package:metranslate/global.dart";

/// 初始化 Dio (可能使用代理)
Dio initDio() {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );
  final bool useProxy = prefs.getBool("useProxy") ?? false;
  final String proxyAddress = prefs.getString("proxyAddress") ?? "";
  if (useProxy && proxyAddress.isNotEmpty) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return "PROXY $proxyAddress";
        };
        return client;
      },
    );
  }
  return dio;
}
