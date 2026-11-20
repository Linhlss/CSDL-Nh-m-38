"""Test bộ đọc RA: không phụ thuộc thứ tự khối SQL toàn tài liệu."""
import sys
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"scripts"))
from ra_sql_blocks import from_repo, parse_ra_sql_blocks

def document(include_division: bool) -> str:
    sections = ["# Tài liệu thử\n", "```sql\nSELECT 0 AS qd;\n```\n"]
    for i in range(1,11):
        sections.append(f"## QRA{i:02} — Thử\n")
        sections.append(f"```sql\nSELECT {i} AS x;\n```\n")
        if i == 7 and include_division:
            sections.append("```sql\nSELECT 777 AS x;\n```\n")
    return "".join(sections)

class TestRAParser(unittest.TestCase):
    def test_real_pr5_12_blocks(self):
        blocks = from_repo(ROOT)
        self.assertEqual(len(blocks), 12)
        self.assertEqual(len([k for k in blocks if k.startswith("QRA") and k!="QRA07_DIV"]),10)
        self.assertIn("NOT EXISTS", blocks["QRA07_DIV"].upper())

    def test_legacy_11_blocks(self):
        blocks = parse_ra_sql_blocks(document(False))
        self.assertEqual(len(blocks), 11)
        self.assertNotIn("QRA07_DIV", blocks)
        self.assertIn("SELECT 8", blocks["QRA08"])

    def test_new_12_blocks(self):
        blocks = parse_ra_sql_blocks(document(True))
        self.assertEqual(len(blocks), 12)
        self.assertIn("SELECT 7", blocks["QRA07"])
        self.assertIn("SELECT 777", blocks["QRA07_DIV"])
        self.assertIn("SELECT 8", blocks["QRA08"])

    def test_duplicate_heading_rejected(self):
        bad = document(True).replace("## QRA08 — Thử", "## QRA07 — Thử")
        with self.assertRaises(ValueError):
            parse_ra_sql_blocks(bad)

    def test_missing_heading_rejected(self):
        bad = document(True).replace("## QRA09 — Thử", "## QRA90 — Thử")
        with self.assertRaises(ValueError):
            parse_ra_sql_blocks(bad)

    def test_extra_fence_outside_qra07_rejected(self):
        bad = document(True).replace(
            "```sql\nSELECT 5 AS x;\n```",
            "```sql\nSELECT 5 AS x;\n```\n```sql\nSELECT 500 AS x;\n```"
        )
        with self.assertRaises(ValueError):
            parse_ra_sql_blocks(bad)

if __name__=="__main__":
    unittest.main()
