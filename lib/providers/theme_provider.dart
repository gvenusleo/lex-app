import "package:flutter/material.dart";
import "package:metranslate/global.dart";

/// 主题状态监听
class ThemeProvider extends ChangeNotifier {
  // 主题背景
  int themeMode = prefs.getInt("themeMode") ?? 0;
  // 全局字体
  String fontFamily = prefs.getString("fontFamily") ?? "Sarasa-UI-SC";
  // 使用系统主题颜色
  bool useSystemThemeColor = prefs.getBool("useSystemThemeColor") ?? true;

  /// 切换主题背景
  Future<void> changeThemeMode(int mode) async {
    themeMode = mode;
    notifyListeners();
    await prefs.setInt("themeMode", mode);
  }

  // 切换全局字体
  Future<void> changeFontFamily(String fontFamily) async {
    this.fontFamily = fontFamily;
    notifyListeners();
    await prefs.setString("fontFamily", fontFamily);
  }

  // 切换是否使用系统主题颜色
  Future<void> changeUseSystemAccentColor(bool useSystemThemeColor) async {
    this.useSystemThemeColor = useSystemThemeColor;
    notifyListeners();
    await prefs.setBool("useSystemThemeColor", useSystemThemeColor);
  }
}
