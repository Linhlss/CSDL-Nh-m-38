#!/usr/bin/env python3
"""Verify the week-1 handoff in a fresh labelled PostgreSQL 17.11 container.

No third-party Python modules. Creates w1_tiny/w1_seed only in the disposable
container. The final-test log for the complete project is deliberately separate.
"""
from __future__ import annotations
import argparse
import copy
import csv
import hashlib
import importlib.util
import io
import json
import re
import subprocess
import sys
import tempfile
from collections import Counter
from datetime import date, datetime
from pathlib import Path
from types import SimpleNamespace
from zoneinfo import ZoneInfo

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
TABLES = {"to_dan_pho": "ma_to", "dia_chi": "ma_dia_chi", "ho_cu_tru": "ma_ho",
          "cu_dan": "ma_cu_dan", "qua_trinh_cu_tru": "ma_qua_trinh",
          "tai_khoan": "ma_tai_khoan", "bien_dong_cu_tru": "ma_bien_dong"}
D = date(2026, 11, 20)


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def load_csv(root):
    data = {}
    for table in TABLES:
        rows = list(csv.DictReader(io.StringIO((root / f"data/generated/{table}.csv").read_text())))
        for row in rows:
            for key, value in row.items():
                row[key] = None if value == "" else int(value) if key.startswith("ma_") else date.fromisoformat(value) if key.startswith("ngay_") else value
        data[table] = rows
    return data


