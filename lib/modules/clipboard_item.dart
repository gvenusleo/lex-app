import "package:isar/isar.dart";

part "clipboard_item.g.dart";

/// 剪切板历史纪录
@collection
class ClipboardItem {
  Id? id = Isar.autoIncrement;

  late String text;
  late DateTime time;
}
