import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../history/history.dart';
import '../history/history_store.dart';
import '../models/practice_mode.dart';
import '../models/practice_result.dart';
import '../models/practice_text.dart';
import '../models/round_outcome.dart';
import '../models/word_list.dart';
import '../settings/settings_store.dart';
import '../texts/text_library.dart';
import '../typing/typing_session.dart';

/// Runs practice rounds: picks the text, feeds input to the session, keeps
/// the clock going, and records the result when a round ends.
class PracticeController extends ChangeNotifier {
  PracticeController({
    required this._library,
    required this._settings,
    required HistoryStore historyStore,
    Random? random,
    DateTime Function()? clock,
  }) : _historyStore = historyStore,
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now,
       _history = historyStore.load(),
       _mode = _settings.value.mode,
       _wordList = _settings.value.wordList {
    _session = _newSession(_pickText());
    _settings.addListener(_onSettingsChanged);
  }

  final TextLibrary _library;
  final SettingsStore _settings;
  final HistoryStore _historyStore;
  final Random _random;
  final DateTime Function() _clock;

  History _history;

  // What the current round was built from, to tell when settings outdate it.
  PracticeMode _mode;
  WordList _wordList;

  late TypingSession _session;
  RoundOutcome? _outcome;
  Timer? _ticker;
  int _shownSecond = 0;

  /// The current round's mode.
  PracticeMode get mode => _mode;
  TypingSession get session => _session;
  History get history => _history;

  /// Set once the current round has ended.
  RoundOutcome? get outcome => _outcome;

  DateTime now() => _clock();

  /// Switches mode, which starts a fresh round (via [_onSettingsChanged]).
  void selectMode(PracticeMode mode) =>
      _settings.update(_settings.value.copyWith(mode: mode));

  /// A fresh text in the current mode, picking up any new word list.
  void next() {
    _wordList = _settings.value.wordList;
    _restart(_pickText());
  }

  /// The same text again.
  void retry() => _restart(_session.text);

  KeystrokeOutcome input(String value) {
    final outcome = _session.input(value, now());
    if (_session.isFinished) {
      _complete();
    } else if (_session.isStarted) {
      _ticker ??= Timer.periodic(const Duration(milliseconds: 100), _onTick);
    }
    notifyListeners();
    return outcome;
  }

  void clearHistory() {
    _history = History(const []);
    _historyStore.save(_history);
    notifyListeners();
  }

  PracticeText _pickText() => _library.textFor(_mode, _wordList, _random);

  TypingSession _newSession(PracticeText text) => TypingSession(
    text,
    timeLimit: switch (_mode) {
      TimeMode(:final limit) => limit,
      WordsMode() || QuoteMode() => null,
    },
  );

  void _restart(PracticeText text) {
    _stopTicker();
    _outcome = null;
    _session = _newSession(text);
    notifyListeners();
  }

  void _onSettingsChanged() {
    final settings = _settings.value;
    final modeChanged = settings.mode != _mode;
    // A new word list replaces the text only while nothing is typed yet.
    final listChanged =
        settings.wordList != _wordList &&
        !_session.isStarted &&
        _mode is! QuoteMode;
    if (!modeChanged && !listChanged) return;
    _mode = settings.mode;
    next();
  }

  void _onTick(Timer _) {
    if (_session.tick(now())) {
      _complete();
      notifyListeners();
      return;
    }
    // Live numbers change once a second; don't rebuild more often than that.
    final second = _session.elapsed(now()).inSeconds;
    if (second != _shownSecond) {
      _shownSecond = second;
      notifyListeners();
    }
  }

  void _complete() {
    _stopTicker();
    final at = now();
    final stats = _session.stats(at);
    final result = PracticeResult(
      modeKey: _mode.key,
      wpm: stats.wpm,
      rawWpm: stats.rawWpm,
      accuracy: stats.accuracy,
      duration: stats.elapsed,
      finishedAt: at,
    );
    _outcome = RoundOutcome(
      result: result,
      stats: stats,
      isPersonalBest: _history.isPersonalBest(result),
      previousBest: _history.bestFor(_mode.key)?.wpm,
      source: _session.text.source,
    );
    _history = _history.add(result);
    _historyStore.save(_history);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _shownSecond = 0;
  }

  @override
  void dispose() {
    _stopTicker();
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
