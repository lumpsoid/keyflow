import 'dart:math';

import '../models/practice_text.dart';
import 'typing_stats.dart';

/// One round of typing against a list of words, Monkeytype-style: a space
/// moves on to the next word, so a slip costs one word, not the rest of the
/// line. Time is always passed in, so every rule here runs on plain values.
class TypingSession {
  TypingSession(this.text, {this.timeLimit});

  /// Extra characters allowed past the end of a word before input is ignored.
  static const maxExtraChars = 12;

  final PracticeText text;

  /// Set for timed rounds; the round ends when it runs out.
  final Duration? timeLimit;

  List<String> get words => text.words;

  String _typed = '';
  DateTime? _startedAt;
  DateTime? _endedAt;
  final List<_Keystroke> _keystrokes = [];

  /// Everything typed so far, words separated by single spaces.
  String get typed => _typed;

  bool get isStarted => _startedAt != null;
  bool get isFinished => _endedAt != null;

  /// What has been typed for each word reached so far; the last entry is
  /// the word in progress.
  List<String> get typedWords => _typed.split(' ');

  /// Index of the word being typed.
  int get currentWordIndex => typedWords.length - 1;

  Duration elapsed(DateTime now) {
    final start = _startedAt;
    if (start == null) return Duration.zero;
    return (_endedAt ?? now).difference(start);
  }

  /// Time left in a timed round, null for untimed ones.
  Duration? remaining(DateTime now) {
    final limit = timeLimit;
    if (limit == null) return null;
    final left = limit - elapsed(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Applies the input field's new content. Input that breaks the shape of
  /// [typed] (leading or double spaces, too many extra characters, typing
  /// past the last word) is dropped, so callers should copy [typed] back
  /// into the field afterwards. Returns the outcome of the newest keystroke.
  KeystrokeOutcome input(String value, DateTime at) {
    if (isFinished || value == _typed) return KeystrokeOutcome.none;
    final (accepted, :endsRound) = _accept(value);
    if (accepted == _typed && !endsRound) return KeystrokeOutcome.none;

    var prefix = 0;
    final shorter = min(accepted.length, _typed.length);
    while (prefix < shorter && accepted[prefix] == _typed[prefix]) {
      prefix++;
    }

    var outcome = KeystrokeOutcome.none;
    if (accepted.length > prefix) _startedAt ??= at;
    for (var i = prefix; i < accepted.length; i++) {
      final correct = _isCorrectAt(accepted, i);
      _keystrokes.add(_Keystroke(at, correct: correct));
      outcome = correct ? KeystrokeOutcome.correct : KeystrokeOutcome.wrong;
    }
    _typed = accepted;

    if (endsRound) {
      _startedAt ??= at;
      final correct = typedWords.last == words.last;
      _keystrokes.add(_Keystroke(at, correct: correct));
      outcome = correct ? KeystrokeOutcome.correct : KeystrokeOutcome.wrong;
    }
    final lastWordDone =
        typedWords.length == words.length && typedWords.last == words.last;
    if (endsRound || lastWordDone) _endedAt = at;
    return outcome;
  }

  /// Ends a timed round once its time is up. Returns true if it just ended.
  bool tick(DateTime now) {
    final limit = timeLimit;
    final start = _startedAt;
    if (isFinished || limit == null || start == null) return false;
    if (now.difference(start) < limit) return false;
    _endedAt = start.add(limit);
    return true;
  }

  /// The round's numbers, live while typing or final once finished.
  TypingStats stats(DateTime now) {
    final elapsed = this.elapsed(now);
    final typedWords = this.typedWords;
    var correctWordChars = 0;
    var correct = 0, incorrect = 0, extra = 0, missed = 0;

    for (var i = 0; i < typedWords.length; i++) {
      final target = words[i];
      final typed = typedWords[i];
      final isDone = i < typedWords.length - 1 || isFinished;
      if (typed == target) {
        // A correct word earns its trailing space too, except the last one.
        correctWordChars += target.length + (i < words.length - 1 ? 1 : 0);
      }
      for (var j = 0; j < max(target.length, typed.length); j++) {
        if (j >= typed.length) {
          if (isDone) missed++;
        } else if (j >= target.length) {
          extra++;
        } else if (typed[j] == target[j]) {
          correct++;
        } else {
          incorrect++;
        }
      }
    }

    final correctStrokes = _keystrokes.where((k) => k.correct).length;
    return TypingStats(
      elapsed: elapsed,
      wpm: wpmFor(correctWordChars, elapsed),
      rawWpm: wpmFor(_typed.length, elapsed),
      accuracy: _keystrokes.isEmpty
          ? 100
          : correctStrokes / _keystrokes.length * 100,
      correctChars: correct,
      incorrectChars: incorrect,
      extraChars: extra,
      missedChars: missed,
      wpmPerSecond: _wpmPerSecond(elapsed),
    );
  }

  /// Words per minute, counting five characters as a word.
  static double wpmFor(int chars, Duration elapsed) {
    final minutes = elapsed.inMilliseconds / Duration.millisecondsPerMinute;
    return minutes <= 0 ? 0 : chars / 5 / minutes;
  }

  /// The part of [value] kept as [typed], and whether it ends the round
  /// with a space after the last word (the space itself is not kept).
  (String, {bool endsRound}) _accept(String value) {
    final rejected = (_typed, endsRound: false);
    if (value.startsWith(' ') || value.contains('  ')) return rejected;
    final parts = value.split(' ');
    if (parts.length > words.length + 1) return rejected;
    for (var i = 0; i < parts.length && i < words.length; i++) {
      if (parts[i].length > words[i].length + maxExtraChars) return rejected;
    }
    if (parts.length == words.length + 1) {
      if (parts.last.isNotEmpty) return rejected;
      return (value.substring(0, value.length - 1), endsRound: true);
    }
    return (value, endsRound: false);
  }

  bool _isCorrectAt(String value, int index) {
    final wordStart = index == 0 ? 0 : value.lastIndexOf(' ', index - 1) + 1;
    final wordIndex = ' '.allMatches(value.substring(0, wordStart)).length;
    final target = words[wordIndex];
    if (value[index] == ' ') {
      return value.substring(wordStart, index) == target;
    }
    final charIndex = index - wordStart;
    return charIndex < target.length && value[index] == target[charIndex];
  }

  List<double> _wpmPerSecond(Duration elapsed) {
    final start = _startedAt;
    if (start == null) return const [];
    final seconds = (elapsed.inMilliseconds / 1000).ceil();
    final samples = <double>[];
    var correct = 0;
    var k = 0;
    for (var s = 1; s <= seconds; s++) {
      final until = start.add(Duration(seconds: s));
      while (k < _keystrokes.length && !_keystrokes[k].at.isAfter(until)) {
        if (_keystrokes[k].correct) correct++;
        k++;
      }
      final span = s == seconds ? elapsed : Duration(seconds: s);
      samples.add(wpmFor(correct, span));
    }
    return samples;
  }
}

enum KeystrokeOutcome { none, correct, wrong }

class _Keystroke {
  const _Keystroke(this.at, {required this.correct});

  final DateTime at;
  final bool correct;
}
