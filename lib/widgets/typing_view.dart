import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The words to type, coloured by what has been typed, with a gliding caret.
/// Shows three lines and scrolls so the caret stays on the second one.
class TypingView extends StatefulWidget {
  const TypingView({
    super.key,
    required this.words,
    required this.typed,
    required this.blinkCaret,
  });

  static const visibleLines = 3;

  final List<String> words;

  /// Everything typed so far, words separated by single spaces.
  final String typed;

  /// Blink while waiting for the first keystroke.
  final bool blinkCaret;

  @override
  State<TypingView> createState() => _TypingViewState();
}

class _TypingViewState extends State<TypingView> {
  TextPainter? _painter;

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TypingColors.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth < 480 ? 22.0 : 28.0;
        final style = TextStyle(
          fontFamily: 'JetBrains Mono',
          // No coding ligatures: every typed character stays its own glyph.
          fontFeatures: const [FontFeature.disable('calt')],
          fontSize: fontSize,
          height: 1.6,
          color: colors.pending,
        );
        final (span, caretIndex) = typingSpan(
          widget.words,
          widget.typed.split(' '),
          style,
          colors,
        );
        _painter?.dispose();
        final painter = _painter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
          strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
        )..layout(maxWidth: constraints.maxWidth);

        final lineHeight = painter.preferredLineHeight;
        final caretPosition = TextPosition(offset: caretIndex);
        final caret = painter.getOffsetForCaret(caretPosition, Rect.zero);
        final caretHeight = painter.getFullHeightForCaret(
          caretPosition,
          Rect.zero,
        );
        final line = ((caret.dy + caretHeight / 2) / lineHeight).floor();
        final scroll = max(0, line - 1) * lineHeight;
        final glyphHeight = textScaler.scale(fontSize) * 1.15;

        return SizedBox(
          height: lineHeight * TypingView.visibleLines,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              maxHeight: double.infinity,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: scroll),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, y, child) =>
                    Transform.translate(offset: Offset(0, -y), child: child),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: painter.height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _TextPainting(painter)),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 90),
                        curve: Curves.easeOut,
                        left: caret.dx - 1,
                        top: line * lineHeight + (lineHeight - glyphHeight) / 2,
                        child: _Caret(
                          height: glyphHeight,
                          color: colors.caret,
                          blink: widget.blinkCaret,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Builds the styled text for [words] given what was typed for each, and
/// the caret's character offset in it. Characters typed past the end of a
/// word are shown inline, so the text grows as the user overshoots.
@visibleForTesting
(TextSpan, int) typingSpan(
  List<String> words,
  List<String> typedWords,
  TextStyle base,
  TypingColors colors,
) {
  final spans = <TextSpan>[];
  final run = StringBuffer();
  Color? runColor;
  var runUnderlined = false;
  var length = 0;
  var caret = 0;

  void flush() {
    if (run.isEmpty) return;
    spans.add(
      TextSpan(
        text: run.toString(),
        style: base.copyWith(
          color: runColor,
          decoration: runUnderlined ? TextDecoration.underline : null,
          decorationColor: colors.incorrect,
          decorationThickness: 2,
        ),
      ),
    );
    run.clear();
  }

  void add(String text, Color color, {bool underlined = false}) {
    if (color != runColor || underlined != runUnderlined) flush();
    runColor = color;
    runUnderlined = underlined;
    run.write(text);
    length += text.length;
  }

  final current = typedWords.length - 1;
  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    final typed = i < typedWords.length ? typedWords[i] : '';
    // A word left behind with mistakes stays underlined.
    final wrong = i < current && typed != word;
    final wordStart = length;
    for (var j = 0; j < max(word.length, typed.length); j++) {
      if (j >= typed.length) {
        add(word[j], colors.pending, underlined: wrong);
      } else if (j >= word.length) {
        add(typed[j], colors.extra, underlined: wrong);
      } else {
        final hit = typed[j] == word[j];
        add(
          word[j],
          hit ? colors.correct : colors.incorrect,
          underlined: wrong,
        );
      }
    }
    if (i == current) caret = wordStart + typed.length;
    if (i < words.length - 1) add(' ', colors.pending);
  }
  flush();
  return (TextSpan(children: spans), caret);
}

class _TextPainting extends CustomPainter {
  _TextPainting(this.painter);

  final TextPainter painter;

  @override
  void paint(Canvas canvas, Size size) => painter.paint(canvas, Offset.zero);

  @override
  bool shouldRepaint(_TextPainting old) => old.painter != painter;
}

class _Caret extends StatefulWidget {
  const _Caret({
    required this.height,
    required this.color,
    required this.blink,
  });

  final double height;
  final Color color;
  final bool blink;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 530),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Caret old) {
    super.didUpdateWidget(old);
    if (old.blink != widget.blink) _sync();
  }

  void _sync() {
    if (widget.blink) {
      _blink.repeat(reverse: true);
    } else {
      _blink.value = 0;
      _blink.stop();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: ReverseAnimation(
      CurvedAnimation(parent: _blink, curve: Curves.easeInOut),
    ),
    child: Container(
      width: 2.5,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
