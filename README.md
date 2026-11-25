# Keyflow

[![CI](https://github.com/lumpsoid/keyflow/actions/workflows/ci.yml/badge.svg)](https://github.com/lumpsoid/keyflow/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A calm, focused typing trainer for phones first, desktop next. Pick a mode,
start typing, and everything but the text fades away.

- **Modes:** time (15 / 30 / 60 s), words (10 / 25 / 50), quotes (short /
  medium / long).
- **Forgiving input:** a space moves on to the next word, so one slip costs
  one word, not the rest of the line. Extra and missed letters are shown.
- **Results:** wpm, accuracy, raw wpm, a speed-over-time chart, and confetti
  when you beat your personal best.
- **Progress:** day streak, averages, personal bests per mode, recent rounds.
- **Settings:** light / dark / auto theme, 200 or 1k common words, live wpm,
  vibration on mistakes.
- **Keyboard:** Tab for a new text, Esc to retry the same one.

It works offline and asks for no permissions. History and settings stay on
the device.

## Install

Download from the [latest release](https://github.com/lumpsoid/keyflow/releases/latest):

| Platform | File |
|---|---|
| Android, most phones | `…-android-arm64-v8a.apk` |
| Android, older 32-bit phones | `…-android-armeabi-v7a.apk` |
| Android, x86_64 emulators | `…-android-x86_64.apk` |
| Linux, x64 | `…-linux-x64.tar.gz` |
| Linux, arm64 (e.g. Raspberry Pi) | `…-linux-arm64.tar.gz` |

Check a download against `SHA256SUMS` with `sha256sum -c --ignore-missing SHA256SUMS`.
On Linux, unpack the archive and run `keyflow` inside it (it needs
GTK 3).

iOS builds aren't published; build it from source on a Mac.

## Build from source

With [Flutter](https://docs.flutter.dev/get-started/install) at the version
pinned in `pubspec.yaml`:

```sh
git clone https://github.com/lumpsoid/keyflow.git && cd keyflow
flutter pub get
scripts/check.sh   # format, analyze, tests
flutter run        # an Android / iOS device, or Linux
```

## How it fits together

- `lib/typing/`: the engine. `TypingSession` turns keystrokes into the
  typed text and the round's numbers; time is passed in, so it is tested
  with plain values.
- `lib/practice/`: `PracticeController` runs a round: picks the text,
  feeds input, keeps the clock, records the result.
- `lib/history/`, `lib/texts/`: results and their streak and bests; the
  bundled texts.
- `lib/pages/`, `lib/widgets/`: the screens. Keystrokes arrive through one
  hidden text field, so phone keyboards and hardware keyboards both work.

## Contributing

Ideas and bug reports are welcome as
[issues](https://github.com/lumpsoid/keyflow/issues). See
[CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

[MIT](LICENSE), except for the bundled assets, which keep their own
licenses:

- Words and quotes come from [Monkeytype](https://github.com/monkeytypegame/monkeytype)
  and are under its own license; see [assets/texts/README.md](assets/texts/README.md).
- The typing font is [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono),
  under the SIL Open Font License (`assets/fonts/OFL.txt`).
