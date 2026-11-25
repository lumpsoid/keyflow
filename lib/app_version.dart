/// The app's version and commit, passed in by the release build:
/// `--dart-define=APP_VERSION=0.1.0 --dart-define=GIT_COMMIT=2391c1d`.
const _version = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');
const _commit = String.fromEnvironment('GIT_COMMIT');

/// Shown in settings and asked for in bug reports, e.g. `0.1.0 (2391c1d)`.
String get appVersionLabel => versionLabel(_version, _commit);

String versionLabel(String version, String commit) =>
    commit.isEmpty ? version : '$version ($commit)';
