# App Store screenshots (Abodi Home)

**Trạng thái: CHƯA LÀM** — cần dựng ảnh marketing rồi export vào đây.

Ảnh marketing nên **thiết kế trong Figma** (ảnh phòng before→after thật + mockup điện thoại + headline), giống bộ Coral Glass của app, rồi export ra `src-1290x2796/` và resize sang `en/`.

## Size nộp lên App Store Connect

| Ô trên App Store Connect | Kích thước nhận | Thư mục |
|---|---|---|
| iPhone with Dynamic Island (medium display) | 1206×2622 **hoặc** 1179×2556 | `en/` |
| iPhone 6.9" Display (nếu có ô này) | 1290×2796 hoặc 1320×2868 | `src-1290x2796/` |

- Đặt bản gốc **1290×2796** vào `src-1290x2796/`, bản resize **1179×2556** (cùng tỉ lệ, không méo) vào `en/`.
- Nếu `TARGETED_DEVICE_FAMILY = "1"` (chỉ iPhone, khuyến nghị) → **không cần ảnh iPad**. Nếu giữ `"1,2"` thì phải thêm ảnh **iPad 13"** (2064×2752).
- Trang store chỉ English → chỉ cần bộ `en/`. Tối đa 10 ảnh/ô (dùng 6).

## 6 ảnh đề xuất (thứ tự upload)

1. `01_redesign` — **"Redesign any room in seconds"** — ảnh phòng before → after
2. `02_styles` — **"A style for every space"** — lưới style theo loại phòng
3. `03_beforeafter` — **"Compare before & after"** — slider so sánh
4. `04_aidesigner` — **"Your own AI Designer"** — màn chat tư vấn
5. `05_mylook` — **"Save every look"** — gallery My look
6. `06_private` — **"Private by design — no account, no ads"**

> Chỉ nêu tính năng ✅ sẽ ship (khớp Description). Khi AI đã wire thật, chụp kết quả **thật** (đừng dùng ảnh mock) để ảnh store không lệch app.

## Export lại khi sửa thiết kế Figma

Export PNG scale 1 (ra 1290×2796), rồi resize về 1179×2556 (giữ tỉ lệ):

```bash
python3 - <<'PY'
from PIL import Image
Image.open("src-1290x2796/01_redesign.png").convert("RGB").resize((1179,2556), Image.LANCZOS).save("en/01_redesign.png")
PY
```
