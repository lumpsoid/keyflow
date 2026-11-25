import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:keyflow/models/language.dart';
import 'package:keyflow/models/practice_mode.dart';
import 'package:keyflow/models/word_list.dart';
import 'package:keyflow/texts/text_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every language loads with a quote of every length', () async {
    for (final language in Language.values) {
      final library = await TextLibrary.load(language);
      expect(library.language, language);
      for (final length in QuoteLength.values) {
        final text = library.textFor(
          QuoteMode(length),
          WordList.common200,
          Random(1),
        );
        expect(text.source, isNotNull, reason: '$language $length');
      }
    }
  });
}
