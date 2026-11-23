# Nội dung App Store: Abodi Home

Trang store **viết tiếng Anh** (English U.S.) — App Store dùng bản tiếng Anh cho mọi quốc gia. Việc này **không** ảnh hưởng ngôn ngữ trong app: app có đủ **16 bản dịch** (en/es/fr/de/pt-BR/pt-PT/ru/tr/ar/hi/bn/id/ja/ko/zh-Hans/zh-Hant), mục Languages trên trang store tự liệt kê.

Nội dung viết **riêng cho Abodi Home** (app AI thiết kế lại nội thất: chụp/chọn ảnh phòng → chọn style → AI dựng lại → lưu "My look", kèm trợ lý AI tư vấn). Chỉ nêu tính năng **đã ✅ xong**; **không** nhắc tính năng còn mock/chưa wire để tránh **Guideline 2.3.1** (mô tả sai). Đếm ký tự bằng `python3 AppStore/count_metadata.py` sau mỗi lần sửa.

Điểm khác biệt nhấn ASO (tránh **4.3** — trùng app AI decor khác): **before/after kéo so sánh**, **nhiều style theo từng loại phòng**, **trợ lý AI tư vấn trang trí (chat + gửi ảnh)**, **16 ngôn ngữ**, **không tài khoản, không quảng cáo**.

> ⚠️ **CỰC KỲ QUAN TRỌNG trước khi submit:** phần **AI generate** và **AI Chat** hiện đang chạy **mock** (`ChatStore.useMock = true`, flow generate dùng dữ liệu mẫu) vì **chưa có credentials Code12/ArtMagic** (appId/secretKey/agentId/template). Store metadata dưới đây mô tả app **như khi AI đã chạy thật**. **KHÔNG được submit khi AI còn mock** — reviewer sẽ thấy app không tạo được thiết kế thật → reject **2.3.1** (mô tả không đúng) hoặc **2.1** (app không hoạt động). Phải wire backend thật + test end-to-end trước (xem mục 6).

## 1. Thông tin chung (App Information / Pricing / App Privacy)

| Mục | Giá trị |
|---|---|
| Bundle ID | `com.abodi.home.interior.room.design` (⚠️ tra App Store trước khi submit để chắc "Abodi" chưa ai dùng) |
| Bundle ID (dev) | `com.abodi.home.interior.room.design.dev` (build nội bộ, không tạo app store riêng) |
| Display name (dưới icon) | `Abodi Home` |
| Primary Language | English (U.S.). Không thêm ngôn ngữ nào khác cho trang store |
| Thiết bị | ✅ `TARGETED_DEVICE_FAMILY = "1"` (chỉ iPhone) → **không cần ảnh iPad**. Giữ nguyên; một khi phát hành kèm iPad thì không bỏ được nữa |
| Danh mục chính / phụ | **Graphics & Design** / **Lifestyle** |
| Giá | Free. Bản 1.0 **không** In-App Purchase, **không** ads (nút Pro ✦ ẩn) |
| Xếp hạng tuổi | Mọi mục nội dung **None**. Unrestricted Web Access: **No**. User-Generated Content: **No** (ảnh người dùng chỉ xử lý để tạo thiết kế, không chia sẻ công khai giữa user). → thường **4+** |
| App Privacy | ⚠️ **KHÔNG** phải "Data Not Collected". App **gửi ảnh phòng lên server AI (Code12/ArtMagic)** để xử lý → phải khai trung thực. Xem khung bên dưới |
| ATT (App Tracking Transparency) | Không áp dụng. Đã **gỡ** `NSUserTrackingUsageDescription` + không gọi `ATTrackingManager` (bản 1.0 không ads). Khớp "không tracking" |
| Privacy Policy URL | Bắt buộc. Trang policy cần nhắc: ảnh được gửi lên dịch vụ AI để tạo thiết kế, **không bán cho bên thứ ba**, thiết kế lưu trên máy, có thể xoá bất cứ lúc nào |
| License Agreement (EULA) | Dùng **Apple Standard EULA** (mặc định) |
| Support URL | Bắt buộc. Dùng site/email liên hệ của team |
| Marketing URL | Không bắt buộc |
| Copyright | `2026 <tên cá nhân hoặc công ty>` |
| Sign-in for review | Không cần (app không có tài khoản — dùng userId ẩn danh) |

