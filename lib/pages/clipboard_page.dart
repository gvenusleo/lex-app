import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:isar/isar.dart";
import "package:lex/global.dart";
import "package:lex/modules/clipboard_item.dart";

/// 剪切板管理页面
class ClipboardPage extends StatefulWidget {
  const ClipboardPage({super.key});

  @override
  State<ClipboardPage> createState() => _ClipboardPageState();
}

class _ClipboardPageState extends State<ClipboardPage> {
  List<ClipboardItem> _items = [];
  List<FocusNode> _nodes = [];
  int _selectedItemIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _items = isar.clipboardItems.where().sortByTimeDesc().findAllSync();
    _nodes = List.generate(_items.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          RawKeyDownEvent rawKeyDownEvent = event;
          RawKeyEventData rawKeyEventData = rawKeyDownEvent.data;
          switch (rawKeyEventData.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              if (_selectedItemIndex > 0) {
                setState(() {
                  _selectedItemIndex--;
                });
              }
              break;
            case LogicalKeyboardKey.arrowDown:
              if (_selectedItemIndex < _items.length - 1) {
                setState(() {
                  _selectedItemIndex++;
                });
              }
              break;
          }
          return;
        }
      },
      child: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.content_paste_off_outlined),
                  SizedBox(height: 8),
                  Text("剪切板为空"),
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return MouseRegion(
                  onHover: (_) {
                    setState(() {
                      _selectedItemIndex = index;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: _items[index].text));
                      // Navigator.pop(context);
                    },
                    child: Focus(
                      focusNode: _nodes[index],
                      child: Container(
                        decoration: _selectedItemIndex == index
                            ? BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        padding: const EdgeInsets.all(4), // 根据索引改变颜色
                        child: Text(
                          _items[index].text,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
