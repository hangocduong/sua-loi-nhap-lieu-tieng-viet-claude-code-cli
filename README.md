# Sửa Lỗi Nhập Liệu Tiếng Việt cho Claude Code CLI

[![Version](https://img.shields.io/github/v/release/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli?label=version&cacheSeconds=60)](https://github.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

> Bản vá giúp gõ tiếng Việt trong Claude Code CLI hoạt động chính xác với các bộ gõ phổ biến: **Unikey**, **EVKey**, **OpenKey**, **GoTiengViet**.

---

## Mục Lục

- [Cài Đặt](#cài-đặt)
- [Cập Nhật](#cập-nhật)
- [Sử Dụng](#sử-dụng)
- [Vấn Đề & Giải Pháp](#vấn-đề--giải-pháp)
- [Xử Lý Sự Cố](#xử-lý-sự-cố)
- [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
- [Chi Tiết Kỹ Thuật](#chi-tiết-kỹ-thuật)
- [Đóng Góp](#đóng-góp)
- [Changelog](#changelog)

---

## Cài Đặt

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/main/install.sh | bash
```

### Windows (PowerShell - Chạy với quyền Admin)

```powershell
irm https://raw.githubusercontent.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/main/install.ps1 | iex
```

### Sau Khi Cài Đặt

**Bắt buộc khởi động lại Claude Code để bản vá có hiệu lực:**

```bash
# Nhấn Ctrl+C để thoát phiên hiện tại, sau đó:
claude
```

---

## Cập Nhật

### Cập nhật bản vá (giữ nguyên Claude Code)

```bash
# Xóa patch cũ và áp dụng patch mới
claude-vn-patch restore && claude-vn-patch
```

### Cập nhật Claude Code + tự động vá lại

```bash
claude-update
```

> **Lưu ý:** Sau mỗi lần Claude Code cập nhật, cần chạy lại `claude-vn-patch` hoặc `claude-update`.

---

## Sử Dụng

| Lệnh | Mô tả |
|------|-------|
| `claude-vn-patch` | Áp dụng bản vá |
| `claude-vn-patch status` | Kiểm tra trạng thái bản vá |
| `claude-vn-patch restore` | Khôi phục file gốc (gỡ bản vá) |
| `claude-update` | Cập nhật Claude Code + tự động áp dụng bản vá |

---

## Vấn Đề & Giải Pháp

### Vấn đề

Bộ gõ tiếng Việt sử dụng kỹ thuật **"backspace-rồi-thay-thế"** để chuyển đổi ký tự (ví dụ: `a` → `á`). Claude Code xử lý phím backspace nhưng không hiển thị ký tự thay thế, dẫn đến mất chữ.

```text
Gõ: "cộng hòa xã hội"
Kết quả (trước khi vá): "ộng hòa ã hội" ❌
```

### Giải pháp

Bản vá v1.6.0+ sử dụng **stack-based algorithm** để xử lý đúng thứ tự ký tự, hoạt động ổn định kể cả khi gõ nhanh.

```text
Gõ: "cộng hòa xã hội"
Kết quả (sau khi vá): "cộng hòa xã hội" ✓
```

---

## Xử Lý Sự Cố

| Lỗi | Giải pháp |
|-----|-----------|
| Gõ tiếng Việt vẫn lỗi sau khi cài | Đã restart Claude Code chưa? Nhấn `Ctrl+C`, chạy `claude` |
| `claude-vn-patch: command not found` | Restart terminal hoặc chạy `source ~/.zshrc` (hoặc `~/.bashrc`) |
| "Could not find Claude Code cli.js" | Cài Claude qua npm: `npm install -g @anthropic-ai/claude-code` |
| "Could not extract variables" | Phiên bản Claude không tương thích. Mở [issue](https://github.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/issues) kèm `claude --version` |
| "Patch already applied" | Bản vá đã được áp dụng. Kiểm tra: `claude-vn-patch status` |
| Lỗi khi gõ nhanh lần đầu | Cập nhật lên v1.6.0+: `claude-vn-patch restore && claude-vn-patch` |

---

## Yêu Cầu Hệ Thống

- **Python** 3.6 trở lên
- **Claude Code** cài qua npm: `npm install -g @anthropic-ai/claude-code`
- **Hệ điều hành:** Windows, macOS, hoặc Linux

### Phiên bản đã kiểm tra

- Claude Code v2.1.12 (Tháng 1/2026)
- macOS Sequoia, Windows 11

---

## Chi Tiết Kỹ Thuật

<details>
<summary>Xem cách hoạt động</summary>

### Nguyên nhân lỗi

Code gốc của Claude Code đếm số ký tự DEL (0x7F) rồi thực hiện backspace **trước** khi chèn ký tự mới:

```text
State: "c" | Input: "o[DEL]ộ" (gõ "cộ" nhanh)

Code gốc:
1. Đếm 1 DEL → thực hiện 1 backspace
2. State "c" → backspace → "" (XÓA NHẦM "c"!)
3. Kết quả: "ộ" thay vì "cộ"
```

### Giải pháp: Stack-based Algorithm (v1.6.0+)

Xử lý từng ký tự theo thứ tự, dùng stack để theo dõi ký tự nào đã được "tiêu thụ" bởi DEL:

```javascript
let _ns = S, _sk = [];  // _ns: new state, _sk: stack

for(const c of l) {
  if(c === "\x7f") {              // Ký tự DEL
    if(_sk.length > 0) _sk.pop(); // DEL tiêu thụ ký tự pending
    else _ns = _ns.backspace();   // DEL ảnh hưởng state gốc
  } else {
    _sk.push(c);                  // Ký tự thường: push stack
  }
}

for(const c of _sk) _ns = _ns.insert(c);  // Chèn ký tự còn lại
```

### Ví dụ minh họa

```text
Input: "o[DEL]ộ" | State ban đầu: "c"

Bước 1: 'o' → push stack → stack=['o']
Bước 2: DEL → pop stack → stack=[]
Bước 3: 'ộ' → push stack → stack=['ộ']
Bước 4: Insert 'ộ' → State = "c" + "ộ" = "cộ" ✓
```

</details>

---

## Cấu Trúc Dự Án

```text
sua-loi-nhap-lieu-tieng-viet-claude-code-cli/
├── install.sh                           # Installer (macOS/Linux)
├── install.ps1                          # Installer (Windows)
├── LICENSE
├── README.md
└── scripts/
    ├── vietnamese-ime-patch.sh          # Entry point (Bash)
    ├── vietnamese-ime-patch.ps1         # Entry point (PowerShell)
    ├── vietnamese-ime-patch-core.py     # Logic chính
    ├── claude-update-wrapper.sh         # Update helper (Bash)
    └── claude-update-wrapper.ps1        # Update helper (PowerShell)
```

---

## Đóng Góp

Mọi đóng góp đều được hoan nghênh! Vui lòng:

1. Fork repository
2. Tạo branch mới: `git checkout -b feature/ten-tinh-nang`
3. Commit thay đổi: `git commit -m "Thêm tính năng X"`
4. Push: `git push origin feature/ten-tinh-nang`
5. Tạo Pull Request

### Báo lỗi

Nếu gặp lỗi, vui lòng [mở issue](https://github.com/hangocduong/sua-loi-nhap-lieu-tieng-viet-claude-code-cli/issues) kèm theo:

- Phiên bản Claude Code: `claude --version`
- Hệ điều hành
- Bộ gõ tiếng Việt đang dùng
- Mô tả lỗi chi tiết

---

## Changelog

### v1.6.0

- Viết lại hoàn toàn thuật toán với proper JavaScript scoping
- Sửa lỗi mất ký tự khi gõ nhanh lần đầu tiên

### v1.5.0

- Đổi tên dự án
- Cập nhật tất cả URL

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
- Stack-based algorithm & dynamic extraction: Dự án này

---

## Giấy Phép

MIT License - Xem [LICENSE](LICENSE) để biết thêm chi tiết.
