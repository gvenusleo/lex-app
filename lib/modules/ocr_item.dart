import "package:isar/isar.dart";

part "ocr_item.g.dart";

/// OCR 历史记录数据模型
@collection
class OcrItem {
  Id? id = Isar.autoIncrement;

  late String image;
  late String result;
  late String language;
  late String service;
  late DateTime time;
}
