# Sửa Lỗi Nhập Liệu Tiếng Việt cho Claude Code CLI

[![Version](https://img.shields.io/github/v/release/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli?label=version)](https://github.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

> Sửa lỗi nhập liệu tiếng Việt (OpenKey, EVKey, Unikey, PHTV) cho terminal Claude Code.

---

## Cài Đặt

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/main/install.ps1 | iex
```

### ⚠️ Quan trọng

**Sau khi cài đặt, thoát và khởi động lại Claude Code để bản vá có hiệu lực!**

```bash
# Nhấn Ctrl+C để thoát phiên hiện tại, sau đó:
claude
```

---

## Sử Dụng

| Lệnh | Mô tả |
|------|-------|
| `claude-vn-patch` | Áp dụng bản vá |
| `claude-vn-patch status` | Kiểm tra trạng thái |
| `claude-vn-patch restore` | Khôi phục file gốc |
| `claude-update` | Cập nhật Claude + tự động vá |

**Sau khi Claude cập nhật:** Chạy `claude-vn-patch` hoặc `claude-update`, rồi **restart Claude Code**.

---

## Vấn Đề & Giải Pháp

### Vấn đề

Bộ gõ tiếng Việt sử dụng kỹ thuật "backspace-rồi-thay-thế" để chuyển đổi ký tự (`a` → `á`). Claude Code xử lý phím backspace nhưng không hiển thị các ký tự thay thế, gây mất chữ.

```text
Gõ: "cộng hòa xã hội" → Kết quả: "ộng hòa ã hội" ❌
```

### Giải pháp (v1.4.0+)

Bản vá dùng stack-based algorithm để xử lý đúng thứ tự ký tự, kể cả khi gõ nhanh.

```text
Gõ: "cộng hòa xã hội" → Kết quả: "cộng hòa xã hội" ✓
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
| Gõ tiếng Việt vẫn lỗi | Đã restart Claude Code chưa? Nhấn `Ctrl+C`, chạy `claude` |
| "Could not find Claude Code cli.js" | Cài Claude qua npm: `npm install -g @anthropic-ai/claude-code` |
| "Could not extract variables" | Mở issue với `claude --version` |
| "Patch already applied" | Bản vá đã hoạt động, kiểm tra: `claude-vn-patch status` |

---

## Chi Tiết Kỹ Thuật

<details>
<summary>Xem cách hoạt động</summary>

### Vấn đề gốc

Code gốc của Claude làm backspace **TRƯỚC** khi chèn ký tự mới:

```text
State: "c" | Input: "o[DEL]ộ" (gõ "cộ" nhanh)
Code gốc: backspace trên "c" → "" (xóa nhầm "c"!)
Đúng ra: chèn "o"→"co", backspace→"c", chèn "ộ"→"cộ"
```

### Giải pháp: Stack-based Algorithm

Dùng stack để tính số DEL thực sự ảnh hưởng state gốc:

- Mỗi ký tự non-DEL: push stack
- Mỗi DEL: pop stack (hoặc xóa từ original nếu stack rỗng)
- Khôi phục ký tự bị xóa nhầm, rồi chèn ký tự thay thế

### Code được chèn (v1.4.0+)

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

</details>

---

## Cấu Trúc Dự Án

```text
sua-loi-nhap-lieu-tieng-viet-claude-code-cli/
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

## Changelog

### v1.4.1

- Thêm thông báo restart sau khi cài đặt/cập nhật

### v1.4.0

- Sửa lỗi mất chữ đầu từ khi gõ nhanh (stack-based algorithm)

### v1.2.0

- Thêm hỗ trợ Windows (PowerShell)

### v1.1.0

- Cài đặt một dòng lệnh qua curl/irm

### v1.0.0

- Phiên bản đầu tiên

---

## Ghi Công

- Ý tưởng ban đầu: [manhit96/claude-code-vietnamese-fix](https://github.com/manhit96/claude-code-vietnamese-fix)
- Trích xuất động & stack-based algorithm: Dự án này

---

## Giấy Phép

MIT License - Xem [LICENSE](LICENSE) để biết thêm chi tiết.
