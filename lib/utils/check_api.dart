import 'package:metranslate/global.dart';

/// 检查翻译服务 API 是否设置
bool checkAPI(String service) {
  switch (service) {
    case "baidu":
      if ((prefs.getString("baiduAppID") ?? "").isEmpty ||
          (prefs.getString("baiduAppKey") ?? "").isEmpty) {
        return false;
      }
      break;
    case "caiyun":
      if ((prefs.getString("caiyunToken") ?? "").isEmpty) {
        return false;
      }
      break;
    case "minimax":
      if ((prefs.getString("minimaxGroupID") ?? "").isEmpty ||
          (prefs.getString("minimaxApiKey") ?? "").isEmpty) {
        return false;
      }
      break;
    case "niutrans":
      if ((prefs.getString("niutransApiKey") ?? "").isEmpty) {
        return false;
      }
      break;
    case "volcengine":
      if ((prefs.getString("volcengineAccessKeyID") ?? "").isEmpty ||
          (prefs.getString("volcengineSecretAccessKey") ?? "").isEmpty) {
        return false;
      }
      break;
    case "youdao":
      if ((prefs.getString("youdaoAppID") ?? "").isEmpty ||
          (prefs.getString("youdaoAppKey") ?? "").isEmpty) {
        return false;
      }
      break;
    case "zhipuai":
      if ((prefs.getString("zhipuaiApiKey") ?? "").isEmpty) {
        return false;
      }
      break;
  }
  return true;
}
