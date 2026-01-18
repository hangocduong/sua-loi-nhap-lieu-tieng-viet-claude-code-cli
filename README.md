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

### Mã Được Chèn (v1.4.0+)

```javascript
// Stack approach: đếm DEL nào ảnh hưởng original vs consume input chars
let _s=0, _od=0;
for(let i=0; i<l.length; i++) {
  l[i]==="\x7f" ? (_s>0 ? _s-- : _od++) : _s++;
}
let _nd = (l.match(/\x7f/g)||[]).length;
let _wd = _nd - _od;  // Số ký tự bị xóa nhầm

// Khôi phục ký tự bị xóa nhầm
if(_wd > 0) {
  let _r = S.text.slice(S.text.length-_nd, S.text.length-_od);
  for(const c of _r) CA = CA.insert(c);
}

// Chèn ký tự sau DEL cuối
let _ld = l.lastIndexOf("\x7f");
let _a = _ld>=0 ? l.slice(_ld+1) : "";
for(const c of _a) CA = CA.insert(c);
```

**Vấn đề gốc:** Code gốc làm backspace TRƯỚC khi chèn ký tự mới.

```text
State: "c" | Input: "o[DEL]ộ" (gõ "cộ" nhanh)
Code gốc: backspace trên "c" → "" (xóa nhầm "c"!)
Đúng ra: chèn "o"→"co", backspace→"c", chèn "ộ"→"cộ"
```

**Giải pháp:** Dùng stack để tính số DEL thực sự ảnh hưởng state gốc:

- Mỗi ký tự non-DEL: push stack
- Mỗi DEL: pop stack (hoặc xóa từ original nếu stack rỗng)
- Khôi phục ký tự bị xóa nhầm, rồi chèn ký tự thay thế

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
