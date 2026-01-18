# Claude Code - Bản Vá Bộ Gõ Tiếng Việt

[![Version](https://img.shields.io/github/v/release/hangocduong/claude-code-vietnamese-fix?label=version)](https://github.com/hangocduong/claude-code-vietnamese-fix/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)

> Sửa lỗi nhập liệu tiếng Việt (OpenKey, EVKey, Unikey, PHTV) cho terminal Claude Code.

---

## Cài Đặt Nhanh

**Một dòng lệnh duy nhất:**

```bash
curl -fsSL https://raw.githubusercontent.com/hangocduong/claude-code-vietnamese-fix/main/install.sh | bash
```

Hoặc nếu bạn muốn xem trước script:

```bash
curl -fsSL https://raw.githubusercontent.com/hangocduong/claude-code-vietnamese-fix/main/install.sh -o install.sh
cat install.sh  # Xem nội dung
bash install.sh # Chạy cài đặt
```

---

## Sử Dụng

| Lệnh | Mô tả |
|------|-------|
| `claude-vn-patch` | Áp dụng bản vá |
| `claude-vn-patch status` | Kiểm tra trạng thái |
| `claude-vn-patch restore` | Khôi phục file gốc |
| `claude-update` | Cập nhật Claude + tự động vá |

**Sau khi Claude cập nhật:** Chạy `claude-vn-patch` hoặc `claude-update`

---

## Vấn Đề & Giải Pháp

### Vấn đề

Bộ gõ tiếng Việt sử dụng kỹ thuật "backspace-rồi-thay-thế" để chuyển đổi ký tự (`a` → `á`). Claude Code xử lý phím backspace nhưng không hiển thị các ký tự thay thế, gây mất chữ.

```text
Gõ: "xin chào" → Kết quả: "xin c" ❌
```

### Giải pháp

Bản vá chặn xử lý ký tự DEL và chèn lại các ký tự còn lại đúng cách.

```text
Gõ: "xin chào" → Kết quả: "xin chào" ✓
```

---

## Yêu Cầu

- Python 3.6+
- Claude Code qua npm: `npm install -g @anthropic-ai/claude-code`
- macOS hoặc Linux

---

## Phiên Bản Đã Kiểm Tra

- Claude Code v2.1.12 (Tháng 1/2026)
- macOS (Homebrew/npm)

---

## Xử Lý Sự Cố

| Lỗi | Giải pháp |
|-----|-----------|
| "Could not find Claude Code cli.js" | Cài Claude qua npm: `npm install -g @anthropic-ai/claude-code` |
| "Could not extract variables" | Mở issue với `claude --version` |
| "Patch already applied" | Bản vá đã hoạt động, kiểm tra: `claude-vn-patch status` |

---

## Chi Tiết Kỹ Thuật

<details>
<summary>Xem cách hoạt động</summary>

### Trích Xuất Biến Động

Script sử dụng regex để tìm các pattern trong mã minify:

```javascript
if(l.includes("\x7f")){
  let $A=(l.match(/\x7f/g)||[]).length,CA=S;
  for(let _A=0;_A<$A;_A++)CA=CA.backspace();
  if(!S.equals(CA)){if(S.text!==CA.text)Q(CA.text);T(CA.offset)}
  // BẢN VÁ CHÈN VÀO ĐÂY
  ct1(),lt1();return
}
```

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

</details>

---

## Cấu Trúc Dự Án

```text
claude-code-vietnamese-fix/
├── install.sh                           # Trình cài đặt
└── scripts/
    ├── vietnamese-ime-patch.sh          # Script chính
    ├── vietnamese-ime-patch-core.py     # Logic xử lý
    └── claude-update-wrapper.sh         # Wrapper cập nhật
```

---

## Ghi Công

- Ý tưởng ban đầu: [manhit96/claude-code-vietnamese-fix](https://github.com/manhit96/claude-code-vietnamese-fix)
- Trích xuất động & hỗ trợ v2.1.12: Dự án này

---

## Giấy Phép

MIT License - Xem [LICENSE](LICENSE) để biết thêm chi tiết.
