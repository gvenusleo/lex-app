import "dart:io";

import "package:process_run/process_run.dart";

/// 使用 Tesseract 进行文字识别
Future<String> ocrByTesseract(String imgPath, {String language = "中文"}) async {
  try {
    language = tesseractSupportLanguage()[language]!;
  } catch (_) {
    return "error:不支持的语言";
  }
  var shell = Shell();
  List<ProcessResult> result = await shell.run(
    "tesseract $imgPath - -l $language",
  );
  return result.outText.trim();
}

/// Tesseract 支持的语言
Map<String, String> tesseractSupportLanguage() {
  return {
    "中文": "chi_sim",
    "英语": "eng",
  };
}
