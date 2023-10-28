import "dart:io";

import "package:dio/dio.dart";
import "package:dio/io.dart";
import "package:lex/global.dart";

/// 初始化 Dio (可能使用代理)
Dio initDio() {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
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
        client.userAgent = 'curl/7.77.0';
        return client;
      },
    );
  }
  return dio;
}
