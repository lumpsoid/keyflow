# Practice texts

From [Monkeytype](https://github.com/monkeytypegame/monkeytype), under its
own license (copied to `LICENSE` here). Imported from master on 2026-11-25; the quotes
file was last changed upstream in commit `20b9530d`.

| file | upstream |
|---|---|
| `english_200.json` | `frontend/static/languages/english.json` |
| `english_1k.json` | `frontend/static/languages/english_1k.json` |
| `quotes_english.json` | `frontend/static/quotes/english.json` |

`tool/import_monkeytype.py` generates them: typographic quotes, dashes and
ellipses become what a phone keyboard types, and quotes over 600 characters
are dropped. Re-run it to refresh; don't edit these files by hand.
