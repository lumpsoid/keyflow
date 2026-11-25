import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keyflow/app.dart';
import 'package:keyflow/history/history_store.dart';
import 'package:keyflow/practice/practice_controller.dart';
import 'package:keyflow/settings/settings_store.dart';

import 'fakes.dart';

void main() {
  testWidgets('type a round, see the result, go again', (tester) async {
    SharedPreferences.setMockInitialValues({'mode': 'quote:short'});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsStore(prefs);
    final controller = PracticeController(
      library: fakeLibrary(),
      settings: settings,
      historyStore: HistoryStore(prefs),
    );
    await tester.pumpWidget(
      KeyflowApp(settings: settings, controller: controller),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('quote'), findsOneWidget);

    const text = 'to be or not';
    final input = find.byKey(const Key('typingInput'));
    for (var i = 1; i <= text.length; i++) {
      await tester.enterText(input, text.substring(0, i));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('next'), findsOneWidget);
    expect(find.textContaining('Hamlet'), findsOneWidget);
    expect(find.textContaining('first round'), findsOneWidget);

    await tester.tap(find.text('next'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('next'), findsNothing);
    expect(controller.session.typed, isEmpty);
    controller.dispose();
  });

  testWidgets('fits a small phone with the keyboard open', (tester) async {
    SharedPreferences.setMockInitialValues({'mode': 'time:60'});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsStore(prefs);
    final controller = PracticeController(
      library: fakeLibrary(),
      settings: settings,
      historyStore: HistoryStore(prefs),
    );
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      KeyflowApp(settings: settings, controller: controller),
    );
    await tester.pump(const Duration(seconds: 1));
    // Overflow would have been reported as an exception.
    expect(tester.takeException(), isNull);
    expect(find.text('60'), findsWidgets);
    controller.dispose();
  });
}
