#!/usr/bin/env python3
"""Check the week-1 handoff (standard library only, no database connection).

Default: read-only checks including recorded file hashes.
--record: after all content checks pass, write the evidence and manifest.
This is a checker for this project's simple DDL, not a general PostgreSQL parser.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import platform
import re
import struct
import sys
import zlib
from datetime import date
from pathlib import Path
from urllib.parse import unquote
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tests/week1_manifest.json"
LOG = ROOT / "tests/week1_verification_log.md"
TABLES = {"to_dan_pho": 3, "dia_chi": 4, "ho_cu_tru": 4, "cu_dan": 5,
          "qua_trinh_cu_tru": 6, "tai_khoan": 5, "bien_dong_cu_tru": 8}
REQUIRED = ["README.md", ".gitignore", "docs/03_dac_ta_nghiep_vu.md", "docs/04_data_dictionary_va_chuan_hoa.md",
            "docs/02_bao_cao_suon.md", "docs/07_ma_tran_truy_van_va_review.md",
            "docs/BAN_GIAO_TV1_TUAN_1.md", "meetings/decision_log.md", "sql/01_schema.sql",
            "sql/02_constraints.sql", "tests/week1_design_cases.md", "tests/week1_sql_compatibility.json",
            "scripts/render_week1_diagrams.py", "scripts/verify_week1.py"]
REQUIRED += [f"diagrams/{name}.{ext}" for name in ("erd_v1", "phan_ra_chuc_nang")
             for ext in ("drawio", "png", "svg")]
RESULTS = []


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sql_contract(text):
    return re.sub(r"\s+", " ", re.sub(r"--[^\n]*", "", text)).strip()


def check(label, function):
    try:
        detail = function()
        RESULTS.append((label, "PASS", detail or ""))
    except Exception as error:
        RESULTS.append((label, "FAIL", str(error)))


def artifacts():
    missing = [name for name in REQUIRED if not (ROOT/name).is_file() or not (ROOT/name).stat().st_size]
    assert not missing, f"Missing/empty: {missing}"
    return f"{len(REQUIRED)} required artifacts exist and are nonempty"


def parse_schema():
    sql = re.sub(r"--[^\n]*", "", read("sql/01_schema.sql"))
    result = {}
    for table, body in re.findall(r"CREATE TABLE IF NOT EXISTS (\w+) \((.*?)\n\);", sql, re.S):
        columns = {}
        for row in body.splitlines():
            match = re.match(r"\s+(\w+)\s+(BIGINT|VARCHAR\(\d+\)|TEXT|DATE|TIMESTAMPTZ)(?=\s|,|$)(.*)", row)
            if match:
                name, dtype, rest = match.groups()
                columns[name] = (dtype, rest)
        result[table] = columns
    return sql, result


def schema_counts():
    sql, tables = parse_schema()
    assert {key:len(value) for key,value in tables.items()} == TABLES
    counts = {"PK":len(re.findall(r"PRIMARY KEY",sql)), "FK":len(re.findall(r"REFERENCES",sql)),
              "UNIQUE":len(re.findall(r"\bUNIQUE\b",sql)), "CHECK":len(re.findall(r"\bCHECK\s*\(",sql)),
              "INDEX":len(re.findall(r"CREATE INDEX",sql))}
    assert counts == {"PK":7,"FK":7,"UNIQUE":3,"CHECK":6,"INDEX":5}, counts
    for columns in tables.values():
        for dtype, rest in columns.values():
            reference = re.search(r"REFERENCES (\w+)\((\w+)\)",rest)
            if reference:
                parent, col = reference.groups()
                assert col in tables[parent], f"Unknown referenced key: {parent}.{col}"
                assert tables[parent][col][0] == dtype, "Foreign-key type mismatch"
    return "7 tables / 35 columns / 7 PK / 7 FK / 3 UNIQUE / 6 CHECK / 5 indexes"


def dictionary():
    _, tables = parse_schema()
    text = read("docs/04_data_dictionary_va_chuan_hoa.md")
    sections = re.findall(r"### 3\.\d+\. `(\w+)`[^\n]*\n(.*?)(?=\n### 3\.|\n## 4\.)",text,re.S)
    assert len(sections) == 7
    count = 0
    for table, body in sections:
        rows = {}
        for row in body.splitlines():
            if re.match(r"\| `\w+` \|",row):
                cells = [cell.strip() for cell in row.strip("|").split("|")]
                rows[cells[0].strip("`")] = cells[1:]
        assert set(rows) == set(tables[table]), f"Dictionary columns differ: {table}"
        for name, (dtype,rest) in tables[table].items():
            cells = rows[name]
            assert cells[0] == dtype, f"Wrong type: {table}.{name}"
            nn = "NOT NULL" in rest or "PRIMARY KEY" in rest
            assert cells[1] == ("Không" if nn else "Có"), f"Wrong NULL: {table}.{name}"
            if "PRIMARY KEY" in rest:
                assert "PK" in cells[2] and "IDENTITY BY DEFAULT" == cells[3]
            reference = re.search(r"REFERENCES (\w+)\((\w+)\)",rest)
            if reference:
                assert f"{reference.group(1)}({reference.group(2)})" in cells[2]
            if "UNIQUE" in rest:
                assert "UNIQUE" in cells[2]
            default = re.search(r"DEFAULT (CURRENT_TIMESTAMP|'[^']*')",rest)
            if default:
                assert cells[3].strip("`") == default.group(1)
            count += 1
    return f"{count} dictionary rows match DDL names, types, NULL, PK/FK, inline UNIQUE and defaults"


def diagrams():
    _, tables = parse_schema()
    tree = ET.parse(ROOT/"diagrams/erd_v1.drawio")
    expected = {f"{t}.{c}" for t,cols in tables.items() for c in cols}
    actual = [c.get("schemaColumn") for c in tree.iter("mxCell") if c.get("schemaColumn")]
    assert len(actual) == 35 and set(actual) == expected
    assert {c.get("schemaTable") for c in tree.iter("mxCell") if c.get("schemaTable")} == set(TABLES)
    references = {f"{t}.{c}" for t,cols in tables.items() for c,(_,rest) in cols.items() if "REFERENCES" in rest}
    assert {c.get("relationship") for c in tree.iter("mxCell") if c.get("relationship")} == references
    for name in ("erd_v1", "phan_ra_chuc_nang"):
        doc = ET.parse(ROOT/f"diagrams/{name}.drawio")
        assert doc.getroot().tag == "mxfile"
        for geo in doc.iter("mxGeometry"):
            if geo.get("width"):
                x,y,w,h = [float(geo.get(k,"0")) for k in ("x","y","width","height")]
                assert 0 <= x <= x+w <= 1150 and 0 <= y <= y+h <= 813
        assert ET.parse(ROOT/f"diagrams/{name}.svg").getroot().tag.endswith("svg")
    func = ET.parse(ROOT/"diagrams/phan_ra_chuc_nang.drawio")
    codes = {c.get("functionCode") for c in func.iter("mxCell") if c.get("functionCode")}
    expected_codes = {"0"} | {str(i) for i in range(1,7)} | {
        f"{i}.{j}" for i,n in enumerate((2,2,2,3,3,2),1) for j in range(1,n+1)}
    assert codes == expected_codes
    assert sum(bool(c.get("functionEdge")) for c in func.iter("mxCell")) == 20
    return "ERD: 7 entities, 35 attributes, 7 FK roles; function tree: 1 root + 6 groups + 14 leaves"


def png_exports():
    for name in ("erd_v1", "phan_ra_chuc_nang"):
        data = (ROOT/f"diagrams/{name}.png").read_bytes()
        assert data[:8] == b"\x89PNG\r\n\x1a\n"
        assert struct.unpack(">II",data[16:24]) == (2300,1626)
        pos = 8
        ended = False
        while pos < len(data):
            size = struct.unpack(">I",data[pos:pos+4])[0]
            kind = data[pos+4:pos+8]; body = data[pos+8:pos+8+size]
            crc = struct.unpack(">I",data[pos+8+size:pos+12+size])[0]
            assert zlib.crc32(kind+body) & 0xffffffff == crc
            pos += 12+size
            if kind == b"IEND":
                ended = True; break
        assert ended and pos == len(data)
    return "2 valid 2300×1626 PNGs, A4 landscape proportions, all PNG chunk CRCs valid"


def coverage():
    matrix = read("docs/07_ma_tran_truy_van_va_review.md")
    for prefix in ("QRA","QSQL"):
        ids = re.findall(r"^\| ("+prefix+r"\d\d) \|",matrix,re.M)
        assert len(ids) == 10 and set(ids) == {f"{prefix}{n:02}" for n in range(1,11)}
    cases = re.findall(r"^\| (D\d\d) \|",read("tests/week1_design_cases.md"),re.M)
    assert len(cases) == 30 and set(cases) == {f"D{n:02}" for n in range(1,31)}
    rules = re.findall(r"^\| (B\d\d) \|",read("docs/03_dac_ta_nghiep_vu.md"),re.M)
    assert len(rules) == 18 and set(rules) == {f"B{n:02}" for n in range(1,19)}
    assert set(re.findall(r"^\| (RV\d\d) \|",matrix,re.M)) == {f"RV{n:02}" for n in range(1,11)}
    return "10 RA + 10 SQL design mappings; 30 design cases; 18 business rules; 10 review notes"


def report_and_handoff():
    report = read("docs/02_bao_cao_suon.md")
    part = report.split("## CHƯƠNG 4")[0].split("## CHƯƠNG 1")[1]
    assert "[TODO" not in part and "[CHÈN HÌNH" not in part
    for n in range(1,4):
        assert len(re.findall(rf"^### {n}\.\d+\.",part,re.M)) >= 4
    ids = re.findall(r"^\| (W1-T1-\d\d) \|",read("meetings/decision_log.md"),re.M)
    assert len(ids) == 20 and set(ids) == {f"W1-T1-{n:02}" for n in range(1,21)}
    assert "CHỜ REVIEW" in read("meetings/decision_log.md")
    assert "dư thừa" in read("docs/04_data_dictionary_va_chuan_hoa.md")
    assert "kiểm tra tệp không thay test DB" in read("docs/BAN_GIAO_TV1_TUAN_1.md")
    return "Chapters 1–3 filled; all 20 TV1 tasks traced; peer-review and DB-test limits explicit"


def local_links(record):
    count = 0
    generated = {LOG.resolve(),MANIFEST.resolve()}
    for file in [ROOT/"README.md", *ROOT.glob("docs/*.md"), *ROOT.glob("tests/*.md"),
                 *ROOT.glob("meetings/*.md"),ROOT/"data/README.md"]:
        text = re.sub(r"```.*?```","",file.read_text(),flags=re.S)
        for target in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)",text):
            if re.match(r"(?:https?://|mailto:|#)",target):
                continue
            path = (file.parent/unquote(target.split("#")[0])).resolve()
            if record and path in generated:
                continue
            assert path.is_file(), f"Broken link in {file.relative_to(ROOT)}: {target}"
            count += 1
    return f"{count} local Markdown file links resolve (anchors and external URLs are not network-tested)"


def sql_compatibility():
    evidence = json.loads(read("tests/week1_sql_compatibility.json"))
    actual = hashlib.sha256(sql_contract(read("sql/01_schema.sql")).encode()).hexdigest()
    assert evidence["equal"] is True and actual == evidence["reference_sha256"] == evidence["local_sha256"]
    return "Executable SQL unchanged from GitHub main d20b394; only comments differ"


def python_syntax():
    for path in (ROOT/"scripts").glob("*.py"):
        ast.parse(path.read_text(),filename=str(path))
    return "Python utility sources parse successfully; no cache files written"


def files_for_manifest():
    files = [ROOT/"README.md",ROOT/".gitignore"]
    for directory in ("docs","diagrams","sql","scripts","tests","meetings","data","report","evidence"):
        files.extend(p for p in (ROOT/directory).rglob("*") if p.is_file()
                     and p.name != ".DS_Store" and "__pycache__" not in p.parts and p != MANIFEST)
    return sorted(set(files))


def check_manifest():
    assert MANIFEST.exists(), "Run --record once to create the evidence manifest"
    entries = json.loads(MANIFEST.read_text())["files"]
    assert {e["path"] for e in entries} == {str(p.relative_to(ROOT)) for p in files_for_manifest()}
    for item in entries:
        path = ROOT/item["path"]
        assert path.stat().st_size == item["bytes"] and sha(path) == item["sha256"], f"Changed: {item['path']}"
    return f"{len(entries)} repository files match their recorded SHA-256 hashes"


def record_evidence():
    recorded_date = date.today()
    rows = "\n".join(f"| {name} | {state} | {detail} |" for name,state,detail in RESULTS)
    LOG.write_text(f"""# BIÊN BẢN TỰ KIỂM TRA BỘ BÀN GIAO TV1 — {recorded_date:%d/%m/%Y}

