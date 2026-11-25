# Changelog

All notable changes to this project are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Practise in Spanish, French, German, Portuguese, Italian, Russian,
  Polish, Dutch, Turkish and Indonesian, with words and quotes in each;
  pick the language in settings.

### Changed

- Personal bests are kept per language; earlier results count as English.

## [0.1.1] - 2026-11-25

### Fixed

- The Linux builds start on Debian 12, Raspberry Pi OS and Ubuntu 22.04;
  0.1.0's needed GLib 2.80 and stopped with "undefined symbol".

## [0.1.0] - 2026-11-25

### Added

- Three practice modes: time (15, 30, 60 seconds), words (10, 25, 50) and
  quotes (short, medium, long).
- Word-by-word input: a space moves on to the next word, so a slip costs
  one word. Extra and missed letters are shown; words left with mistakes
  stay underlined.
- A three-line text view that follows the caret, in JetBrains Mono, with
  everything else fading out while you type.
- Results: wpm, accuracy, raw wpm, character counts, a speed-over-time
  chart, and confetti for a new personal best.
- Progress: day streak, average of the last 10 rounds, personal bests per
  mode, recent rounds.
- Settings: light, dark or auto theme; 200 or 1k common words; live wpm;
  vibration on mistakes.
- Tab for a new text and Esc to retry it, on a hardware keyboard.
- Words and quotes from Monkeytype.
