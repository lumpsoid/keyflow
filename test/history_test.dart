import 'package:flutter_test/flutter_test.dart';
import 'package:keyflow/history/history.dart';
import 'package:keyflow/models/practice_result.dart';

PracticeResult result(double wpm, DateTime at, {String mode = 'words:25'}) =>
    PracticeResult(
      modeKey: mode,
      wpm: wpm,
      rawWpm: wpm,
      accuracy: 100,
      duration: const Duration(seconds: 20),
      finishedAt: at,
    );

void main() {
  final today = DateTime(2026, 3, 10, 9);

  test('streak counts consecutive days ending today or yesterday', () {
    final days = [10, 9, 8, 6].map((d) => DateTime(2026, 3, d, 20));
    final history = History([for (final d in days) result(50, d)]);
    expect(history.streakDays(today), 3);
    expect(history.streakDays(DateTime(2026, 3, 11)), 3);
    expect(history.streakDays(DateTime(2026, 3, 12)), 0);
  });

  test('streak survives a DST change', () {
    // Europe moves clocks on 2026-03-29; days are counted by date.
    final history = History([
      for (final d in [28, 29, 30]) result(50, DateTime(2026, 3, d, 1)),
    ]);
    expect(history.streakDays(DateTime(2026, 3, 30, 23)), 3);
  });

  test('a personal best beats every earlier result in its mode', () {
    final history = History([
      result(60, today),
      result(90, today, mode: 'time:30'),
    ]);
    expect(history.isPersonalBest(result(61, today)), isTrue);
    expect(history.isPersonalBest(result(60, today)), isFalse);
    expect(
      history.isPersonalBest(result(10, today, mode: 'quote:short')),
      isFalse,
      reason: 'nothing to beat in a new mode',
    );
    expect(history.bestFor('time:30')?.wpm, 90);
  });

  test('results are kept newest first and capped', () {
    var history = History(const []);
    for (var i = 0; i < History.capacity + 5; i++) {
      history = history.add(
        result(i.toDouble(), today.add(Duration(minutes: i))),
      );
    }
    expect(history.results, hasLength(History.capacity));
    expect(history.results.first.wpm, History.capacity + 4);
    expect(history.averageWpm(count: 2), History.capacity + 3.5);
  });
}
