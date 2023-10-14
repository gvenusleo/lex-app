import "package:flutter/material.dart";
import "package:metranslate/providers/theme_provider.dart";
import "package:metranslate/utils/font_utils.dart";
import "package:provider/provider.dart";

/// 全局字体设置页面
class FontSettingPage extends StatefulWidget {
  const FontSettingPage({Key? key}) : super(key: key);

  @override
  State<FontSettingPage> createState() => _FontSettingPageState();
}

class _FontSettingPageState extends State<FontSettingPage> {
  // 字体列表
  List<String> _fonts = [];

  @override
  void initState() {
    _readFonts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("全局字体"),
        actions: [
          // 添加字体
          IconButton(
            onPressed: () async {
              await loadLocalFont();
              _readFonts();
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: readAllFont(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _fonts = snapshot.data as List<String>;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: _fonts.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return RadioListTile(
                    value: "默认字体",
                    groupValue: context.watch<ThemeProvider>().fontFamily,
                    title: const Text(
                      "默认字体",
                      style: TextStyle(fontFamily: "默认字体"),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ThemeProvider>().changeFontFamily(value);
                      }
                    },
                  );
                }
                if (index == _fonts.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Text("注意：仅支持导入 otf/ttf/ttc 格式的字体文件"),
                  );
                }
                return RadioListTile(
                  value: _fonts[index - 1],
                  groupValue: context.watch<ThemeProvider>().fontFamily,
                  title: Text(
                    _fonts[index - 1].split(".").first,
                    style: TextStyle(fontFamily: _fonts[index - 1]),
                  ),
                  secondary: IconButton(
                    onPressed: () async {
                      /* 删除字体 */
                      if (context.read<ThemeProvider>().fontFamily ==
                          _fonts[index - 1]) {
                        context.read<ThemeProvider>().changeFontFamily("默认字体");
                      }
                      await deleteFont(_fonts[index - 1]);
                      _readFonts();
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeProvider>().changeFontFamily(value);
                    }
                  },
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  /// 读取所有字体
  Future<void> _readFonts() async {
    readAllFont().then(
      (value) => setState(
        () {
          _fonts = value;
        },
      ),
    );
  }
}
