import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/practice_mode.dart';
import '../practice/practice_controller.dart';
import '../settings/settings_store.dart';
import '../typing/typing_session.dart';
import '../widgets/mode_picker.dart';
import '../widgets/typing_view.dart';
import 'history_page.dart';
import 'results_view.dart';
import 'settings_sheet.dart';

/// The main screen: pick a mode, type, see the result.
///
/// Keystrokes go to an invisible text field, so the phone's own keyboard and
/// a hardware keyboard both work; the field's text mirrors the session's.
class PracticePage extends StatefulWidget {
  const PracticePage({
    super.key,
    required this.controller,
    required this.settings,
  });

  final PracticeController controller;
  final SettingsStore settings;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  late TypingSession _session = widget.controller.session;

  PracticeController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // A new round (next, retry, mode change) starts with an empty field.
    if (!identical(_controller.session, _session)) {
      _session = _controller.session;
      _input.clear();
    }
    if (_controller.outcome != null && _focus.hasFocus) _focus.unfocus();
  }

  void _onChanged(String value) {
    final outcome = _controller.input(value);
    if (outcome == KeystrokeOutcome.wrong && widget.settings.value.haptics) {
      HapticFeedback.lightImpact();
    }
    final typed = _controller.session.typed;
    if (_input.text != typed) {
      _input.value = TextEditingValue(
        text: typed,
        selection: TextSelection.collapsed(offset: typed.length),
      );
    }
  }

  void _next() {
    _controller.next();
    _focus.requestFocus();
  }

  void _retry() {
    _controller.retry();
    _focus.requestFocus();
  }

  void _selectMode(PracticeMode mode) {
    _controller.selectMode(mode);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.tab): _next,
        const SingleActivator(LogicalKeyboardKey.escape): _retry,
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Off to the side and see-through: it only collects keys.
              Positioned(
                left: 0,
                top: 0,
                width: 1,
                height: 1,
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    key: const Key('typingInput'),
                    controller: _input,
                    focusNode: _focus,
                    autofocus: true,
                    onChanged: _onChanged,
                    autocorrect: false,
                    enableSuggestions: false,
                    enableIMEPersonalizedLearning: false,
                    enableInteractiveSelection: false,
                    showCursor: false,
                    textCapitalization: TextCapitalization.none,
                    // Stops Android keyboards from composing, autocorrecting
                    // and auto-capitalising, which would garble keystrokes.
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.none,
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: Listenable.merge([_controller, widget.settings]),
                builder: (context, _) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: switch (_controller.outcome) {
                    final outcome? => ResultsView(
                      key: ObjectKey(outcome),
                      outcome: outcome,
                      onNext: _next,
                      onRetry: _retry,
                    ),
                    null => _Practice(
                      key: const ValueKey('practice'),
                      controller: _controller,
                      settings: widget.settings,
                      focused: _focus.hasFocus,
                      onFocus: _focus.requestFocus,
                      onSelectMode: _selectMode,
                      onRestart: _next,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Practice extends StatelessWidget {
  const _Practice({
    super.key,
    required this.controller,
    required this.settings,
    required this.focused,
    required this.onFocus,
    required this.onSelectMode,
    required this.onRestart,
  });

  final PracticeController controller;
  final SettingsStore settings;
  final bool focused;
  final VoidCallback onFocus;
  final ValueChanged<PracticeMode> onSelectMode;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    // While typing, everything but the text fades away.
    final typing = session.isStarted;

    return Column(
      children: [
        _Chrome(
          visible: !typing,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'typing practice',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'progress',
                  icon: const Icon(Icons.insights),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HistoryPage(controller: controller),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'settings',
                  icon: const Icon(Icons.tune),
                  onPressed: () => showSettingsSheet(context, settings),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Chrome(
                          visible: !typing,
                          child: ModePicker(
                            mode: controller.mode,
                            onChanged: onSelectMode,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _LiveInfo(
                          controller: controller,
                          showWpm: settings.value.liveWpm,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onFocus,
                          behavior: HitTestBehavior.opaque,
                          child: _FocusVeil(
                            focused: focused,
                            child: TypingView(
                              words: session.words,
                              typed: session.typed,
                              blinkCaret: !typing,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          tooltip: 'new text (tab) · same again (esc)',
                          iconSize: 28,
                          icon: const Icon(Icons.refresh),
                          onPressed: onRestart,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades out (and stops taking taps) while the user types.
class _Chrome extends StatelessWidget {
  const _Chrome({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !visible,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: child,
    ),
  );
}

/// The time left or words done, and optionally the running wpm.
class _LiveInfo extends StatelessWidget {
  const _LiveInfo({required this.controller, required this.showWpm});

  final PracticeController controller;
  final bool showWpm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.session;
    final now = controller.now();
    final style = theme.textTheme.headlineSmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final progress = switch (session.remaining(now)) {
      final left? => '${(left.inMilliseconds / 1000).ceil()}',
      null =>
        '${session.currentWordIndex.clamp(0, session.words.length)}'
            '/${session.words.length}',
    };
    final wpm = session.stats(now).wpm;
    return AnimatedOpacity(
      opacity: session.isStarted ? 1 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Text(progress, style: style),
          const Spacer(),
          if (showWpm && session.isStarted)
            Text(
              '${wpm.toStringAsFixed(0)} wpm',
              style: style?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

/// Blurs the text with a hint while the keyboard isn't attached.
class _FocusVeil extends StatelessWidget {
  const _FocusVeil({required this.focused, required this.child});

  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: focused ? 1 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: focused ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(switch (defaultTargetPlatform) {
                  TargetPlatform.android ||
                  TargetPlatform.iOS => 'tap here to type',
                  _ => 'click here to type',
                }, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