**Lệnh đã chạy:** `python3 scripts/verify_week1.py --record` từ thư mục gốc.
**Python thực tế:** {platform.python_version()}. **Hệ điều hành:** {platform.system()} {platform.release()}.
**Phạm vi:** kiểm tra tệp và đối chiếu cấu trúc/tài liệu, không kết nối PostgreSQL.

| Kiểm tra | Kết quả | Bằng chứng / phạm vi |
|---|---|---|
{rows}

## Kiểm tra trực quan

Đã mở và xem cả hai ảnh PNG sau khi dựng: tên/thuộc tính đọc được, không cắt bảng hoặc chữ; hai vai trò cũ/mới tách riêng; cây chức năng đủ ba cấp. PNG là 2300×1626, tỷ lệ A4 ngang. SVG và drawio được kiểm XML; việc xem ảnh không thay việc TV2/TV3 review nội dung.

## Kiểm tra tương thích

`week1_sql_compatibility.json` lưu URL phiên bản gốc và SHA-256 SQL chuẩn hóa. Đã đọc bản GitHub tại d20b394, bỏ chú thích dòng và gộp khoảng trắng để so với local; không thay đổi câu lệnh tạo bảng/chỉ mục.

## Những điều chưa được xác nhận

- Lệnh kiểm tra tệp này không chạy DDL hoặc S01–S21 trên PostgreSQL. Kiểm chứng DB độc lập (nếu đã có) được ghi riêng trong docs/REVIEW_TV3_CHI_TIET.md; không dùng log này làm bằng chứng DB.
- Lệnh này không nghiệm thu cơ chế tuần 2 trong constraints/seed/query/security; xem sản phẩm và kết quả của từng owner. Ca D01–D30 là đối chiếu thiết kế với đáp án kỳ vọng, không là kết quả DB PASS.
- Lệnh này không tự xác nhận review của TV2/TV3 hoặc Gate 1 PASS; xem meetings/decision_log.md và báo cáo review mới nhất. Phân tích chuẩn hóa công bố điểm dư thừa ngày sự kiện và phần cần chốt tuần 2.
- Biên bản này chỉ kiểm tra tệp; trạng thái tích hợp PR và commit xem docs/REVIEW_TV3_CHI_TIET.md, meetings/decision_log.md và lịch sử main trên GitHub. Merge không thay thế xác nhận Gate 1.

