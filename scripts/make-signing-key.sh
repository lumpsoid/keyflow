#!/usr/bin/env bash
# Create the Android release key with a generated password that nobody has
# to see or type, and keep everything CI needs in .env (gitignored):
#   ANDROID_KEYSTORE_BASE64   the keystore itself, so .env is a full backup
#   ANDROID_KEYSTORE_PASSWORD
#   ANDROID_KEY_ALIAS
#   ANDROID_KEY_PASSWORD
# The keystore also goes to android/release.jks (gitignored).
#
#   scripts/make-signing-key.sh            create the key and .env
#   scripts/make-signing-key.sh --upload   then set the repo's GitHub secrets
#                                          from .env (gh secret set -f)
#
# Nothing secret is printed. Back up .env in a password manager: a lost
# key means installed apps can never be updated.
set -euo pipefail
cd "$(dirname "$0")/.."
umask 077

fail() { echo "make-signing-key: $*" >&2; exit 1; }

keystore=android/release.jks
alias=release

[[ -e .env || -e $keystore ]] && fail ".env or $keystore exists; refusing to overwrite a key"
git check-ignore -q .env || fail ".env is not gitignored"
git check-ignore -q "$keystore" || fail "$keystore is not gitignored"

# Generated locally from the system's CSPRNG. PKCS12 keystores use one
# password for both the store and the key.
password=$(openssl rand -base64 64 | tr -dc 'A-Za-z0-9' | head -c 40)
[[ ${#password} -eq 40 ]] || fail "password generation failed"

KEYTOOL_PASSWORD=$password keytool -genkeypair -noprompt \
  -keystore "$keystore" -storetype PKCS12 \
  -alias "$alias" -keyalg RSA -keysize 4096 -validity 36500 \
  -dname "CN=lumpsoid" \
  -storepass:env KEYTOOL_PASSWORD -keypass:env KEYTOOL_PASSWORD >/dev/null

{
  printf 'ANDROID_KEYSTORE_BASE64=%s\n' "$(base64 -w0 "$keystore")"
  printf 'ANDROID_KEYSTORE_PASSWORD=%s\n' "$password"
  printf 'ANDROID_KEY_ALIAS=%s\n' "$alias"
  printf 'ANDROID_KEY_PASSWORD=%s\n' "$password"
} > .env
unset password

echo "Created $keystore and .env (mode 600). The certificate:"
# Reads the password from .env without printing it.
KEYTOOL_PASSWORD=$(sed -n 's/^ANDROID_KEYSTORE_PASSWORD=//p' .env) \
  keytool -list -v -keystore "$keystore" -storepass:env KEYTOOL_PASSWORD \
  | grep -E '^(Alias name|Owner|Valid|[[:space:]]*SHA256):'

if [[ ${1:-} == --upload ]]; then
  gh secret set -f .env
  echo "GitHub secrets set from .env."
fi
echo "Back up .env in your password manager."
