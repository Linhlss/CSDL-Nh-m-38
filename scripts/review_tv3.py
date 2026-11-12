#!/usr/bin/env python3
"""Reproduce TV3 review in a DISPOSABLE, labelled PostgreSQL Docker container.

Standard library only. Never connect to a host/user database. Creates four
review databases inside the specified container; run once per fresh container.
SQL comes from TV3's document/fixture and main's validation, not copied queries.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import platform
import re
import subprocess
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[1]
SOURCE = "7abe4d54f7e7cc96ac086b7e1127073493152e24"
RESULTS = []


def command(args, **kwargs):
    return subprocess.run(args, text=True, capture_output=True, **kwargs)


def psql(sql, db="postgres", role="postgres", direct=False, stop=True):
    args = ["docker", "exec", "-i", OPTIONS.container, "psql", "-X", "-qAt",
            "-v", "VERBOSITY=verbose", "-U", role, "-d", db]
    if stop:
        args += ["-v", "ON_ERROR_STOP=1"]
    if direct:
        args += ["-h", "127.0.0.1"]
    return command(args, input=sql, timeout=90)


def run(sql, db="postgres", **kwargs):
    result = psql(sql, db, **kwargs)
    if result.returncode:
        raise RuntimeError(result.stderr)
    return result.stdout.strip()


def rows(sql, db, setup="", **kwargs):
    query = sql.strip().rstrip(";")
    wrapped = f"SELECT COALESCE(json_agg(row_to_json(t)), '[]'::json) FROM ({query}) t;"
    if setup:
        wrapped = f"BEGIN;\n{setup}\n{wrapped}\nROLLBACK;"
    return json.loads(run(wrapped, db, **kwargs))


def compare(test, actual, expected, kind="verification"):
    key = lambda x: json.dumps(x, ensure_ascii=False, sort_keys=True)
    passed = sorted(actual, key=key) == sorted(expected, key=key)
    RESULTS.append({"test": test, "kind": kind, "status": "PASS" if passed else "FAIL",
                    "expected": expected, "actual": actual})
    print(f"{RESULTS[-1]['status']}: {test}", flush=True)


def clean(sql):
    return re.sub(r"--[^\n]*", "", sql).strip().rstrip(";")


def read(path):
    return path.read_text(encoding="utf-8")


def validation(name):
    fragment = read(ROOT / "sql/06_validation.sql").split(f"-- {name}:", 1)[1]
    return re.search(r"SELECT\b.*?;", fragment, re.S).group()


def data(fixture):
    return fixture.split("-- ----- DỮ LIỆU THỬ -----", 1)[1].split("-- ----- Q_d", 1)[0]


def security(db, suffix):
    result = psql(SECURITY, db, stop=False)
    states = re.findall(r"ERROR:\s+(\w{5}):", result.stderr)
    compare(f"{suffix}/security-script-expected-errors", [states], [["42501"] * 6])
    if result.returncode:
        raise RuntimeError(result.stderr)


NAMES = {1: "Nguyen Van An", 2: "Tran Thi Binh", 3: "Le Thi Chi", 4: "Pham Van Dung",
         5: "Hoang Van Em", 6: "Vu Van Phuc", 7: "Do Thi Giang", 8: "Bui Thi Ha",
         9: "Ngo Van Khoa", 10: "Nguyen Van An", 11: "Bien tuoi dung ngay",
         12: "Bien tuoi ngay sau", 13: "Da ket thuc hom qua", 14: "Bat dau ngay mai",
         15: "Hai to dong thoi", 17: "Hai loai trong qua khu"}


def people(ids):
    return [{"ma_cu_dan": i, "ho_ten": NAMES[i]} for i in ids]


EXPECTED = {
    "QRA01": people([1, 7, 9, 10]), "QRA02": people([2]),
    "QRA03": [dict(people([1])[0], ngay_sinh="1950-01-01")],
    "QRA04": people([4, 9]),
    "QRA05": [{"ma_dia_chi": 5, "dia_chi_chuan": "So 5 ngo B (chua co ho)"}],
    "QRA06": people([6]), "QRA07": people([4]),
    "QRA08": [{"ma_cu_dan": i} for i in [1, 2, 3, 7, 9, 10]],
    "QRA09": people([5]), "QRA10": people([4])}

EDGE = """
INSERT INTO to_dan_pho(ma_to, ten_to) VALUES(4,'Tổ 04');
INSERT INTO cu_dan(ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh) VALUES
 (11,'Bien tuoi dung ngay','1966-11-20','Nam'),
 (12,'Bien tuoi ngay sau','1966-11-21','Nu'),
 (13,'Da ket thuc hom qua','1940-01-01','Nam'),
 (14,'Bat dau ngay mai','1940-01-01','Nu'),
 (15,'Hai to dong thoi','1990-01-01','Nam'),
 (17,'Hai loai trong qua khu','1970-01-01','Nu');
