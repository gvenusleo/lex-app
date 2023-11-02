import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:isar/isar.dart";
import "package:lex/global.dart";
import "package:lex/modules/history_item.dart";
import "package:lex/utils/service_map.dart";

/// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  Map<String, List<HistoryItem>> _history = {};
  late TabController _tabController;
  final Map<String, String> serviceName = serviceMap();

  @override
  void initState() {
    initData();
    _tabController = TabController(
      length: _history.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("历史记录"),
        bottom: _history.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                splashBorderRadius: BorderRadius.circular(8),
                tabs: _history.keys
                    .map(
                      (e) => Tab(
                        text: serviceName[e] ?? e,
                      ),
                    )
                    .toList(),
              ),
      ),
      body: _history.isEmpty
          ? const Center(
              child: Text("暂无历史记录"),
            )
          : TabBarView(
              controller: _tabController,
              children: _history.keys.toList().map((e) {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: _history[e]!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                "${_history[e]![index].from} → ${_history[e]![index].to}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _history[e]![index]
                                    .time
                                    .toString()
                                    .substring(0, 19),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                          InkWell(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: double.infinity,
                              child: Text(
                                "原文：${_history[e]![index].text}",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              // 复制原文
                              Clipboard.setData(
                                ClipboardData(text: _history[e]![index].text),
                              );
                            },
                          ),
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                              width: double.infinity,
                              child: Text(
                                "译文：${_history[e]![index].result}",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              // 复制译文
                              Clipboard.setData(
                                ClipboardData(text: _history[e]![index].result),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      floatingActionButton: _history.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                // 清空历史记录
                await isar.writeTxn(() async {
                  await isar.historyItems.deleteAll(
                    _history[_history.keys.toList()[_tabController.index]]!
                        .map((e) => e.id!)
                        .toList(),
                  );
                });
                initData();
              },
              tooltip: "清空历史记录",
              child: const Icon(Icons.delete_forever_outlined),
            ),
    );
  }

  /// 初始化历史记录数据
  Future<void> initData() async {
    isar.historyItems
        .where()
        .sortByTimeDesc()
        .thenByService()
        .findAll()
        .then((value) {
      setState(() {
        _history = {};
        if (value.isNotEmpty) {
          _history["全部"] = value;
          for (var element in value) {
            if (_history.containsKey(element.service)) {
              _history[element.service]!.add(element);
            } else {
              _history[element.service] = [element];
            }
          }
          _tabController = TabController(
            length: _history.length,
            vsync: this,
          );
        }
      });
    });
  }
}
