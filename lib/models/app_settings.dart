import 'package:flutter/material.dart' show ThemeMode;

import 'language.dart';
import 'practice_mode.dart';
import 'word_list.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = Language.english,
    this.wordList = WordList.common200,
    this.haptics = true,
    this.liveWpm = true,
    this.mode = PracticeMode.fallback,
  });

  final ThemeMode themeMode;
  final Language language;

  /// The list picked; a language without it uses [words] instead.
  final WordList wordList;

  /// The list words are actually drawn from in [language].
  WordList get words => language.listFor(wordList);

  /// Buzz lightly on a wrong keystroke.
  final bool haptics;

  /// Show the running wpm while typing.
  final bool liveWpm;

  /// The last mode picked, restored on launch.
  final PracticeMode mode;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Language? language,
    WordList? wordList,
    bool? haptics,
    bool? liveWpm,
    PracticeMode? mode,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    wordList: wordList ?? this.wordList,
    haptics: haptics ?? this.haptics,
    liveWpm: liveWpm ?? this.liveWpm,
    mode: mode ?? this.mode,
  );
}
