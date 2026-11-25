import '../typing/typing_stats.dart';
import 'practice_result.dart';

/// A finished round, as shown on the results screen.
class RoundOutcome {
  const RoundOutcome({
    required this.result,
    required this.stats,
    required this.isPersonalBest,
    required this.previousBest,
    this.source,
  });

  final PracticeResult result;
  final TypingStats stats;
  final bool isPersonalBest;

  /// Best wpm in this mode before this round; null on a mode's first round.
  final double? previousBest;

  /// The quote's attribution, null for word rounds.
  final String? source;
}