INSERT INTO qua_trinh_cu_tru VALUES
 (13,11,1,'THUONG_TRU','2026-11-20','2026-11-20'),
 (14,12,1,'THUONG_TRU','2026-11-20',NULL),
 (15,13,1,'THUONG_TRU','2010-01-01','2026-11-19'),
 (16,14,1,'THUONG_TRU','2026-11-21',NULL),
 (17,15,1,'THUONG_TRU','2015-01-01',NULL),
 (18,15,3,'TAM_TRU','2026-11-20',NULL),
 (19,12,1,'TAM_TRU','2026-11-20',NULL),
 (20,17,1,'THUONG_TRU','2010-01-01','2019-12-31'),
 (21,17,3,'TAM_TRU','2020-01-01','2021-12-31');
"""


def snapshot(db):
    tables = ["to_dan_pho", "dia_chi", "ho_cu_tru", "cu_dan", "qua_trinh_cu_tru",
              "tai_khoan", "bien_dong_cu_tru"]
    return {table: rows(f"SELECT * FROM {table} ORDER BY 1", db) for table in tables}


def denied(label, statement, db, role, direct=False):
    prefix = "" if direct else f"SET ROLE {role};"
    result = psql(f"{prefix} SELECT current_user; {statement}", db, role=role if direct else "postgres", direct=direct)
    compare(label, [{"role": result.stdout.strip(), "denied": result.returncode != 0,
                     "sqlstate": re.findall(r"ERROR:\s+(\w{5}):", result.stderr)}],
            [{"role": role, "denied": True, "sqlstate": ["42501"]}])


def guard_state(db):
    """Hash complete data + relevant catalog state, without advancing sequences."""
    state = snapshot(db)
    state["roles"] = rows("SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolreplication, rolbypassrls, rolcanlogin, rolinherit, rolconfig FROM pg_roles WHERE rolname LIKE 'csdl17_%' OR rolname LIKE 'review_%' ORDER BY rolname", db)
    state["memberships"] = rows("SELECT * FROM pg_auth_members ORDER BY roleid, member, grantor", db)
    state["database"] = rows("SELECT datdba, datacl::text FROM pg_database WHERE datname=current_database()", db)
    state["schema"] = rows("SELECT nspowner, nspacl::text FROM pg_namespace WHERE nspname='public'", db)
    state["relations"] = rows("SELECT c.relname, c.relkind, c.relowner, c.relacl::text FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' ORDER BY c.relname", db)
    state["views"] = rows("SELECT viewname, definition FROM pg_views WHERE schemaname='public' ORDER BY viewname", db)
    for seq in rows("SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='S' ORDER BY c.relname", db):
        name = seq["relname"].replace('"', '""')
        state["sequence/" + name] = rows(f'SELECT last_value, is_called FROM public."{name}"', db)
    return hashlib.sha256(json.dumps(state,sort_keys=True,ensure_ascii=False).encode()).hexdigest()


def guard_rejected(db, label, category):
    before = guard_state(db)
    result = psql(SECURITY, db, stop=False)
    compare(f"guard/{label}/stopped", [{"failed":result.returncode != 0,
        "states":re.findall(r"ERROR:\s+(\w{5}):",result.stderr),
        "preflight": "CSDL17_PREFLIGHT" in result.stderr,
        "reason": category in result.stderr, "demo_output":bool(result.stdout.strip())}],
        [{"failed":True,"states":["42501"],"preflight":True,"reason":True,"demo_output":False}])
    compare(f"guard/{label}/unchanged", [guard_state(db)], [before])


def guard_tests(schema, fixture):
    db = "review_guard"
    run(f"CREATE DATABASE {db};")
    run(schema, db)
    run(data(fixture), db)
    security(db, "guard/safe-existing")
    # Each attribute is tested independently on EACH of the three demo roles.
    for role in ("csdl17_admin","csdl17_reader","csdl17_report"):
        for bad, good in (("SUPERUSER","NOSUPERUSER"),("CREATEDB","NOCREATEDB"),
                          ("CREATEROLE","NOCREATEROLE"),("REPLICATION","NOREPLICATION"),
                          ("BYPASSRLS","NOBYPASSRLS"),("NOLOGIN","LOGIN")):
            run(f"ALTER ROLE {role} {bad};", db)
            try:
                guard_rejected(db, f"{role}/{bad}", "attributes")
            finally:
                run(f"ALTER ROLE {role} {good};", db)
    for label, setup, cleanup in [
        ("database-owner",f"ALTER DATABASE {db} OWNER TO csdl17_admin;",f"ALTER DATABASE {db} OWNER TO postgres;"),
        ("schema-owner","ALTER SCHEMA public OWNER TO csdl17_reader;","ALTER SCHEMA public OWNER TO pg_database_owner;"),
        ("table-owner","ALTER TABLE cu_dan OWNER TO csdl17_reader;","ALTER TABLE cu_dan OWNER TO postgres;"),
        ("view-owner","ALTER VIEW vw_thong_ke_cu_dan_theo_to OWNER TO csdl17_report;","ALTER VIEW vw_thong_ke_cu_dan_theo_to OWNER TO postgres;"),
        ("sequence-owner","CREATE SEQUENCE public.review_owned_seq; ALTER SEQUENCE public.review_owned_seq OWNER TO csdl17_report;","DROP SEQUENCE public.review_owned_seq;")]:
        run(setup, db)
        try:
            guard_rejected(db, label, "ownership")
        finally:
            run(cleanup, db)
    run("CREATE ROLE review_guard_parent;", db)
    for label, options in [("inherit-parent","INHERIT TRUE, SET FALSE"),("set-parent-noinherit","INHERIT FALSE, SET TRUE")]:
        run(f"GRANT review_guard_parent TO csdl17_reader WITH {options};", db)
        try:
            guard_rejected(db, label, "membership")
        finally:
            run("REVOKE review_guard_parent FROM csdl17_reader;", db)
    # A bad existing reader is checked before the other missing roles are created.
    run("ALTER ROLE csdl17_admin RENAME TO review_renamed_admin; ALTER ROLE csdl17_report RENAME TO review_renamed_report; ALTER ROLE csdl17_reader NOLOGIN;", db)
    try:
        guard_rejected(db, "before-creating-missing-roles", "attributes")
    finally:
        run("ALTER ROLE review_renamed_admin RENAME TO csdl17_admin; ALTER ROLE review_renamed_report RENAME TO csdl17_report; ALTER ROLE csdl17_reader LOGIN;", db)
    # Receiving a demo role is allowed; being a member of a parent role is not.
    run(f"CREATE ROLE review_installer LOGIN; GRANT csdl17_reader TO review_installer; GRANT CONNECT ON DATABASE {db} TO review_installer;", db)
    security(db, "guard/reverse-membership-allowed")
    compare("guard/installer-can-set-demo-role", rows("SELECT current_user, session_user",db,
            role="review_installer",direct=True,setup="SET ROLE csdl17_reader;"),
            [{"current_user":"csdl17_reader","session_user":"review_installer"}])
    # An error LATER in setup must roll back prior CREATE VIEW / REVOKE changes.
    run("GRANT UPDATE ON cu_dan TO csdl17_reader; CREATE OR REPLACE VIEW vw_thong_ke_cu_dan_theo_to AS SELECT ma_to,ten_to,-1::bigint AS so_cu_dan FROM to_dan_pho;", db)
    before = guard_state(db)
    injected = SECURITY.replace("\nCOMMIT;", "\nSELECT 1/0;\nCOMMIT;", 1)
    if injected == SECURITY:
        raise RuntimeError("Could not inject setup rollback test before COMMIT")
    result = psql(injected, db, stop=False)
    compare("guard/setup-error-stops-before-demo", [{"failed":result.returncode != 0,
        "states":re.findall(r"ERROR:\s+(\w{5}):",result.stderr)}],
        [{"failed":True,"states":["22012"]}])
    compare("guard/setup-error-rolls-back-all-state", [guard_state(db)], [before])
    run("REVOKE UPDATE ON cu_dan FROM csdl17_reader;", db)
    security(db, "guard/after-negative-cases")


def main():
    global OPTIONS, SECURITY
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--container", required=True)
    parser.add_argument("--tv3-root", type=Path, required=True)
    OPTIONS = parser.parse_args()
    label = command(["docker", "inspect", "--format", '{{index .Config.Labels "csdl17.review"}}', OPTIONS.container])
    if label.returncode or label.stdout.strip() != "tv3":
        raise SystemExit("Refusing container without label csdl17.review=tv3")
    tv3 = OPTIONS.tv3_root.resolve()
    SECURITY = read(tv3 / "sql/05_security.sql")
    fixture = read(tv3 / "tests/ra_fixture.sql")
    original = command(["git", "-C", str(tv3), "show", f"{SOURCE}:tests/ra_fixture.sql"])
    if original.returncode:
        raise SystemExit(original.stderr)
    ra = read(tv3 / "docs/06a_dai_so_quan_he.md")
    blocks = re.findall(r"```sql\n(.*?)```", ra, re.S)
    if len(blocks) != 11:
        raise SystemExit("Expected Q_d and ten SQL counterparts in RA document")
    queries = {f"QRA{i:02}": clean(sql) for i, sql in enumerate(blocks[1:], 1)}
    v = {name: validation(name) for name in ("V_E1_CU", "V_E1_MOI", "V_B09")}
    schema = read(ROOT / "sql/01_schema.sql")
    for db, source in [("review_original", original.stdout), ("review_fixed", fixture)]:
        run(f"CREATE DATABASE {db};")
        run(schema, db)
        run(data(source), db)
        security(db, db)
    compare("original/B09-reproduced", [{"count": len(rows(v["V_B09"], "review_original"))}], [{"count": 1}], "reproduction")
    db = "review_fixed"
    for name, sql in v.items():
        compare(f"fixed/{name}/clean", rows(sql, db), [])
    for name, sql in queries.items():
        compare(f"core/{name}/full-rows", rows(sql, db), EXPECTED[name])
        # Check the actual fixture copy too, guarding document/fixture divergence.
        fragment = fixture.split(f"-- ----- {name} ·", 1)[1].split("-- -----", 1)[0]
        fragment = "\n".join(line for line in fragment.splitlines()[1:] if not line.startswith("\\"))
        compare(f"fixture/{name}/full-rows", rows(clean(fragment), db), EXPECTED[name])
    qd = rows(clean(blocks[0]), db)
    qd_expected = [dict(zip(["ma_qua_trinh", "ma_cu_dan", "ma_ho", "loai_cu_tru", "ngay_bat_dau"], row)) for row in [
        (1,1,1,"THUONG_TRU","2010-01-01"), (2,2,3,"TAM_TRU","2024-03-01"),
        (3,3,3,"THUONG_TRU","2008-01-01"), (5,4,4,"TAM_TRU","2021-01-01"),
        (8,7,1,"THUONG_TRU","2016-01-01"), (11,9,2,"THUONG_TRU","2022-06-01"), (12,10,2,"TAM_TRU","2023-01-01")]]
    compare("core/Q_d/full-rows", qd, qd_expected)
    view_expected = [{"ma_to": i, "ten_to": f"Tổ {i:02}", "so_cu_dan": count} for i, count in [(1,4),(2,2),(3,1)]]
    compare("core/VIEW/full-rows", rows("SELECT * FROM vw_thong_ke_cu_dan_theo_to", db), view_expected)
    before = snapshot(db)
    for direct in [False, True]:
        mode = "direct-login" if direct else "set-role"
        identity = rows("SELECT current_user, session_user", db, role="csdl17_reader" if direct else "postgres", direct=direct,
                        setup="" if direct else "SET ROLE csdl17_reader;")
        compare(f"{mode}/reader-identity", identity, [{"current_user":"csdl17_reader", "session_user":"csdl17_reader" if direct else "postgres"}])
        if direct:
            compare(f"{mode}/reader-select", rows("SELECT ma_cu_dan, ho_ten FROM cu_dan WHERE ma_cu_dan=1", db, role="csdl17_reader", direct=True), people([1]))
            compare(f"{mode}/report-view", rows("SELECT * FROM vw_thong_ke_cu_dan_theo_to", db, role="csdl17_report", direct=True), view_expected)
        else:
            compare(f"{mode}/reader-select", rows("SELECT ma_cu_dan, ho_ten FROM cu_dan WHERE ma_cu_dan=1", db, setup="SET ROLE csdl17_reader;"), people([1]))
            compare(f"{mode}/report-view", rows("SELECT * FROM vw_thong_ke_cu_dan_theo_to", db, setup="SET ROLE csdl17_report;"), view_expected)
        for label, stmt, role in [
            ("reader-update", "UPDATE cu_dan SET ghi_chu='forbidden' WHERE ma_cu_dan=1;", "csdl17_reader"),
            ("reader-insert", "INSERT INTO to_dan_pho(ten_to) VALUES('forbidden');", "csdl17_reader"),
            ("reader-delete", "DELETE FROM qua_trinh_cu_tru WHERE ma_qua_trinh=1;", "csdl17_reader"),
            ("reader-account", "SELECT * FROM tai_khoan;", "csdl17_reader"),
            ("report-residents", "SELECT * FROM cu_dan;", "csdl17_report"),
            ("report-episodes", "SELECT * FROM qua_trinh_cu_tru;", "csdl17_report")]:
            denied(f"{mode}/{label}", stmt, db, role, direct)
    compare("security/no-data-changes", [snapshot(db)], [before])
    compare("security/admin-update-rollback", rows("SELECT ghi_chu FROM cu_dan WHERE ma_cu_dan=1", db,
            setup="SET ROLE csdl17_admin; UPDATE cu_dan SET ghi_chu='admin-test' WHERE ma_cu_dan=1;"), [{"ghi_chu":"admin-test"}])
    compare("security/admin-rollback-clean", [snapshot(db)], [before])
    security(db, "rerun")
    compare("security/rerun-no-data-changes", [snapshot(db)], [before])
    roles = rows("SELECT rolname, rolsuper, rolcreatedb, rolcreaterole FROM pg_roles WHERE rolname IN ('csdl17_admin','csdl17_reader','csdl17_report')", db)
    compare("security/role-attributes", roles, [{"rolname": name, "rolsuper":False,"rolcreatedb":False,"rolcreaterole":False} for name in ["csdl17_admin","csdl17_reader","csdl17_report"]])
    compare("security/not-table-owner", rows("SELECT tablename FROM pg_tables WHERE schemaname='public' AND tableowner LIKE 'csdl17_%'", db), [])
    # Edge dataset stays separate from TV2's official seed.
    run(EDGE, db)
    extended = dict(EXPECTED)
    extended.update({"QRA01":people([1,7,9,10,11,12,15]), "QRA02":people([2,15]),
        "QRA03":[dict(people([1])[0],ngay_sinh="1950-01-01"),dict(people([11])[0],ngay_sinh="1966-11-20")],
        "QRA04":people([4,9,15,17]), "QRA07":people([4,12,15,17]),
        "QRA08":[{"ma_cu_dan":i} for i in [1,2,3,7,9,10,11,12,15]], "QRA09":people([5,13,17])})
    for name, sql in queries.items():
        compare(f"edge/{name}/full-rows", rows(sql, db), extended[name])
    view_edge = [{"ma_to": i,"ten_to":f"Tổ {i:02}","so_cu_dan":c} for i,c in [(1,7),(2,3),(3,1),(4,0)]]
    compare("edge/VIEW/zero-and-distinct", rows("SELECT * FROM vw_thong_ke_cu_dan_theo_to", db, role="csdl17_report", direct=True), view_edge)
    for key in ("V_E1_CU", "V_E1_MOI", "V_B09"):
        compare(f"edge/{key}/clean", rows(v[key], db), [])
    duplicate = "INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan) VALUES "
    for role, key, values, episode in [("CU","V_E1_CU","('CHUYEN_DI',6,NULL,'2025-07-01',1);",6),
                                       ("MOI","V_E1_MOI","('CHUYEN_DEN',NULL,2,'2024-03-01',1);",2)]:
        setup = duplicate + values
        actual = rows(v[key], db, setup=setup)
        compare(f"E1/{role}/duplicate-found", [{k:r[k] for k in ("ma_qua_trinh","vai_tro","so_lan")} for r in actual], [{"ma_qua_trinh":episode,"vai_tro":role,"so_lan":2}])
        expected_ids = rows("SELECT ma_bien_dong FROM bien_dong_cu_tru WHERE " + ("ma_qua_trinh_cu" if role=="CU" else "ma_qua_trinh_moi") + f"={episode}", db)
        compare(f"E1/{role}/all-event-ids", [len(actual[0]["cac_ma_bien_dong"])==2 and expected_ids[0]["ma_bien_dong"] in actual[0]["cac_ma_bien_dong"]], [True])
        opposite = "V_E1_MOI" if role == "CU" else "V_E1_CU"
        compare(f"E1/{role}/nulls-not-grouped", rows(v[opposite], db, setup=setup), [])
    both_roles = duplicate + "('CHUYEN_DEN',NULL,6,'2018-01-01',1);"
    for key in v:
        compare(f"E1/both-roles-valid/{key}", rows(v[key], db, setup=both_roles), [])
    for label, setup in [
        ("old-date", "UPDATE bien_dong_cu_tru SET ngay_bien_dong='2025-06-30' WHERE ma_qua_trinh_cu=6;"),
        ("old-null", "UPDATE qua_trinh_cu_tru SET ngay_ket_thuc=NULL WHERE ma_qua_trinh=6;"),
        ("new-date", "UPDATE bien_dong_cu_tru SET ngay_bien_dong='2024-03-02' WHERE loai_bien_dong='CHUYEN_DEN';"),
        ("internal-old", "UPDATE qua_trinh_cu_tru SET ngay_ket_thuc='2020-12-30' WHERE ma_qua_trinh=4;"),
        ("internal-new", "UPDATE qua_trinh_cu_tru SET ngay_bat_dau='2021-01-02' WHERE ma_qua_trinh=5;")]:
        compare(f"B09/{label}/found", [len(rows(v["V_B09"], db, setup=setup))], [1])
    compare("QRA10/exclude-different-person", rows(queries["QRA10"], db, setup=duplicate+"('CHUYEN_NOI_BO',1,2,'2024-03-01',1);"), EXPECTED["QRA10"])
    for key in v:
        compare(f"after-negative-tests/{key}/clean", rows(v[key], db), [])
    # Replay the exact corrected psql fixture on empty tables, including its ROLLBACK.
    run("CREATE DATABASE review_fixture;")
    run(schema, "review_fixture")
    security("review_fixture", "empty-db")
    run(fixture, "review_fixture")
    compare("fixture/rollback-empty", [{t:len(r) for t,r in snapshot("review_fixture").items()}], [{t:0 for t in before}])
    guard_tests(schema, fixture)
    compare("RISK/fixture-no-result-assertions", [bool(re.search(r"\bASSERT\b|RAISE EXCEPTION|\\if", fixture))], [False], "reproduction")
    result = {"recorded_at":datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).isoformat(),
        "source_tv3_commit":SOURCE, "tv3_worktree_head":command(["git","-C",str(tv3),"rev-parse","HEAD"]).stdout.strip(),
        "scope":"pre-merge regression: fixed fixture, strict setup and existing-role rejection",
        "postgres_version":run("SELECT version();"), "python":platform.python_version(),
        "image":command(["docker","inspect","--format","{{.Image}}",OPTIONS.container]).stdout.strip(),
        "image_digest":command(["docker","image","inspect","--format","{{json .RepoDigests}}","postgres:17.11"]).stdout.strip(),
        "direct_login_auth":"TCP 127.0.0.1 inside isolated container; trust auth, authorization tested; no password authentication claim",
        "files_sha256":{str(path.relative_to(root)):hashlib.sha256(path.read_bytes()).hexdigest() for root,path in [
            (ROOT,ROOT/"sql/01_schema.sql"),(ROOT,ROOT/"sql/06_validation.sql"),(ROOT,Path(__file__).resolve()),
            (tv3,tv3/"sql/05_security.sql"),(tv3,tv3/"tests/ra_fixture.sql"),(tv3,tv3/"docs/06a_dai_so_quan_he.md")]},
        "summary":{"passed":sum(x["status"]=="PASS" for x in RESULTS),"failed":sum(x["status"]=="FAIL" for x in RESULTS),
                   "reproductions":sum(x["kind"]=="reproduction" for x in RESULTS)}, "checks":RESULTS}
    (ROOT/"tests/tv3_review_results.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(result["summary"]))
    return bool(result["summary"]["failed"])


if __name__ == "__main__":
    raise SystemExit(main())