def oracle(t):
    """Independent Python interpretation of the ten business questions."""
    maps = {table: {r[key]: r for r in t[table]} for table, key in TABLES.items()}
    cd, ho, dc, qt = [maps[k] for k in ("cu_dan", "ho_cu_tru", "dia_chi", "qua_trinh_cu_tru")]
    active = [r for r in t["qua_trinh_cu_tru"] if r["ngay_bat_dau"] <= D and (r["ngay_ket_thuc"] is None or r["ngay_ket_thuc"] >= D)]
    org = lambda q: dc[ho[q["ma_ho"]]["ma_dia_chi"]]["ma_to"]
    person = lambda cid: {"ma_cu_dan": cid, "ho_ten": cd[cid]["ho_ten"]}
    q1 = {(q["ma_cu_dan"], q["loai_cu_tru"]) for q in active if org(q) == 1}
    house_people = {hid: {q["ma_cu_dan"] for q in active if q["ma_ho"] == hid} for hid in ho}
    org_people = {oid: {q["ma_cu_dan"] for q in active if org(q) == oid} for oid in maps["to_dan_pho"]}
    all_houses = {cid: {q["ma_ho"] for q in t["qua_trinh_cu_tru"] if q["ma_cu_dan"] == cid} for cid in cd}
    kinds = {cid: {q["loai_cu_tru"] for q in t["qua_trinh_cu_tru"] if q["ma_cu_dan"] == cid} for cid in cd}
    begun = {q["ma_cu_dan"] for q in t["qua_trinh_cu_tru"] if q["ngay_bat_dau"] <= D}
    current = {q["ma_cu_dan"] for q in active}
    events = Counter((r["ngay_bien_dong"].isoformat()[:7], r["loai_bien_dong"]) for r in t["bien_dong_cu_tru"])
    q9 = []
    for b in t["bien_dong_cu_tru"]:
        if b["loai_bien_dong"] != "CHUYEN_NOI_BO": continue
        old, new = qt[b["ma_qua_trinh_cu"]], qt[b["ma_qua_trinh_moi"]]
        if old["ma_cu_dan"] == new["ma_cu_dan"] and org(old) != org(new):
            q9.append({"ma_bien_dong": b["ma_bien_dong"], "ma_cu_dan": old["ma_cu_dan"], "ma_to_cu": org(old), "ma_to_moi": org(new), "ngay_bien_dong": b["ngay_bien_dong"].isoformat()})
    return {
        "QSQL01": [dict(person(cid), loai_cu_tru=kind) for cid, kind in q1],
        "QSQL02": [{"ma_ho": hid, "so_cu_dan": len(p)} for hid, p in house_people.items() if len(p) >= 4],
        "QSQL03": [{"ma_to": oid, "ten_to": maps["to_dan_pho"][oid]["ten_to"], "so_cu_dan": len(p)} for oid, p in org_people.items()],
        "QSQL04": [{"ma_dia_chi": did, "dia_chi_chuan": r["dia_chi_chuan"]} for did, r in dc.items() if not any(h["ma_dia_chi"] == did for h in ho.values())],
        "QSQL05": [dict(person(cid), so_ho=len(houses)) for cid, houses in all_houses.items() if len(houses) >= 2],
        "QSQL06": [person(cid) for cid, k in kinds.items() if k == {"THUONG_TRU", "TAM_TRU"}],
        "QSQL07": [person(cid) for cid in begun - current],
        "QSQL08": [{"thang": month, "loai_bien_dong": kind, "so_su_kien": count} for (month, kind), count in events.items()],
        "QSQL09": q9,
        "QSQL10": [{"ma_tai_khoan": aid, "ten_hien_thi": a["ten_hien_thi"], "so_su_kien": sum(b["ma_tai_khoan"] == aid for b in t["bien_dong_cu_tru"])} for aid, a in maps["tai_khoan"].items()]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--container", required=True)
    parser.add_argument("--client-date", default="2026-11-16")
    args = parser.parse_args()
    label = subprocess.run(["docker", "inspect", "--format", '{{index .Config.Labels "csdl17.review"}}', args.container], text=True, capture_output=True)
    if label.returncode or label.stdout.strip() != "tv3": raise SystemExit("Container must be disposable and labelled csdl17.review=tv3")
    h = module("review_helpers", ROOT / "scripts/review_tv3.py")
    h.OPTIONS = SimpleNamespace(container=args.container)
    h.SECURITY = (ROOT / "sql/05_security.sql").read_text()
    gen = module("week1_generator", ROOT / "scripts/generate_data.py")
    compare, rows, run = h.compare, h.rows, h.run
    data = load_csv(ROOT)
    gen.validate_data(data)
    compare("data/636-counts", [{k: len(v) for k, v in data.items()}], [{"to_dan_pho":8,"dia_chi":50,"ho_cu_tru":60,"cu_dan":200,"qua_trinh_cu_tru":250,"tai_khoan":5,"bien_dong_cu_tru":63}])
    with tempfile.TemporaryDirectory(prefix="csdl17-gen-") as folder:
        a, b = Path(folder)/"a", Path(folder)/"b"
        gen.main(a); gen.main(b)
        files = [f"data/generated/{t}.csv" for t in TABLES] + ["sql/03_seed.sql"]
        compare("generator/two-runs-byte-identical", [all((a/p).read_bytes() == (b/p).read_bytes() for p in files)], [True])
        compare("generator/committed-files-match", [all((a/p).read_bytes() == (ROOT/p).read_bytes() for p in files)], [True])
        compare("generator/LF-only", [all(b"\r" not in (a/p).read_bytes() for p in files)], [True])
        bad = copy.deepcopy(data); bad["ho_cu_tru"][0]["ngay_lap"] = date(9999,1,1)
        try: gen.validate_data(bad); rejected = False
        except ValueError as err: rejected = "B15" in str(err)
        compare("generator/reject-B15", [rejected], [True])
        original_validator = gen.validate_data
        def fail_before_export(t):
            t["ho_cu_tru"][0]["ngay_lap"] = date(9999,1,1)
            original_validator(t)
        gen.validate_data = fail_before_export
        try: gen.main(Path(folder)/"bad")
        except ValueError: pass
        finally: gen.validate_data = original_validator
        compare("generator/reject-before-any-output", [(Path(folder)/"bad").exists()], [False])
    # Trace the original defect and prove only household opening dates changed.
    old = {}
    for table in TABLES:
        result = subprocess.run(["git","show",f"63388b394095da137a460ca2f439082bef2077f5:data/generated/{table}.csv"],text=True,capture_output=True,check=True)
        old[table] = list(csv.DictReader(io.StringIO(result.stdout)))
    old_h = {r["ma_ho"]:r for r in old["ho_cu_tru"]}
    compare("original/B15-54-reproduced", [sum(old_h[q["ma_ho"]]["ngay_lap"] > q["ngay_bat_dau"] for q in old["qua_trinh_cu_tru"])], [54], "reproduction")
    for table in TABLES:
        committed = list(csv.DictReader(io.StringIO((ROOT/f"data/generated/{table}.csv").read_text())))
        if table == "ho_cu_tru":
            keep = lambda r: {k:v for k,v in r.items() if k != "ngay_lap"}
            compare("B15/only-house-opening-dates-change", [keep(r) for r in committed], [keep(r) for r in old[table]])
        else: compare(f"B15/preserve-{table}", committed, old[table])
    parts = re.split(r"^-- (QSQL\d{2})\.[^\n]*\n", (ROOT/"sql/04_queries.sql").read_text(), flags=re.M)
    sql = {parts[i]:h.clean(parts[i+1]) for i in range(1,len(parts),2)}
    if len(sql)!=10: raise RuntimeError("Expected exactly ten QSQL")
    from ra_sql_blocks import from_repo
    named = from_repo(ROOT)
    ra = {key:h.clean(value) for key,value in named.items()
          if key.startswith("QRA") and key != "QRA07_DIV"}
    ra07_div = h.clean(named["QRA07_DIV"]) if "QRA07_DIV" in named else None
    fixture=(ROOT/"tests/week1_fixture.sql").read_text()
    inserts=fixture.split("-- BEGIN_FIXTURE_DATA",1)[1].split("-- END_FIXTURE_DATA",1)[0]
    tiny_expected=json.loads((ROOT/"tests/week1_expected.json").read_text())
    results={}
    for db, seed in [("w1_tiny",inserts),("w1_seed",(ROOT/"sql/03_seed.sql").read_text())]:
        run(f"CREATE DATABASE {db};")
        run((ROOT/"sql/01_schema.sql").read_text(),db); run(seed,db)
        h.security(db,db)
        expected=tiny_expected if db=="w1_tiny" else oracle(data)
        actual={}
        for key, query in sql.items():
            actual[key]=rows(query,db)
            compare(f"{db}/{key}/full-tuples",actual[key],expected[key])
        results[db]=actual
        counts={t:rows(f"SELECT COUNT(*) AS n FROM {t}",db)[0]["n"] for t in TABLES}
        compare(f"{db}/total-rows",[sum(counts.values())],[29 if db=="w1_tiny" else 636])
        for key in ("V_E1_CU","V_E1_MOI","V_B09"):
            compare(f"{db}/{key}",rows(h.validation(key),db),[])
        compare(f"{db}/B15",rows("SELECT q.ma_qua_trinh FROM qua_trinh_cu_tru q JOIN ho_cu_tru h USING(ma_ho) JOIN cu_dan c USING(ma_cu_dan) WHERE h.ngay_lap>q.ngay_bat_dau OR c.ngay_sinh>q.ngay_bat_dau",db),[])
        names={r["ma_cu_dan"]:r["ho_ten"] for r in rows("SELECT ma_cu_dan,ho_ten FROM cu_dan",db)}
        unique=lambda rr:list({json.dumps(r,sort_keys=True,ensure_ascii=False):r for r in rr}.values())
        for rak,sqk in [("QRA01","QSQL01"),("QRA04","QSQL05"),("QRA05","QSQL04"),("QRA07","QSQL06"),("QRA09","QSQL07"),("QRA10","QSQL09")]:
            expected_rows=actual[sqk]
            if rak=="QRA01": expected_rows=unique([{k:r[k] for k in ("ma_cu_dan","ho_ten")} for r in expected_rows])
            if rak=="QRA04": expected_rows=[{k:r[k] for k in ("ma_cu_dan","ho_ten")} for r in expected_rows]
            if rak=="QRA10": expected_rows=unique([{"ma_cu_dan":r["ma_cu_dan"],"ho_ten":names[r["ma_cu_dan"]]} for r in expected_rows])
            compare(f"{db}/{rak}-vs-{sqk}",rows(ra[rak],db),expected_rows)
        if ra07_div:
            compare(f"{db}/QRA07_DIV-vs-QRA07", rows(ra07_div,db), rows(ra["QRA07"],db))
        compare(f"{db}/VIEW-vs-QSQL03",rows("SELECT * FROM vw_thong_ke_cu_dan_theo_to",db,role="csdl17_report",direct=True),actual["QSQL03"])
        before=h.snapshot(db)
        h.denied(f"{db}/S20-reader-update","UPDATE cu_dan SET ghi_chu='forbidden' WHERE ma_cu_dan=1;",db,"csdl17_reader",True)
        h.denied(f"{db}/S21-report-base-table","SELECT * FROM cu_dan;",db,"csdl17_report",True)
        compare(f"{db}/permission-data-unchanged",[h.snapshot(db)],[before])
    db="w1_tiny"
    for key,expected in {"QRA02":[{"ma_cu_dan":5,"ho_ten":"Trần Thị Dung"}],"QRA03":[{"ma_cu_dan":1,"ho_ten":"Nguyễn Văn An","ngay_sinh":"1966-11-20"}],"QRA06":[{"ma_cu_dan":6,"ho_ten":"Đỗ Văn Em"}],"QRA08":[{"ma_cu_dan":i} for i in [1,2,3,4,5]]}.items():
        compare(f"tiny/{key}/hand-answer",rows(ra[key],db),expected)
    close="DELETE FROM bien_dong_cu_tru WHERE ma_bien_dong=3; UPDATE qua_trinh_cu_tru SET ngay_ket_thuc='2026-11-19' WHERE ma_qua_trinh=7;"
    compare("C1/expired-without-event",rows(sql["QSQL07"],db,setup=close),tiny_expected["QSQL07"])
    compare("C1/inclusive-last-day",rows(sql["QSQL07"].replace("2026-11-20","2026-11-19"),db,setup=close),[])
    future="INSERT INTO cu_dan(ma_cu_dan,ho_ten,ngay_sinh,gioi_tinh) VALUES(80,'Tương lai','1990-01-01','Nam'); INSERT INTO qua_trinh_cu_tru VALUES(80,80,2,'THUONG_TRU','2026-12-01',NULL);"
    compare("edge/future-not-past-inactive",rows(sql["QSQL07"],db,setup=future),tiny_expected["QSQL07"])
    compare("edge/future-not-never",rows(ra["QRA06"],db,setup=future),[{"ma_cu_dan":6,"ho_ten":"Đỗ Văn Em"}])
    compare("edge/same-org-move-excluded",rows(sql["QSQL09"],db,setup="UPDATE ho_cu_tru SET ma_dia_chi=1 WHERE ma_ho=2;"),[])
    # Existing PK/FK/CHECK only. Cross-table constraints remain week-2 work.
    before=h.snapshot(db)
    for key,statement,state in [("S17","INSERT INTO qua_trinh_cu_tru VALUES(90,9999,1,'THUONG_TRU','2026-01-01',NULL);","23503"),("S18","INSERT INTO qua_trinh_cu_tru VALUES(90,1,1,'THUONG_TRU','2026-01-02','2026-01-01');","23514"),("S19","INSERT INTO bien_dong_cu_tru(ma_bien_dong,loai_bien_dong,ngay_bien_dong,ma_tai_khoan) VALUES(90,'CHUYEN_NOI_BO','2026-11-15',1);","23514")]:
        result=h.psql("BEGIN;"+statement+"ROLLBACK;",db)
        compare(f"tiny/{key}/SQLSTATE",[{"failed":result.returncode!=0,"states":re.findall(r"ERROR:\s+(\w{5}):",result.stderr)}],[{"failed":True,"states":[state]}])
    compare("tiny/negative-tests-clean",[h.snapshot(db)],[before])
    db="w1_seed"
    run((ROOT/"sql/03_seed.sql").read_text(),db)
    for key, query in sql.items(): compare(f"seed/reload/{key}",rows(query,db),results[db][key])
    for table,key in TABLES.items():
        maximum=max(r[key] for r in data[table])
        compare(f"sequence/{table}",rows(f"SELECT nextval(pg_get_serial_sequence('{table}','{key}')) AS n",db),[{"n":maximum+1}])
        run(f"SELECT setval(pg_get_serial_sequence('{table}','{key}'),{maximum});",db)
    input_files=["scripts/generate_data.py","scripts/verify_week1_runtime.py","sql/01_schema.sql","sql/03_seed.sql","sql/04_queries.sql","sql/05_security.sql","sql/06_validation.sql","tests/week1_fixture.sql","tests/week1_expected.json"]
    summary={"passed":sum(r["status"]=="PASS" for r in h.RESULTS),"failed":sum(r["status"]=="FAIL" for r in h.RESULTS),"reproductions":sum(r["kind"]=="reproduction" for r in h.RESULTS)}
    report={"client_date":args.client_date,"recorded_at":datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).isoformat(),"postgres_version":run("SELECT version();"),"python":sys.version.split()[0],"scope":"week1 technical handoff; not final project acceptance or personal machine certification","git_head":subprocess.check_output(["git","rev-parse","HEAD"],text=True).strip(),"files_sha256":{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in input_files},"query_sha256":{k:hashlib.sha256(v.encode()).hexdigest() for k,v in (sql|ra).items()},"summary":summary,"checks":h.RESULTS}
    (ROOT/"tests/week1_execution_results.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8",newline="\n")
    print(json.dumps(summary))
    return bool(summary["failed"])


if __name__=="__main__": raise SystemExit(main())