### App Privacy — khai thế nào cho đúng (QUAN TRỌNG)

App **không có tài khoản, không analytics, không ads, không tracking**, nhưng **có gửi ảnh phòng + tin nhắn chat lên server AI** để tạo thiết kế / trả lời tư vấn. Khai trong App Store Connect:

| Data Type | Collected? | Linked to identity? | Tracking? | Mục đích |
|---|---|---|---|---|
| **User Content → Photos or Videos** | **Yes** | **No** (gắn userId ẩn danh, không phải danh tính) | **No** | **App Functionality** (xử lý ảnh để AI tạo thiết kế) |
| **User Content → Other (tin nhắn chat)** | **Yes** | **No** | **No** | **App Functionality** (AI trả lời tư vấn) |
| Mọi loại khác (Contact, Location, Identifiers, Usage, Diagnostics…) | **No** | — | — | — |

> Thiết kế đã tạo, lịch sử "My look", cài đặt, ngôn ngữ **nằm trên máy**. Ảnh gửi lên server chỉ để xử lý AI; trang Privacy Policy phải mô tả rõ điều này (Guideline 5.1.1/5.1.2). ⚠️ Đừng khai "Data Not Collected" — sai vì có upload ảnh.

## 2. Nội dung trang store (English U.S.)

**App Name** (tối đa 30). Dẫn bằng thương hiệu **Abodi** rồi cụm tìm nhiều **"AI"**, **"Room"**, **"Home Design"**. App Store ghép chữ trong tên nên khớp "abodi", "ai", "room", "home design".

```text
Abodi: AI Room & Home Design
```

**Subtitle** (tối đa 30). Thêm chữ chưa có trong tên ("interior", "decor", "restyle", "ideas") để mở rộng từ khoá. Không dùng "Free"/tên app khác.

```text
Interior decor & restyle ideas
```

**Promotional Text** (tối đa 170). Ô này không tính xếp hạng tìm kiếm, sửa được bất cứ lúc nào mà không cần duyệt lại.

```text
Snap a photo of any room and let AI restyle it in seconds — modern, cozy, minimal and more. Save your favorite looks, compare before and after, and ask the AI for advice.
```

**Keywords** (tối đa 100). Không lặp chữ đã có trong tên/subtitle (abodi, ai, room, home, design, interior, decor, restyle, ideas — Apple không tính lặp), không dùng tên app khác, không "free".

```text
bedroom,living,kitchen,makeover,renovate,furniture,remodel,house,bathroom,wall,paint,style,garden
```
<!-- đếm lại bằng count_metadata.py sau mỗi lần sửa -->
<!-- Lưu ý: "room","home","design","interior","decor" KHÔNG cho vào đây — đã nằm trong Name/Subtitle nên Apple tự index; lặp là phí ô. Apple tự ghép token nên "ai room","home design","interior decor","bedroom makeover" đều match sẵn. -->

**Description** (tối đa 4000):