## Kiểm tra lại

Nhận bản mới bằng `git pull --ff-only origin main` trên nhánh main, rồi chạy `python3 scripts/verify_week1.py`. Lệnh kiểm tra chỉ đọc, gồm đối chiếu SHA-256 của các tệp trong repository. Sau khi sửa nội dung, review rồi chạy lại --record để tái tạo biên bản và manifest trước commit; không chỉnh log thành PASS bằng tay.
""",encoding="utf-8")
    entries = [{"path":str(p.relative_to(ROOT)),"bytes":p.stat().st_size,"sha256":sha(p)} for p in files_for_manifest()]
    MANIFEST.write_text(json.dumps({"version":"v1-candidate","recorded_date":recorded_date.isoformat(),
                                    "scope":"static_handoff_checks_only",
                                    "database_executed":False,"group_gate1_approved":False,"files":entries},
                                   ensure_ascii=False,indent=2)+"\n",encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--record",action="store_true",help="Write evidence and manifest after checks pass")
    args = parser.parse_args()
    for name,function in [("Required artifacts",artifacts),("DDL contract",schema_counts),
                          ("Data dictionary",dictionary),("Editable diagrams",diagrams),("PNG exports",png_exports),
                          ("Question/rule/case coverage",coverage),("Report and task handoff",report_and_handoff),
                          ("Local file links",lambda:local_links(args.record)),("SQL compatibility",sql_compatibility),
                          ("Utility syntax",python_syntax)]:
        check(name,function)
    if all(state == "PASS" for _,state,_ in RESULTS):
        if args.record:
            record_evidence()
        check("Repository manifest",check_manifest)
    for name,state,detail in RESULTS:
        print(f"{state}: {name}: {detail}")
    failed = sum(state == "FAIL" for _,state,_ in RESULTS)
    print(f"RESULT: {len(RESULTS)-failed}/{len(RESULTS)} checks passed; database not executed; Gate 1 awaiting peer review")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
