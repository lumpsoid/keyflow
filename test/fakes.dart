import 'package:keyflow/models/language.dart';
import 'package:keyflow/models/quote.dart';
import 'package:keyflow/texts/text_library.dart';

/// A tiny library so tests know every word that can come up.
TextLibrary fakeLibrary() => TextLibrary(
  common200: const ['go'],
  common1k: const ['run'],
  quotes: const [Quote(id: 1, text: 'to be or not', source: 'Hamlet')],
);

/// Like [fakeLibrary], for any language; Polish has no 1k list.
TextLibrary fakeLibraryIn(Language language) => language == Language.english
    ? fakeLibrary()
    : TextLibrary(
        language: language,
        common200: ['${language.name}200'],
        common1k: language == Language.polish ? null : ['${language.name}1k'],
        quotes: [Quote(id: 1, text: '${language.name} quote', source: 'x')],
      );