```text
Abodi turns a single photo of your room into a beautiful redesign in seconds. Point your camera at any space, pick a style you love, and watch AI reimagine it — walls, furniture, lighting and mood. It is fast, private and works without an account.

REDESIGN ANY ROOM
- Take a photo or pick one from your library
- Choose from styles for every space: living room, bedroom, kitchen, bathroom, and outdoor
- Try looks like modern, cozy, minimal, warm and more
- Get a fresh AI concept in seconds

SEE THE DIFFERENCE
- Drag the before/after slider to compare your room with the new design
- Keep the versions you like and try the same room in other styles

YOUR OWN AI DESIGNER
- Ask the built-in AI Designer anything about decorating — colors, layouts, small-space ideas
- Send a photo of your room and get tailored suggestions back
- Turn a suggestion into a full redesign with one tap

SAVE YOUR LOOKS
- Every design you like is saved to My look on your device
- Download a design to Photos or share it with a friend
- Clean up anytime — it is your gallery

FIND INSPIRATION
- Browse curated styles by room and category
- Open any look to start redesigning your own space

PRIVATE BY DESIGN
No account, no ads and no trackers. Your photos are used only to create your designs, and your saved looks, history and settings stay on your iPhone. You can delete anything at any time.

IN YOUR LANGUAGE
Abodi speaks 16 languages and opens in your device language when it can — English, Spanish, French, German, Portuguese (Brazil & Portugal), Russian, Turkish, Arabic, Hindi, Bengali, Indonesian, Japanese, Korean, and Chinese (Simplified & Traditional). Switch any time in Settings.

Download Abodi and see your home in a whole new style.
```

**What's New in This Version**:

```text
First release of Abodi.
```

## 3. Icon và ảnh chụp màn hình

- Icon app: `AppStore/AppIcon-1024.png`, 1024×1024, không nền trong suốt, không bo góc (Apple tự bo). App Store lấy icon từ bản build nên **không cần tải file này lên** — để lưu trữ/gửi designer.
- Ảnh chụp: ✅ **đã có bộ đầu** — 6 ảnh **1206×2622** ở `AppStore/screenshots/en/` (chụp từ app thật, English), nộp lên ô "iPhone with Dynamic Island (medium display)" được luôn.
- **Size đẩy lên store:** ô "iPhone with Dynamic Island (medium display)" nhận **1206×2622** hoặc **1179×2556**; ô "iPhone 6.9" Display" nhận **1290×2796**.
- 6 ảnh (theo thứ tự upload):
  1. **01_makeover** — AI Room Makeover (before/after + "Reimagine any room")
  2. **02_advice** — AI Design Advice (trợ lý AI)
  3. **03_styles** — Explore Interior Styles
  4. **04_inspiration** — Discover Inspiration
  5. **05_home** — Home/Create thật (catalog style)
  6. **06_chat** — AI Designer welcome thật
- App **chỉ iPhone** (`TARGETED_DEVICE_FAMILY = "1"`) → không cần ảnh iPad. Tối đa 10 ảnh/slot.
- ⚠️ Khi AI wire thật, nên chụp lại 1 ảnh **kết quả generate thật** (before/after result) để không lệch app.

## 4. Ghi chú cho người duyệt (App Review Information › Notes)

```text
Abodi is an AI interior-design app. The user takes or picks a photo of a room, chooses a style, and the app returns an AI-generated redesign of that room. A built-in AI Designer (chat) also answers decorating questions and can give advice on a photo the user sends.

There is NO account and NO sign-in. The app uses an anonymous on-device identifier only. Saved designs, history, language and settings are stored on the device.

How Abodi processes images: to create a redesign, the photo the user selects is sent to our AI image service for processing, and the generated result is returned. Likewise, chat messages (and an optional attached photo) are sent to the AI service to produce a reply. No other data is collected: no analytics, no advertising, no third-party tracking SDKs. App Tracking Transparency does not apply and the app ships no NSUserTrackingUsageDescription.

Steps to test:
1. Launch the app, choose a language, pass the short onboarding.
2. On the Create tab, tap the upload area, then "Take photo" or "Photo library" and choose a room photo. (Camera and Photo Library permissions are requested only here, when the feature is used.)
3. Pick a style, then tap Generate. After a few seconds the redesigned room appears; drag the before/after slider to compare, then "Save to My look".
4. Open the AI Designer from the floating button, type a question (for example "ideas for a cozy small bedroom"), and send. You can also attach a room photo for tailored advice.
5. My look shows saved designs; each can be downloaded to Photos or shared.

Permissions, requested only when the related feature is used:
- Camera: to take a photo of the room to redesign.
- Photo Library: to pick a room photo to redesign.
- Add to Photos: to save a generated design back to the photo library.

The app has no in-app purchases in this version and shows no ads. There is no user-to-user content: a user's photos and designs are private to them and are not shared with or shown to other users.
```

