# App Store screenshots (Abodi)

**Marketing screenshots** (không phải raw app capture): nền Coral-Glass + headline lớn 2 màu + mockup điện thoại chứa UI app thật — giống bộ của dự án mẫu 3dmap.

- `en/` — 5 ảnh **1206×2622** (ô "iPhone with Dynamic Island (medium display)").
- `src-1290x2796/` — bản **1290×2796** (ô "iPhone 6.9" Display" nếu có).

## Bộ 5 ảnh (thứ tự upload)

| # | File | Headline | Màn app |
|---|---|---|---|
| 1 | `01_reimagine` | Reimagine **any room** | Home/Create (hero before/after) |
| 2 | `02_aidesigner` | Your own **AI Designer** | Màn chat AI |
| 3 | `03_styles` | A look for **every space** | Lưới style (See all) |
| 4 | `04_tryit` | Try any style **in seconds** | Style detail |
| 5 | `05_languages` | Private — **16 languages** | Màn chọn ngôn ngữ (cờ) |

## Tạo lại

Ảnh được **compose bằng script** (Pillow), không dựng tay:

1. Chụp lại màn app thật (English) vào `scripts/store/shots/`:
   ```bash
   xcrun simctl io "iPhone 17 Pro" screenshot scripts/store/shots/home.png
   ```
   (các tên cần: `home.png`, `chat.png`, `category.png`, `detail.png`, `language.png`)
2. Render:
   ```bash
   python3 scripts/store/make_screenshots.py
   ```
   → ghi đè `en/` + `src-1290x2796/`. Sửa headline/thêm frame trong `FRAMES` của script.

> ⚠️ Khi AI generate chạy thật (có creds Code12), nên chụp lại 1 màn **kết quả generate thật** (before/after result) rồi thêm 1 frame cho nó.
> App chỉ iPhone (`TARGETED_DEVICE_FAMILY="1"`) → không cần ảnh iPad.
