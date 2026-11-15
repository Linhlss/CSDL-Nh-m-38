#!/usr/bin/env python3
"""Sinh dữ liệu giả lập nhất quán cho BTL CSDL Đề tài 17 (TV2).

- Seed cố định: 20261110 (tái lập 100%).
- Quy mô mục tiêu: 8 tổ, 50 địa chỉ, 60 hộ, 200 cư dân, ~250 đợt cư trú, ~70 biến động, 5 tài khoản.
- Bao phủ đầy đủ kịch bản S01–S16 và các ca biên đối soát TV1/TV3 (tổ 0 người, tài khoản 0 sự kiện,
  đợt tương lai, hai đợt cùng hộ, trùng họ tên, nội bộ cùng tổ/khác tổ, ngày cắt tuổi 60).
- Tự kiểm tra toàn bộ quy tắc DQ01–DQ10, B06 (không chồng lấn cùng người + cùng loại),
  E1 (không trùng vai trò cũ/mới) và B09 (ngày chuyển t: cũ kết thúc t-1, mới bắt đầu t).
- Xuất CSV vào data/generated/ và script INSERT vào sql/03_seed.sql.
"""

from __future__ import annotations

import csv
import random
from datetime import date, timedelta
from pathlib import Path

SEED = 20261110
REF_DATE = date(2026, 11, 20)

ROOT = Path(__file__).resolve().parent.parent
CSV_DIR = ROOT / "data" / "generated"
SEED_SQL_PATH = ROOT / "sql" / "03_seed.sql"

HO_LIST = [
    "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ",
    "Võ", "Đặng", "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý",
]
DEM_NAM = ["Văn", "Hữu", "Đức", "Minh", "Quốc", "Gia", "Tuấn", "Thành", "Công"]
DEM_NU = ["Thị", "Ngọc", "Thanh", "Minh", "Thu", "Phương", "Khánh", "Bảo", "Hồng"]
TEN_NAM = ["An", "Bình", "Cường", "Dũng", "Đạt", "Hải", "Hùng", "Khang", "Khoa", "Long", "Nam", "Phong", "Quân", "Sơn", "Trung", "Tú", "Vinh"]
TEN_NU = ["Anh", "Chi", "Dung", "Hà", "Hạnh", "Hương", "Lan", "Linh", "Mai", "My", "Nga", "Ngân", "Nhung", "Phương", "Quỳnh", "Thảo", "Trang", "Vy"]
STREETS = [
    "Phố Tạ Quang Bửu",
    "Phố Lê Thanh Nghị",
    "Phố Trần Đại Nghĩa",
    "Phố Bạch Mai",
    "Ngõ 40 Tạ Quang Bửu",
    "Ngõ 128 Lê Thanh Nghị",
    "Phố Đại La",
    "Đường Giải Phóng",
]
WARD_NAME = "Phường Bách Khoa, Quận Hai Bà Trưng, Hà Nội"


def sql_str(val: str | None) -> str:
    if val is None:
        return "NULL"
    return "'" + val.replace("'", "''") + "'"


def sql_date(val: date | None) -> str:
    if val is None:
        return "NULL"
    return f"DATE '{val.isoformat()}'"


def sql_int(val: int | None) -> str:
    if val is None:
        return "NULL"
    return str(val)


def intervals_overlap(a_start: date, a_end: date | None, b_start: date, b_end: date | None) -> bool:
    """Kiểm tra hai đoạn [a_start, a_end] và [b_start, b_end] (bao gồm ngày cuối, None = vô hạn) có giao nhau."""
    eff_a_end = a_end if a_end is not None else date(9999, 12, 31)
    eff_b_end = b_end if b_end is not None else date(9999, 12, 31)
    return a_start <= eff_b_end and b_start <= eff_a_end


