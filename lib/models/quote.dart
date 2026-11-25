class Quote {
  const Quote({required this.id, required this.text, required this.source});

  factory Quote.fromJson(Map<String, Object?> json) => Quote(
    id: json['id'] as int,
    text: json['text'] as String,
    source: json['source'] as String,
  );

  final int id;
  final String text;
  final String source;
}
