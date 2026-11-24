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
from datetime import date, datetime
from pathlib import Path
from urllib.parse import unquote
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tests/week1_manifest.json"
LOG = ROOT / "tests/week1_verification_log.md"
LEDGER = "meetings/decision_log.md"
TABLES = {"to_dan_pho": 3, "dia_chi": 4, "ho_cu_tru": 4, "cu_dan": 5,
          "qua_trinh_cu_tru": 6, "tai_khoan": 5, "bien_dong_cu_tru": 8}
REQUIRED = ["README.md", ".gitignore", "docs/03_dac_ta_nghiep_vu.md", "docs/04_data_dictionary_va_chuan_hoa.md",
            "docs/02_bao_cao_suon.md", "docs/07_ma_tran_truy_van_va_review.md",
            LEDGER, "sql/01_schema.sql",
            "sql/02_constraints.sql", "tests/week1_design_cases.md", "tests/week1_sql_compatibility.json",
            "scripts/render_week1_diagrams.py", "scripts/verify_week1.py"]
REQUIRED += [f"diagrams/{name}.{ext}" for name in ("erd_v1", "phan_ra_chuc_nang")
             for ext in ("drawio", "png", "svg")]
REQUIRED += [".gitattributes", "docs/05_ke_hoach_du_lieu_va_sql.md",
             "tests/week1_fixture.sql", "tests/week1_expected.json", "tests/week1_environment.md",
             "tests/week1_execution_results.json", "scripts/verify_week1_runtime.py"]
RESULTS = []


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def gate1_state():
    parts = read(LEDGER).split('<a id="gate1"></a>')
    assert len(parts) == 2, "Gate 1 must have one current decision section"
    values = {}
    for key in ("Gate 1", "Phiên bản thiết kế", "Ngày tiếp nhận", "Nguồn xác nhận", "Thành viên đồng ý"):
        matches = re.findall(r"^\| " + re.escape(key) + r" \| ([^|\n]+) \|$", parts[1], re.M)
        assert len(matches) == 1, f"Missing/ambiguous Gate 1 field: {key}"
        values[key] = matches[0].strip()
    status = values["Gate 1"]
    assert status in ("PASS", "CHỜ REVIEW"), "Unknown Gate 1 status"
    approved = status == "PASS"
    assert values["Phiên bản thiết kế"] == ("v1" if approved else "v1-candidate"), "Gate 1 and design version disagree"
    if approved:
        datetime.strptime(values["Ngày tiếp nhận"], "%d/%m/%Y")
        assert values["Nguồn xác nhận"] and values["Nguồn xác nhận"] not in ("...", "Chưa có"), "Approved Gate 1 needs a confirmation source"
        assert set(re.findall(r"\bTV[123]\b", values["Thành viên đồng ý"])) == {"TV1", "TV2", "TV3"}, "Approved Gate 1 needs all three members"
    return {"status": status, "version": values["Phiên bản thiết kế"], "approved": approved,
            "received_on": values["Ngày tiếp nhận"], "source": values["Nguồn xác nhận"]}


def week1_counts():
    statuses = [line.split("|")[-2].strip() for line in read(LEDGER).splitlines()
                if re.match(r"^\| W1-(?:T[123]|G)-\d\d \|", line)]
    done = sum(value.startswith("Đạt") for value in statuses)
    deferred = sum(value.startswith("Hoãn") for value in statuses)
    return {"total": len(statuses), "completed": done, "deferred": deferred,
            "pending": len(statuses) - done - deferred}


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
    ids = re.findall(r"^\| (W1-T1-\d\d) \|",read(LEDGER),re.M)
    assert len(ids) == 20 and set(ids) == {f"W1-T1-{n:02}" for n in range(1,21)}
    gate = gate1_state()
    assert "dư thừa" in read("docs/04_data_dictionary_va_chuan_hoa.md")
    assert "kiểm tra tệp không thay test DB" in read(LEDGER)
    return f"Chapters 1–3 filled; all 20 TV1 tasks traced; Gate 1 {gate['status']} / {gate['version']}; confirmation source and DB-test limits explicit"


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
    files = [ROOT/"README.md",ROOT/".gitignore",ROOT/".gitattributes"]
    for directory in ("docs","diagrams","sql","scripts","tests","meetings","data","report","evidence","presentation"):
        files.extend(p for p in (ROOT/directory).rglob("*") if p.is_file()
                     and p.name != ".DS_Store" and "__pycache__" not in p.parts and p != MANIFEST)
    # The printable report is versioned with its sources and images; TeX build
    # intermediates stay local and must not make the manifest machine-dependent.
    latex = ROOT / "Báo_cáo_CSDL_nhóm_38"
    if latex.is_dir():
        files.extend(p for p in latex.rglob("*") if p.is_file()
                     and (p.suffix in {".tex", ".md"} or p.name in {".gitignore", "main.pdf"}
                          or (latex / "image" in p.parents and p.suffix in {".png", ".pdf", ".svg"})))
    files.extend(p for p in (ROOT / "erd.png", ROOT / "Slide/HUST_PPT_template_2022_Blue_16x9.pptx")
                 if p.is_file())
    review = ROOT / "BAO_CAO_KET_QUA_SUA_LATEX.md"
    if review.is_file():
        files.append(review)
    return sorted(set(files))


