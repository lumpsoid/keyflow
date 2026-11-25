# Maintaining

What to do, and in what order, for the recurring jobs. The scripts live in
[`scripts/`](../scripts).

| Script | Does |
|---|---|
| `scripts/check.sh` | Every gate in CI's order: `dart format` check, `flutter analyze`, `flutter test`, version format |
| `scripts/version.sh show\|check\|bump X.Y.Z` | Print, check or bump the version in `pubspec.yaml` |
| `scripts/release.sh` | Check the tree is releasable, run the gates, tag `vX.Y.Z` |
| `scripts/make-signing-key.sh [--upload]` | Create the Android release key with a generated password into `.env` (and the GitHub secrets) |
| `tool/import_monkeytype.py` | Regenerate `assets/texts/` from a Monkeytype checkout |

## Fresh checkout

```shell
flutter pub get
scripts/check.sh
```

## Everyday

1. Branch off `trunk` (`feat/…`, `fix/…`).
2. Change, then run `scripts/check.sh`.
3. Add a line under `## [Unreleased]` in [CHANGELOG.md](../CHANGELOG.md)
   for anything a user would notice.
4. Merge into `trunk`. CI runs the gates and a debug Android build on
   every push and pull request.

## Version

`pubspec.yaml` `version: X.Y.Z+N` is the only place the version lives.
`X.Y.Z` is Android's `versionName` and is shown at the bottom of Settings
with the commit, `0.1.0 (2391c1d)`; release builds pass both in with
`--dart-define` (`lib/app_version.dart`), and local builds show `dev`.
`N` is Android's `versionCode`: it must grow with every release, or Android
refuses the update.

`scripts/version.sh bump X.Y.Z` sets it, raises `N` by one and dates the
changelog's Unreleased section. Before 1.0.0: a minor bump (0.2.0) for new
features or changed behaviour, a patch bump (0.1.1) for fixes.

## Release

1. On `trunk`, clean tree:
   ```shell
   scripts/version.sh bump 0.2.0
   ```
2. Review `CHANGELOG.md`: the new `## [0.2.0] - date` section is the
   release notes. Commit:
   ```shell
   git commit -am "chore(release): 0.2.0"
   ```
3. Tag (it re-runs every gate first):
   ```shell
   scripts/release.sh
   ```
4. Push the commit and the tag:
   ```shell
   git push origin trunk v0.2.0
   ```
5. The [Release workflow](../.github/workflows/release.yml) re-runs the
   gates, builds signed APKs (one per ABI) and Linux bundles (x64, arm64),
   and publishes a GitHub Release with `SHA256SUMS` and the changelog
   section as its notes. Check it on the repository's Releases page.

If a release goes wrong, delete the tag (`git push origin :v0.2.0`,
`git tag -d v0.2.0`) and its GitHub Release, fix, and tag again. Never
reuse a build number that reached a device.

iOS is not released: distributing it needs an Apple developer account and
signing. The project builds for iOS from source on a Mac.

## Android signing key

A release is signed with one key for the app's lifetime. **If the key is
lost, installed apps cannot be updated**; users would have to uninstall and
lose their history.

The key already exists. `scripts/make-signing-key.sh` created it with a
generated password that nobody had to see or type:

- `android/release.jks`: the keystore (gitignored).
- `.env` (gitignored, mode 600): `ANDROID_KEYSTORE_BASE64` (the keystore
  itself), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`. It is a complete backup on its own: **keep a
  copy in a password manager.**
- The repository's Actions secrets, set from `.env` with
  `gh secret set -f .env`.

The certificate is `CN=lumpsoid`, SHA-256
`88:2D:20:DB:61:90:05:63:FA:B4:B4:0A:59:6F:45:55:37:0F:23:14:AD:63:B0:2C:75:6E:5E:00:56:B4:79:C4`.

To restore the secrets on a new repository: `gh secret set -f .env`. To
restore the keystore file from a backed-up `.env`, decode
`ANDROID_KEYSTORE_BASE64` with `base64 --decode` into
`android/release.jks`. The script refuses to run while either file exists,
so it never replaces a key that is in use.

Release builds without `android/key.properties` fall back to the debug key,
which is fine for `flutter run --release` but must never be published; the
Release workflow fails instead when the secrets are missing.

## Dependencies

Dependabot opens weekly pull requests for pub, Gradle and GitHub Actions,
minor and patch bumps grouped per ecosystem. Merge them when CI is green;
read the changelog of a major bump first.

- **Flutter** is pinned in `pubspec.yaml` (`environment: flutter:`); every
  workflow reads it from there. After `flutter upgrade` locally, set it to
  the new `flutter --version`, run the gates, and let CI's Android build
  confirm.
- **Gradle, AGP, Kotlin** (`android/settings.gradle.kts`,
  `android/gradle/wrapper/gradle-wrapper.properties`): CI's debug Android
  build catches breakage.

## GitHub repository settings

Once, on GitHub:

- Description and topics (`flutter`, `typing`, `typing-practice`,
  `android`, `linux`).
- Settings → General → Features: Issues on.
- Settings → Code security: Dependabot alerts and security updates on.
- Settings → Branches: optionally protect `trunk` and require the CI
  checks.
