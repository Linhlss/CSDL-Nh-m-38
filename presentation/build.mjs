import fs from 'node:fs';
import path from 'node:path';
import {Presentation, PresentationFile} from '@oai/artifact-tool';
import {program, ra, sql, seed} from './story.mjs';

const build=process.env.HUST_BUILD;
const report='Báo_cáo_CSDL_nhóm_38';
const navy='#07345D', red='#AF1932', black='#203145', muted='#41586D', light='#EDF4FA', white='#FFFFFF', green='#21634E';
const p=Presentation.create({slideSize:{width:1280,height:720}});
const numbers=[98,8,23,17,31,1,27,2,4,56];
const savedChecks=JSON.parse(fs.readFileSync('tests/week1_execution_results.json','utf8')).checks;
const qsqlRows=Object.fromEntries(savedChecks.filter(row=>/^w1_seed\/QSQL\d{2}\/full-tuples$/.test(row.test))
 .map(row=>[row.test.split('/')[1],row.actual]));
const qsqlId=i=>`QSQL${String(i).padStart(2,'0')}`;
const byTo=qsqlRows.QSQL03.map(row=>[row.ma_to,row.ten_to,row.so_cu_dan]);
const oldLog=fs.readFileSync('tests/report_sql_01_10_log.txt','utf8');
const raSamples=oldLog.split('\n').slice(4,7).map(l=>l.split('|').slice(0,2).map(x=>x.trim()));
const sqlFull=Array.from(fs.readFileSync(path.join(report,'chuong5.tex'),'utf8').matchAll(/\\begin\{lstlisting\}\[style=sqlvn\]\n([\s\S]*?)\\end\{lstlisting\}/g),m=>m[1].trim());
const roles=[
 ['Thao tác','csdl17_admin','csdl17_reader','csdl17_report'],
 ['Đọc bảng nghiệp vụ','6 bảng','6 bảng','Từ chối'],
 ['Đọc bảng tài khoản','Được','Từ chối','Từ chối'],
 ['Đọc VIEW tổng hợp','Được','Từ chối','Được'],
 ['Sửa dữ liệu nghiệp vụ','Theo ràng buộc','Từ chối','Từ chối'],
 ['Xóa hai bảng lịch sử','Từ chối','Từ chối','Từ chối'],
];
const formula9='π[mã tài khoản, loại](BD) ÷ π[loại](BD)';
const matchRows=[['Tài khoản','Đến','Đi','Nội bộ'],...['1','2','3','4'].map(x=>[x,'Có','Có','Có']),['5','—','—','—']];
const toTable=[['Mã tổ','Tên tổ','Số cư dân'],...byTo];
const sampleTable=[['Mã biến động','Mã cư dân','Tổ cũ','Tổ mới','Ngày biến động'],
 ...qsqlRows.QSQL09.slice(0,3).map(row=>[row.ma_bien_dong,row.ma_cu_dan,row.ma_to_cu,row.ma_to_moi,
  row.ngay_bien_dong.split('-').reverse().join('/')])];