def week1_handoff():
    expected = {f"W1-T{person}-{n:02}" for person, count in [(1,20),(2,14),(3,14)]
                for n in range(1,count+1)} | {f"W1-G-{n:02}" for n in range(1,6)}
    text = read(LEDGER)
    rows = re.findall(r"^\| (W1-(?:T[123]|G)-\d\d) \|", text, re.M)
    assert len(rows)==53 and set(rows)==expected, "Week1 handoff must trace all 53 unique IDs"
    checklist = read("docs/03_CHECKLIST_DU_AN.md")
    counts = {1: (20,14,14,5), 2: (15,16,13,3), 3: (15,11,11,5)}
    project_ids = {f"W{week}-{owner}-{n:02}"
                   for week, sizes in counts.items()
                   for owner, size in zip(("T1","T2","T3","G"),sizes)
                   for n in range(1,size+1)}
    all_boxes = re.findall(r"^- \[([ x])\] \*\*(W[123]-(?:T[123]|G)-\d\d)",checklist,re.M)
    assert len(all_boxes)==142 and {key for _,key in all_boxes}==project_ids, "Checklist must retain all 142 unique project IDs"
    boxes = [(mark,key) for mark,key in all_boxes if key.startswith("W1-")]
    assert len(boxes)==53 and {key for _,key in boxes}==expected
    ledger = [line.split("|") for line in text.splitlines()
              if re.match(r"^\| W1-(?:T[123]|G)-\d\d \|",line)]
    ready = {cells[1].strip() for cells in ledger if cells[-2].strip().startswith("Đạt")}
    deferred = {cells[1].strip() for cells in ledger if cells[-2].strip().startswith("Hoãn")}
    marked = {key for mark,key in boxes if mark=="x"}
    assert marked==ready, "Checklist boxes must agree with the evidence ledger, not an assumed completion count"
    assert not marked & deferred, "Deferred tasks must not count as complete"
    for cells in ledger:
        if cells[1].strip() in deferred:
            targets = re.findall(r"\bW2-(?:T[123]|G)-\d\d\b", cells[-2])
            assert targets and all(target in project_ids for target in targets), "Deferred week1 tasks need a valid week2 handoff ID"
    if gate1_state()["approved"]:
        gate_tasks = {"W1-T1-01", "W1-T1-19", "W1-T1-20", "W1-T2-14", "W1-G-03", "W1-G-04"}
        assert gate_tasks <= ready, "Approved Gate 1 must have its six confirmations completed"
    counts = week1_counts()
    for name, sid in [("Dương Ngọc Ninh","20237469"),("Trần Tuấn Ngọc","20227064"),("Trần Bùi Tùng Linh","20227057")]:
        assert name in text and sid in text
    return f"142 unique project IDs; shared ledger: 53 week1 IDs, {counts['completed']} completed, {counts['deferred']} deferred to week2, {counts['pending']} awaiting confirmation; deferred tasks stay unchecked"


