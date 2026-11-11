#!/usr/bin/env python3
"""Render the editable week-1 diagrams and matching PNG/SVG exports.

Requires Python 3 + Pillow. Run from any working directory. This does not alter SQL.
"""
from __future__ import annotations

import html
import re
from pathlib import Path
from xml.etree import ElementTree as ET

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "diagrams"
WIDTH, HEIGHT, SCALE = 1150, 813, 2
FONT = Path("/System/Library/Fonts/Supplemental/Arial.ttf")
BOLD = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")
if not FONT.exists():
    FONT = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    BOLD = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf")


def schema():
    text = (ROOT / "sql/01_schema.sql").read_text()
    tables = {}
    for name, body in re.findall(r"CREATE TABLE IF NOT EXISTS (\w+) \((.*?)\n\);", text, re.S):
        columns = []
        for line in body.splitlines():
            m = re.match(r"\s+(\w+)\s+(BIGINT|VARCHAR\(\d+\)|TEXT|DATE|TIMESTAMPTZ)(?=\s|,|$)(.*)", line)
            if not m:
                continue
            col, typ, rest = m.groups()
            pk = "PRIMARY KEY" in rest
            fk = re.search(r"REFERENCES (\w+)\((\w+)\)", rest)
            nullable = not (pk or "NOT NULL" in rest)
            columns.append(dict(name=col, type=typ.lower(), pk=pk, fk=fk.groups() if fk else None,
                                nullable=nullable, unique="UNIQUE" in rest))
        tables[name] = columns
    return tables


class Drawing:
    def __init__(self, name, title, subtitle):
        self.name = name
        self.image = Image.new("RGB", (WIDTH * SCALE, HEIGHT * SCALE), "#ffffff")
        self.draw = ImageDraw.Draw(self.image)
        self.svg = ET.Element("svg", xmlns="http://www.w3.org/2000/svg", width=str(WIDTH),
                              height=str(HEIGHT), viewBox=f"0 0 {WIDTH} {HEIGHT}")
        ET.SubElement(self.svg, "rect", width=str(WIDTH), height=str(HEIGHT), fill="white")
        self.mx = ET.Element("mxfile", host="app.diagrams.net", version="24.7.17")
        diagram = ET.SubElement(self.mx, "diagram", id=name, name=title)
        model = ET.SubElement(diagram, "mxGraphModel", dx=str(WIDTH), dy=str(HEIGHT), grid="1",
                              gridSize="10", page="1", pageScale="1", pageWidth=str(WIDTH),
                              pageHeight=str(HEIGHT), math="0", shadow="0")
        self.cells = ET.SubElement(model, "root")
        ET.SubElement(self.cells, "mxCell", id="0")
        ET.SubElement(self.cells, "mxCell", id="1", parent="0")
        self.count = 0
        self.text(30, 20, WIDTH - 60, 28, title, 23, "#183153", True)
        self.text(30, 55, WIDTH - 60, 22, subtitle, 12, "#52657b")

    def ident(self):
        self.count += 1
        return f"n{self.count}"

    def text(self, x, y, w, h, text, size=14, color="#183153", bold=False, align="left", **meta):
        ident = self.ident()
        lines = text.split("\n")
        while size >= 9:
            font = ImageFont.truetype(str(BOLD if bold else FONT), round(size * SCALE))
            maxw = max(self.draw.textlength(t, font=font) for t in lines)
            lineheight = size * 1.25
            if maxw <= (w - 10) * SCALE and lineheight * len(lines) <= h + 2:
                break
            size -= .5
        assert size >= 9, f"Text does not fit: {text}"
        for i, line in enumerate(lines):
            tx = x + 5 if align == "left" else x + w / 2
            ty = y + (h - lineheight * len(lines)) / 2 + i * lineheight
            self.draw.text((tx * SCALE, ty * SCALE), line, font=font, fill=color,
                           anchor="mt" if align == "center" else "lt")
            node = ET.SubElement(self.svg, "text", x=str(tx), y=str(ty + size),
                                 fill=color, **{"font-family": "Arial, sans-serif", "font-size": str(size),
                                 "font-weight": "700" if bold else "400",
                                 "text-anchor": "middle" if align == "center" else "start"})
            node.text = line
        style = (f"text;html=1;whiteSpace=wrap;align={align};verticalAlign=middle;"
                 f"fontFamily=Arial;fontSize={size};fontColor={color};"
                 f"fontStyle={1 if bold else 0};spacingLeft=5;")
        cell = ET.SubElement(self.cells, "mxCell", id=ident, value=html.escape(text).replace("\n", "<br>"),
                             style=style, vertex="1", parent="1", **meta)
        ET.SubElement(cell, "mxGeometry", x=str(x), y=str(y), width=str(w), height=str(h), **{"as": "geometry"})
        return ident

    def box(self, x, y, w, h, fill="#f3f7fc", border="#31577c", **meta):
        ident = self.ident()
        self.draw.rectangle((x*SCALE, y*SCALE, (x+w)*SCALE, (y+h)*SCALE), fill=fill, outline=border, width=2)
        ET.SubElement(self.svg, "rect", x=str(x), y=str(y), width=str(w), height=str(h), fill=fill,
                      stroke=border, **{"stroke-width": "1"})
        cell = ET.SubElement(self.cells, "mxCell", id=ident, value="", style=f"rounded=0;fillColor={fill};strokeColor={border};",
                             vertex="1", parent="1", **meta)
        ET.SubElement(cell, "mxGeometry", x=str(x), y=str(y), width=str(w), height=str(h), **{"as": "geometry"})
        return ident

    def line(self, points, color="#52657b", **meta):
        ident = self.ident()
        self.draw.line([(x*SCALE, y*SCALE) for x, y in points], fill=color, width=2*SCALE)
        ET.SubElement(self.svg, "polyline", points=" ".join(f"{x},{y}" for x, y in points),
                      fill="none", stroke=color, **{"stroke-width": "1.6"})
        cell = ET.SubElement(self.cells, "mxCell", id=ident, value="", edge="1", parent="1",
                             style=f"endArrow=none;startArrow=none;rounded=0;strokeColor={color};strokeWidth=1.6;", **meta)
        geo = ET.SubElement(cell, "mxGeometry", relative="1", **{"as": "geometry"})
        ET.SubElement(geo, "mxPoint", x=str(points[0][0]), y=str(points[0][1]), **{"as": "sourcePoint"})
        ET.SubElement(geo, "mxPoint", x=str(points[-1][0]), y=str(points[-1][1]), **{"as": "targetPoint"})
        if len(points) > 2:
            arr = ET.SubElement(geo, "Array", **{"as": "points"})
            for x, y in points[1:-1]:
                ET.SubElement(arr, "mxPoint", x=str(x), y=str(y))

    def save(self):
        OUT.mkdir(exist_ok=True)
        self.image.save(OUT / f"{self.name}.png", dpi=(188, 188))
        for path, tree in [(OUT / f"{self.name}.drawio", self.mx), (OUT / f"{self.name}.svg", self.svg)]:
            ET.indent(tree)
            ET.ElementTree(tree).write(path, encoding="utf-8", xml_declaration=True)
        print(f"Rendered {self.name}: editable drawio + {WIDTH*SCALE}×{HEIGHT*SCALE} PNG + SVG")


