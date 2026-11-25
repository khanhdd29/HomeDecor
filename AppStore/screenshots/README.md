# App Store screenshots (Abodi)

**Marketing screenshots** (không phải raw app capture): nền Coral-Glass + headline lớn 2 màu + mockup điện thoại chứa UI app thật — giống bộ của dự án mẫu 3dmap.

- `en/` — 5 ảnh **1206×2622** (ô "iPhone with Dynamic Island (medium display)").
- `src-1290x2796/` — bản **1290×2796** (ô "iPhone 6.9" Display" nếu có).

## Bộ 6 ảnh (thứ tự upload) — kể trọn câu chuyện: ảnh phòng → chọn style → before/after

| # | File | Headline | Màn app |
|---|---|---|---|
| 1 | `01_reimagine` | Reimagine **any room** | Home/Create (hero) |
| 2 | `02_yourroom` | Start with **your own room** | Upload Photo (ảnh phòng đã chọn) |
| 3 | `03_pickstyle` | Pick any **style** | Choose Style (room type + style) |
| 4 | `04_beforeafter` | See it **before & after** | Your Design (slider so sánh) ⭐ |
| 5 | `05_aidesigner` | Your own **AI Designer** | Màn chat AI |
| 6 | `06_styles` | A look for **every space** | Style detail |

## Tạo lại

Ảnh được **compose bằng script** (Pillow), không dựng tay. Headline tự co (`fit_font`) nên không bị cắt:

1. Chụp lại màn app thật (English) vào `scripts/store/shots/` — các tên cần: `home.png`, `upload.png`, `choosestyle.png`, `result.png`, `chat.png`, `detail.png`:
   ```bash
   xcrun simctl io "iPhone 17 Pro" screenshot scripts/store/shots/home.png
   ```
   (Để có màn `upload/choosestyle/result`: nạp 1 ảnh phòng vào sim bằng `xcrun simctl addmedia "iPhone 17 Pro" <ảnh>` rồi đi flow Try Now → chọn ảnh → Generate.)
2. Render:
   ```bash
   python3 scripts/store/make_screenshots.py
   ```
   → ghi đè `en/` + `src-1290x2796/`. Sửa headline/đổi frame trong `FRAMES`.

> ⚠️ `04_beforeafter` hiện dùng kết quả MOCK (ảnh "after" chưa đúng vì AI chưa wire). Khi có creds Code12 và AI chạy thật, **chụp lại `result.png`** rồi render lại để ảnh store khớp app.
> App chỉ iPhone (`TARGETED_DEVICE_FAMILY="1"`) → không cần ảnh iPad.