def runtime_evidence():
    result=json.loads(read("tests/week1_execution_results.json"))
    assert result["summary"]["failed"]==0 and result["summary"]["passed"]==len(result["checks"])
    keys={item["test"] for item in result["checks"] if item["status"]=="PASS"}
    assert all(f"{db}/QSQL{n:02}/full-tuples" in keys for db in ("w1_tiny","w1_seed") for n in range(1,11))
    # Lịch sử tuần 1 được giữ nguyên; 06_validation.sql đã được mở rộng
    # trong tuần 2. Không sửa hash trong log chạy PostgreSQL ngày 16/11.
    # 05_security.sql: TV3 thu hồi DELETE bảng lịch sử khỏi admin (B12, X02, 20/11).
    week2_evolved = {"sql/06_validation.sql", "scripts/verify_week1_runtime.py",
                     "sql/05_security.sql"}
    for path,digest in result["files_sha256"].items():
        if path in week2_evolved:
            continue  # version hiện tại được xác thực qua manifest + CI tuần 2
        assert sha(ROOT/path)==digest, f"Runtime-tested input changed: {path}"
    clean=lambda s:re.sub(r"--[^\n]*","",s).strip().rstrip(";")
    parts=re.split(r"^-- (QSQL\d{2})\.[^\n]*\n",read("sql/04_queries.sql"),flags=re.M)
    sql={parts[i]:clean(parts[i+1]) for i in range(1,len(parts),2)}
    from ra_sql_blocks import parse_ra_sql_blocks
    named = parse_ra_sql_blocks(read("docs/06a_dai_so_quan_he.md"))
    sql.update({k:clean(v) for k,v in named.items()
                if k.startswith("QRA") and k != "QRA07_DIV"})
    current_hashes = {k:hashlib.sha256(v.encode()).hexdigest() for k,v in sql.items()}
    mismatches = [k for k,v in current_hashes.items() if result["query_sha256"].get(k) != v]
    missing = sorted(set(result["query_sha256"]) - set(current_hashes))
    assert not mismatches and not missing, f"Historical SQL hashes changed: mismatched={mismatches}, missing={missing}"
    return f"{result['summary']['passed']}/{len(result['checks'])} historical PostgreSQL checks; week1 input versions preserved in log; week2 validation/runtime tooling tracked by new manifest and CI (DB not rerun by this script)"


def newline_policy():
    assert "* text=auto eol=lf" in read(".gitattributes")
    for path in files_for_manifest():
        if path.suffix in (".md",".py",".sql",".csv",".json",".drawio",".svg"):
            assert b"\r" not in path.read_bytes(), f"Expected LF text: {path.relative_to(ROOT)}"
    return "LF policy and repository text verified; PNG/binary content unchanged; no unperformed Windows test claimed"


def check_manifest():
    assert MANIFEST.exists(), "Run --record once to create the evidence manifest"
    manifest = json.loads(MANIFEST.read_text())
    gate = gate1_state()
    assert manifest["version"] == gate["version"] and manifest["group_gate1_approved"] is gate["approved"], "Manifest Gate 1 status differs from the current decision"
    assert manifest["week1_tasks"] == week1_counts(), "Manifest task counts differ from the shared ledger"
    entries = manifest["files"]
    assert {e["path"] for e in entries} == {str(p.relative_to(ROOT)) for p in files_for_manifest()}
    for item in entries:
        path = ROOT/item["path"]
        assert path.stat().st_size == item["bytes"] and sha(path) == item["sha256"], f"Changed: {item['path']}"
    return f"{len(entries)} repository files match their recorded SHA-256 hashes"