def erd(tables):
    d = Drawing("erd_v1", "MÔ HÌNH THỰC THỂ – LIÊN KẾT", "Đề tài 17 • Bộ bàn giao TV1 • Cấu trúc v1 / chờ review chéo • 11/11/2026")
    positions = {
        "to_dan_pho": (30, 110, 250), "dia_chi": (30, 335, 250), "ho_cu_tru": (30, 580, 250),
        "cu_dan": (395, 110, 325), "qua_trinh_cu_tru": (395, 410, 325),
        "tai_khoan": (830, 110, 290), "bien_dong_cu_tru": (830, 410, 290),
    }
    relationships = [
        ("dia_chi.ma_to", [(155,216),(155,335)], [(165,228,"1"),(165,309,"0..N")]),
        ("ho_cu_tru.ma_dia_chi", [(155,465),(155,580)], [(165,478,"1"),(165,554,"0..N")]),
        ("qua_trinh_cu_tru.ma_cu_dan", [(557,264),(557,410)], [(567,277,"1"),(567,384,"0..N")]),
        ("qua_trinh_cu_tru.ma_ho", [(280,645),(335,645),(335,560),(395,560)], [(287,650,"1"),(345,536,"0..N")]),
        ("bien_dong_cu_tru.ma_tai_khoan", [(975,264),(975,410)], [(985,277,"1"),(985,384,"0..N")]),
        ("bien_dong_cu_tru.ma_qua_trinh_cu", [(720,470),(830,470)], [(718,473,"0..1"),(785,473,"0..N")]),
        ("bien_dong_cu_tru.ma_qua_trinh_moi", [(720,550),(830,550)], [(718,553,"0..1"),(785,553,"0..N")]),
    ]
    for name, points, labels in relationships:
        d.line(points, relationship=name)
        for x, y, label in labels:
            d.text(x, y, 52, 21, label, 12)
    d.text(733, 441, 83, 23, "đợt cũ", 12, align="center")
    d.text(733, 521, 83, 23, "đợt mới", 12, align="center")
    for table, (x,y,w) in positions.items():
        rows = tables[table]
        d.box(x,y,w,34+len(rows)*24, schemaTable=table)
        d.box(x,y,w,34, fill="#183153")
        d.text(x+3,y+1,w-6,32,table,15,"#ffffff",True,align="center")
        for i,c in enumerate(rows):
            prefix = "PK" if c["pk"] else "FK" if c["fk"] else "UQ" if c["unique"] else "  "
            line = f"{prefix}  {c['name']} : {c['type']}{' ?' if c['nullable'] else ''}"
            d.text(x+3,y+34+i*24,w-6,24,line,12, schemaColumn=f"{table}.{c['name']}")
    d.text(30,733,1090,24,"Ký hiệu: PK khóa chính • FK khóa ngoại • UQ duy nhất • ? cho phép NULL • 1 bắt buộc • 0..1 tùy chọn • 0..N nhiều",12)
    d.text(30,763,1090,23,"Mỗi sự kiện: đến chỉ đợt mới; đi chỉ đợt cũ; nội bộ có cả hai. UNIQUE ghép địa chỉ: (ma_to, dia_chi_chuan).",12)
    d.save()


