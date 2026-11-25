import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/practice_mode.dart';
import '../models/word_list.dart';

/// Keeps [AppSettings] on the device and notifies when they change.
class SettingsStore extends ValueNotifier<AppSettings> {
  SettingsStore(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static AppSettings _read(SharedPreferences prefs) {
    const defaults = AppSettings();
    return AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[prefs.getString('theme')] ??
          defaults.themeMode,
      wordList:
          WordList.values.asNameMap()[prefs.getString('wordList')] ??
          defaults.wordList,
      haptics: prefs.getBool('haptics') ?? defaults.haptics,
      liveWpm: prefs.getBool('liveWpm') ?? defaults.liveWpm,
      mode: PracticeMode.parse(prefs.getString('mode') ?? ''),
    );
  }

  void update(AppSettings settings) {
    value = settings;
    _prefs
      ..setString('theme', settings.themeMode.name)
      ..setString('wordList', settings.wordList.name)
      ..setBool('haptics', settings.haptics)
      ..setBool('liveWpm', settings.liveWpm)
      ..setString('mode', settings.mode.key);
  }
}
