# Claude Code - Bản Vá Bộ Gõ Tiếng Việt

Sửa lỗi nhập liệu tiếng Việt (OpenKey, EVKey, Unikey, PHTV) cho terminal Claude Code.

## Vấn Đề

Bộ gõ tiếng Việt sử dụng kỹ thuật "backspace-rồi-thay-thế" để chuyển đổi ký tự (`a` → `á`). Claude Code xử lý phím backspace (ký tự DEL 0x7F) nhưng không hiển thị được các ký tự thay thế, gây mất chữ.

## Giải Pháp

Bản vá này chặn xử lý ký tự DEL và chèn lại các ký tự còn lại một cách đúng đắn.

## Phiên Bản Đã Kiểm Tra

- Claude Code v2.1.12 (Tháng 1/2026)
- macOS (cài đặt qua Homebrew/npm)

## Cài Đặt Nhanh

```bash
# Clone hoặc tải repo này
git clone https://github.com/hangocduong/claude-code-vietnamese-fix.git
cd claude-code-vietnamese-fix

# Chạy trình cài đặt
./install.sh
```

## Cài Đặt Thủ Công

```bash
# Sao chép scripts vào ~/.claude/scripts/
mkdir -p ~/.claude/scripts
cp scripts/*.sh scripts/*.py ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh ~/.claude/scripts/*.py

# Thêm aliases vào file cấu hình shell
echo 'alias claude-vn-patch="$HOME/.claude/scripts/vietnamese-ime-patch.sh"' >> ~/.zshrc
echo 'alias claude-update="$HOME/.claude/scripts/claude-update-wrapper.sh"' >> ~/.zshrc
source ~/.zshrc

# Áp dụng bản vá
claude-vn-patch
```

## Cách Sử Dụng

| Lệnh | Mô tả |
|------|-------|
| `claude-vn-patch` | Áp dụng bản vá (mặc định) |
| `claude-vn-patch status` | Kiểm tra bản vá đã được áp dụng chưa |
| `claude-vn-patch restore` | Khôi phục cli.js gốc |
| `claude-update` | Cập nhật Claude + tự động áp dụng bản vá |

## Sau Khi Claude Cập Nhật

Chạy một trong các lệnh sau:
```bash
claude-vn-patch      # Chỉ áp dụng bản vá
claude-update        # Cập nhật + áp dụng bản vá
```

## Cách Hoạt Động

### Lỗi

```
Người dùng gõ: "xin chào" bằng bộ gõ tiếng Việt
Bộ gõ gửi: x → xi → xin → xin<DEL>c → xin ch → xin ch<DEL>à → xin chà<DEL>o → xin chào
Claude xử lý: <DEL> xóa ký tự, nhưng các ký tự còn lại bị mất
Kết quả: "xin c" thay vì "xin chào"
```

### Cách Sửa

1. **Phát hiện** khối xử lý ký tự DEL trong cli.js đã được minify
2. **Trích xuất** tên biến động (chúng thay đổi giữa các phiên bản)
3. **Chèn** mã:
   - Lọc bỏ ký tự DEL khỏi input
   - Chèn lại các ký tự còn lại đúng cách
   - Cập nhật trạng thái text/offset

### Trích Xuất Biến Động

Script sử dụng regex để tìm các pattern như:
```javascript
// Mã gốc (đã minify)
if(l.includes("\x7f")){
  let $A=(l.match(/\x7f/g)||[]).length,CA=S;
  for(let _A=0;_A<$A;_A++)CA=CA.backspace();
  if(!S.equals(CA)){if(S.text!==CA.text)Q(CA.text);T(CA.offset)}
  // ... BẢN VÁ ĐƯỢC CHÈN VÀO ĐÂY ...
  ct1(),lt1();return
}
```

Trích xuất: `input=l, state=CA, cur_state=S, text_fn=Q, offset_fn=T`

### Mã Được Chèn

```javascript
let _vn=l.replace(/\x7f/g,"");
if(_vn.length>0){
  for(const _c of _vn)CA=CA.insert(_c);
  if(!S.equals(CA)){
    if(S.text!==CA.text)Q(CA.text);
    T(CA.offset)
  }
}
```

## Cấu Trúc Dự Án

```
claude-code-vietnamese-fix/
├── README.md
├── install.sh                           # Trình cài đặt một lệnh
├── scripts/
│   ├── vietnamese-ime-patch.sh          # Điểm vào (bash)
│   ├── vietnamese-ime-patch-core.py     # Logic chính (python)
│   └── claude-update-wrapper.sh         # Wrapper cập nhật + vá
└── docs/
    └── technical-details.md             # Chi tiết kỹ thuật về bản vá
```

## Yêu Cầu

- Python 3.6+
- Claude Code được cài đặt qua npm (`npm install -g @anthropic-ai/claude-code`)
- macOS hoặc Linux

## Xử Lý Sự Cố

### "Could not find Claude Code cli.js" (Không tìm thấy cli.js của Claude Code)

Claude Code chưa được cài đặt hoặc được cài đặt dạng binary (không phải npm). Cài đặt bằng:
```bash
npm install -g @anthropic-ai/claude-code
```

### "Could not extract variables" (Không thể trích xuất biến)

Phiên bản Claude Code có thể đã thay đổi đáng kể. Mở issue với:
```bash
claude --version
```

### "Patch already applied" (Bản vá đã được áp dụng)

Bản sửa lỗi đã hoạt động. Kiểm tra bằng:
```bash
claude-vn-patch status
```

## Ghi Công

- Ý tưởng sửa lỗi ban đầu: [manhit96/claude-code-vietnamese-fix](https://github.com/manhit96/claude-code-vietnamese-fix)
- Trích xuất động & hỗ trợ v2.1.12: Dự án này

## Giấy Phép

MIT
