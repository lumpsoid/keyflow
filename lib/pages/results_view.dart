import 'package:flutter/material.dart';

import '../models/practice_mode.dart';
import '../models/round_outcome.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti.dart';
import '../widgets/wpm_chart.dart';

/// The end of a round: the numbers, how they compare, and the way onward.
class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
    required this.outcome,
    required this.onNext,
    required this.onRetry,
  });

  final RoundOutcome outcome;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typing = TypingColors.of(context);
    final stats = outcome.stats;
    final result = outcome.result;

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Verdict(outcome: outcome),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _CountUp(
                          label: 'wpm',
                          value: result.wpm,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _CountUp(
                          label: 'accuracy',
                          value: result.accuracy,
                          suffix: '%',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: typing.correct,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: WpmChart(samples: stats.wpmPerSecond),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _Fact('raw', result.rawWpm.toStringAsFixed(0)),
                      _Fact(
                        'characters',
                        '${stats.correctChars}/${stats.incorrectChars}/'
                            '${stats.extraChars}/${stats.missedChars}',
                        tooltip: 'correct / incorrect / extra / missed',
                      ),
                      _Fact(
                        'time',
                        '${(stats.elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s',
                      ),
                      _Fact('mode', PracticeMode.parse(result.modeKey).label),
                    ],
                  ),
                  if (outcome.source case final source?) ...[
                    const SizedBox(height: 20),
                    Text(
                      '— $source',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        autofocus: true,
                        onPressed: onNext,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('next'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.replay),
                        label: const Text('same text again'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (outcome.isPersonalBest)
          Positioned.fill(
            child: Confetti(
              colors: [
                typing.caret,
                typing.correct,
                typing.incorrect,
                scheme.tertiary,
              ],
            ),
          ),
      ],
    );
  }
}

/// One line on how this round compares with earlier ones.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.outcome});

  final RoundOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previous = outcome.previousBest;
    final (icon, text, highlight) = switch (previous) {
      _ when outcome.isPersonalBest => (
        Icons.emoji_events,
        'new personal best! up from ${previous?.toStringAsFixed(0)} wpm',
        true,
      ),
      null => (
        Icons.flag_outlined,
        'first round in this mode — the score to beat',
        false,
      ),
      final best => (
        Icons.trending_up,
        'personal best ${best.toStringAsFixed(0)} wpm',
        false,
      ),
    };
    final color = highlight ? scheme.primary : scheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _CountUp extends StatelessWidget {
  const _CountUp({
    required this.label,
    required this.value,
    required this.style,
    this.suffix = '',
  });

  final String label;
  final double value;
  final TextStyle? style;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Text(
            '${v.toStringAsFixed(0)}$suffix',
            style: style,
            semanticsLabel: '${value.toStringAsFixed(0)}$suffix $label',
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, {this.tooltip});

  final String label;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
    return tooltip == null ? fact : Tooltip(message: tooltip, child: fact);
  }
}