let slide, seq=0;
function text(value,x,y,w,h,z=23,{color=black,bold=false,font='Lato',align='left',name='',fill}={}){
 const o=slide.shapes.add({name:name||String(value).replaceAll('\n',' ').slice(0,70),geometry:'textbox',position:{left:x,top:y,width:w,height:h},fill:fill||'none'});
 o.text=value;
 o.text.style={fontSize:z+'pt',typeface:font,color,bold,alignment:align,insets:0,wrap:'square',autoFit:'none',verticalAlignment:'top'};
 return o;
}
function block(v,x,y,w,h,z=22,selected=false){
 const o=slide.shapes.add({geometry:'rect',name:v.split('\n')[0],position:{left:x,top:y,width:w,height:h},fill:selected?navy:light,line:{fill:selected?navy:'#BCD0E1',width:1}});
 o.text=v;o.text.style={fontSize:z+'pt',typeface:'Lato',color:selected?white:navy,bold:true,alignment:'center',verticalAlignment:'middle',insets:{left:8,right:8,top:4,bottom:4}};return o;
}
function ar(x,y,w=48){
 slide.shapes.add({geometry:'rightArrow',name:'Chiều liên kết',position:{left:x,top:y,width:w,height:20},fill:'#577C9E'});
}
function tbl(values,x,y,widths,row=46,z=18,accent=-1){
 const t=slide.tables.add({rows:values.length,columns:widths.length,left:x,top:y,width:widths.reduce((a,b)=>a+b,0),height:row*values.length,columnWidths:widths,values:values.map(r=>r.map(String))});
 t.styleOptions={headerRow:false,bandedRows:false};
 for(const [i,rv] of values.entries()){
  t.rows[i].height=row;
  for(let j=0;j<rv.length;j++){
   const c=t.getCell(i,j);c.fill=i===0?navy:i===accent?'#D6E9FA':i%2?light:white;
   c.text.style={fontSize:z+'pt',typeface:'Lato',bold:i===0||i===accent,color:i===0?white:black,
    alignment:j===0?'left':'left',verticalAlignment:'middle',insets:4,wrap:'square'};
  }
 }
 t.borders.assign({style:'solid',fill:'#CFDFEC',width:0.65});
 return t;
}
function txtLines(items,x,y,w,{step=102,size=20}={}){
 for(const [i,[heading,body]] of items.entries()){
  text(heading,x,y+step*i,w,36,size+2,{color:navy,bold:true});
  text(body,x,y+step*i+39,w,step-39,size);
 }
}
function eq(str,x,y,w,h=44,z=24){text(str,x,y,w,h,z,{font:'Arial',color:navy,bold:true});}
function code(str,x,y,w,h,z=15){text(str,x,y,w,h,z,{font:'Courier New',color:navy,fill:'#EFF5FA'});}
function picture(file,box,alt,crop){
 const bytes=fs.readFileSync(file),svg=file.endsWith('.svg');
 slide.images.add({blob:bytes,contentType:svg?'image/svg+xml':'image/png',alt,
  ...(crop?{fit:'cover',crop}:{fit:'contain'}),
  position:{left:box[0],top:box[1],width:box[2],height:box[3]}});
}
function securityPicture(name,x,y,width,cropWidth,alt,top=188){
 const file=path.join(report,'image/security',name);
 const png=fs.readFileSync(file);
 const originalWidth=png.readUInt32BE(16), originalHeight=png.readUInt32BE(20);
 picture(file,[x,y,width,width*(originalHeight-top)/cropWidth],alt,{
  left:0,top:top/originalHeight,right:1-cropWidth/originalWidth,bottom:0,
 });
}
function idx(rows,x=55,y=147,w=552){
 for(const [i,[what,tag]] of rows.entries()){
  const j=i%5, left=x+Math.floor(i/5)*600;
  text(String(i+1).padStart(2,'0'),left,y+j*89,48,38,20,{color:red,bold:true});
  text(what,left+48,y+j*89,w-49,60,19,{color:navy,bold:true});
  text(tag,left+48,y+59+j*89,w-49,26,14,{color:muted});
 }
}
const sql3Join=sqlFull[2].slice(sqlFull[2].indexOf('LEFT JOIN qua_trinh_cu_tru'),sqlFull[2].indexOf('GROUP BY'))
 .trim().split('\n').map(line=>line.trimStart()).join('\n')
 .replace(' AS q ON q.ma_ho', ' AS q\n  ON q.ma_ho').replace(' OR q.ngay_ket_thuc', '\n      OR q.ngay_ket_thuc');
