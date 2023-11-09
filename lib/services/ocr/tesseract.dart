import "dart:io";

import "package:process_run/process_run.dart";

/// Tesseract OCR
class TesseractOcr {
  /// 使用 Tesseract 进行文字识别
  static Future<String> ocr(String imgPath, {String language = "中文"}) async {
    var shell = Shell();
    List<ProcessResult> result = await shell.run(
      "tesseract $imgPath - -l $language",
    );
    return result.outText.trim();
  }

  /// Tesseract 支持的语言
  static Future<Map<String, String>> languages() async {
    var shell = Shell();
    List<ProcessResult> result = await shell.run(
      "tesseract --list-langs",
    );
    final List<String> langs = result.outText.trim().split("\n");
    langs.removeAt(0);
    if (langs.last == "osd") {
      langs.removeLast();
    }
    Map<String, String> langMap = {};
    for (String lang in langs) {
      langMap[_allLanguages()[lang] ?? lang] = lang;
    }
    return langMap;
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

  /// Tesseract 全部支持的语言
  static Map<String, String> _allLanguages() {
    return {
      "afr": "南非荷兰语",
      "amh": "阿姆哈拉语",
      "ara": "阿拉伯语",
      "asm": "阿萨姆语",
      "aze": "阿塞拜疆语",
      "aze_cyrl": "阿塞拜疆语(西里尔字母)",
      "bel": "白俄罗斯语",
      "ben": "孟加拉语",
      "bod": "藏语",
      "bos": "波斯尼亚语",
      "bre": "布列塔尼语",
      "bul": "保加利亚语",
      "cat": "加泰罗尼亚语(瓦伦西亚语)",
      "ceb": "宿务语",
      "ces": "捷克语",
      "chi_sim": "中文",
      "chi_tra": "繁体中文",
      "chr": "切罗基语",
      "cos": "科西嘉语",
      "cym": "威尔士语",
      "dan": "丹麦语",
      "dan_frak": "丹麦语(弗拉庫图尔字体)",
      "deu": "德语",
      "deu_frak": "德语(弗拉库图尔字体)",
      "dzo": "宗喀语",
      "ell": "希腊语(现代)",
      "eng": "英语",
      "enm": "中古英语(1100-1500年)",
      "epo": "世界语",
      "equ": "数学/方程式检测模块",
      "est": "爱沙尼亚语",
      "eus": "巴斯克语",
      "fao": "法罗语",
      "fas": "波斯语",
      "fil": "菲律宾语(他加禄语)",
      "fin": "芬兰语",
      "fra": "法语",
      "frk": "德语(弗拉库图尔字体)",
      "frm": "中古法语(约1400-1600年)",
      "fry": "西弗里西亚语",
      "gla": "苏格兰盖尔语",
      "gle": "爱尔兰语",
      "glg": "加利西亚语",
      "grc": "古希腊语(至1453年)",
      "guj": "古吉拉特语",
      "hat": "海地克里奥尔语",
      "heb": "希伯来语",
      "hin": "印地语",
      "hrv": "克罗地亚语",
      "hun": "匈牙利语",
      "hye": "亚美尼亚语",
      "iku": "因纽特语",
      "ind": "印度尼西亚语",
      "isl": "冰岛语",
      "ita": "意大利语",
      "ita_old": "意大利语(古代)",
      "jav": "爪哇语",
      "jpn": "日语",
      "kan": "卡纳达语",
      "kat": "格鲁吉亚语",
      "kat_old": "格鲁吉亚语(古代)",
      "kaz": "哈萨克语",
      "khm": "中央高棉语",
      "kir": "吉尔吉斯语(柯尔克孜语)",
      "kmr": "库尔德语(拉丁字母)",
      "kor": "韩语",
      "kor_vert": "韩语(竖排)",
      "kur": "库尔德语(阿拉伯字母)",
      "lao": "老挝语",
      "lat": "拉丁语",
      "lav": "拉脱维亚语",
      "lit": "立陶宛语",
      "ltz": "卢森堡语",
      "mal": "马拉雅拉姆语",
      "mar": "马拉地语",
      "mkd": "马其顿语",
      "mlt": "马耳他语",
      "mon": "蒙古语",
      "mri": "毛利语",
      "msa": "马来语",
      "mya": "缅甸语",
      "nep": "尼泊尔语",
      "nld": "荷兰语(弗拉芒语)",
      "nor": "挪威语",
      "oci": "奥克语(1500年后)",
      "ori": "奥里亚语",
      "osd": "方向和脚本检测模块",
      "pan": "旁遮普语；旁遮普语",
      "pol": "波兰语",
      "por": "葡萄牙语",
      "pus": "普什图语；普什图语",
      "que": "克丘亚语",
      "ron": "罗马尼亚语(摩尔达维亚语；摩尔多瓦语)",
      "rus": "俄语",
      "san": "梵语",
      "sin": "僧伽罗语；僧伽罗语",
      "slk": "斯洛伐克语",
      "slk_frak": "斯洛伐克语(弗拉库图尔字体)",
      "slv": "斯洛文尼亚语",
      "snd": "信德语",
      "spa": "西班牙语；卡斯蒂利亚语",
      "spa_old": "西班牙语(卡斯蒂利亚语)",
      "sqi": "阿尔巴尼亚语",
      "srp": "塞尔维亚语",
      "srp_latn": "塞尔维亚语(拉丁字母)",
      "sun": "巽他语",
      "swa": "斯瓦希里语",
      "swe": "瑞典语",
      "syr": "叙利亚语",
      "tam": "泰米尔语",
      "tat": "塔塔尔语",
      "tel": "泰卢固语",
      "tgk": "塔吉克语",
      "tgl": "他加禄语(新菲律宾语)",
      "tha": "泰语",
      "tir": "提格里尼亚语",
      "ton": "汤加语",
      "tur": "土耳其语",
      "uig": "维吾尔语；维吾尔语",
      "ukr": "乌克兰语",
      "urd": "乌尔都语",
      "uzb": "乌兹别克语",
      "uzb_cyrl": "乌兹别克语(西里尔字母)",
      "vie": "越南语",
      "yid": "意第绪语",
      "yor": "约鲁巴语"
    };
  }
}
