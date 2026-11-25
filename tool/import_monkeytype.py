"""Converts Monkeytype's word lists and quotes into the app's assets.

Usage: python3 -I tool/import_monkeytype.py <monkeytype checkout or download dir>

The directory must contain each language's upstream files (languages/<name>.json,
languages/<name>_1k.json where it exists, quotes/<name>.json), either at their
repo paths (frontend/static/...) or flattened with '/' replaced by '_'.
Typographic characters are replaced with what a phone keyboard types. Quotes
longer than 600 characters, or with a character outside the language's
keyboard, are dropped; so are list entries that aren't one word.

The language names must match the app's `Language` enum.
"""

import json
import re
import string
import sys
from pathlib import Path

# Letters each language types beyond ASCII, lowercase; and whether it has a
# 1k list upstream.
LANGUAGES = {
    "english": ("", True),
    "spanish": ("áéíóúüñ¡¿", True),
    "french": ("àâæçéèêëîïôœùûüÿ", True),
    "german": ("äöüß", True),
    "portuguese": ("áâãàçéêíóôõú", True),
    "italian": ("àèéìíîòóùú", True),
    "russian": ("абвгдеёжзийклмнопрстуфхцчшщъыьэюя", True),
    "polish": ("ąćęłńóśźż", False),
    "dutch": ("áéëïóöü", True),
    "turkish": ("âçğıöşü", True),
    "indonesian": ("", True),
}
ASCII = set(string.printable) - set("\t\n\r\x0b\x0c")
MAX_QUOTE_LENGTH = 600
REPLACEMENTS = {
    "’": "'", "‘": "'", "“": '"', "”": '"', "„": '"',
    "—": "-", "–": "-", "…": "...", "\n": " ",
}
# French and Russian quotation marks, with the spaces French sets inside them.
GUILLEMETS = [(re.compile(r"«\s*"), '"'), (re.compile(r"\s*»"), '"')]
OUT = Path(__file__).resolve().parent.parent / "assets" / "texts"


def find(root: Path, rel: str) -> Path:
    rel = f"frontend/static/{rel}"
    for candidate in (root / rel, root / rel.replace("/", "_")):
        if candidate.is_file():
            return candidate
    sys.exit(f"missing {rel} under {root}")


def normalize(text: str) -> str:
    for old, new in REPLACEMENTS.items():
        text = text.replace(old, new)
    for pattern, new in GUILLEMETS:
        text = pattern.sub(new, text)
    return " ".join(text.split())


def typeable(text: str, letters: str) -> bool:
    return all(c in ASCII or c.lower() in letters for c in text)


def words(path: Path, letters: str) -> list[str]:
    kept = []
    for word in json.loads(path.read_text())["words"]:
        if word not in kept and " " not in word and typeable(word, letters):
            kept.append(word)
    return kept


def main() -> None:
    root = Path(sys.argv[1])
    for language, (letters, has_1k) in LANGUAGES.items():
        lists = {"200": f"languages/{language}.json"}
        if has_1k:
            lists["1k"] = f"languages/{language}_1k.json"
        for size, rel in lists.items():
            kept = words(find(root, rel), letters)
            out = OUT / f"{language}_{size}.json"
            out.write_text(json.dumps(kept, ensure_ascii=False))
            print(f"{out.name}: {len(kept)} words")

        quotes = []
        for q in json.loads(find(root, f"quotes/{language}.json").read_text())[
            "quotes"
        ]:
            text = normalize(q["text"])
            if len(text) <= MAX_QUOTE_LENGTH and typeable(text, letters):
                source = normalize(q["source"])
                quotes.append({"id": q["id"], "text": text, "source": source})
        out = OUT / f"quotes_{language}.json"
        out.write_text(json.dumps(quotes, ensure_ascii=False, separators=(",", ":")))
        print(f"{out.name}: {len(quotes)} quotes")


if __name__ == "__main__":
    main()