def main() -> None:
    rng = random.Random(SEED)

    # 1. TO_DAN_PHO (8 tổ; Tổ 08 là tổ 0 người đang cư trú)
    to_dan_pho = []
    for i in range(1, 9):
        note = f"Tổ dân phố số {i} - {WARD_NAME}" if i < 8 else f"Tổ dân phố số 8 - {WARD_NAME} (không có cư dân đang cư trú tại ngày d)"
        to_dan_pho.append({"ma_to": i, "ten_to": f"Tổ {i:02d}", "ghi_chu": note})

    # 2. DIA_CHI (50 địa chỉ; ma_dia_chi 49, 50 là S04: chưa có nhóm hộ)
    dia_chi = []
    for i in range(1, 51):
        if i <= 46:
            ma_to = ((i - 1) % 7) + 1
        elif i <= 48:
            ma_to = 8  # Tổ 08 có địa chỉ nhưng không có hộ/cư dân
        else:
            ma_to = ((i - 1) % 7) + 1  # Địa chỉ 49, 50 thuộc Tổ 7, 1 nhưng không có hộ (S04)
        street = STREETS[(i - 1) % len(STREETS)]
        dia_chi.append({
            "ma_dia_chi": i,
            "ma_to": ma_to,
            "dia_chi_chuan": f"Số {10 + i} {street}, {WARD_NAME}",
            "ghi_chu": "Địa chỉ chưa có hộ (S04)" if i in (49, 50) else None,
        })

    # 3. HO_CU_TRU (60 hộ; gắn vào địa chỉ 1..46; hộ 59, 60 là S05: không có cư dân đang ở tại d)
    ho_cu_tru = []
    for i in range(1, 61):
        ma_dia_chi = ((i - 1) % 46) + 1
        ngay_lap = date(2020, 1, 1) + timedelta(days=rng.randint(0, 1500))
        note = "Hộ không có cư dân đang ở tại d (S05)" if i in (59, 60) else None
        ho_cu_tru.append({
            "ma_ho": i,
            "ma_dia_chi": ma_dia_chi,
            "ngay_lap": ngay_lap,
            "ghi_chu": note,
        })

    # Bản đồ tiện ích: ma_ho -> ma_to
    dc_to_map = {d["ma_dia_chi"]: d["ma_to"] for d in dia_chi}
    ho_to_map = {h["ma_ho"]: dc_to_map[h["ma_dia_chi"]] for h in ho_cu_tru}

    # Chọn hộ theo từng tổ (tổ 1..7)
    ho_by_to: dict[int, list[int]] = {t: [] for t in range(1, 8)}
    for h in ho_cu_tru:
        if h["ma_ho"] in (59, 60):
            continue
        t = ho_to_map[h["ma_ho"]]
        if t in ho_by_to:
            ho_by_to[t].append(h["ma_ho"])

    # Đảm bảo hộ 1 (Tổ 1), hộ 2 (Tổ 2) dùng làm hộ đông người (S14 >= 4)
    # Hộ 3 (Tổ 3) có đúng 3 người (biên < 4)
    # Hộ 4 (Tổ 4) có đúng 1 người (S14)

    # 4. TAI_KHOAN (5 tài khoản; tk 5 không ghi sự kiện nào - QSQL10)
    tai_khoan = [
        {"ma_tai_khoan": 1, "ten_dang_nhap": "admin_demo", "ten_hien_thi": "Quản trị viên Hệ thống", "vai_tro": "QUAN_TRI", "trang_thai": "HOAT_DONG"},
        {"ma_tai_khoan": 2, "ten_dang_nhap": "canbo_01", "ten_hien_thi": "Cán bộ Cư trú 01", "vai_tro": "CAN_BO", "trang_thai": "HOAT_DONG"},
        {"ma_tai_khoan": 3, "ten_dang_nhap": "canbo_02", "ten_hien_thi": "Cán bộ Cư trú 02", "vai_tro": "CAN_BO", "trang_thai": "HOAT_DONG"},
        {"ma_tai_khoan": 4, "ten_dang_nhap": "thongke_01", "ten_hien_thi": "Cán bộ Tổng hợp 01", "vai_tro": "THONG_KE", "trang_thai": "HOAT_DONG"},
        {"ma_tai_khoan": 5, "ten_dang_nhap": "canbo_duphong", "ten_hien_thi": "Cán bộ Dự phòng (0 sự kiện)", "vai_tro": "CAN_BO", "trang_thai": "HOAT_DONG"},
    ]

    # 5. CU_DAN (200 cư dân)
    cu_dan = []
    for i in range(1, 201):
        gioi_tinh = "Nam" if i % 2 == 1 else "Nu"
        if i == 200:
            gioi_tinh = "Khac"
        ho = rng.choice(HO_LIST)
        if gioi_tinh == "Nam":
            ho_ten = f"{ho} {rng.choice(DEM_NAM)} {rng.choice(TEN_NAM)}"
        elif gioi_tinh == "Nu":
            ho_ten = f"{ho} {rng.choice(DEM_NU)} {rng.choice(TEN_NU)}"
        else:
            ho_ten = f"{ho} Minh Anh"
        # Mặc định tuổi từ 18..58
        ngay_sinh = date(1968, 1, 1) + timedelta(days=rng.randint(0, 14000))
        note = None
        cu_dan.append({
            "ma_cu_dan": i,
            "ho_ten": ho_ten,
            "ngay_sinh": ngay_sinh,
            "gioi_tinh": gioi_tinh,
            "ghi_chu": note,
        })

    # Gán ca biên cụ thể cho các cư dân đầu tiên (1..30)
    # S03: đúng ngày cắt 60 tuổi (1966-11-20), trên 60 (1960-05-10), và sát sau ngày cắt (1966-11-21)
    cu_dan[0]["ngay_sinh"] = date(1966, 11, 20)
    cu_dan[0]["ghi_chu"] = "Đúng ngày cắt 60 tuổi tại 2026-11-20 (S03)"
    cu_dan[1]["ngay_sinh"] = date(1960, 5, 10)
    cu_dan[1]["ghi_chu"] = "Trên 60 tuổi tại 2026-11-20 (S03)"
    cu_dan[2]["ngay_sinh"] = date(1966, 11, 21)
    cu_dan[2]["ghi_chu"] = "Sau ngày cắt 1 ngày - chưa đủ 60 tuổi (biên S03)"

    # S16: Hai người trùng họ tên hoàn toàn nhưng khác ma_cu_dan
    cu_dan[3]["ho_ten"] = "Nguyễn Văn An"
    cu_dan[3]["gioi_tinh"] = "Nam"
    cu_dan[3]["ghi_chu"] = "Trùng họ tên với ma_cu_dan 5 (S16)"
    cu_dan[4]["ho_ten"] = "Nguyễn Văn An"
    cu_dan[4]["gioi_tinh"] = "Nam"
    cu_dan[4]["ghi_chu"] = "Trùng họ tên với ma_cu_dan 4 (S16)"

    # 6. QUA_TRINH_CU_TRU & BIEN_DONG_CU_TRU
    qua_trinh: list[dict] = []
    bien_dong: list[dict] = []

    # Theo dõi khoảng thời gian theo (ma_cu_dan, loai_cu_tru) để bảo đảm B06
    used_intervals: dict[tuple[int, str], list[tuple[date, date | None]]] = {}
    used_as_cu: set[int] = set()
    used_as_moi: set[int] = set()

    def add_qt(ma_cu_dan: int, ma_ho: int, loai: str, start: date, end: date | None) -> int:
        assert end is None or end >= start, f"Invalid dates {start}..{end}"
        key = (ma_cu_dan, loai)
        for s, e in used_intervals.get(key, []):
            assert not intervals_overlap(start, end, s, e), f"Overlap B06 for {key}: {start}..{end} vs {s}..{e}"
        used_intervals.setdefault(key, []).append((start, end))
        qt_id = len(qua_trinh) + 1
        qua_trinh.append({
            "ma_qua_trinh": qt_id,
            "ma_cu_dan": ma_cu_dan,
            "ma_ho": ma_ho,
            "loai_cu_tru": loai,
            "ngay_bat_dau": start,
            "ngay_ket_thuc": end,
        })
        return qt_id

    def add_bd(loai_bd: str, qt_cu: int | None, qt_moi: int | None, ngay: date, ma_tk: int, note: str | None = None) -> int:
        assert ma_tk in (1, 2, 3, 4), "TK 5 phải có 0 sự kiện"
        if qt_cu is not None:
            assert qt_cu not in used_as_cu, f"E1_CU violation on qt {qt_cu}"
            used_as_cu.add(qt_cu)
            q_cu_obj = qua_trinh[qt_cu - 1]
            assert q_cu_obj["ngay_ket_thuc"] == ngay - timedelta(days=1), "B09 cu violation"
        if qt_moi is not None:
            assert qt_moi not in used_as_moi, f"E1_MOI violation on qt {qt_moi}"
            used_as_moi.add(qt_moi)
            q_moi_obj = qua_trinh[qt_moi - 1]
            assert q_moi_obj["ngay_bat_dau"] == ngay, "B09 moi violation"
        if qt_cu is not None and qt_moi is not None:
            assert qua_trinh[qt_cu - 1]["ma_cu_dan"] == qua_trinh[qt_moi - 1]["ma_cu_dan"], "Same person violation"
        bd_id = len(bien_dong) + 1
        bien_dong.append({
            "ma_bien_dong": bd_id,
            "loai_bien_dong": loai_bd,
            "ma_qua_trinh_cu": qt_cu,
            "ma_qua_trinh_moi": qt_moi,
            "ngay_bien_dong": ngay,
            "ma_tai_khoan": ma_tk,
            "ghi_chu": note,
        })
        return bd_id

    # --- Lớp 1: Kịch bản bắt buộc S01–S16 & ca biên ---
    # Hộ 1 (Tổ 01): 5 cư dân đang ở tại d (cư dân 1..5 -> thỏa S01, S03, S14 >=4, S16 trùng tên)
    add_qt(1, ho_by_to[1][0], "THUONG_TRU", date(2023, 1, 10), None)
    add_qt(2, ho_by_to[1][0], "THUONG_TRU", date(2023, 3, 15), None)
    add_qt(3, ho_by_to[1][0], "THUONG_TRU", date(2024, 2, 1), None)
    add_qt(4, ho_by_to[1][0], "THUONG_TRU", date(2024, 6, 1), None)
    qt5 = add_qt(5, ho_by_to[1][0], "TAM_TRU", date(2025, 11, 1), None)
    add_bd("CHUYEN_DEN", None, qt5, date(2025, 11, 1), 2, "Chuyển đến tạm trú (S11)")

    # Cư dân 6: ở Tổ 01 có CẢ THUONG_TRU và TAM_TRU hiệu lực tại d (kiểm tra DISTINCT và COUNT DISTINCT người trong Tổ 01)
    add_qt(6, ho_by_to[1][1], "THUONG_TRU", date(2022, 5, 1), None)
    add_qt(6, ho_by_to[1][2], "TAM_TRU", date(2026, 10, 1), None)

    # Cư dân 7, 8, 9, 10: ở Hộ 2 (Tổ 02) — 4 người đang ở (S02 tạm trú Tổ 02, S14 hộ >=4)
    add_qt(7, ho_by_to[2][0], "TAM_TRU", date(2026, 8, 1), None)
    add_qt(8, ho_by_to[2][0], "TAM_TRU", date(2026, 9, 1), None)
    add_qt(9, ho_by_to[2][0], "THUONG_TRU", date(2024, 1, 1), None)
    add_qt(10, ho_by_to[2][0], "THUONG_TRU", date(2024, 1, 1), None)

    # Cư dân 11, 12, 13: ở Hộ 3 (Tổ 03) — đúng 3 người đang ở (biên < 4 cho QSQL02)
    add_qt(11, ho_by_to[3][0], "THUONG_TRU", date(2024, 5, 1), None)
    add_qt(12, ho_by_to[3][0], "THUONG_TRU", date(2024, 5, 1), None)
    add_qt(13, ho_by_to[3][0], "TAM_TRU", date(2026, 1, 1), None)

    # Cư dân 14: ở Hộ 4 (Tổ 04) — đúng 1 người đang ở (S14)
    add_qt(14, ho_by_to[4][0], "THUONG_TRU", date(2023, 7, 1), None)

    # Cư dân 15: S06 + S13 (CHUYEN_NOI_BO khác tổ: Tổ 01 -> Tổ 02)
    q15_cu = add_qt(15, ho_by_to[1][3], "THUONG_TRU", date(2022, 1, 1), date(2026, 10, 14))
    q15_moi = add_qt(15, ho_by_to[2][1], "THUONG_TRU", date(2026, 10, 15), None)
    add_bd("CHUYEN_NOI_BO", q15_cu, q15_moi, date(2026, 10, 15), 2, "Chuyển nội bộ khác tổ (S13, QSQL09)")

    # Cư dân 16: S06 + CHUYEN_NOI_BO cùng tổ (Tổ 02 -> Tổ 02, đối chứng QSQL09)
    q16_cu = add_qt(16, ho_by_to[2][1], "THUONG_TRU", date(2023, 1, 1), date(2026, 11, 4))
    q16_moi = add_qt(16, ho_by_to[2][2], "THUONG_TRU", date(2026, 11, 5), None)
    add_bd("CHUYEN_NOI_BO", q16_cu, q16_moi, date(2026, 11, 5), 3, "Chuyển nội bộ cùng tổ (đối chứng QSQL09)")

    # Cư dân 17: hai đợt CÙNG MỘT HỘ (loại trừ khỏi QSQL05 vì chỉ ở 1 hộ)
    add_qt(17, ho_by_to[3][1], "THUONG_TRU", date(2021, 1, 1), date(2024, 12, 31))
    add_qt(17, ho_by_to[3][1], "TAM_TRU", date(2025, 6, 1), None)

    # Cư dân 18: S07 (từng thường trú và từng tạm trú, hiện vẫn ở)
    add_qt(18, ho_by_to[4][1], "TAM_TRU", date(2022, 1, 1), date(2023, 12, 31))
    add_qt(18, ho_by_to[4][1], "THUONG_TRU", date(2024, 1, 1), None)

    # Cư dân 19, 20: S09 + S12 (đã kết thúc cư trú trước d, CHUYEN_DI)
    q19 = add_qt(19, ho_by_to[5][0], "THUONG_TRU", date(2022, 3, 1), date(2026, 10, 31))
    add_bd("CHUYEN_DI", q19, None, date(2026, 11, 1), 2, "Chuyển đi khỏi phường (S09, S12)")
    q20 = add_qt(20, ho_by_to[5][0], "TAM_TRU", date(2024, 4, 1), date(2026, 9, 30))
    add_bd("CHUYEN_DI", q20, None, date(2026, 10, 1), 3, "Hết tạm trú chuyển đi (S09, S12)")

    # S05: Hộ 59 và 60 từng có cư dân 21, 22 nhưng đã chuyển đi trước d -> hộ 0 người đang ở
    q21 = add_qt(21, 59, "THUONG_TRU", date(2023, 1, 1), date(2026, 8, 31))
    add_bd("CHUYEN_DI", q21, None, date(2026, 9, 1), 2, "Rời hộ 59 để hộ trống tại d (S05)")
    q22 = add_qt(22, 60, "TAM_TRU", date(2024, 1, 1), date(2026, 7, 31))
    add_bd("CHUYEN_DI", q22, None, date(2026, 8, 1), 3, "Rời hộ 60 để hộ trống tại d (S05)")

    # Đợt tương lai (ngay_bat_dau > 2026-11-20, ngay_ket_thuc IS NULL) cho cư dân 23, 24
    q23 = add_qt(23, ho_by_to[6][0], "THUONG_TRU", date(2026, 12, 1), None)
    add_bd("CHUYEN_DEN", None, q23, date(2026, 12, 1), 2, "Đợt tương lai sau ngày d")
    q24 = add_qt(24, ho_by_to[6][1], "TAM_TRU", date(2026, 11, 25), None)
    add_bd("CHUYEN_DEN", None, q24, date(2026, 11, 25), 3, "Đợt tương lai sau ngày d")

    # S10: Cư dân 25, 26, 27 chưa từng có bất kỳ đợt cư trú nào (0 qua_trinh_cu_tru)
    for cid in (25, 26, 27):
        cu_dan[cid - 1]["ghi_chu"] = "Cư dân mới chưa có đợt cư trú (S10)"

    # Cư dân 28, 29, 30: thêm sự kiện chuyển nội bộ khác tổ trong 2026-11
    q28_cu = add_qt(28, ho_by_to[1][4], "THUONG_TRU", date(2023, 5, 1), date(2026, 11, 9))
    q28_moi = add_qt(28, ho_by_to[3][2], "THUONG_TRU", date(2026, 11, 10), None)
    add_bd("CHUYEN_NOI_BO", q28_cu, q28_moi, date(2026, 11, 10), 1, "Chuyển nội bộ Tổ 1 -> Tổ 3")

    q29_cu = add_qt(29, ho_by_to[2][3], "TAM_TRU", date(2025, 2, 1), date(2026, 11, 14))
    q29_moi = add_qt(29, ho_by_to[4][2], "TAM_TRU", date(2026, 11, 15), None)
    add_bd("CHUYEN_NOI_BO", q29_cu, q29_moi, date(2026, 11, 15), 4, "Chuyển nội bộ Tổ 2 -> Tổ 4")

    q30 = add_qt(30, ho_by_to[5][1], "THUONG_TRU", date(2026, 11, 18), None)
    add_bd("CHUYEN_DEN", None, q30, date(2026, 11, 18), 2, "Chuyển đến tháng 11/2026")

    # --- Lớp 2: Dữ liệu nền sinh ngẫu nhiên có kiểm soát cho cư dân 31..200 ---
    # Dùng các hộ thuộc Tổ 1..7 (trừ hộ 1, 2, 3, 4 đã kiểm soát sĩ số; trừ hộ 59, 60 để giữ S05)
    bg_hos = [h["ma_ho"] for h in ho_cu_tru if h["ma_ho"] not in (1, 2, 3, 4, 59, 60)]
    # Để S15 có Tổ 07 không phát sinh biến động trong tháng 2026-11, tránh tạo biến động tháng 11 cho Tổ 07
    bg_hos_no_t7 = [h for h in bg_hos if ho_to_map[h] != 7]

    for cid in range(31, 201):
        # 5 cư dân cuối (196..200) không có đợt nào thêm cho S10
        if cid >= 196:
            continue

        loai = "THUONG_TRU" if rng.random() < 0.72 else "TAM_TRU"
        ho1 = rng.choice(bg_hos)
        start1 = date(2021, 1, 1) + timedelta(days=rng.randint(0, 1400))

        # Khoảng 25% cư dân nền có sự kiện biến động (đóng đợt 1 và mở đợt 2 hoặc chuyển đi)
        roll = rng.random()
        if roll < 0.14 and len(bien_dong) < 68:
            # Chuyển nội bộ sang hộ khác
            ho2 = rng.choice([h for h in bg_hos_no_t7 if h != ho1])
            move_date = date(2025, 1, 1) + timedelta(days=rng.randint(0, 670))
            if move_date <= start1:
                move_date = start1 + timedelta(days=30)
            q1 = add_qt(cid, ho1, loai, start1, move_date - timedelta(days=1))
            q2 = add_qt(cid, ho2, loai, move_date, None)
            tk = rng.choice([1, 2, 3, 4])
            # Tránh tạo biến động ở Tổ 07 vào tháng 2026-11
            if not (move_date.year == 2026 and move_date.month == 11 and (ho_to_map[ho1] == 7 or ho_to_map[ho2] == 7)):
                add_bd("CHUYEN_NOI_BO", q1, q2, move_date, tk)
        elif roll < 0.22 and len(bien_dong) < 68:
            # Chuyển đi
            leave_date = date(2025, 1, 1) + timedelta(days=rng.randint(0, 670))
            if leave_date <= start1:
                leave_date = start1 + timedelta(days=30)
            q1 = add_qt(cid, ho1, loai, start1, leave_date - timedelta(days=1))
            tk = rng.choice([1, 2, 3, 4])
            if not (leave_date.year == 2026 and leave_date.month == 11 and ho_to_map[ho1] == 7):
                add_bd("CHUYEN_DI", q1, None, leave_date, tk)
        elif roll < 0.30 and len(bien_dong) < 68:
            # Chuyển đến
            arrive_date = date(2025, 1, 1) + timedelta(days=rng.randint(0, 670))
            q1 = add_qt(cid, ho1, loai, arrive_date, None)
            tk = rng.choice([1, 2, 3, 4])
            if not (arrive_date.year == 2026 and arrive_date.month == 11 and ho_to_map[ho1] == 7):
                add_bd("CHUYEN_DEN", None, q1, arrive_date, tk)
        else:
            # Đợt cư trú ổn định
            add_qt(cid, ho1, loai, start1, None)
            # ~15% có thêm một đợt loại khác (để phong phú dữ liệu)
            if rng.random() < 0.15:
                other_loai = "TAM_TRU" if loai == "THUONG_TRU" else "THUONG_TRU"
                ho_other = rng.choice([h for h in bg_hos if h != ho1])
                start2 = date(2025, 1, 1) + timedelta(days=rng.randint(0, 600))
                add_qt(cid, ho_other, other_loai, start2, None)

    # Bảo đảm đạt gần mục tiêu ~250 đợt cư trú nếu còn thiếu
    cid_pool = list(range(31, 195))
    rng.shuffle(cid_pool)
    for cid in cid_pool:
        if len(qua_trinh) >= 250:
            break
        existing_types = {q["loai_cu_tru"] for q in qua_trinh if q["ma_cu_dan"] == cid}
        for loai in ("THUONG_TRU", "TAM_TRU"):
            if loai not in existing_types:
                ho_x = rng.choice(bg_hos)
                add_qt(cid, ho_x, loai, date(2025, 6, 1) + timedelta(days=rng.randint(0, 300)), None)
                break

    # Xuất CSV vào data/generated/
    CSV_DIR.mkdir(parents=True, exist_ok=True)
    tables = [
        ("to_dan_pho.csv", ["ma_to", "ten_to", "ghi_chu"], to_dan_pho),
        ("dia_chi.csv", ["ma_dia_chi", "ma_to", "dia_chi_chuan", "ghi_chu"], dia_chi),
        ("ho_cu_tru.csv", ["ma_ho", "ma_dia_chi", "ngay_lap", "ghi_chu"], ho_cu_tru),
        ("cu_dan.csv", ["ma_cu_dan", "ho_ten", "ngay_sinh", "gioi_tinh", "ghi_chu"], cu_dan),
        ("tai_khoan.csv", ["ma_tai_khoan", "ten_dang_nhap", "ten_hien_thi", "vai_tro", "trang_thai"], tai_khoan),
        ("qua_trinh_cu_tru.csv", ["ma_qua_trinh", "ma_cu_dan", "ma_ho", "loai_cu_tru", "ngay_bat_dau", "ngay_ket_thuc"], qua_trinh),
        ("bien_dong_cu_tru.csv", ["ma_bien_dong", "loai_bien_dong", "ma_qua_trinh_cu", "ma_qua_trinh_moi", "ngay_bien_dong", "ma_tai_khoan", "ghi_chu"], bien_dong),
    ]

    for filename, cols, rows in tables:
        with open(CSV_DIR / filename, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=cols)
            writer.writeheader()
            for r in rows:
                out = {}
                for c in cols:
                    v = r[c]
                    out[c] = v.isoformat() if isinstance(v, date) else ("" if v is None else v)
                writer.writerow(out)

    # Xuất sql/03_seed.sql
    lines = [
        "-- Dữ liệu giả lập BTL CSDL Đề tài 17 (TV2) — sinh tự động bởi scripts/generate_data.py",
        f"-- Seed cố định: {SEED}. Ngày tham chiếu kiểm chứng: {REF_DATE.isoformat()}.",
        "-- Toàn bộ dữ liệu là mô phỏng 100%; không chứa CCCD/SĐT/thông tin người thật.",
        "-- Nạp theo thứ tự FK từ bảng cha tới bảng con, cuối cùng đồng bộ sequence.",
        "",
        "BEGIN;",
        "",
        "TRUNCATE TABLE bien_dong_cu_tru, qua_trinh_cu_tru, tai_khoan, cu_dan, ho_cu_tru, dia_chi, to_dan_pho RESTART IDENTITY CASCADE;",
        "",
        "-- 1. TO_DAN_PHO",
        "INSERT INTO to_dan_pho (ma_to, ten_to, ghi_chu) VALUES",
    ]
    lines.extend(
        f"({r['ma_to']}, {sql_str(r['ten_to'])}, {sql_str(r['ghi_chu'])})" + (";" if idx == len(to_dan_pho) - 1 else ",")
        for idx, r in enumerate(to_dan_pho)
    )

    lines.extend(["", "-- 2. DIA_CHI", "INSERT INTO dia_chi (ma_dia_chi, ma_to, dia_chi_chuan, ghi_chu) VALUES"])
    lines.extend(
        f"({r['ma_dia_chi']}, {r['ma_to']}, {sql_str(r['dia_chi_chuan'])}, {sql_str(r['ghi_chu'])})" + (";" if idx == len(dia_chi) - 1 else ",")
        for idx, r in enumerate(dia_chi)
    )

    lines.extend(["", "-- 3. HO_CU_TRU", "INSERT INTO ho_cu_tru (ma_ho, ma_dia_chi, ngay_lap, ghi_chu) VALUES"])
    lines.extend(
        f"({r['ma_ho']}, {r['ma_dia_chi']}, {sql_date(r['ngay_lap'])}, {sql_str(r['ghi_chu'])})" + (";" if idx == len(ho_cu_tru) - 1 else ",")
        for idx, r in enumerate(ho_cu_tru)
    )

    lines.extend(["", "-- 4. CU_DAN", "INSERT INTO cu_dan (ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh, ghi_chu) VALUES"])
    lines.extend(
        f"({r['ma_cu_dan']}, {sql_str(r['ho_ten'])}, {sql_date(r['ngay_sinh'])}, {sql_str(r['gioi_tinh'])}, {sql_str(r['ghi_chu'])})" + (";" if idx == len(cu_dan) - 1 else ",")
        for idx, r in enumerate(cu_dan)
    )

    lines.extend(["", "-- 5. TAI_KHOAN", "INSERT INTO tai_khoan (ma_tai_khoan, ten_dang_nhap, ten_hien_thi, vai_tro, trang_thai) VALUES"])
    lines.extend(
        f"({r['ma_tai_khoan']}, {sql_str(r['ten_dang_nhap'])}, {sql_str(r['ten_hien_thi'])}, {sql_str(r['vai_tro'])}, {sql_str(r['trang_thai'])})" + (";" if idx == len(tai_khoan) - 1 else ",")
        for idx, r in enumerate(tai_khoan)
    )

    lines.extend(["", "-- 6. QUA_TRINH_CU_TRU", "INSERT INTO qua_trinh_cu_tru (ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc) VALUES"])
    lines.extend(
        f"({r['ma_qua_trinh']}, {r['ma_cu_dan']}, {r['ma_ho']}, {sql_str(r['loai_cu_tru'])}, {sql_date(r['ngay_bat_dau'])}, {sql_date(r['ngay_ket_thuc'])})" + (";" if idx == len(qua_trinh) - 1 else ",")
        for idx, r in enumerate(qua_trinh)
    )

    lines.extend(["", "-- 7. BIEN_DONG_CU_TRU", "INSERT INTO bien_dong_cu_tru (ma_bien_dong, loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong, ma_tai_khoan, ghi_chu) VALUES"])
    lines.extend(
        f"({r['ma_bien_dong']}, {sql_str(r['loai_bien_dong'])}, {sql_int(r['ma_qua_trinh_cu'])}, {sql_int(r['ma_qua_trinh_moi'])}, {sql_date(r['ngay_bien_dong'])}, {r['ma_tai_khoan']}, {sql_str(r['ghi_chu'])})" + (";" if idx == len(bien_dong) - 1 else ",")
        for idx, r in enumerate(bien_dong)
    )

    lines.extend([
        "",
        "-- Đồng bộ lại sequence sau khi nạp ID gán tay",
        "SELECT setval(pg_get_serial_sequence('to_dan_pho', 'ma_to'), COALESCE((SELECT MAX(ma_to) FROM to_dan_pho), 1));",
        "SELECT setval(pg_get_serial_sequence('dia_chi', 'ma_dia_chi'), COALESCE((SELECT MAX(ma_dia_chi) FROM dia_chi), 1));",
        "SELECT setval(pg_get_serial_sequence('ho_cu_tru', 'ma_ho'), COALESCE((SELECT MAX(ma_ho) FROM ho_cu_tru), 1));",
        "SELECT setval(pg_get_serial_sequence('cu_dan', 'ma_cu_dan'), COALESCE((SELECT MAX(ma_cu_dan) FROM cu_dan), 1));",
        "SELECT setval(pg_get_serial_sequence('tai_khoan', 'ma_tai_khoan'), COALESCE((SELECT MAX(ma_tai_khoan) FROM tai_khoan), 1));",
        "SELECT setval(pg_get_serial_sequence('qua_trinh_cu_tru', 'ma_qua_trinh'), COALESCE((SELECT MAX(ma_qua_trinh) FROM qua_trinh_cu_tru), 1));",
        "SELECT setval(pg_get_serial_sequence('bien_dong_cu_tru', 'ma_bien_dong'), COALESCE((SELECT MAX(ma_bien_dong) FROM bien_dong_cu_tru), 1));",
        "",
        "COMMIT;",
        "",
    ])

    SEED_SQL_PATH.write_text("\n".join(lines), encoding="utf-8")

    total = len(to_dan_pho) + len(dia_chi) + len(ho_cu_tru) + len(cu_dan) + len(tai_khoan) + len(qua_trinh) + len(bien_dong)
    print(f"Generated successfully: total={total} rows")
    print(f"  to_dan_pho={len(to_dan_pho)}, dia_chi={len(dia_chi)}, ho_cu_tru={len(ho_cu_tru)}, "
          f"cu_dan={len(cu_dan)}, tai_khoan={len(tai_khoan)}, qua_trinh_cu_tru={len(qua_trinh)}, "
          f"bien_dong_cu_tru={len(bien_dong)}")


if __name__ == "__main__":
    main()
