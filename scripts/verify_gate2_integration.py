"""Gate 2: đối soát RA, SQL, VIEW và quyền trên hai CSDL PostgreSQL sạch.

Chạy sau khi tạo DB seed636 và DB fixture, nạp schema/constraints/security.
Script tự nạp fixture RA vào DB fixture sau khi ra_fixture.sql đã ROLLBACK.
"""
from __future__ import annotations
import argparse, json, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/"scripts"))
from ra_sql_blocks import from_repo

SEED_COUNTS = {
    "QRA01":34,"QRA02":10,"QRA03":2,"QRA04":54,"QRA05":4,
    "QRA06":8,"QRA07":31,"QRA08":61,"QRA09":17,"QRA10":22,
}
TINY_IDS = {
    "QRA01":[1,7,9,10],"QRA02":[2],"QRA03":[1],"QRA04":[4,9],
    "QRA05":[5],"QRA06":[6],"QRA07":[4],
    "QRA08":[1,2,3,7,9,10],"QRA09":[5],"QRA10":[4],
}
SEED_SAMPLE_IDS = {
    "QRA02":[7,8,32,42,62,77,88,162,178,190],
    "QRA03":[1,2],
    "QRA06":[25,26,27,196,197,198,199,200],
}
PAIRINGS = {
    "QRA01":"QSQL01","QRA04":"QSQL05","QRA05":"QSQL04",
    "QRA07":"QSQL06","QRA09":"QSQL07","QRA10":"QSQL09",
}
PASSED = 0

def psql(database: str, statement: str, *, ok: bool = True):
    cmd=["psql","-X","-v","ON_ERROR_STOP=1","-q","-A","-t","-d",database,"-c",statement]
    p=subprocess.run(cmd,capture_output=True,text=True,encoding="utf-8")
    if ok and p.returncode:
        raise AssertionError(f"psql failed on {database}: {p.stderr}\n{statement[:250]}")
    return p

def rows(database: str, query: str, *, role: str | None=None) -> list[dict]:
    q=query.strip().rstrip(";")
    prefix=f"SET ROLE {role}; " if role else ""
    p=psql(database,prefix+f"SELECT row_to_json(_row_) FROM ({q}) _row_;")
    return [json.loads(line) for line in p.stdout.splitlines() if line.strip()]

def canonical(records):
    return sorted(json.dumps(r,sort_keys=True,ensure_ascii=False) for r in records)

def assert_equal(name,actual,expected):
    global PASSED
    if canonical(actual)!=canonical(expected):
        raise AssertionError(f"{name}: mismatch:\nACTUAL={actual[:6]}\nEXPECTED={expected[:6]}")
    PASSED+=1
    print(f"PASS {name}")

def assert_pred(name,condition,detail=""):
    global PASSED
    if not condition:raise AssertionError(f"{name}: {detail}")
    PASSED+=1
    print(f"PASS {name}")

def ids(name,values):
    field="ma_dia_chi" if name=="QRA05" else "ma_cu_dan"
    return sorted(r[field] for r in values)

def check_data(database,ra,sql,seed):
    global PASSED
    result={name:rows(database,statement) for name,statement in ra.items()}
    for name in SEED_COUNTS:
        expected=SEED_COUNTS[name] if seed else len(TINY_IDS[name])
        assert_pred(f"{database}/{name}/count",len(result[name])==expected,
                    f"{len(result[name])} != {expected}")
        if not seed:
            assert_pred(f"{database}/{name}/hand-ids",
                        ids(name,result[name])==TINY_IDS[name])
        elif name in SEED_SAMPLE_IDS:
            assert_pred(f"{database}/{name}/seed-ids",
                        ids(name,result[name])==SEED_SAMPLE_IDS[name])
    assert_equal(f"{database}/QRA07_DIV=QRA07",
                 result["QRA07_DIV"],result["QRA07"])
    # SQL TV2: toàn bộ 10 câu phải chạy, 6 cặp được đối soát độc lập.
    results={name:rows(database,statement) for name,statement in sql.items()}
    assert_pred(f"{database}/QSQL-number",len(results)==10)
    for rak,sqk in PAIRINGS.items():
        field="ma_dia_chi" if rak=="QRA05" else "ma_cu_dan"
        projected_ra={r[field] for r in result[rak]}
        projected_sql={r[field] for r in results[sqk]}
        assert_pred(f"{database}/{rak}-vs-{sqk}",
                    projected_ra==projected_sql,
                    f"RA={len(projected_ra)}, SQL={len(projected_sql)}")
    assert_equal(f"{database}/VIEW-vs-QSQL03",
                 rows(database,"SELECT * FROM vw_thong_ke_cu_dan_theo_to",
                      role="csdl17_report"),results["QSQL03"])
    return result

def fixture_data():
    text=(ROOT/"tests/ra_fixture.sql").read_text(encoding="utf-8")
    return text.split("-- ----- DỮ LIỆU THỬ -----",1)[1].split("-- ----- Q_d",1)[0]

