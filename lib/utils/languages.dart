import 'package:metranslate/utils/translate_service/baidu.dart';
import 'package:metranslate/utils/translate_service/caiyun.dart';
import 'package:metranslate/utils/translate_service/deepl_free.dart';
import 'package:metranslate/utils/translate_service/google.dart';
import 'package:metranslate/utils/translate_service/niutrans.dart';
import 'package:metranslate/utils/translate_service/volcengine.dart';
import 'package:metranslate/utils/translate_service/yandex.dart';
import 'package:metranslate/utils/translate_service/youdao.dart';

/// 初始化模型原语言
String initFromLanguage() {
  return "自动";
}

/// 初始化模型目标语言
String initToLanguage() {
  return "中文";
}

/// 获取所有受支持语言及其受支持翻译服务
Map<String, List<String>> allLanguages() {
  Map<String, List<String>> result = {};
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
  for (String language in niutransSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["小牛翻译"];
    } else {
      result[language]!.add("小牛翻译");
    }
  }
  for (String language in volcengineSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["火山翻译", "火山翻译 Free"];
    } else {
      result[language]!.addAll(["火山翻译", "火山翻译 Free"]);
    }
  }
  for (String language in yandexSupportLanguage().keys) {
    if (result[language] == null) {
      result[language] = ["Yandex 翻译"];
    } else {
      result[language]!.add("Yandex 翻译");
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
