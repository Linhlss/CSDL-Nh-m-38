import fs from 'node:fs';
import { program } from './story.mjs';
const opening='Hai trang nhận diện HUST đứng trước bìa và trước khi bắt đầu tính giờ. Khung 20 phút gồm 20 slide nội dung và ba trang phân phần. Mười một phụ lục A01–A11 dùng khi hỏi đáp.';
let board='# Storyboard thuyết trình đề tài 17\n\n'+opening+'\n\n| Trang PDF | Mục | Tiêu đề | Thông điệp | Thành phần hình ảnh | Người nói | Thời lượng / lũy kế | Nguồn chính |\n|---:|---|---|---|---|---|---|---|\n';
let source='# Nguồn nội dung theo slide\n\nHai trang nhận diện và ba trang phân phần dùng bố cục gốc của mẫu PowerPoint HUST. Nội dung chuyên môn dựa trên báo cáo LaTeX hiện hành. Phép chia dùng RA 9 của báo cáo. Phần SQL theo mã QSQL01–QSQL13 (mười câu chính và ba câu bổ sung). Hai câu trình bày chính là QSQL03 và QSQL09.\n\n| Mục | Nội dung đối chiếu | Nguồn | Trạng thái |\n|---|---|---|---|\n';
let notebook='# Lời nhắc diễn giả\n\n'+opening+' Ghi chú cũng có trong Notes của PPTX.\n';
for(const [i,item] of program.entries()) {
 const {id,tag,cue}=item, time=item.secs?item.secs+' giây / '+item.clock:'Hỏi đáp';
 const speaker=item.name?item.name+' ('+item.who+')':item.who;
 board+=`| ${i+3} | ${tag} | ${item.title} | ${item.point} | ${item.visual} | ${speaker} | ${time} | \`${item.refs[0]}\` |\n`;
 const evidence=item.number?'Bố cục gốc trong mẫu HUST':([11,21].includes(id)?'Danh mục đối chiếu với LaTeX và bảng đối chiếu Chương 4.':(item.refs.some(x=>x.includes('log'))?'Đối chiếu log PostgreSQL và báo cáo':'Đối chiếu báo cáo và nguồn thiết kế'));
 source+=`| ${tag} | ${item.point} | ${item.refs.map(x=>'\x60'+x+'\x60').join(', ')} | ${evidence} |\n`;
 notebook+=`\n## ${tag} · ${item.title}\n\n${speaker} · ${time}\n\n${item.notes}\n\n${cue?.[0]?`Thao tác (${cue[0]} giây) · ${cue[1]}\n\n`:''}Nguồn ${item.refs.map(x=>'\x60'+x+'\x60').join(', ')}.\n`;
}
fs.writeFileSync('presentation/STORYBOARD.md',board);
fs.writeFileSync('presentation/SOURCE_MAP.md',source);
fs.writeFileSync('presentation/SPEAKER_NOTES.md',notebook);
