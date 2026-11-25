import 'package:flutter/material.dart';

import 'pages/practice_page.dart';
import 'practice/practice_controller.dart';
import 'settings/settings_store.dart';
import 'theme/app_theme.dart';

class TypingPracticeApp extends StatelessWidget {
  const TypingPracticeApp({
    super.key,
    required this.settings,
    required this.controller,
  });

  final SettingsStore settings;
  final PracticeController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: settings,
    builder: (context, value, _) => MaterialApp(
      title: 'Typing Practice',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: value.themeMode,
      home: PracticePage(controller: controller, settings: settings),
    ),
  );
}
