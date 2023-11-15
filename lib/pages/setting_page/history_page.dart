import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:isar/isar.dart";
import "package:lex/global.dart";
import "package:lex/modules/translation_item.dart";
import "package:lex/utils/service_map.dart";

/// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // with TickerProviderStateMixin {
  List<TranslationItem> _translationHistory = [];
  // List<OcrItem> _ocrHistory = [];
  // late TabController _tabController;
  // int _selectedIndex = 0;
  final Map<String, String> translationServiceName = translationServiceMap();
  // final Map<String, String> ocrServiceName = ocrServiceMap();

  @override
  void initState() {
    _initData();
    // _tabController = TabController(
    // length: 2,
    // vsync: this,
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("历史记录"),
        // bottom: TabBar(
        // controller: _tabController,
        // isScrollable: true,
        // splashBorderRadius: BorderRadius.circular(8),
        // tabs: const [
        // Tab(
        // text: "文本翻译",
        // ),
        // Tab(
        // text: "文字识别",
        // ),
        // ],
        // onTap: (value) {
        // setState(() {
        // _selectedIndex = value;
        // });
        // },
        // ),
      ),
      body: // TabBarView(
          // controller: _tabController,
          // children: [
          _translationHistory.isEmpty
              ? _buildEmpty()
              : _buildTranslationItems(),
      //   _ocrHistory.isEmpty ? _buildEmpty() : _buildOcrItems(),
      // ],
      // ),
      floatingActionButton: _buildFab(),
    );
  }

  /// 初始化历史记录数据
  Future<void> _initData() async {
    setState(() {
      _translationHistory =
          isar.translationItems.where().sortByTimeDesc().findAllSync();
      // _ocrHistory = isar.ocrItems.where().sortByImageDesc().findAllSync();
    });
  }

  /// 构建文本翻译历史记录
  Widget _buildTranslationItems() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: _translationHistory.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    "${translationServiceName[_translationHistory[index].service]}：${_translationHistory[index].from} → ${_translationHistory[index].to}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _translationHistory[index].time.toString().substring(0, 19),
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  width: double.infinity,
                  child: Text(
                    "原文：${_translationHistory[index].text}",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 50,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  // 复制原文
                  Clipboard.setData(
                    ClipboardData(text: _translationHistory[index].text),
                  );
                },
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  width: double.infinity,
                  child: Text(
                    "译文：${_translationHistory[index].result}",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 50,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  // 复制译文
                  Clipboard.setData(
                    ClipboardData(text: _translationHistory[index].result),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建文字识别历史记录
  // Widget _buildOcrItems() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.only(bottom: 18),
  //     itemCount: _ocrHistory.length,
  //     itemBuilder: (context, index) {
  //       return Card(
  //         clipBehavior: Clip.hardEdge,
  //         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 4),
  //             Row(
  //               children: [
  //                 const SizedBox(width: 4),
  //                 Text(
  //                   "${ocrServiceName[_ocrHistory[index].service]}：${_ocrHistory[index].language}",
  //                   style: const TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 const Spacer(),
  //                 Text(
  //                   _ocrHistory[index].time.toString().substring(0, 19),
  //                   style: const TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 4),
  //               ],
  //             ),
  //             InkWell(
  //               child: Container(
  //                 padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
  //                 width: double.infinity,
  //                 child: Text(
  //                   _ocrHistory[index].result,
  //                   style: const TextStyle(
  //                     fontSize: 14,
  //                   ),
  //                   maxLines: 50,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               onTap: () {
  //                 // 复制译文
  //                 Clipboard.setData(
  //                   ClipboardData(text: _ocrHistory[index].result),
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  /// 历史记录未空时显示的组件
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 36,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            "暂无历史记录",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }

  /// FAB
  Widget? _buildFab() {
    // if (_selectedIndex == 0 && _translationHistory.isNotEmpty) {
    return FloatingActionButton(
      onPressed: () async {
        // 清空历史记录
        await isar.writeTxn(() async {
          await isar.translationItems.deleteAll(
            _translationHistory.map((e) => e.id!).toList(),
          );
        });
        _initData();
      },
      tooltip: "清空历史记录",
      child: const Icon(Icons.delete_forever_outlined),
    );
    // }
    // if (_selectedIndex == 1 && _ocrHistory.isNotEmpty) {
    //   return FloatingActionButton(
    //     onPressed: () async {
    //       // 清空历史记录
    //       await isar.writeTxn(() async {
    //         await isar.ocrItems.deleteAll(
    //           _ocrHistory.map((e) => e.id!).toList(),
    //         );
    //       });
    //       _initData();
    //     },
    //     tooltip: "清空历史记录",
    //     child: const Icon(Icons.delete_forever_outlined),
    //   );
    // }
    // return null;
  }
}