def function_tree():
    d = Drawing("phan_ra_chuc_nang", "SƠ ĐỒ PHÂN RÃ CHỨC NĂNG", "Đề tài 17 • Cấp 0 → cấp 1 → cấp 2 • Bộ bàn giao TV1 • 11/11/2026")
    root = (365,105,420,64)
    groups = [
        ("1. Quản lý\nđịa bàn", ["1.1 Tổ dân phố", "1.2 Địa chỉ"]),
        ("2. Quản lý hộ\nvà cư dân", ["2.1 Nhóm hộ", "2.2 Hồ sơ cư dân"]),
        ("3. Quản lý\nquá trình cư trú", ["3.1 Mở đợt", "3.2 Kết thúc đợt"]),
        ("4. Ghi nhận\nbiến động", ["4.1 Chuyển đến", "4.2 Chuyển đi", "4.3 Chuyển nội bộ"]),
        ("5. Tra cứu\nvà thống kê", ["5.1 Hiện tại", "5.2 Lịch sử", "5.3 Thống kê theo\ntổ / loại cư trú"]),
        ("6. Quản trị\nvà bảo mật", ["6.1 Vai trò", "6.2 Giới hạn\ntruy cập dữ liệu"]),
    ]
    for i, (title, children) in enumerate(groups):
        x, w, y = 30+i*185, 165, 290
        center = x+w/2
        d.line([(575,169),(575,230),(center,230),(center,y)], functionEdge=f"0-{i+1}")
        for j, child in enumerate(children):
            cy = 430+j*86
            d.line([(center,358),(center,383),(x-10,383),(x-10,cy+30),(x,cy+30)], functionEdge=f"{i+1}-{i+1}.{j+1}")
            d.box(x,cy,w,60,fill="#f3f7fc",functionCode=f"{i+1}.{j+1}")
            d.text(x+3,cy+3,w-6,54,child,13,align="center")
        d.box(x,y,w,68,fill="#dceafb",functionCode=str(i+1))
        d.text(x+3,y+3,w-6,62,title,14,bold=True,align="center")
    d.box(*root,fill="#183153",functionCode="0")
    d.text(root[0]+4,root[1]+4,root[2]-8,root[3]-8,"QUẢN LÝ CƯ DÂN\nVÀ BIẾN ĐỘNG CƯ TRÚ",18,"#ffffff",True,align="center")
    d.text(30,733,1090,24,"Một phường mô phỏng • Sáu nhóm chức năng • Mười bốn chức năng cấp 2 • Dữ liệu giả lập 100%",13)
    d.text(30,763,1090,23,"Đường nối biểu diễn quan hệ phân rã chức năng; không biểu diễn thứ tự xử lý hay luồng dữ liệu.",12)
    d.save()


if __name__ == "__main__":
    tables = schema()
    assert len(tables) == 7 and sum(map(len,tables.values())) == 35
    erd(tables)
    function_tree()
