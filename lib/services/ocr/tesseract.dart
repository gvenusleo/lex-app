import 'dart:io';

import 'package:process_run/process_run.dart';

/// Tesseract OCR
class Tesseract {
  /// 使用 Tesseract 进行文字识别
  static Future<String> ocr(String imgPath, {String language = "中文"}) async {
    try {
      language = supportLanguage()[language]!;
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
  static Map<String, String> supportLanguage() {
    return {
      "中文": "chi_sim",
      "英语": "eng",
    };
  }

  /// 判断是否安装了 Tesseract
  static Future<bool> isInstalled() async {
    try {
      var shell = Shell();
      await shell.run("tesseract --version");
      return true;
    } catch (_) {
      return false;
    }
  }
}