def record_evidence():
    recorded_date = date.today()
    gate = gate1_state()
    rows = "\n".join(f"| {name} | {state} | {detail} |" for name,state,detail in RESULTS)
    LOG.write_text(f"""# BIÊN BẢN KIỂM TRA TỆP DỰ ÁN — {recorded_date:%d/%m/%Y}

**Lệnh đã chạy:** `python3 scripts/verify_week1.py --record` từ thư mục gốc.
**Python thực tế:** {platform.python_version()}. **Hệ điều hành:** {platform.system()} {platform.release()}.
**Phạm vi:** kiểm tra tệp và đối chiếu cấu trúc/tài liệu, không kết nối PostgreSQL.
**Trạng thái đọc từ nhật ký:** Gate 1 {gate['status']}; thiết kế {gate['version']}. Ngày tiếp nhận: {gate['received_on']}; nguồn: {gate['source']}.

| Kiểm tra | Kết quả | Bằng chứng / phạm vi |
|---|---|---|
{rows}

## Kiểm tra trực quan

Lần dựng sơ đồ tuần 1 đã mở và xem cả hai ảnh PNG: tên/thuộc tính đọc được, không cắt bảng hoặc chữ; hai vai trò cũ/mới tách riêng; cây chức năng đủ ba cấp. Lần kiểm tra tệp này kiểm PNG 2300×1626, CRC và XML của SVG/drawio, không tự nhận là một lần review hình ảnh mới hoặc thay review nội dung của TV2/TV3.

## Kiểm tra tương thích

`week1_sql_compatibility.json` lưu URL phiên bản gốc tại d20b394 và SHA-256 SQL chuẩn hóa đã đối chiếu. Lần kiểm tra này bỏ chú thích dòng, gộp khoảng trắng và so với hash đã ghi; không tự nhận đã tải lại nguồn GitHub. Không thay đổi câu lệnh tạo bảng/chỉ mục.

## Những điều chưa được xác nhận

- Lệnh kiểm tra tệp này không chạy DDL hoặc S01–S21 trên PostgreSQL. Nguồn và phạm vi kiểm chứng độc lập nằm trong [nhật ký chung](../meetings/decision_log.md), [log146](tv3_review_results.json) và [log96](week1_execution_results.json); không dùng biên bản tĩnh này làm bằng chứng chạy DB mới.
- Lệnh này không nghiệm thu cơ chế tuần 2 trong constraints/seed/query/security; xem sản phẩm và kết quả của từng owner. Ca D01–D30 là đối chiếu thiết kế với đáp án kỳ vọng, không là kết quả DB PASS.
- Trạng thái Gate 1 ở trên được đọc từ xác nhận đã lưu trong meetings/decision_log.md; script không tạo lời đồng ý hoặc chữ ký của thành viên. Phân tích chuẩn hóa công bố điểm dư thừa ngày sự kiện và phần cần chốt tuần 2.
- Biên bản này chỉ kiểm tra tệp; trạng thái tích hợp PR, commit, bảng53mã và xác nhận còn thiếu tập trung tại meetings/decision_log.md. Merge không thay thế xác nhận Gate 1; lịch tuần 2 nằm trong checklist hiện hành.

## Kiểm tra lại

Nhận bản mới bằng `git pull --ff-only origin main` trên nhánh main, rồi chạy `python3 scripts/verify_week1.py`. Lệnh kiểm tra chỉ đọc, gồm đối chiếu SHA-256 của các tệp trong repository. Sau khi sửa nội dung, review rồi chạy lại --record để tái tạo biên bản và manifest trước commit; không chỉnh log thành PASS bằng tay.
""",encoding="utf-8")
    entries = [{"path":str(p.relative_to(ROOT)),"bytes":p.stat().st_size,"sha256":sha(p)} for p in files_for_manifest()]
    MANIFEST.write_text(json.dumps({"version":gate["version"],"recorded_date":recorded_date.isoformat(),
                                    "scope":"static_handoff_and_recorded_runtime_evidence",
                                    "runtime_evidence_available":True,"week1_technical_complete":True,
                                    "database_executed":False,"group_gate1_approved":gate["approved"],
                                    "week1_tasks":week1_counts(),"files":entries},
                                   ensure_ascii=False,indent=2)+"\n",encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--record",action="store_true",help="Write evidence and manifest after checks pass")
    args = parser.parse_args()
    for name,function in [("Required artifacts",artifacts),("DDL contract",schema_counts),
                          ("Data dictionary",dictionary),("Editable diagrams",diagrams),("PNG exports",png_exports),
                          ("Question/rule/case coverage",coverage),("Report and task handoff",report_and_handoff),
                          ("Local file links",lambda:local_links(args.record)),("SQL compatibility",sql_compatibility),
                          ("Utility syntax",python_syntax),("Week1 task trace",week1_handoff),
                          ("Recorded runtime evidence",runtime_evidence),("LF text policy",newline_policy)]:
        check(name,function)
    if all(state == "PASS" for _,state,_ in RESULTS):
        if args.record:
            record_evidence()
        check("Repository manifest",check_manifest)
    for name,state,detail in RESULTS:
        print(f"{state}: {name}: {detail}")
    failed = sum(state == "FAIL" for _,state,_ in RESULTS)
    try:
        gate = gate1_state()
        gate_summary = f"{gate['status']} / {gate['version']}"
    except (AssertionError, ValueError, OSError):
        gate_summary = "INVALID (see failed checks)"
    print(f"RESULT: {len(RESULTS)-failed}/{len(RESULTS)} checks passed; database not executed; Gate 1 {gate_summary}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
