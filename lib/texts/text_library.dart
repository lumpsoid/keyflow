import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/language.dart';
import '../models/practice_mode.dart';
import '../models/practice_text.dart';
import '../models/quote.dart';
import '../models/word_list.dart';

/// One language's bundled practice texts (Monkeytype's lists), and how a
/// round's text is picked from them.
class TextLibrary {
  TextLibrary({
    this.language = Language.english,
    required this.common200,
    this.common1k,
    required List<Quote> quotes,
  }) : assert(common200.isNotEmpty && (common1k?.isNotEmpty ?? true)),
       assert(
         (common1k != null) == language.wordLists.contains(WordList.common1k),
       ),
       _quotesByLength = [
         for (final length in QuoteLength.values)
           quotes.where((q) => length.fits(q.text)).toList(),
       ];

  /// Words generated per second of a timed round; enough for 300 wpm.
  static const timedWordsPerSecond = 5;

  final Language language;
  final List<String> common200;

  /// Null for a language without a 1k list.
  final List<String>? common1k;

  /// Indexed by [QuoteLength.index].
  final List<List<Quote>> _quotesByLength;

  static Future<TextLibrary> load(
    Language language, [
    AssetBundle? bundle,
  ]) async {
    final assets = bundle ?? rootBundle;
    Future<List<String>> words(WordList list) async => (jsonDecode(
      await assets.loadString(
        'assets/texts/${language.name}_${list.fileSuffix}.json',
      ),
    ) as List).cast<String>();
    final quotesJson = await assets.loadString(
      'assets/texts/quotes_${language.name}.json',
    );
    return TextLibrary(
      language: language,
      common200: await words(WordList.common200),
      common1k: language.wordLists.contains(WordList.common1k)
          ? await words(WordList.common1k)
          : null,
      quotes: await compute(_parseQuotes, quotesJson),
    );
  }

  PracticeText textFor(PracticeMode mode, WordList list, Random random) =>
      switch (mode) {
        TimeMode(:final seconds) => PracticeText(
          _randomWords(list, seconds * timedWordsPerSecond, random),
        ),
        WordsMode(:final count) => PracticeText(
          _randomWords(list, count, random),
        ),
        QuoteMode(:final length) => _randomQuote(length, random),
      };

  List<String> _randomWords(WordList list, int count, Random random) {
    final pool = switch (language.listFor(list)) {
      WordList.common200 => common200,
      WordList.common1k => common1k!,
    };
    final picked = <String>[];
    while (picked.length < count) {
      final word = pool[random.nextInt(pool.length)];
      // Never the same word twice in a row; it reads like a stutter.
      if (pool.length > 1 && picked.isNotEmpty && picked.last == word) continue;
      picked.add(word);
    }
    return picked;
  }

  PracticeText _randomQuote(QuoteLength length, Random random) {
    final pool = _quotesByLength[length.index];
    final quote = pool[random.nextInt(pool.length)];
    return PracticeText(quote.text.split(' '), source: quote.source);
  }
}

List<Quote> _parseQuotes(String json) => [
  for (final q in jsonDecode(json) as List)
    Quote.fromJson((q as Map).cast<String, Object?>()),
];
