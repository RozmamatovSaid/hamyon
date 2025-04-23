import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hamyon/services/local_database.dart';
import 'package:hamyon/views/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase().init();
  await initializeDateFormatting('uz_UZ', null);
  runApp(
    EasyLocalization(
      supportedLocales: [Locale("en"), Locale("ru"), Locale("uz")],
      path: "translations",
      fallbackLocale: Locale("uz"),
      startLocale: Locale("uz"),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<String> _localeCodes = ['uz', 'ru', 'en'];

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(),
      dark: ThemeData.dark(),
      initial: AdaptiveThemeMode.system,
      builder: (light, dark) {
        return MaterialApp(
          theme: light,
          darkTheme: dark,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        );
      },
    );
  }
}
