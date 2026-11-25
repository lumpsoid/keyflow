import 'package:flutter/material.dart';

import '../models/practice_mode.dart';

/// A compact pill: the mode kind (time, words, quote) and its options.
class ModePicker extends StatelessWidget {
  const ModePicker({super.key, required this.mode, required this.onChanged});

  final PracticeMode mode;
  final ValueChanged<PracticeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kinds = <(String, IconData, PracticeMode, bool)>[
      ('time', Icons.timer_outlined, const TimeMode(30), mode is TimeMode),
      ('words', Icons.notes, const WordsMode(25), mode is WordsMode),
      (
        'quote',
        Icons.format_quote,
        const QuoteMode(QuoteLength.medium),
        mode is QuoteMode,
      ),
    ];
    final options = <(String, PracticeMode)>[
      ...switch (mode) {
        TimeMode() => [for (final s in TimeMode.options) ('$s', TimeMode(s))],
        WordsMode() => [
          for (final c in WordsMode.options) ('$c', WordsMode(c)),
        ],
        QuoteMode() => [
          for (final l in QuoteLength.values) (l.name, QuoteMode(l)),
        ],
      },
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (label, icon, target, selected) in kinds)
              _Choice(
                label: label,
                icon: icon,
                selected: selected,
                onTap: selected ? null : () => onChanged(target),
              ),
            Container(
              width: 3,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            for (final (label, target) in options)
              _Choice(
                label: label,
                selected: target == mode,
                onTap: () => onChanged(target),
              ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final text = Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: icon == null
              ? text
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    text,
                  ],
                ),
        ),
      ),
    );
  }
}
