import '../models/language.dart';
import '../models/practice_result.dart';

/// Past results, newest first, and what they add up to.
class History {
  History(Iterable<PracticeResult> results)
    : results = List.unmodifiable(
        results.toList()..sort((a, b) => b.finishedAt.compareTo(a.finishedAt)),
      );

  /// Results kept; older ones are dropped on save.
  static const capacity = 1000;

  final List<PracticeResult> results;

  bool get isEmpty => results.isEmpty;

  History add(PracticeResult result) =>
      History([result, ...results.take(capacity - 1)]);

  /// Best wpm per language and mode key: speeds in different languages
  /// don't compare.
  Map<(Language, String), PracticeResult> get personalBests {
    final best = <(Language, String), PracticeResult>{};
    for (final r in results) {
      final key = (r.language, r.modeKey);
      final current = best[key];
      if (current == null || r.wpm > current.wpm) best[key] = r;
    }
    return best;
  }

  PracticeResult? bestFor(Language language, String modeKey) =>
      personalBests[(language, modeKey)];

  /// Whether [result] beats every earlier result in its language and mode. A
  /// first result there is not a personal best: there was nothing to beat.
  bool isPersonalBest(PracticeResult result) {
    final previous = results.where(
      (r) =>
          r.language == result.language &&
          r.modeKey == result.modeKey &&
          r != result,
    );
    return previous.isNotEmpty && previous.every((r) => result.wpm > r.wpm);
  }

  /// Consecutive days with at least one result, ending today or yesterday
  /// (a streak is not lost until a whole day is missed).
  int streakDays(DateTime today) {
    final days = {for (final r in results) _day(r.finishedAt)};
    var day = _day(today);
    if (!days.contains(day)) day = _previousDay(day);
    var streak = 0;
    while (days.contains(day)) {
      streak++;
      day = _previousDay(day);
    }
    return streak;
  }

  /// Mean wpm of the latest [count] results.
  double? averageWpm({int count = 10}) {
    if (results.isEmpty) return null;
    final latest = results.take(count);
    return latest.fold<double>(0, (sum, r) => sum + r.wpm) / latest.length;
  }

  Duration get totalTime =>
      results.fold(Duration.zero, (sum, r) => sum + r.duration);

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  // Built from fields, not by subtracting 24h, so DST changes don't skip days.
  static DateTime _previousDay(DateTime d) =>
      DateTime(d.year, d.month, d.day - 1);
}
