import "package:lex/services/ocr/baidu.dart";
import "package:lex/services/ocr/tesseract.dart";
import "package:lex/services/ocr/youdao.dart";
import "package:lex/services/translation/baidu.dart";
import "package:lex/services/translation/caiyun.dart";
import "package:lex/services/translation/minimax.dart";
import "package:lex/services/translation/niutrans.dart";
import "package:lex/services/translation/volcengine.dart";
import "package:lex/services/translation/youdao.dart";
import "package:lex/services/translation/zhipuai.dart";

/// 检查翻译服务 API 是否设置
bool checkTranslationAPI(String service) {
  switch (service) {
    case "baidu":
      return BaiduTranslation.checkApi();
    case "caiyun":
      return CaiyunTranslation.checkApi();
    case "minimax":
      return MiniMaxTranslation.checkApi();
    case "niutrans":
      return NiutransTranslation.checkApi();
    case "volcengine":
      return VolcengineTranslation.checkApi();
    case "youdao":
      return YoudaoTranslation.checkApi();
    case "zhipuai":
      return ZhipuaiTranslation.checkApi();
  }
  return true;
}

/// 检查 OCR 服务 API 是否设置
Future<bool> checkOcrApi(String service) async {
  switch (service) {
    case "tesseract":
      return await TesseractOcr.isInstalled();
    case "baidu":
      return BaiduOcr.checkApi();
    case "youdao":
      return YoudaoOcr.checkApi();
  }
  return false;
}