## 5. Đã kiểm tra để tránh reject

- **Mô tả đúng với app (2.3.1):** chỉ nêu tính năng ✅ sẽ ship: chụp/chọn ảnh phòng, chọn style theo loại phòng, AI generate, before/after slider, lưu/tải/chia sẻ My look, trợ lý AI chat + gửi ảnh, Inspiration, 16 ngôn ngữ, privacy xoá dữ liệu. **Không** nhắc: nút Pro/premium (ẩn ở v1), tính năng còn mock. ⚠️ **AI generate + chat phải chạy thật (không mock) trước khi submit** — nếu không, mô tả sai + app không hoạt động.
- **Riêng tư (5.1.1 / 5.1.2):** app **có** gửi ảnh + chat lên server AI → App Privacy khai **User Content (Photos, Other)** = Collected · Not linked · No tracking · App Functionality (xem mục 1). Trang Privacy Policy phải nói rõ ảnh được xử lý bởi dịch vụ AI, không bán, thiết kế lưu trên máy. **Không** khai "Data Not Collected".
- **ATT:** đã gỡ `NSUserTrackingUsageDescription` + không gọi ATT → khớp "không tracking".
- **Trùng lặp / 4.3:** nhiều app AI decor → tên + mô tả dẫn bằng điểm riêng (before/after slider, AI Designer chat + gửi ảnh, nhiều style theo phòng, 16 ngôn ngữ, privacy-first). Trước submit tra "Abodi" chưa ai dùng.
- **Nội dung do AI tạo (1.2 / UGC):** ảnh/thiết kế của user là **riêng tư, không chia sẻ công khai giữa người dùng** → không cần hệ thống kiểm duyệt/report/block. Ghi rõ trong Review Notes.
- **IAP (3.1):** v1 không có IAP, nút Pro ẩn → không mô tả mua hàng.
- **Export compliance:** cần thêm `ITSAppUsesNonExemptEncryption = NO` vào Info.plist trước khi archive (xem mục 6) — hiện **chưa có**.

## 6. Việc còn phải làm trước khi submit

1. **🔴 WIRE AI THẬT (chặn submit):** lấy credentials Code12/ArtMagic (appId/secretKey/agentId/template), tắt `ChatStore.useMock`, nối flow generate + chat vào server thật, **test end-to-end** ra thiết kế thật. Không làm xong = không submit.
2. **GoogleService-Info.plist thật** (Firebase/Crashlytics) với bundle id `com.abodi.home.interior.room.design` — hiện là file placeholder.
3. ✅ **`ITSAppUsesNonExemptEncryption = NO`** đã thêm vào `HomeDecor/Resources/Info.plist`.
4. ✅ **Thiết bị:** `TARGETED_DEVICE_FAMILY = "1"` (chỉ iPhone) — xong.
5. **Tra "Abodi"** trên App Store (các nước phát hành) để chắc chưa trùng tên/thương hiệu (4.1/4.3).
6. **Privacy Policy + Support URL** do team chỉ định; nội dung trang nhắc "ảnh xử lý bởi dịch vụ AI, không bán, thiết kế lưu trên máy".
7. **Dựng + export 6 ảnh** marketing (mục 3 / screenshots/README.md).
8. **Tài khoản Apple Developer**, chọn Team trong Xcode › Signing, đăng ký bundle ID, tạo app (Primary Language: English U.S.), điền mục 1–4.
9. Archive › Distribute › App Store Connect › Upload, chọn build, gửi duyệt.

## 7. Kết quả đếm ký tự (EN)

Chạy `python3 AppStore/count_metadata.py` để cập nhật. Giới hạn: App Name 30 · Subtitle 30 · Promotional Text 170 · Keywords 100 · Description 4000 · What's New 4000.
