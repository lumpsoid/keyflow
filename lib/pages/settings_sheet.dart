import 'package:flutter/material.dart';

import '../app_version.dart';
import '../models/language.dart';
import '../models/word_list.dart';
import '../settings/settings_store.dart';

Future<void> showSettingsSheet(BuildContext context, SettingsStore settings) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _SettingsSheet(settings: settings),
    );

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ValueListenableBuilder(
      valueListenable: settings,
      builder: (context, value, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('settings', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('theme', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('auto')),
                  ButtonSegment(value: ThemeMode.light, label: Text('light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('dark')),
                ],
                selected: {value.themeMode},
                onSelectionChanged: (s) =>
                    settings.update(value.copyWith(themeMode: s.first)),
              ),
              const SizedBox(height: 20),
              Text('language', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in Language.values)
                    ChoiceChip(
                      label: Text(language.label),
                      selected: language == value.language,
                      onSelected: (_) =>
                          settings.update(value.copyWith(language: language)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text('words from', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<WordList>(
                segments: [
                  for (final list in WordList.values)
                    ButtonSegment(
                      value: list,
                      label: Text(list.label),
                      enabled: value.language.wordLists.contains(list),
                    ),
                ],
                selected: {value.words},
                onSelectionChanged: (s) =>
                    settings.update(value.copyWith(wordList: s.first)),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('live wpm'),
                subtitle: const Text('show speed while typing'),
                value: value.liveWpm,
                onChanged: (on) => settings.update(value.copyWith(liveWpm: on)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('vibrate on mistakes'),
                subtitle: const Text('a light tap on a wrong key'),
                value: value.haptics,
                onChanged: (on) => settings.update(value.copyWith(haptics: on)),
              ),
              const SizedBox(height: 12),
              Text(
                'Words and quotes come from Monkeytype '
                '(github.com/monkeytypegame/monkeytype), under its own license.',
                style: muted,
              ),
              const SizedBox(height: 4),
              Text('Version $appVersionLabel', style: muted),
            ],
          ),
        ),
      ),
    );
  }
}
