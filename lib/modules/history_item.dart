import "package:isar/isar.dart";

part "history_item.g.dart";

/// 翻译历史记录数据模型
@collection
class HistoryItem {
  Id? id = Isar.autoIncrement;

  late String text;
  late String result;
  late String from;
  late String to;
  late String service;
  late DateTime time;
}
