import "package:lex/global.dart";
import 'package:lex/utils/translation_service/baidu.dart';
import 'package:lex/utils/translation_service/bing.dart';
import 'package:lex/utils/translation_service/caiyun.dart';
import 'package:lex/utils/translation_service/cambridge_dict.dart';
import 'package:lex/utils/translation_service/deepl_free.dart';
import 'package:lex/utils/translation_service/google.dart';
import 'package:lex/utils/translation_service/niutrans.dart';
import 'package:lex/utils/translation_service/volcengine.dart';
import 'package:lex/utils/translation_service/yandex.dart';
import 'package:lex/utils/translation_service/youdao.dart';

/// 初始化模型原语言
String initFromLanguage() {
  return prefs.getString("fromLanguage") ?? "自动";
}

/// 初始化模型目标语言
String initToLanguage() {
  return prefs.getString("toLanguage") ?? "中文";
}

/// 获取所有受支持语言及其受支持翻译服务
Map<String, List<String>> allLanguages() {
  Map<String, List<String>> result = {};
  for (String language in bingSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["Bing 翻译"];
    } else {
      result[language]!.add("Bing 翻译");
    }
  }
  for (String language in deeplFreeSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["DeepL 翻译"];
    } else {
      result[language]!.add("DeepL 翻译");
    }
  }
  for (String language in googleSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["Google 翻译"];
    } else {
      result[language]!.add("Google 翻译");
    }
  }
  for (String language in yandexSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["Yandex 翻译"];
    } else {
      result[language]!.add("Yandex 翻译");
    }
  }
  for (String language in volcengineSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["火山翻译", "火山翻译 Free"];
    } else {
      result[language]!.addAll(["火山翻译", "火山翻译 Free"]);
    }
  }
  for (String language in cambridgeDictSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["剑桥词典"];
    } else {
      result[language]!.add("剑桥词典");
    }
  }
  for (String language in baiduSupportLanguage().keys) {
    result[language] = ["百度翻译"];
  }
  for (String language in caiyunSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["彩云小译"];
    } else {
      result[language]!.add("彩云小译");
    }
  }
  for (String language in niutransSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["小牛翻译"];
    } else {
      result[language]!.add("小牛翻译");
    }
  }
  for (String language in youdaoSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["有道翻译"];
    } else {
      result[language]!.add("有道翻译");
    }
  }

  result.remove("自动");
  return result;
}
