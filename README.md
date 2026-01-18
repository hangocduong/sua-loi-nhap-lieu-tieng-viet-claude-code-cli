# Claude Code - Bản Vá Bộ Gõ Tiếng Việt

[![Version](https://img.shields.io/github/v/release/hangocduong/claude-code-vietnamese-fix?label=version)](https://github.com/hangocduong/claude-code-vietnamese-fix/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

> Sửa lỗi nhập liệu tiếng Việt (OpenKey, EVKey, Unikey, PHTV) cho terminal Claude Code.

---

## Cài Đặt

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hangocduong/claude-code-vietnamese-fix/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/hangocduong/claude-code-vietnamese-fix/main/install.ps1 | iex
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
- Windows, macOS, hoặc Linux

---

## Phiên Bản Đã Kiểm Tra

- Claude Code v2.1.12 (Tháng 1/2026)
- macOS, Windows (npm)

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

### Mã Được Chèn (v1.3.0+)

```javascript
// Tìm DEL cuối cùng, chỉ chèn ký tự sau nó
// Fix lỗi gõ nhanh: nhiều DEL+char có thể đến cùng lúc
let _lastDel=l.lastIndexOf("\x7f");
let _vn=_lastDel>=0?l.slice(_lastDel+1):"";
if(_vn.length>0){
  for(const _c of _vn)CA=CA.insert(_c);
  if(!S.equals(CA)){
    if(S.text!==CA.text)Q(CA.text);
    T(CA.offset)
  }
}
```

**Tại sao cần `lastIndexOf` thay vì `replace`?**

Khi gõ nhanh, nhiều cặp DEL+ký tự có thể đến trong một batch:

- Input: `[DEL]á[DEL]à` (gõ "a" → "á" → "à" nhanh)
- Patch cũ: xóa DEL → `áà` → chèn cả hai → **SAI**
- Patch mới: tìm DEL cuối → chỉ chèn `à` → **ĐÚNG**

</details>

---

## Cấu Trúc Dự Án

```text
claude-code-vietnamese-fix/
├── install.sh                           # Installer (macOS/Linux)
├── install.ps1                          # Installer (Windows)
└── scripts/
    ├── vietnamese-ime-patch.sh          # Wrapper (Bash)
    ├── vietnamese-ime-patch.ps1         # Wrapper (PowerShell)
    ├── vietnamese-ime-patch-core.py     # Logic chính
    ├── claude-update-wrapper.sh         # Update (Bash)
    └── claude-update-wrapper.ps1        # Update (PowerShell)
```

---

## Ghi Công

- Ý tưởng ban đầu: [manhit96/claude-code-vietnamese-fix](https://github.com/manhit96/claude-code-vietnamese-fix)
- Trích xuất động & hỗ trợ v2.1.12: Dự án này

---

## Giấy Phép

MIT License - Xem [LICENSE](LICENSE) để biết thêm chi tiết.
