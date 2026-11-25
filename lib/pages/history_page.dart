import 'package:flutter/material.dart';

import '../history/history.dart';
import '../models/practice_mode.dart';
import '../models/practice_result.dart';
import '../practice/practice_controller.dart';

/// Progress over time: streak, totals, personal bests and recent rounds.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.controller});

  final PracticeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final history = controller.history;
        return Scaffold(
          appBar: AppBar(
            title: const Text('progress'),
            actions: [
              if (!history.isEmpty)
                IconButton(
                  tooltip: 'clear history',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          body: history.isEmpty
              ? const _Empty()
              : _Progress(history: history, today: controller.now()),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('clear history?'),
        content: const Text('Every result and personal best will be gone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('clear'),
          ),
        ],
      ),
    );
    if (clear ?? false) controller.clearHistory();
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.keyboard, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('nothing here yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Finish a round and your progress shows up here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.history, required this.today});

  final History history;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = history.streakDays(today);
    final bests = history.personalBests.values.toList()
      ..sort((a, b) => b.wpm.compareTo(a.wpm));
    final minutes = history.totalTime.inMinutes;
    final heading = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Tile(
                  icon: Icons.local_fire_department,
                  value: '$streak',
                  label: streak == 1 ? 'day streak' : 'days streak',
                  highlight: streak > 0,
                ),
                _Tile(
                  icon: Icons.speed,
                  value: history.averageWpm()?.toStringAsFixed(0) ?? '-',
                  label: 'avg wpm, last 10',
                ),
                _Tile(
                  icon: Icons.check_circle_outline,
                  value: '${history.results.length}',
                  label: 'rounds',
                ),
                _Tile(
                  icon: Icons.schedule,
                  value: minutes < 1 ? '<1' : '$minutes',
                  label: 'minutes typed',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('personal bests', style: heading),
            const SizedBox(height: 4),
            for (final r in bests) _ResultTile(result: r, today: today),
            const SizedBox(height: 24),
            Text('recent', style: heading),
            const SizedBox(height: 4),
            for (final r in history.results.take(50))
              _ResultTile(result: r, today: today),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 160,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: highlight ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(value, style: theme.textTheme.headlineMedium),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.today});

  final PracticeResult result;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${PracticeMode.parse(result.modeKey).label} · ${result.language.label}',
      ),
      subtitle: Text(
        '${result.accuracy.toStringAsFixed(0)}% acc · ${_when(result.finishedAt)}',
      ),
      trailing: Text(
        '${result.wpm.toStringAsFixed(0)} wpm',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  String _when(DateTime at) {
    final days = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(at.year, at.month, at.day)).inDays;
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return switch (days) {
      0 => 'today $time',
      1 => 'yesterday $time',
      _ =>
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}',
    };
  }
}
