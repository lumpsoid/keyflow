# Practice texts

From [Monkeytype](https://github.com/monkeytypegame/monkeytype), under its
own license (copied to `LICENSE` here). Imported from master on 2026-11-25.

For each language `<lang>` (english, spanish, french, german, portuguese,
italian, russian, polish, dutch, turkish, indonesian):

| file | upstream |
|---|---|
| `<lang>_200.json` | `frontend/static/languages/<lang>.json` |
| `<lang>_1k.json` | `frontend/static/languages/<lang>_1k.json` (none for polish) |
| `quotes_<lang>.json` | `frontend/static/quotes/<lang>.json` |

`tool/import_monkeytype.py` generates them: typographic quotes, dashes and
ellipses become what a phone keyboard types; quotes over 600 characters or
with a character outside the language's keyboard are dropped, and so are
list entries of more than one word. Re-run it to refresh; don't edit these
files by hand.
