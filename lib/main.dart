import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'history/history_store.dart';
import 'practice/practice_controller.dart';
import 'settings/settings_store.dart';
import 'texts/text_library.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['JetBrains Mono'], ofl);
  });
  final (prefs, library) = await (
    SharedPreferences.getInstance(),
    TextLibrary.load(),
  ).wait;
  final settings = SettingsStore(prefs);
  runApp(
    TypingPracticeApp(
      settings: settings,
      controller: PracticeController(
        library: library,
        settings: settings,
        historyStore: HistoryStore(prefs),
      ),
    ),
  );
}
