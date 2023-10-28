import "package:flutter/material.dart";
import "package:lex/providers/theme_provider.dart";
import "package:provider/provider.dart";

/// 亮色主题
ThemeData buildLightTheme(ColorScheme? lightDynamic, BuildContext context) {
  ColorScheme colorScheme =
      (context.watch<ThemeProvider>().useSystemThemeColor &&
              lightDynamic != null)
          ? lightDynamic
          : ColorScheme.fromSeed(
              seedColor: const Color(0xff0788FF),
              brightness: Brightness.light,
            );
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: context.watch<ThemeProvider>().fontFamily,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
    ),
  );
}

/// 暗色主题
ThemeData buildDarkTheme(ColorScheme? darkDynamic, BuildContext context) {
  ColorScheme colorScheme =
      (context.watch<ThemeProvider>().useSystemThemeColor &&
              darkDynamic != null)
          ? darkDynamic
          : ColorScheme.fromSeed(
              seedColor: const Color(0xff0788FF),
              brightness: Brightness.dark,
            );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: context.watch<ThemeProvider>().fontFamily,
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
    ),
  );
}
