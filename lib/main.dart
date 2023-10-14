import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:metranslate/global.dart";
import "package:metranslate/pages/home_page.dart";
import "package:metranslate/providers/theme_provider.dart";
import "package:metranslate/providers/window_provider.dart";
import "package:metranslate/theme/theme.dart";
import "package:provider/provider.dart";

Future<void> main() async {
  await init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WindowProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "质感翻译",
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en"),
          Locale("zh"),
        ],
        theme: buildLightTheme(lightDynamic, context),
        darkTheme: buildDarkTheme(darkDynamic, context),
        themeMode: [
          ThemeMode.system,
          ThemeMode.light,
          ThemeMode.dark
        ][context.watch<ThemeProvider>().themeMode],
        home: const HomePage(),
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          );
        },
      );
    });
  }
}
