import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keyflow/history/history_store.dart';
import 'package:keyflow/models/practice_mode.dart';
import 'package:keyflow/models/word_list.dart';
import 'package:keyflow/practice/practice_controller.dart';
import 'package:keyflow/settings/settings_store.dart';

import 'fakes.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsStore settings;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'mode': 'words:10'});
    prefs = await SharedPreferences.getInstance();
    settings = SettingsStore(prefs);
    now = DateTime(2026, 5, 1, 8);
  });

  PracticeController controller() => PracticeController(
    library: fakeLibrary(),
    settings: settings,
    historyStore: HistoryStore(prefs),
    clock: () => now,
  );

  void typeAll(PracticeController c) {
    final text = c.session.words.join(' ');
    for (var i = 1; i <= text.length; i++) {
      now = now.add(const Duration(milliseconds: 150));
      c.input(text.substring(0, i));
    }
  }

  test('restores the last mode and records a finished round', () {
    final c = controller();
    expect(c.mode, const WordsMode(10));
    expect(c.session.words, List.filled(10, 'go'));

    typeAll(c);
    final outcome = c.outcome;
    expect(outcome, isNotNull);
    expect(outcome!.result.modeKey, 'words:10');
    expect(outcome.result.accuracy, 100);
    expect(outcome.previousBest, isNull);
    expect(HistoryStore(prefs).load().results, hasLength(1));
    c.dispose();
  });

  test('a faster second round is a personal best', () {
    final c = controller();
    typeAll(c);
    c.next();
    final text = c.session.words.join(' ');
    c.input(text[0]);
    now = now.add(const Duration(milliseconds: 500));
    c.input(text);
    expect(c.outcome!.isPersonalBest, isTrue);
    c.dispose();
  });

  test('changing mode starts a fresh round and is remembered', () {
    final c = controller();
    c.selectMode(const QuoteMode(QuoteLength.short));
    expect(c.mode, const QuoteMode(QuoteLength.short));
    expect(c.session.text.source, 'Hamlet');
    expect(SettingsStore(prefs).value.mode, const QuoteMode(QuoteLength.short));
    c.dispose();
  });

  test('a new word list replaces an untouched round only', () {
    final c = controller();
    settings.update(settings.value.copyWith(wordList: WordList.common1k));
    expect(c.session.words.first, 'run');

    c.input('r');
    settings.update(settings.value.copyWith(wordList: WordList.common200));
    expect(c.session.words.first, 'run', reason: 'round in progress is kept');
    c.next();
    expect(c.session.words.first, 'go');
    c.dispose();
  });
}