def get_qsql():
    text=(ROOT/"sql/04_queries.sql").read_text(encoding="utf-8")
    parts=re.split(r"^-- (QSQL\d{2})\.[^\n]*\n",text,flags=re.M)
    named={parts[i]:parts[i+1].strip() for i in range(1,len(parts),2)}
    if list(named)!=[f"QSQL{i:02}" for i in range(1,11)]:
        raise AssertionError(f"Unexpected SQL labels: {list(named)}")
    return named

def expect_permission_denied(database,role,sql):
    p=psql(database,f"SET ROLE {role}; {sql}",ok=False)
    assert_pred(f"{database}/{role}/denied-{sql.split()[0]}",
                p.returncode!=0 and "permission denied" in p.stderr.lower(),
                p.stderr[:300])

def security(database):
    for role in ("csdl17_reader","csdl17_report"):
        identity=rows(database,"SELECT current_user AS name",role=role)
        assert_equal(f"{database}/{role}/identity",identity,[{"name":role}])
    assert_pred(f"{database}/reader-select-allowed",
        len(rows(database,"SELECT ma_cu_dan FROM cu_dan LIMIT 1",
                 role="csdl17_reader"))==1)
    assert_pred(f"{database}/report-view-allowed",
        len(rows(database,"SELECT * FROM vw_thong_ke_cu_dan_theo_to",
                 role="csdl17_report"))>0)
    expect_permission_denied(database,"csdl17_reader",
       "UPDATE cu_dan SET ghi_chu='forbidden' WHERE ma_cu_dan=1;")
    expect_permission_denied(database,"csdl17_reader",
       "SELECT * FROM tai_khoan LIMIT 1;")
    expect_permission_denied(database,"csdl17_report",
       "SELECT * FROM cu_dan LIMIT 1;")
    expect_permission_denied(database,"csdl17_report",
       "SELECT * FROM qua_trinh_cu_tru LIMIT 1;")

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--seed-db",default="postgres")
    parser.add_argument("--fixture-db",default="csdl17_ra_fixture")
    args=parser.parse_args()
    ra=from_repo(ROOT)
    if len(ra)!=12:
        raise AssertionError("Gate2 requires PR5 variant QRA07_DIV")
    sql=get_qsql()
    counts=rows(args.seed_db,"""
      SELECT (SELECT COUNT(*) FROM to_dan_pho) AS to_dan_pho,
             (SELECT COUNT(*) FROM dia_chi) AS dia_chi,
             (SELECT COUNT(*) FROM ho_cu_tru) AS ho_cu_tru,
             (SELECT COUNT(*) FROM cu_dan) AS cu_dan,
             (SELECT COUNT(*) FROM qua_trinh_cu_tru) AS qua_trinh_cu_tru,
             (SELECT COUNT(*) FROM bien_dong_cu_tru) AS bien_dong_cu_tru,
             (SELECT COUNT(*) FROM tai_khoan) AS tai_khoan
    """)[0]
    assert_equal("seed636/table-counts",[counts],[{
      "to_dan_pho":8,"dia_chi":50,"ho_cu_tru":60,"cu_dan":200,
      "qua_trinh_cu_tru":250,"bien_dong_cu_tru":63,"tai_khoan":5
    }])
    check_data(args.seed_db,ra,sql,True)
    security(args.seed_db)

    # RA fixture has already run and rolled back, so this is a clean DB.
    before=rows(args.fixture_db,"SELECT COUNT(*) AS n FROM cu_dan")
    assert_equal("fixture/clean-after-ROLLBACK",before,[{"n":0}])
    psql(args.fixture_db,fixture_data())
    check_data(args.fixture_db,ra,sql,False)
    security(args.fixture_db)
    # S14b: bổ sung một đợt KHÁC LOẠI ở cùng hộ, cùng ngày hiệu lực
    # trong transaction ROLLBACK. Fixture gốc không có ca này.
    before=rows(args.fixture_db,"SELECT COUNT(*) AS n FROM qua_trinh_cu_tru")
    statement="""
    BEGIN;
    INSERT INTO qua_trinh_cu_tru(ma_qua_trinh,ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau)
    VALUES (99090,1,1,'TAM_TRU',DATE '2026-01-01');
    SELECT row_to_json(x) FROM (
       SELECT q.ma_ho, COUNT(*) AS n_dot, COUNT(DISTINCT q.ma_cu_dan) AS n_nguoi
       FROM qua_trinh_cu_tru q
       WHERE q.ngay_bat_dau <= DATE '2026-11-20'
         AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
       GROUP BY q.ma_ho
       HAVING COUNT(*) > COUNT(DISTINCT q.ma_cu_dan)
    ) x;
    ROLLBACK;
    """
    p=psql(args.fixture_db,statement)
    duplicates=[json.loads(line) for line in p.stdout.splitlines() if line.strip()]
    assert_pred("fixture/S14b-count-distinct-counterexample",
                any(row["n_dot"]>row["n_nguoi"] for row in duplicates))
    assert_equal("fixture/S14b-rollback-clean",
                 rows(args.fixture_db,"SELECT COUNT(*) AS n FROM qua_trinh_cu_tru"),before)
    print(f"RESULT: {PASSED} checks PASS (2 DB, 10 QRA + division, 10 QSQL, roles, VIEW)")

if __name__=="__main__":
    main()
