# Contributing

Thanks for wanting to help with Keyflow. It is a small personal
project, so there is no formal process, only a request to make things go
smoothly for both of us.

## Start with an issue

If you have an idea or want to change something, please **open an issue
first** ([Proposal](https://github.com/lumpsoid/keyflow/issues/new?template=proposal.yml))
and describe the problem and what you have in mind. We can talk it through
there: whether it fits the app, and how it could be built. Once we agree on
the shape, open a pull request that links the issue.

This is a wish, not a rule: nothing stops you from opening a pull request
straight away. Talking first just saves you from building something that
then needs a different approach. Small, obvious fixes (a typo, a broken
link, a clear bug with a one-line fix) can go straight to a pull request.

Bugs are welcome as issues too
([Bug report](https://github.com/lumpsoid/keyflow/issues/new?template=bug_report.yml));
the version at the bottom of Settings and your on-screen keyboard help.

## Setting up

You need [Flutter](https://docs.flutter.dev/get-started/install) at the
version pinned in `pubspec.yaml` (`environment: flutter:`), with the
toolchain for your target. `flutter doctor` checks it.

```shell
git clone https://github.com/lumpsoid/keyflow.git && cd keyflow
flutter pub get
scripts/check.sh  # every gate
flutter run
```

## Where a change goes

- **A typing rule** (what counts as correct, wpm, accuracy, when a round
  ends) → `TypingSession` in [`lib/typing`](lib/typing), tested with plain
  values in `test/typing_session_test.dart`. Nowhere else decides these.
- **Streaks, personal bests, averages** → `History` in
  [`lib/history`](lib/history).
- **Round order** (pick text, tick, finish, record) →
  `PracticeController` in [`lib/practice`](lib/practice).
- **Practice texts** → regenerate with `tool/import_monkeytype.py`; don't
  edit `assets/texts/` by hand.
- **Display** → [`lib/pages`](lib/pages) and [`lib/widgets`](lib/widgets).
  Widgets render the session; they don't re-derive its numbers.

[CLAUDE.md](CLAUDE.md) lists the rules, and
[CODE-PRINCIPLES.md](CODE-PRINCIPLES.md) the code style.

## Before you open a pull request

- `scripts/check.sh` passes: `dart format`, `flutter analyze`,
  `flutter test`. CI runs the same.
- New behaviour has tests: rules as unit tests, pages as widget tests.
- Anything a user would notice has a line in [CHANGELOG.md](CHANGELOG.md)
  under Unreleased.
- Commit messages follow
  [Conventional Commits](https://www.conventionalcommits.org/):
  `feat(typing): count a skipped word's letters as missed`.

Contributions are accepted under the project's [MIT license](LICENSE).
