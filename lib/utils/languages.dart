// import 'package:metranslate/utils/translate_service/baidu.dart';
// import 'package:metranslate/utils/translate_service/caiyun.dart';
// import 'package:metranslate/utils/translate_service/deepl_free.dart';
// import 'package:metranslate/utils/translate_service/google.dart';
// import 'package:metranslate/utils/translate_service/minimax.dart';
// import 'package:metranslate/utils/translate_service/niutrans.dart';
// import 'package:metranslate/utils/translate_service/volcengine.dart';
// import 'package:metranslate/utils/translate_service/volcengine_free.dart';
// import 'package:metranslate/utils/translate_service/yandex.dart';
// import 'package:metranslate/utils/translate_service/youdao.dart';

/// 获取默认语言列表
List<String> languages() {
  return [
    "自动",
    "中文",
    "英语",
    "日语",
    "韩语",
    "法语",
    "德语",
    "俄语",
    "意大利语",
    "葡萄牙语",
    "繁体中文",
  ];
}

/// 初始化模型原语言
String initFromLanguage() {
  return "自动";
}

/// 初始化模型目标语言
String initToLanguage() {
  return "中文";
}
