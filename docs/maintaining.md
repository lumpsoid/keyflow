# Maintaining

What to do, and in what order, for the recurring jobs. The scripts live in
[`scripts/`](../scripts).

| Script | Does |
|---|---|
| `scripts/check.sh` | Every gate in CI's order: `dart format` check, `flutter analyze`, `flutter test`, version format |
| `scripts/version.sh show\|check\|bump X.Y.Z` | Print, check or bump the version in `pubspec.yaml` |
| `scripts/release.sh` | Check the tree is releasable, run the gates, tag `vX.Y.Z` |
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
lose their history. Keep the keystore and its passwords in a password
manager, with a backup.

Create it once (or reuse a key you already sign your other apps with):

```shell
keytool -genkeypair -v -keystore typing-practice-release.jks \
  -alias typing-practice -keyalg RSA -keysize 4096 -validity 36500
chmod 600 typing-practice-release.jks
```

For local release builds, put the keystore at `android/release.jks` and
write `android/key.properties` (both gitignored):

```properties
storeFile=release.jks
storePassword=…
keyAlias=typing-practice
keyPassword=…
```

Without `key.properties`, release builds fall back to the debug key, which
is fine for `flutter run --release` but must never be published; the
Release workflow fails instead.

For CI, add the repository secrets. `gh secret set` prompts for the value,
so passwords stay out of shell history:

```shell
base64 -w0 typing-practice-release.jks | gh secret set ANDROID_KEYSTORE_BASE64 -R lumpsoid/typing_practice
gh secret set ANDROID_KEYSTORE_PASSWORD -R lumpsoid/typing_practice
gh secret set ANDROID_KEY_ALIAS -R lumpsoid/typing_practice
gh secret set ANDROID_KEY_PASSWORD -R lumpsoid/typing_practice
```

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
