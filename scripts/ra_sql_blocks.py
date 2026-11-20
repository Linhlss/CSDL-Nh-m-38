"""Đọc các khối SQL kiểm chứng RA bằng mã QRA, không bằng vị trí tuần tự.

Chấp nhận 11 khối (Q_d + QRA01..10) hoặc 12 khối (thêm QRA07_DIV).
Lỗi thiếu/trùng/sai vị trí phải raise ValueError thay vì âm thầm đổi tên.
"""
from __future__ import annotations
import re
from pathlib import Path

FENCE = re.compile(r"(?ms)^```sql[ \t]*\n(.*?)\n```[ \t]*$")
HEAD = re.compile(r"(?m)^## (QRA\d{2})\s*[—–:-]\s*.*$")

def parse_ra_sql_blocks(document: str) -> dict[str, str]:
    heads = list(HEAD.finditer(document))
    expected = [f"QRA{i:02}" for i in range(1, 11)]
    labels = [m.group(1) for m in heads]
    if labels != expected:
        raise ValueError(f"RA headings must be QRA01..QRA10 in order; found {labels}")

    preamble = document[:heads[0].start()]
    preamble_sql = FENCE.findall(preamble)
    if len(preamble_sql) != 1:
        raise ValueError(f"Expected one Q_d SQL fence before QRA01, found {len(preamble_sql)}")

    found: dict[str, str] = {"Q_d": preamble_sql[0].strip()}
    for index, head in enumerate(heads):
        next_head = heads[index + 1].start() if index + 1 < len(heads) else len(document)
        section = document[head.end():next_head]
        sql_blocks = FENCE.findall(section)
        key = head.group(1)
        allowed = (1, 2) if key == "QRA07" else (1,)
        if len(sql_blocks) not in allowed:
            raise ValueError(f"{key}: expected {allowed} SQL blocks, found {len(sql_blocks)}")
        found[key] = sql_blocks[0].strip()
        if key == "QRA07" and len(sql_blocks) == 2:
            found["QRA07_DIV"] = sql_blocks[1].strip()

    if len(found) not in (11, 12):
        raise ValueError(f"Unexpected RA SQL block count: {len(found)}")
    return found

def from_repo(root: Path) -> dict[str, str]:
    return parse_ra_sql_blocks(
        (root / "docs/06a_dai_so_quan_he.md").read_text(encoding="utf-8")
    )

if __name__ == "__main__":
    import sys
    result = from_repo(Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1])
    print(f"PASS: parsed {len(result)} named SQL blocks: {', '.join(result)}")
