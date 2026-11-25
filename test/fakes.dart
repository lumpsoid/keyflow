import 'package:keyflow/models/quote.dart';
import 'package:keyflow/texts/text_library.dart';

/// A tiny library so tests know every word that can come up.
TextLibrary fakeLibrary() => TextLibrary(
  common200: const ['go'],
  common1k: const ['run'],
  quotes: const [Quote(id: 1, text: 'to be or not', source: 'Hamlet')],
);
