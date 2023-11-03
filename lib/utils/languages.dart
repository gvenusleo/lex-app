import "package:lex/global.dart";
import 'package:lex/services/ocr/baidu.dart';
import 'package:lex/services/ocr/tesseract.dart';
import 'package:lex/services/translation/baidu.dart';
import 'package:lex/services/translation/bing.dart';
import 'package:lex/services/translation/caiyun.dart';
import 'package:lex/services/translation/cambridge_dict.dart';
import 'package:lex/services/translation/deepl_free.dart';
import 'package:lex/services/translation/google.dart';
import 'package:lex/services/translation/niutrans.dart';
import 'package:lex/services/translation/volcengine.dart';
import 'package:lex/services/translation/yandex.dart';
import 'package:lex/services/translation/youdao.dart';

/// 初始化模型原语言
String initTranslationFrom() {
  return prefs.getString("fromLanguage") ?? "自动";
}

/// 初始化模型目标语言
String initTranslationTo() {
  return prefs.getString("toLanguage") ?? "中文";
}

/// 获取所有受支持语言及其受支持翻译服务
Map<String, List<String>> allTranslationLanguages() {
  Map<String, List<String>> result = {};
  for (String language in BingTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["Bing 翻译"];
    } else {
      result[language]!.add("Bing 翻译");
    }
  }
  for (String language in DeeplFreeTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["DeepL 翻译"];
    } else {
      result[language]!.add("DeepL 翻译");
    }
  }
  for (String language in GoogleTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["Google 翻译"];
    } else {
      result[language]!.add("Google 翻译");
    }
  }
  for (String language in YandexTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["Yandex 翻译"];
    } else {
      result[language]!.add("Yandex 翻译");
    }
  }
  for (String language in VolcengineTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["火山翻译", "火山翻译 Free"];
    } else {
      result[language]!.addAll(["火山翻译", "火山翻译 Free"]);
    }
  }
  for (String language in CambridgeDict.languages().keys) {
    if (result[language] == null) {
      result[language] = ["剑桥词典"];
    } else {
      result[language]!.add("剑桥词典");
    }
  }
  for (String language in BaiduTranslation.languages().keys) {
    result[language] = ["百度翻译"];
  }
  for (String language in CaiyunTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["彩云小译"];
    } else {
      result[language]!.add("彩云小译");
    }
  }
  for (String language in NiutransTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["小牛翻译"];
    } else {
      result[language]!.add("小牛翻译");
    }
  }
  for (String language in YoudaoTranslation.languages().keys) {
    if (result[language] == null) {
      result[language] = ["有道翻译"];
    } else {
      result[language]!.add("有道翻译");
    }
  }

  result.remove("自动");
  return result;
}

/// 获取 OCR 服务支持的语言
Future<Map<String, String>> ocrLanguages(String service) async {
  switch (service) {
    case "tesseract":
      return await TesseractOcr.languages();
    case "baidu":
      return BaiduOcr.languages();
  }
  return {};
}
