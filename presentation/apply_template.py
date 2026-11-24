"""Keep HUST package masters, layouts, theme and branding byte for byte."""
from copy import deepcopy
from pathlib import Path
import json
import posixpath
import re
import sys
from lxml import etree as E
from zipfile import ZipFile, ZIP_DEFLATED

P = 'http://schemas.openxmlformats.org/presentationml/2006/main'
R = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
PR = 'http://schemas.openxmlformats.org/package/2006/relationships'
CT = 'http://schemas.openxmlformats.org/package/2006/content-types'
A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
MC = 'http://schemas.openxmlformats.org/markup-compatibility/2006'
P14 = 'http://schemas.microsoft.com/office/powerpoint/2010/main'
q = lambda ns, tag: f'{{{ns}}}{tag}'
for prefix, url in [('p',P),('a',A),('r',R),('mc',MC),('p14',P14)]:
    E.register_namespace(prefix,url)

template, native, dest = map(Path, sys.argv[1:4])
layouts = json.loads(native.with_name('hust-layouts.json').read_text())
with ZipFile(template) as z:
    files = {n:z.read(n) for n in z.namelist() if not n.endswith('/')}
with ZipFile(native) as z:
    components={n:z.read(n) for n in z.namelist() if not n.endswith('/')}
def xml(source, path):
    return E.fromstring(source[path])
def write(path, tree):
    files[path]=E.tostring(tree, encoding='utf-8', xml_declaration=True)
def slide_name(n):
    return f'ppt/slides/slide{n}.xml'
def rel_name(n):
    return f'ppt/slides/_rels/slide{n}.xml.rels'

styles = {n:(xml(files,slide_name(n)),xml(files,rel_name(n))) for n in (3,4,13)}
openers = [(files[slide_name(n)], files[rel_name(n)]) for n in (1,2)]
pres_path='ppt/presentation.xml'
pres=xml(files,pres_path)
for node in list(pres):
    if node.tag in {q(P,'extLst'),q(P,'custShowLst')}:
        pres.remove(node)
ids=pres.find(q(P,'sldIdLst'))
ids.clear()
pres_rel_path='ppt/_rels/presentation.xml.rels'
pres_rels=xml(files,pres_rel_path)
for node in list(pres_rels):
    if node.get('Type','').endswith('/slide'):
        pres_rels.remove(node)
typ=xml(files,'[Content_Types].xml')
for n in list(typ):
    if re.match(r'/ppt/slides/slide\d+\.xml$',n.get('PartName','')):
        typ.remove(n)
existing_parts={x.get('PartName') for x in typ}
for n in xml(components,'[Content_Types].xml'):
    if n.get('PartName','').startswith('/ppt/notesSlides/') and n.get('PartName') not in existing_parts:
        typ.append(deepcopy(n))
for n,b in components.items():
    if n.startswith('ppt/notesSlides/'):
        files[n]=b

def register_slide(n):
    rel_id=f'rIdCSDL{n}'
    E.SubElement(ids,q(P,'sldId'),{'id':str(255+n),q(R,'id'):rel_id})
    E.SubElement(pres_rels,q(PR,'Relationship'),{'Id':rel_id,'Type':R+'/slide','Target':f'slides/slide{n}.xml'})
    E.SubElement(typ,q(CT,'Override'),{'PartName':'/'+slide_name(n),'ContentType':'application/vnd.openxmlformats-officedocument.presentationml.slide+xml'})

# Store the two originals in unused parts to preserve all existing slide and
# speaker-note relationships. Presentation order puts them before the cover.
for n,(opener,relationships) in enumerate(openers,start=len(layouts)+1):
    files[slide_name(n)]=opener
    files[rel_name(n)]=relationships
    register_slide(n)

for n,layout in enumerate(layouts,start=1):
    base, base_rels=styles[layout]
    slide=deepcopy(base)
    for node in list(slide):
        if node.tag in {q(P,'timing'),q(P,'transition'),q(P,'extLst')}:
            slide.remove(node)
    tree=slide.find(f'{q(P,"cSld")}/{q(P,"spTree")}')
    for el in list(tree):
        if el.tag not in {q(P,'nvGrpSpPr'),q(P,'grpSpPr')} and not (n==1 and el.tag==q(P,'pic')):
            tree.remove(el)
    native_tree=xml(components,slide_name(n)).find(f'{q(P,"cSld")}/{q(P,"spTree")}')
    taken={int(x.get('id')) for x in tree.iter(q(P,'cNvPr'))}
    for el in native_tree:
        if el.tag in {q(P,'nvGrpSpPr'),q(P,'grpSpPr')}:
            continue
        el=deepcopy(el)
        for nv in el.iter(q(P,'cNvPr')):
            counter=int(nv.get('id'))
            while counter in taken:
                counter+=1
            taken.add(counter)
            nv.set('id',str(counter))
        tree.append(el)
    rels=deepcopy(base_rels)
    for rel in list(rels):
        if rel.get('Type','').endswith('/slideLayout') or (n==1 and rel.get('Type','').endswith('/image')):
            continue
        rels.remove(rel)
    for rel in xml(components,rel_name(n)):
        relation=rel.get('Type','').rsplit('/',1)[-1]
        if relation=='slideLayout':
            continue
        target=rel.get('Target','')
        part=target.lstrip('/') if target.startswith('/') else posixpath.normpath(posixpath.join('ppt/slides',target))
        if relation=='image':
            destpart=f'ppt/media/csdl_{n}_{Path(part).name}'
            files[destpart]=components[part]
            rel.set('Target','../media/'+Path(destpart).name)
        elif relation=='notesSlide':
            rel.set('Target',f'../notesSlides/notesSlide{n}.xml')
        else:
            raise ValueError(f'Unexpected relationship for slide {n}: {relation}')
        rels.append(deepcopy(rel))
    write(slide_name(n),slide)
    write(rel_name(n),rels)
    register_slide(n)
write(pres_path,pres)
write(pres_rel_path,pres_rels)
write('[Content_Types].xml',typ)
app='docProps/app.xml'
if app in files:
    tree=xml(files,app)
    ns='http://schemas.openxmlformats.org/officeDocument/2006/extended-properties'
    for tag, value in [('Slides',str(len(layouts)+len(openers))),('Notes',str(len(layouts))),('HiddenSlides','0')]:
        el=tree.find(q(ns,tag))
        if el is not None:
            el.text=value
    write(app,tree)
with ZipFile(dest,'w',ZIP_DEFLATED) as z:
    for n,data in files.items():
        z.writestr(n,data)
