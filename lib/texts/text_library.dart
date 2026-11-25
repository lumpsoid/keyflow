import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/practice_mode.dart';
import '../models/practice_text.dart';
import '../models/quote.dart';
import '../models/word_list.dart';

/// The bundled practice texts (Monkeytype's English lists), and how a round's
/// text is picked from them.
class TextLibrary {
  TextLibrary({
    required this.common200,
    required this.common1k,
    required List<Quote> quotes,
  }) : assert(common200.isNotEmpty && common1k.isNotEmpty),
       _quotesByLength = [
         for (final length in QuoteLength.values)
           quotes.where((q) => length.fits(q.text)).toList(),
       ];

  /// Words generated per second of a timed round; enough for 300 wpm.
  static const timedWordsPerSecond = 5;

  final List<String> common200;
  final List<String> common1k;

  /// Indexed by [QuoteLength.index].
  final List<List<Quote>> _quotesByLength;

  static Future<TextLibrary> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    Future<List<String>> words(String name) async =>
        (jsonDecode(await assets.loadString('assets/texts/$name.json')) as List)
            .cast<String>();
    final quotesJson = await assets.loadString(
      'assets/texts/quotes_english.json',
    );
    return TextLibrary(
      common200: await words('english_200'),
      common1k: await words('english_1k'),
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
    final pool = switch (list) {
      WordList.common200 => common200,
      WordList.common1k => common1k,
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
