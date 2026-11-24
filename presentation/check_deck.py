"""Verify slide structure, sources, notes and rendered page coverage."""
from pathlib import Path
from zipfile import ZipFile
from lxml import etree as E
from pypdf import PdfReader
import hashlib
import json
import posixpath
import re
import sys
import unicodedata

workspace = Path.cwd()
deck, pdf = map(Path, sys.argv[1:3])
template = workspace / 'Slide/HUST_PPT_template_2022_Blue_16x9.pptx'
report = workspace / 'Báo_cáo_CSDL_nhóm_38'
ns = {'p':'http://schemas.openxmlformats.org/presentationml/2006/main',
      'a':'http://schemas.openxmlformats.org/drawingml/2006/main',
      'r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
expected_times = [25,5,45,40,65,40,85,55,45,55,5,20,40,95,100,35,5,40,90,105,95,85,25]
expected_roles = ['TV1']*10 + ['TV2']*6 + ['TV3']*7
owners = [9,12,14,15,19,20,24,28,29,30,31,32,33,34]
dividers = {
    2: (1, 'Trần Bùi Tùng Linh', 'Bài toán và thiết kế CSDL'),
    11: (2, 'Trần Tuấn Ngọc', 'Dữ liệu, SQL và kiểm thử'),
    17: (3, 'Dương Ngọc Ninh', 'Đại số quan hệ và bảo mật'),
}
figures = {
    5: report/'image/phan_ra_chuc_nang.png',
    7: workspace/'erd.png',
    8: workspace/'diagrams/erd_v1.png',
}
security_figures = {
    21: ('SEC_B1_select_ok.png','SEC_B1_denied.png'),
    22: ('SEC_B2_view_ok.png','SEC_B2_denied.png'),
}
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def alltext(root):
    return '\n'.join(root.xpath('//a:t/text()',namespaces=ns))
def canon(s):
    return re.sub(r'\s+','',unicodedata.normalize('NFC',s))
def allowed_wording(s):
    return 'môphỏng' not in canon(s).casefold()
def check_divider(text, index):
    number, _, title = dividers[index]
    visible = canon(text)
    assert canon(f'PHẦN {number}') in visible and canon(title) in visible,index
    assert all(canon(name) not in visible for _,name,_ in dividers.values()),index
    return number

with ZipFile(deck) as z, ZipFile(template) as t:
    assert z.testzip() is None
    retained=[k for k in t.namelist() if not k.endswith('/') and k.startswith(('ppt/slideMasters/','ppt/slideLayouts/','ppt/theme/','ppt/media/'))]
    assert len(retained)>20
    for part in retained:
        assert z.read(part)==t.read(part),part
    pres=E.fromstring(z.read('ppt/presentation.xml'))
    relationships=E.fromstring(z.read('ppt/_rels/presentation.xml.rels'))
    targets={e.get('Id'):e.get('Target') for e in relationships}
    order=[posixpath.join('ppt',targets[e.get('{'+ns['r']+'}id')])
           for e in pres.findall('p:sldIdLst/p:sldId',ns)]
    assert order==[f'ppt/slides/slide{i}.xml' for i in [35,36,*range(1,35)]]
    for source, target in [(1,35),(2,36)]:
        assert t.read(f'ppt/slides/slide{source}.xml')==z.read(f'ppt/slides/slide{target}.xml')
        assert t.read(f'ppt/slides/_rels/slide{source}.xml.rels')==z.read(f'ppt/slides/_rels/slide{target}.xml.rels')
    size=pres.find('p:sldSz',ns)
    assert [size.get(k) for k in ['cx','cy']]==['12192000','6858000']
    elapsed = folio = 0
    for i in range(1,35):
        slide=E.fromstring(z.read(f'ppt/slides/slide{i}.xml'))
        note=E.fromstring(z.read(f'ppt/notesSlides/notesSlide{i}.xml'))
        copy=alltext(slide)
        speech=alltext(note)
        assert slide.xpath('//p:sp[p:txBody//a:t]',namespaces=ns),(i,'not editable')
        if i in owners:
            assert slide.xpath('//a:tbl',namespaces=ns),(i,'no native table')
        if i<=23:
            elapsed += expected_times[i-1]
            if i in dividers:
                number = check_divider(copy, i)
                rels=E.fromstring(z.read(f'ppt/slides/_rels/slide{i}.xml.rels'))
                assert any(x.get('Target')=='../slideLayouts/slideLayout11.xml' for x in rels),i
                tag=f'Phần {number}'
            else:
                folio += 1
                tag=f'{folio:02d}'
                assert len(speech)>120,(i,'empty notes')
                if i!=1:
                    assert tag in copy.splitlines(),(i,'wrong content folio')
            header=f'{tag} · {expected_roles[i-1]} · {expected_times[i-1]} giây · Lũy kế {elapsed//60:02d}:{elapsed%60:02d}'
            assert header in speech,(i,'speaker/timing')
        else:
            assert 'PHỤ LỤC' in copy and f'A{i-23:02d}' in copy and 'Phụ lục hỏi đáp' in speech,i
        if i in figures or i in security_figures:
            rels=E.fromstring(z.read(f'ppt/slides/_rels/slide{i}.xml.rels'))
            embeds=slide.xpath('//p:pic//a:blip/@r:embed',namespaces=ns)
            parts=[posixpath.normpath(posixpath.join('ppt/slides',rel.get('Target')))
                   for rel in rels if rel.get('Id') in embeds]
            paths=([figures[i]] if i in figures else [report/'image/security'/name for name in security_figures[i]])
            for path in paths:
                assert any(z.read(part)==path.read_bytes() for part in parts),(i,path)
        assert 'PRESENTATION TITLE' not in copy and 'Click to edit' not in copy
        if i in (14,29):
            assert "DATE '2026-11-20'" in copy,i
        else:
            assert '2026-11-20' not in copy,i
        assert 'Q_d' not in copy,i
        assert allowed_wording(copy) and allowed_wording(speech),i
        for owner in slide.xpath('/p:sld/p:cSld/p:spTree/p:sp/p:spPr/a:xfrm|/p:sld/p:cSld/p:spTree/p:pic/p:spPr/a:xfrm|/p:sld/p:cSld/p:spTree/p:graphicFrame/p:xfrm',namespaces=ns):
            pos=owner.find('a:off',ns)
            ext=owner.find('a:ext',ns)
            if pos is None or ext is None:
                continue
            x,y,w,h=map(int,(pos.get('x'),pos.get('y'),ext.get('cx'),ext.get('cy')))
            assert min(x,y,w,h)>=0 and x+w<=12192000+5 and y+h<=6858000+5,(i,x,y,w,h)
    b09 = alltext(E.fromstring(z.read('ppt/slides/slide34.xml')))
    assert all(token in b09 for token in ('A11','p_ngay - 1','23514','trg_dot_khong_pha_su_kien'))
    assert folio==20 and elapsed==1200
    src=(report/'chuong5.tex').read_text()
    listings=re.findall(r'\\begin\{lstlisting\}\[style=sqlvn\]\n(.*?)\\end\{lstlisting\}',src,re.S)
    raw=(workspace/'sql/04_queries.sql').read_text()
    source_queries=re.split(r'^-- QSQL\d{2}\.[^\n]*\n',raw,flags=re.M)[1:]
    assert [sql.strip() for sql in listings]==[sql.split('\n',1)[1].strip() for sql in source_queries]
    for number,case in [(29,3),(30,9)]:
        slide=E.fromstring(z.read(f'ppt/slides/slide{number}.xml'))
        assert canon(listings[case-1]) in canon(alltext(slide)),number
    catalog=E.fromstring(z.read('ppt/slides/slide28.xml'))
    rows=[row.xpath('.//a:t/text()',namespaces=ns) for row in catalog.xpath('//a:tbl/a:tr',namespaces=ns)]
    assert [(row[0],int(row[-1])) for row in rows[1:]]==list(zip(
        [f'QSQL{i:02}' for i in range(1,11)],[36,24,8,4,54,31,17,45,22,5]))
    recorded=json.loads((workspace/'tests/week1_execution_results.json').read_text())['checks']
    results={c['test']:c['actual'] for c in recorded}
    qsql03=[[r['ma_to'],r['ten_to'],r['so_cu_dan']] for r in results['w1_seed/QSQL03/full-tuples']]
    qsql09=[[r['ma_bien_dong'],r['ma_cu_dan'],r['ma_to_cu'],r['ma_to_moi'],
             '/'.join(reversed(r['ngay_bien_dong'].split('-')))]
            for r in results['w1_seed/QSQL09/full-tuples'][:3]]
    for number,expected in [(14,qsql03),(29,qsql03),(15,qsql09),(30,qsql09)]:
        slide=E.fromstring(z.read(f'ppt/slides/slide{number}.xml'))
        actual=[row.xpath('.//a:t/text()',namespaces=ns) for row in slide.xpath('//a:tbl/a:tr',namespaces=ns)]
        assert actual[1:]==[[str(x) for x in row] for row in expected],number

reader=PdfReader(pdf)
assert len(reader.pages)==36
for i,page in enumerate(reader.pages,1):
    assert abs(float(page.mediabox.width)/float(page.mediabox.height)-16/9)<0.01
    msg=page.extract_text() or ''
    if i>=3 and i-2 not in dividers:
        assert len(msg.strip())>12,(i,'no extracted text')
    if i-2 in dividers:
        check_divider(msg, i-2)
    if i>25:
        assert f'A{i-25:02d}' in msg,(i,'missing folio')
    if i in (16,17,31,32):
        assert ('QSQL03' if i in (16,31) else 'QSQL09') in msg,i
    if i == 36:
        assert msg.count('END IF;') == 4,i
    assert allowed_wording(msg),i
    assert not re.search(r'^\s*Slide\s+(?:A)?\d+\s*$',msg,re.I|re.M),(i,'extra Slide label')
    assert '\ufffd' not in msg,(i,'replacement glyph')
print(json.dumps({'slide_count':36,'original_openers':2,'notes_count':34,'pdf_pages':36,
  'main_seconds':sum(expected_times),'template_parts_byte_identical':len(retained),
  'divider_pages':{i+2:d[1] for i,d in dividers.items()},
  'speaker_seconds':{r:sum(t for t,role in zip(expected_times,expected_roles) if role==r) for r in dict.fromkeys(expected_roles)},
  'original_figure_pages':{i+2:str(p.relative_to(workspace)) for i,p in figures.items()},
  'security_image_pages':{i+2:names for i,names in security_figures.items()},
  'native_table_slides':[i+2 for i in owners],'pptx_sha256':sha(deck),'pdf_sha256':sha(pdf)},ensure_ascii=False,indent=2))
