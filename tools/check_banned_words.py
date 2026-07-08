"""
blog/ guide/ 配下のポータル中立性チェック（GitHub Actions 用スタンドアロン版）

背景: 通常の中立性チェックの正本は ~/projects/MyPython/check_neutrality.py だが、
CI ランナーは本 repo のみを checkout するため MyPython 側を参照できない。
本スクリプトは check_neutrality.py の以下2点を本 repo 内に限定移植したもの:

  1. BANNED_WORDS のうち本 CI が検査してきた3語（横浜ホームクリニック / yokohama-home.clinic / 大澤基）
  2. reviewedBy(Person) JSON-LD 構造ブロックに限定した「大澤基」allowlist
     （E-E-A-T 実名監修化・2026-06-29 院長確定 / A1 バイパス対策・敵対レビュー 2026-07-03）

allowlist の正本は check_neutrality.py の REVIEWEDBY_PERSON_BLOCK_RE / _compute_allowlisted_spans。
そちら側でロジックが変わったら本スクリプトも追従させること（乖離すると本 CI と
MyPython 側 pre-commit hook の判定が再びずれる＝2026-07-08 romubase 姉妹事故と同型）。
"""
import re
import sys
from pathlib import Path

BANNED_WORDS = [
    "横浜ホームクリニック",
    "yokohama-home.clinic",
    "大澤基",
]

# check_neutrality.py の REVIEWEDBY_PERSON_BLOCK_RE と同一パターン（構造限定・厳密一致）
REVIEWEDBY_PERSON_BLOCK_RE = re.compile(
    r'"reviewedBy"\s*:\s*\{\s*'
    r'"@type"\s*:\s*"Person"\s*,\s*'
    r'"name"\s*:\s*"大澤基"\s*,\s*'
    r'"jobTitle"\s*:\s*"[^"]*"\s*,\s*'
    r'"url"\s*:\s*"[^"]*"\s*'
    r"\}"
)

# check_neutrality.py の _LD_JSON_SCRIPT_RE と同一パターン
LD_JSON_SCRIPT_RE = re.compile(
    r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>.*?</script>',
    re.DOTALL | re.IGNORECASE,
)


def is_within_spans(start, end, spans):
    return any(s <= start and end <= e for (s, e) in spans)


def compute_allowlisted_spans(content):
    """"大澤基" について、reviewedBy(Person) 構造ブロックかつ ld+json script タグ内に
    完全に含まれるマッチの span 一覧を返す（A1 バイパス対策込み）。"""
    ld_json_spans = [m.span() for m in LD_JSON_SCRIPT_RE.finditer(content)]
    spans = []
    for m in REVIEWEDBY_PERSON_BLOCK_RE.finditer(content):
        span = m.span()
        if is_within_spans(span[0], span[1], ld_json_spans):
            spans.append(span)
    return spans


def scan_file(path):
    content = path.read_text(encoding="utf-8")
    allowlisted_spans = compute_allowlisted_spans(content)
    findings = []
    for word in BANNED_WORDS:
        for m in re.finditer(re.escape(word), content):
            if word == "大澤基" and is_within_spans(m.start(), m.end(), allowlisted_spans):
                continue  # reviewedBy(Person) 構造ブロック内の実名監修者表記 → 許可
            line_no = content.count("\n", 0, m.start()) + 1
            line = content.splitlines()[line_no - 1].strip()
            findings.append((line_no, line))
    return findings


def main():
    base = Path(".")
    found_any = False
    print("=== ポータル中立性チェック ===")
    for dirname in ("blog", "guide"):
        d = base / dirname
        if not d.is_dir():
            continue
        for file_path in sorted(d.rglob("*.html")):
            findings = scan_file(file_path)
            if findings:
                found_any = True
                print(f"!! 禁止語検出: {dirname}/{file_path.name}")
                for line_no, line in findings:
                    print(f"{line_no}:{line}")
    if found_any:
        print("\n禁止語が検出されました。修正してから再pushしてください。")
        sys.exit(1)
    print("OK: 禁止語なし -- 中立性チェック合格")


if __name__ == "__main__":
    main()
