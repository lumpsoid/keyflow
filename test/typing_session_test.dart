import 'package:flutter_test/flutter_test.dart';
import 'package:typing_practice/models/practice_text.dart';
import 'package:typing_practice/typing/typing_session.dart';

final t0 = DateTime(2026, 1, 1, 12);
DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

/// Types [text] one character at a time, [msPerChar] apart, from [startMs].
void typeChars(
  TypingSession s,
  String text, {
  int startMs = 0,
  int msPerChar = 100,
}) {
  var value = s.typed;
  for (var i = 0; i < text.length; i++) {
    value += text[i];
    s.input(value, at(startMs + i * msPerChar));
  }
}

void main() {
  TypingSession session(String words, {Duration? limit}) =>
      TypingSession(PracticeText(words.split(' ')), timeLimit: limit);

  test('starts on the first keystroke and finishes on the last word', () {
    final s = session('the cat');
    expect(s.isStarted, isFalse);
    typeChars(s, 'the ca');
    expect(s.isStarted, isTrue);
    expect(s.isFinished, isFalse);
    typeChars(s, 't', startMs: 600);
    expect(s.isFinished, isTrue);

    final stats = s.stats(at(10000));
    expect(stats.elapsed, const Duration(milliseconds: 600));
    expect(stats.accuracy, 100);
    // 7 characters (6 letters, 1 space) in 0.01 minutes = 140 wpm.
    expect(stats.wpm, closeTo(140, 0.001));
    expect(stats.correctChars, 6);
  });

  test('a space skips to the next word, counting what was missed', () {
    final s = session('hello world now');
    typeChars(s, 'hel world now');
    expect(s.isFinished, isTrue);
    final stats = s.stats(at(5000));
    expect(stats.missedChars, 2);
    expect(stats.correctChars, 3 + 5 + 3);
    // The space after the incomplete word was a wrong keystroke.
    expect(stats.accuracy, closeTo(12 / 13 * 100, 0.001));
  });

  test('a space after a wrong last word ends the round', () {
    final s = session('a b');
    typeChars(s, 'a x ');
    expect(s.isFinished, isTrue);
    expect(s.typed, 'a x');
    expect(s.stats(at(1000)).incorrectChars, 1);
  });

  test('extra characters are counted and capped', () {
    final s = session('hi there');
    typeChars(s, 'hiii');
    expect(s.typed, 'hiii');
    expect(s.stats(at(500)).extraChars, 2);
    final tooLong = 'hi${'x' * (TypingSession.maxExtraChars + 1)}';
    expect(s.input(tooLong, at(600)), KeystrokeOutcome.none);
    expect(s.typed, 'hiii');
  });

  test('leading and double spaces are ignored', () {
    final s = session('a b c');
    s.input(' ', at(0));
    expect(s.typed, '');
    expect(s.isStarted, isFalse);
    typeChars(s, 'a ');
    s.input('a  ', at(300));
    expect(s.typed, 'a ');
  });

  test('backspace removes characters without counting a keystroke', () {
    final s = session('abc def');
    typeChars(s, 'abx');
    s.input('ab', at(400));
    typeChars(s, 'c', startMs: 500);
    final stats = s.stats(at(600));
    expect(s.typed, 'abc');
    expect(stats.incorrectChars, 0);
    expect(stats.accuracy, 75); // 3 of 4 keystrokes were right
  });

  test('reports the outcome of the newest keystroke', () {
    final s = session('ab');
    expect(s.input('a', at(0)), KeystrokeOutcome.correct);
    expect(s.input('ax', at(100)), KeystrokeOutcome.wrong);
  });

  test('a timed round ends exactly at its limit', () {
    final s = session('one two three four', limit: const Duration(seconds: 15));
    typeChars(s, 'one t');
    expect(s.tick(at(14999)), isFalse);
    expect(s.tick(at(20000)), isTrue);
    expect(s.isFinished, isTrue);
    expect(s.elapsed(at(30000)), const Duration(seconds: 15));
    expect(s.input('one tw', at(20001)), KeystrokeOutcome.none);
  });

  test('wpm per second is sampled for each second', () {
    final s = session('aaaaa bbbbb ccccc');
    typeChars(s, 'aaaaa bbbbb ccccc', msPerChar: 200);
    final samples = s.stats(at(99999)).wpmPerSecond;
    // 17 keystrokes 200ms apart take 3.2s: four samples.
    expect(samples, hasLength(4));
    expect(samples.first, closeTo(6 / 5 / (1 / 60), 0.001));
  });
}
