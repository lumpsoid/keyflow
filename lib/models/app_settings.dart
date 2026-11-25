import 'package:flutter/material.dart' show ThemeMode;

import 'practice_mode.dart';
import 'word_list.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.wordList = WordList.common200,
    this.haptics = true,
    this.liveWpm = true,
    this.mode = PracticeMode.fallback,
  });

  final ThemeMode themeMode;
  final WordList wordList;

  /// Buzz lightly on a wrong keystroke.
  final bool haptics;

  /// Show the running wpm while typing.
  final bool liveWpm;

  /// The last mode picked, restored on launch.
  final PracticeMode mode;

  AppSettings copyWith({
    ThemeMode? themeMode,
    WordList? wordList,
    bool? haptics,
    bool? liveWpm,
    PracticeMode? mode,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    wordList: wordList ?? this.wordList,
    haptics: haptics ?? this.haptics,
    liveWpm: liveWpm ?? this.liveWpm,
    mode: mode ?? this.mode,
  );
}
