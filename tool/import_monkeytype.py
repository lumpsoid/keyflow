"""Converts Monkeytype's English word lists and quotes into the app's assets.

Usage: python3 -I tool/import_monkeytype.py <monkeytype checkout or download dir>

The directory must contain the three upstream files, either at their repo
paths (frontend/static/...) or flattened with '/' replaced by '_'.
Typographic characters are replaced with what a phone keyboard types, and
quotes longer than 600 characters are dropped (too long for a phone).
"""

import json
import sys
from pathlib import Path

SOURCES = {
    "english_200": "frontend/static/languages/english.json",
    "english_1k": "frontend/static/languages/english_1k.json",
    "quotes": "frontend/static/quotes/english.json",
}
MAX_QUOTE_LENGTH = 600
REPLACEMENTS = {
    "’": "'", "‘": "'", "“": '"', "”": '"',
    "—": "-", "–": "-", "…": "...", "\n": " ",
}
OUT = Path(__file__).resolve().parent.parent / "assets" / "texts"


def find(root: Path, rel: str) -> Path:
    for candidate in (root / rel, root / rel.replace("/", "_")):
        if candidate.is_file():
            return candidate
    sys.exit(f"missing {rel} under {root}")


def normalize(text: str) -> str:
    for old, new in REPLACEMENTS.items():
        text = text.replace(old, new)
    return " ".join(text.split())


def main() -> None:
    root = Path(sys.argv[1])
    for name in ("english_200", "english_1k"):
        words = json.loads(find(root, SOURCES[name]).read_text())["words"]
        out = OUT / f"{name}.json"
        out.write_text(json.dumps(words, ensure_ascii=False))
        print(f"{out.name}: {len(words)} words")

    quotes = []
    for q in json.loads(find(root, SOURCES["quotes"]).read_text())["quotes"]:
        text = normalize(q["text"])
        if len(text) <= MAX_QUOTE_LENGTH and text.isascii():
            quotes.append({"id": q["id"], "text": text, "source": normalize(q["source"])})
    out = OUT / "quotes_english.json"
    out.write_text(json.dumps(quotes, ensure_ascii=False, separators=(",", ":")))
    print(f"{out.name}: {len(quotes)} quotes")


if __name__ == "__main__":
    main()