const sql9Filter=sqlFull[8].slice(sqlFull[8].indexOf('WHERE'),sqlFull[8].indexOf('ORDER BY')).trimEnd();
for(const s of program){
 seq=s.id;slide=p.slides.add();
 const {tag,clock,cue}=s;
 slide.speakerNotes.text=[`${tag} · ${s.who} · ${s.secs?s.secs+' giây · Lũy kế '+clock:'Phụ lục hỏi đáp'}`,s.notes,...(cue?.[0]?[`Thao tác (${cue[0]} giây) · ${cue[1]}`]:[]),'Nguồn: '+s.refs.join(' • ')].join('\n\n');

 if(s.number){
  text(`PHẦN ${s.number}`,534,257,625,38,19,{color:red,bold:true});
  text(s.title,530,315,685,82,37,{color:navy,bold:true,name:'Tiêu đề phần'});
  continue;
 }
 if(seq!==1&&seq!==20){
  if(seq>20)text('PHỤ LỤC · HỎI ĐÁP',1006,23,217,28,13,{color:white,bold:true,align:'right'});
  text(s.title,55,12,seq<=20?1170:945,55,31,{color:white,bold:true,name:'Tiêu đề'});
  text(tag,1164,642,61,22,12,{color:muted,align:'right',name:'Số slide'});
 }
 switch(seq){
 case 1:
  text('Xây dựng cơ sở dữ liệu\nquản lý cư dân và\nbiến động cư trú',53,173,765,223,43,{color:'#A51025',bold:true,name:'Tiêu đề'});
  text('Tại một phường',56,383,735,55,27,{color:navy,bold:true});
  text('Bài tập lớn Cơ sở dữ liệu · Đề tài 17 · Nhóm 38\nLớp 174356 · GVHD ThS. Nguyễn Thị Thanh Huyền',56,450,790,65,18,{color:navy});
  text('Trần Bùi Tùng Linh  20227057\nTrần Tuấn Ngọc       20227064\nDương Ngọc Ninh     20237469',56,524,714,103,18,{color:black});
  break;
 case 2:
  text('Một cư dân chuyển từ hộ A sang hộ B',60,133,1150,64,30,{color:navy,bold:true});
  txtLines([['Nơi ở hiện tại','Người này hiện thuộc hộ nào?'],['Lịch sử cư trú','Người này từng ở hộ A trong khoảng thời gian nào?'],['Ghi nhận biến động','Ai ghi nhận lần chuyển, vào lúc nào?']],60,220,1150,{step:76,size:19});
  text('Nếu chỉ lưu địa chỉ hiện tại, cập nhật sang hộ B sẽ làm mất lịch sử cư trú ở hộ A.',60,503,1150,90,22,{color:navy,bold:true});
  break;
 case 3:
  text('Đề tài xét một phường gồm nhiều tổ dân phố, địa chỉ và hộ cư trú.',60,142,1150,62,24);
  block('Đợt tại hộ A\nKết thúc trước một ngày',68,260,329,115,20);
  ar(410,307,55);
  block('Biến động chuyển hộ\nTài khoản và thời điểm ghi',476,260,330,115,20,true);
  ar(819,307,55);
  block('Đợt tại hộ B\nBắt đầu vào ngày chuyển',884,260,329,115,20);
  text('Tra cứu người đang ở, lịch sử cư trú và thống kê theo tổ.',60,434,1150,60,23,{color:navy,bold:true});
  text('Nhóm thiết kế và kiểm tra ràng buộc, truy vấn và quyền truy cập trên PostgreSQL 17.',60,511,1150,60,20);
  break;
 case 4:
  picture(path.join(report,'image/phan_ra_chuc_nang.png'),[143,111,995,509],'Cây phân rã gốc gồm 6 nhóm và 14 chức năng cấp 2');
  break;
 case 5:
  txtLines([['Địa bàn','Tổ dân phố · Địa chỉ · Hộ cư trú'],['Hồ sơ','Cư dân · Tài khoản']],65,143,1120,{step:90,size:21});
  block('Cư dân',122,360,237,88,25);ar(371,394,82);
  block('Quá trình cư trú',465,360,350,88,25,true);ar(824,394,82);
  block('Hộ cư trú',914,360,237,88,25);
  text('Biến động cư trú ghi nhận việc chuyển đến, chuyển đi hoặc chuyển nội bộ.',70,507,1120,80,23);
  break;
 case 6:
  picture('erd.png',[58,106,619,530],'Ảnh ERD Chen gốc của nhóm', {
   left:1900/6375, right:1900/6375, top:300/2805, bottom:300/2805
  });
  txtLines([['Địa bàn','Tổ quản lý địa chỉ. Địa chỉ chứa hộ.'],['Đợt cư trú','Mỗi đợt gắn một cư dân và một hộ.'],['Biến động','Đợt cũ và đợt mới là hai liên kết riêng. Mỗi biến động có tài khoản ghi nhận.']],710,173,498,{step:126,size:20});
  break;
 case 7:
  picture('diagrams/erd_v1.png',[51,109,763,530],'Ảnh gốc lược đồ bảy bảng của nhóm', {
   left:40/2300, right:40/2300, top:25/1626, bottom:60/1626
  });
  text('7 bảng · 35 cột',855,135,369,53,25,{color:navy,bold:true});
  text('7 khóa chính và 7 khóa ngoại',855,189,370,68,20,{color:muted});
  txtLines([['Khóa ngoại phía N','Địa chỉ giữ mã tổ. Hộ giữ mã địa chỉ.'],
   ['Hai khóa ngoại về đợt','Đợt cũ và đợt mới có thể để trống tùy loại biến động.']],
   855,292,369,{step:139,size:18});
  break;
 case 8:
  text('Một bảng gộp',63,160,360,45,24,{color:navy,bold:true});
  text('Mỗi lần chuyển sẽ lặp họ tên, địa chỉ và thông tin người ghi.',63,216,349,184,24);
  ar(425,259,69);
  tbl([['Tách bảng','Phụ thuộc hàm'],['Cư dân','ma_cu_dan xác định hồ sơ'],['Hộ','ma_ho xác định địa chỉ và ngày lập'],['Đợt cư trú','ma_qua_trinh xác định người, hộ, loại, khoảng ngày'],['Biến động','ma_bien_dong xác định sự kiện và tài khoản']],528,155,[186,509],66,17);
  text('Kết luận 3NF có điều kiện. B09 kiểm soát phần dư thừa của ngày biến động.',63,526,1150,84,23,{color:navy,bold:true});
  break;
 case 9:
  text('B06 · Khoảng ngày',56,144,380,45,21,{color:navy,bold:true});
  block('Đợt A',459,139,300,43,17);
  block('Đợt B',674,185,276,43,17);
  text('PostgreSQL từ chối đợt giao khoảng nếu cùng người và loại.',458,235,749,40,17,{color:red,bold:true});
  text('B09 · Ngày chuyển t',56,304,380,49,21,{color:navy,bold:true});
  block('Đợt cũ kết thúc t − 1',459,293,292,59,17);
  ar(762,312,54);
  block('Đợt mới bắt đầu t',829,293,374,59,17,true);
  text('Trigger đối chiếu ngày của biến động và hai đợt.',459,367,749,38,17);
  text('B10 · Một giao dịch',56,457,382,55,21,{color:navy,bold:true});
  block('Đóng đợt cũ',459,445,209,59,17);
  ar(677,464,31);
  block('Mở đợt mới',718,445,209,59,17);
  ar(937,464,31);
  block('Ghi biến động',978,445,225,59,17,true);
  text('Một bước lỗi thì PostgreSQL hoàn tác cả chuỗi.',460,522,729,66,19,{color:navy,bold:true});
  break;
 case 10:
  text('636',96,202,447,170,108,{color:navy,bold:true});
  text('bản ghi kiểm thử',107,370,458,62,30,{color:navy,bold:true});
  text('PostgreSQL 17',109,447,420,54,23,{color:muted});
  tbl([['Bảng','Số bản ghi'],...seed],637,143,[345,213],53,21);
  break;
 case 11: idx(ra);break;
 case 12:
  text('Đầu vào Q_ht gồm 5 cột NOT NULL của các đợt còn hiệu lực.',56,129,1160,53,21,{color:muted});
  txtLines([['1. Chọn các đợt thường trú','R_1 = σ[loại = THUONG_TRU](Q_ht)'],['2. Lấy các hộ của Tổ 01','R_2 = π[mã hộ](Hộ ⋈ địa chỉ thuộc Tổ 01)'],['3. Nối rồi chiếu kết quả','Nối R_1 với R_2 theo mã hộ, nối cư dân theo mã cư dân.\nChiếu mã và họ tên.']],57,205,652,{step:115,size:19});
  text('23 bộ · Trích 3 dòng',772,211,428,45,23,{color:navy,bold:true});
  tbl([['Mã cư dân','Họ tên'],...raSamples],771,270,[137,323],59,18);
  break;
 case 13:
  eq(formula9,55,135,1170,61,28);
  tbl(matchRows,59,227,[189,155,155,155],58,20,4);
  txtLines([['Tập loại trong dữ liệu','Chuyển đến, chuyển đi, chuyển nội bộ.'],['Kết quả','Tài khoản 1, 2, 3, 4.\nTài khoản 5 chưa ghi biến động.']],770,235,431,{step:138,size:21});
  break;
 case 14: idx(sql);break;
 case 15:
  text('Điều kiện hiệu lực đặt trong ON',55,132,642,45,22,{color:navy,bold:true});
  code(sql3Join,55,201,659,237,15);
  text('COUNT(DISTINCT q.ma_cu_dan) đếm mỗi cư dân một lần trong tổ.',55,469,650,98,21);
  tbl(toTable,755,137,[124,155,186],49,17,8);
  break;
 case 16:
  block('Biến động',57,139,220,62,18,true);ar(289,159,37);
  block('Đợt cũ và đợt mới',340,139,339,62,18);
  ar(691,159,37);block('Hộ, địa chỉ và mã tổ',744,139,425,62,18);
  code(sql9Filter,55,229,1168,111,18);
  text('22 lần chuyển giữa hai tổ · Trích 3 dòng đầu',55,359,1168,40,19,{color:navy,bold:true});
  tbl(sampleTable,55,410,[226,192,173,174,404],47,17);
  break;
 case 17:
  text('Đăng nhập trực tiếp bằng csdl17_reader',55,122,1170,52,27,{color:navy,bold:true});
  text('Đọc được 200 cư dân',55,196,555,38,21,{bold:true});
  text('Từ chối ghi và đọc bảng tài khoản',650,196,575,38,21,{bold:true});
  securityPicture('SEC_B1_select_ok.png',55,244,555,1180,'Phiên reader đọc được 200 cư dân');
  securityPicture('SEC_B1_denied.png',650,244,575,1320,'Phiên reader bị từ chối thao tác ghi và đọc bảng tài khoản');
  text('Reader có quyền SELECT trên 6 bảng nghiệp vụ.',55,510,1169,42,20);
  text('Admin bị thu hồi quyền DELETE trên hai bảng lịch sử.',55,550,1169,42,20);
  break;
 case 18:
  text('Đăng nhập trực tiếp bằng csdl17_report',55,122,1170,52,27,{color:navy,bold:true});
  text('Đọc được VIEW tổng hợp theo 8 tổ',55,196,555,38,21,{bold:true});
  text('Từ chối đọc trực tiếp hai bảng gốc',650,196,575,38,21,{bold:true});
  securityPicture('SEC_B2_view_ok.png',55,244,555,1180,'Phiên report đọc VIEW có ba cột và tám tổ');
  securityPicture('SEC_B2_denied.png',650,244,575,1320,'Phiên report bị từ chối đọc hai bảng gốc',202);
  text('VIEW trả mã tổ, tên tổ và số cư dân.',650,455,575,55,19);
  text('B3 · Truy vấn tra cứu dùng tham số để giữ dữ liệu nhập tách khỏi câu lệnh.',55,555,1169,65,20,{color:navy,bold:true});
  break;
 case 19:
  txtLines([['Dữ liệu nạp vào cơ sở dữ liệu','636 bản ghi trên 7 bảng. Kiểm tra dữ liệu đạt.'],['Kết quả truy vấn','10 QSQL khớp toàn bộ các dòng đối chiếu.'],['Kiểm tra kết quả','24 hộ có từ 4 người. Tổ 08 và tài khoản 5 đều có số đếm bằng 0.']],60,155,1160,{step:135,size:22});
  break;
 case 20:
  text('Cảm ơn cô đã lắng nghe',508,155,685,100,36,{color:'#A51025',bold:true,name:'Tiêu đề'});
  txtLines([['Mô hình cư trú theo thời gian','Lưu đợt và biến động để tra cứu lịch sử.'],['Ràng buộc trong PostgreSQL','Kiểm tra khoảng ngày và tính nguyên tử.'],['Truy vấn và quyền truy cập','Kiểm chứng trên cùng bộ dữ liệu kiểm thử.']],508,267,699,{step:96,size:17});
  text('Nhóm sẵn sàng trả lời câu hỏi.',508,578,690,50,20,{bold:true,color:navy});
  text(tag,1164,682,61,22,12,{color:muted,align:'right',name:'Số slide'});
  break;
 case 21:
  tbl([['Câu','Nội dung','Phép toán','Số bộ'],...ra.map(([a,b],n)=>[n+1,a,b,numbers[n]])],55,142,[78,761,199,127],40,16);
  break;
 case 22:
  text('Q_ht giữ ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau.',55,149,1170,74,21,{color:muted});
  eq('R_1 = σ[loai_cu_tru = THUONG_TRU](Q_ht)',60,238,1156,50,24);
  eq('R_2 = π[ma_ho](HO ⋈[HO.ma_dia_chi = DC.ma_dia_chi] σ[ma_to = 1](DC))',60,307,1156,52,23);
  eq('R_3 = R_1 ⋈[R_1.ma_ho = R_2.ma_ho] R_2',60,376,1156,50,24);
  eq('KQ = π[CD.ma_cu_dan, ho_ten](R_3 ⋈[R_3.ma_cu_dan = CD.ma_cu_dan] CD)',60,445,1156,50,23);
  break;
 case 23:
  eq(formula9,55,149,1170,65,29);
  txtLines([['Quan hệ bị chia','Các cặp (mã tài khoản, loại biến động) phân biệt trong BD.'],['Quan hệ chia','Tập loại biến động xuất hiện trong BD. Mẫu có 3 loại.'],['Điều kiện và tập trả về','Với mọi loại trong số chia, cặp tài khoản và loại đều có trong số bị chia.\nKết quả {1, 2, 3, 4}.']],57,251,1150,{step:107,size:20});
  break;
 case 24:
  txtLines([['RA 4 · Hiệu','π[mã cư dân](Qbd) − π[mã cư dân](Qht), rồi nối hồ sơ.\nHiện tại không còn đợt hiệu lực.'],['RA 5 · Giao','π[mã cư dân](đợt tạm trú) ∩ π[mã cư dân](đợt thường trú).\nCư dân có cả hai loại trong lịch sử.'],['RA 6 · Hợp','π[mã biến động](BD nối đợt cũ của cư dân 92)\n∪ π[mã biến động](BD nối đợt mới của cư dân 92).']],58,147,1160,{step:153,size:20});
  break;
 case 25:
  tbl([['Mã câu','Nội dung','Kỹ thuật chính','Số dòng'],...sql.map(([a,b],n)=>[qsqlId(n+1),a,b,qsqlRows[qsqlId(n+1)].length])],55,142,[145,582,325,113],41,15);
  break;
 case 26:
  {const full=sqlFull[2].split('\n').map(l=>l.trimStart()).join('\n').replace(' OR q.ngay_ket_thuc','\n  OR q.ngay_ket_thuc');
   code(full,54,140,749,448,13);
   tbl(toTable,825,145,[98,130,163],47,15,8);
  }break;
 case 27:
  code(sqlFull[8],55,108,1168,342,13);
  tbl(sampleTable,55,465,[228,191,174,174,401],34,15);
  break;
 case 28:
  tbl([['Mã','Kiểm tra','Kết quả quan sát'],['B06','Hai đợt cùng người và cùng loại giao ngày','GiST từ chối với 23P01'],['B09','Sửa ngày đợt làm lệch ngày biến động','Trigger từ chối với 23514'],['B10','Lỗi khóa ngoại giữa chuỗi thao tác chuyển nội bộ','23503. Toàn bộ giao dịch hoàn tác.'],['B10','Đóng cũ, mở mới và ghi biến động hợp lệ','Ba bước thành công nhất quán']],55,149,[118,570,477],89,18);
  break;
 case 29:
  tbl(roles,55,144,[344,276,268,277],48,16);
  tbl([['Kiểm tra','Kết quả đã ghi'],['Catalog quyền','15/15 đạt'],['Đăng nhập độc lập','Reader 12/12 đạt. Report 10/10 đạt.'],['B12 K01–K05','Ma trận quyền khớp. DELETE/TRUNCATE lịch sử bị chặn.']],55,454,[357,808],38,16);
  break;
 case 30:
  tbl([['Bảng','Số bản ghi'],...seed],55,146,[279,153],49,17);
  txtLines([['Kiểm chứng trên bộ 636 bản ghi','10 QSQL khớp toàn bộ dòng đối chiếu. Đại số quan hệ có 8 kiểm tra đạt và 2 câu ghi nhận kết quả.'],['B3 trên cơ sở dữ liệu thử nghiệm','Với cùng đầu vào thử, ghép chuỗi trả 200 dòng và dùng tham số trả 0. Từ khóa Hùng trả 8 dòng.'],['Hướng mở rộng','Kiểm toán cập nhật lịch sử, phân quyền theo tổ và quy tắc công bố nhóm nhỏ.']],529,153,681,{step:134,size:19});
  break;
 case 31: {
  const constraints = fs.readFileSync('sql/02_constraints.sql','utf8');
  const start = constraints.indexOf('    IF p_cu IS NOT NULL THEN');
  const end = constraints.indexOf("\n\n    IF p_loai = 'CHUYEN_NOI_BO' THEN", start);
  const dateChecks = constraints.slice(start,end)
   .replace(/^ {8}IF NOT FOUND THEN\n[\s\S]*?^ {8}END IF;\n/gm,'')
   .split('\n').filter(Boolean).map(line=>line.slice(4)).join('\n');
  code('-- fn_kiem_tra_su_kien: trích phần kiểm tra ngày\n'+dateChecks,55,108,1168,366,13);
  tbl([
   ['Chiều kiểm tra','Trigger','Khi chạy'],
   ['Thuận','trg_bien_dong_hop_le','Thêm hoặc sửa biến động'],
   ['Ngược','trg_dot_khong_pha_su_kien','Sửa cư dân, hộ hoặc ngày của đợt'],
  ],55,490,[203,493,469],43,17);
  break;
 }
 }
}
await (await PresentationFile.exportPptx(p)).save(path.join(build,'native.pptx'));
fs.writeFileSync(path.join(build,'hust-layouts.json'),JSON.stringify(program.map(item=>item.layout)));
