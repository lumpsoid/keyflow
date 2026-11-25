import 'package:flutter/material.dart';

/// Colours of the typing text, beyond what [ColorScheme] names.
@immutable
class TypingColors extends ThemeExtension<TypingColors> {
  const TypingColors({
    required this.pending,
    required this.correct,
    required this.incorrect,
    required this.extra,
    required this.caret,
  });

  /// Not typed yet.
  final Color pending;
  final Color correct;
  final Color incorrect;

  /// Typed past the end of a word.
  final Color extra;
  final Color caret;

  static TypingColors of(BuildContext context) =>
      Theme.of(context).extension<TypingColors>() ?? _dark;

  @override
  TypingColors copyWith({
    Color? pending,
    Color? correct,
    Color? incorrect,
    Color? extra,
    Color? caret,
  }) => TypingColors(
    pending: pending ?? this.pending,
    correct: correct ?? this.correct,
    incorrect: incorrect ?? this.incorrect,
    extra: extra ?? this.extra,
    caret: caret ?? this.caret,
  );

  @override
  TypingColors lerp(TypingColors? other, double t) {
    if (other == null) return this;
    return TypingColors(
      pending: Color.lerp(pending, other.pending, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      incorrect: Color.lerp(incorrect, other.incorrect, t)!,
      extra: Color.lerp(extra, other.extra, t)!,
      caret: Color.lerp(caret, other.caret, t)!,
    );
  }
}

const _dark = TypingColors(
  pending: Color(0xFF646669),
  correct: Color(0xFFD1D0C5),
  incorrect: Color(0xFFCA4754),
  extra: Color(0xFF7E2A33),
  caret: Color(0xFFE2B714),
);

const _light = TypingColors(
  pending: Color(0xFFADA79C),
  correct: Color(0xFF33302B),
  incorrect: Color(0xFFD7263D),
  extra: Color(0xFF8F1D2C),
  caret: Color(0xFFE07A1F),
);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final typing = dark ? _dark : _light;
  final background = dark ? const Color(0xFF323437) : const Color(0xFFF4EFE6);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: typing.caret,
        brightness: brightness,
      ).copyWith(
        primary: typing.caret,
        onPrimary: background,
        surface: background,
        onSurface: typing.correct,
        onSurfaceVariant: typing.pending,
        error: typing.incorrect,
        surfaceContainerLow: dark
            ? const Color(0xFF2C2E31)
            : const Color(0xFFECE5D8),
        surfaceContainer: dark
            ? const Color(0xFF2A2C2F)
            : const Color(0xFFE6DECF),
        surfaceContainerHigh: dark
            ? const Color(0xFF393B3F)
            : const Color(0xFFE0D7C6),
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    extensions: [typing],
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: typing.correct,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
