# App Store screenshots (Abodi Home)

**Trạng thái: ĐÃ CÓ BỘ ĐẦU** — 6 ảnh chụp từ app thật (English) ở `en/`, **1206×2622** (hợp lệ cho ô "iPhone with Dynamic Island (medium display)"), nộp lên store được luôn.

> 4 ảnh đầu là **màn onboarding intro** của app (đã thiết kế sẵn: before/after + headline — rất hợp làm ảnh store); 2 ảnh cuối là màn **Home** và **AI Designer** thật. Muốn "xịn" hơn (thêm nền/headline marketing riêng) thì dựng frame trong Figma rồi thay vào. ⚠️ Khi AI đã wire thật, nên chụp lại ảnh có **kết quả generate thật** để không lệch app.

## Size nộp lên App Store Connect

| Ô trên App Store Connect | Kích thước nhận | Thư mục |
|---|---|---|
| iPhone with Dynamic Island (medium display) | 1206×2622 **hoặc** 1179×2556 | `en/` |
| iPhone 6.9" Display (nếu có ô này) | 1290×2796 hoặc 1320×2868 | `src-1290x2796/` |

- Đặt bản gốc **1290×2796** vào `src-1290x2796/`, bản resize **1179×2556** (cùng tỉ lệ, không méo) vào `en/`.
- Nếu `TARGETED_DEVICE_FAMILY = "1"` (chỉ iPhone, khuyến nghị) → **không cần ảnh iPad**. Nếu giữ `"1,2"` thì phải thêm ảnh **iPad 13"** (2064×2752).
- Trang store chỉ English → chỉ cần bộ `en/`. Tối đa 10 ảnh/ô (dùng 6).

## 6 ảnh hiện có (`en/`, thứ tự upload)

1. `01_makeover` — **AI Room Makeover** (intro: before/after + "Reimagine any room")
2. `02_advice` — **AI Design Advice** (intro: trợ lý AI tư vấn)
3. `03_styles` — **Explore Interior Styles** (intro: nhiều style)
4. `04_inspiration` — **Discover Inspiration** (intro: khám phá ý tưởng)
5. `05_home` — **Home / Create** thật ("Reimagine any room", catalog style)
6. `06_chat` — **AI Designer** thật (màn welcome + gợi ý câu hỏi)

> Tất cả 1206×2622. Nếu đổi UI thì chụp lại bằng: `xcrun simctl io "iPhone 17 Pro" screenshot AppStore/screenshots/en/<tên>.png` (app đang để English). Khi AI wire thật, nên thêm 1 ảnh **kết quả generate thật** (before/after result) thay cho 1 intro.

## Export lại khi sửa thiết kế Figma

Export PNG scale 1 (ra 1290×2796), rồi resize về 1179×2556 (giữ tỉ lệ):

```bash
python3 - <<'PY'
from PIL import Image
Image.open("src-1290x2796/01_redesign.png").convert("RGB").resize((1179,2556), Image.LANCZOS).save("en/01_redesign.png")
PY
```
