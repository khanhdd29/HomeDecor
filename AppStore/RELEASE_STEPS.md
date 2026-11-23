# Đưa Abodi Home lên App Store: làm theo từ trên xuống

Làm tới bước nào thì chép khối nội dung ở bước đó. Các khối chữ dài (Description, Review Notes) nằm trong [metadata.md](metadata.md) để khỏi lệch nội dung — file này trỏ tới đúng mục.

| | |
|---|---|
| Tên trên store (App Name) | `Abodi: AI Room & Home Design` (điền ở bước 1) |
| Subtitle | `Interior decor & restyle ideas` (điền ở bước 2) |
| Tên dưới icon | `Abodi Home` |
| Bundle ID | `com.abodi.home.interior.room.design` |
| Version / Build | `1.0.0` / `1`. Mỗi lần upload lại phải **tăng số build** |
| Thiết bị | ⚠️ Hiện **iPhone + iPad** (`TARGETED_DEVICE_FAMILY = "1,2"`). Khuyến nghị đổi về `"1"` (chỉ iPhone) → khỏi ảnh iPad |
| Ngôn ngữ trang store | Chỉ **English (U.S.)** (app vẫn có 16 ngôn ngữ bên trong) |
| Danh mục | Primary **Graphics & Design** · Secondary **Lifestyle** |

---

## 🔴 Bước 0-A. CHẶN SUBMIT — AI phải chạy thật

Bản hiện tại chạy **mock** cho AI generate + AI Chat (chưa có credentials Code12/ArtMagic). **Không được submit** khi còn mock (reviewer sẽ thấy app không tạo được thiết kế → reject 2.3.1 / 2.1).

- [ ] Có **appId / secretKey / agentId / template code** từ Code12.
- [ ] Tắt `ChatStore.useMock`, nối flow generate + chat vào server thật.
- [ ] **Test end-to-end**: chụp ảnh phòng → chọn style → Generate → ra thiết kế thật; chat hỏi → có trả lời thật.
- [ ] Thay **GoogleService-Info.plist** thật (bundle id `com.abodi.home.interior.room.design`).

## Bước 0-B. Chuẩn bị (làm một lần)

- [ ] Có tài khoản **Apple Developer Program** (99 USD/năm).
- [ ] **Link web cần có sẵn** (team chỉ định):

  | Ô | Link | Dùng ở |
  |---|---|---|
  | Privacy Policy URL | `<điền>` — trang nên nhắc: ảnh xử lý bởi dịch vụ AI, không bán, thiết kế lưu trên máy (5.1.1) | bước 4 |
  | Support URL | `<điền>` — trang có cách liên hệ (email) | bước 5 |
  | Marketing URL | `<điền>` (không bắt buộc) | bước 5 |

- [ ] Xcode › Settings › Accounts: đăng nhập Apple ID của tài khoản Developer.
- [ ] Icon 1024 đã có: [AppStore/AppIcon-1024.png](AppIcon-1024.png) (đã nhúng trong build, không cần tải lên riêng).
- [ ] **Ảnh chụp**: dựng + export 6 ảnh marketing vào [AppStore/screenshots/en/](screenshots/en). Xem [screenshots/README.md](screenshots/README.md).
- [ ] **Thêm `ITSAppUsesNonExemptEncryption = NO`** vào `HomeDecor/Resources/Info.plist` → khỏi bị hỏi Export Compliance mỗi lần upload.
- [ ] **Quyết định thiết bị:** đổi `TARGETED_DEVICE_FAMILY` về `"1"` (chỉ iPhone, khuyến nghị) trong `HomeDecor.xcodeproj` nếu không làm iPad.
- [ ] **Tra "Abodi"** trên App Store (các nước phát hành) để chắc chưa trùng tên/thương hiệu (4.1 / 4.3).

---

## Bước 1. Tạo app

**1.1** [developer.apple.com](https://developer.apple.com) › Certificates, Identifiers & Profiles › Identifiers › **+** › App IDs:
- Description: `Abodi Home`
- Bundle ID (Explicit): `com.abodi.home.interior.room.design`

**1.2** [appstoreconnect.apple.com](https://appstoreconnect.apple.com) › Apps › **+ › New App**:

| Ô | Điền |
|---|---|
| Platforms | iOS |
| Name | `Abodi: AI Room & Home Design` |
| Primary Language | English (U.S.) |
| Bundle ID | `com.abodi.home.interior.room.design` |
| SKU | `abodi-ios-001` (tự đặt, không hiện ra ngoài) |
| User Access | Full Access |

---

## Bước 2. General › App Information

**Subtitle** (30/30), dán vào ô *Subtitle* ngay dưới ô *Name*:

```text
Interior decor & restyle ideas
```

| Ô | Điền |
|---|---|
| Category | Primary: **Graphics & Design**. Secondary: **Lifestyle** |
| Content Rights | *"…third-party content?"* → **No** (ảnh do user cung cấp, không nhúng nội dung bên thứ ba sẵn) |
| Age Rating (*Edit*) | Mọi mục nội dung: **None**. Unrestricted Web Access: **No**. User-Generated Content: **No** → thường **4+** |
| License Agreement | Để mặc định (**Apple Standard EULA**) |

Bấm **Save**.

---

## Bước 3. General › Pricing and Availability

| Ô | Điền |
|---|---|
| Price | **Free** (bản 1.0 không có In-App Purchase) |
| Availability | Các quốc gia muốn phát hành |

Bấm **Save**.

---

## Bước 4. General › App Privacy

⚠️ App **có gửi ảnh + chat lên server AI** → **KHÔNG** khai "Data Not Collected".

| Ô | Điền |
|---|---|
| Privacy Policy URL | `<link ở bước 0-B>` |
| Data Collection | *Get Started* → **Yes, we collect data** → khai như bảng dưới |

| Data Type | Linked? | Tracking? | Purpose |
|---|---|---|---|
| **User Content → Photos or Videos** | No | No | App Functionality |
| **User Content → Other User Content** (tin nhắn chat) | No | No | App Functionality |

> Không khai Location / Identifiers / Usage / Diagnostics (app không thu). Đã gỡ `NSUserTrackingUsageDescription` + không ATT.

Bấm **Save** → **Publish**.

---

## Bước 5. iOS App › 1.0 Prepare for Submission

**Previews and Screenshots:**

| Ô trên App Store Connect | Kích thước nhận | Dùng thư mục |
|---|---|---|
| iPhone with Dynamic Island (medium display) | 1206×2622 **hoặc** 1179×2556 | [`screenshots/en/`](screenshots/en) |
| iPhone 6.9" Display (nếu có ô này) | 1290×2796 hoặc 1320×2868 | [`screenshots/src-1290x2796/`](screenshots/src-1290x2796) |

> Nếu giữ iPad (`"1,2"`) thì có thêm ô **iPad 13"** → phải nộp ảnh iPad. Đổi về `"1"` để khỏi.

Tải 6 ảnh theo thứ tự `01…06` (xem [screenshots/README.md](screenshots/README.md)).

**Promotional Text** (170/170 — sửa được bất cứ lúc nào, không cần duyệt lại):

```text
Snap a photo of any room and let AI restyle it in seconds — modern, cozy, minimal and more. Save your favorite looks, compare before and after, and ask the AI for advice.
```

**Description** (chép nguyên khối từ [metadata.md](metadata.md) › **mục 2 › Description**).

**Keywords** (97/100):

```text
bedroom,living,kitchen,makeover,renovate,furniture,remodel,house,bathroom,wall,paint,style,garden
```

| Ô | Điền |
|---|---|
| Support URL | `<link ở bước 0-B>` |
| Marketing URL | `<link ở bước 0-B>` (hoặc để trống) |
| Version | `1.0.0` |
| Copyright | `2026 <tên cá nhân hoặc công ty>` |
| App Icon | Tự lấy từ build, không cần tải lên |
| Build | Để trống, chọn ở bước 8 sau khi upload |

Ô **What's New** không có ở bản đầu tiên (từ 1.0.1 mới điền).

Bấm **Save**.

---

## Bước 6. App Review Information

| Ô | Điền |
|---|---|
| Sign-In Information | **Bỏ tích** "Sign-in required" (app không có tài khoản) |
| Contact Information | Họ tên, số điện thoại (+84…), email người Apple liên hệ. **Bắt buộc** |
| Attachment | Không cần |

**Notes**: chép nguyên khối từ [metadata.md](metadata.md) › **mục 4** (đã gồm: không tài khoản, có gửi ảnh/chat lên dịch vụ AI, không analytics/ads/tracking; bước test generate + chat; giải thích quyền Camera/Photos).

Bấm **Save**.

---

## Bước 7. Build và upload từ Xcode

1. [ ] `ITSAppUsesNonExemptEncryption = NO` đã thêm vào Info.plist (bước 0-B).
2. [ ] Target **SwiftBase** › **Signing & Capabilities**: tích *Automatically manage signing*, chọn **Team** trả phí.
3. [ ] Xác nhận `TARGETED_DEVICE_FAMILY` đúng ý (`"1"` iPhone-only, khuyến nghị).
4. [ ] AI đã wire thật, GoogleService-Info.plist thật (bước 0-A).
5. Thanh công cụ chọn scheme **SwiftBase** + **Any iOS Device (arm64)** → **Product › Archive**.
   - Build release không được dùng `ENABLE_DEBUG_DYLIB=NO` của lệnh dev; Xcode Archive tự lo. (Lệnh dev simulator: `xcodebuild -scheme SwiftBase -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build CODE_SIGNING_ALLOWED=NO ENABLE_DEBUG_DYLIB=NO`.)
6. Organizer: **Validate App** → **Distribute App › App Store Connect › Upload**.
7. Chờ Apple xử lý build (~10–30 phút, có email).

---

## Bước 8. Gửi duyệt

1. Trang **1.0.0 Prepare for Submission** › mục **Build** → chọn build vừa upload.
2. **App Store Version Release**: chọn phát hành tự động khi được duyệt, hoặc thủ công.
3. **Add for Review** → **Submit to App Review** (thường 1–2 ngày).

Muốn cho người khác dùng thử trước: **TestFlight** với chính build đã upload.

---

## Checklist trước khi submit

- [ ] 🔴 AI generate + chat **chạy thật** (không mock), test end-to-end
- [ ] GoogleService-Info.plist thật (bundle id Abodi)
- [x] Tên + bundle id Abodi (`com.abodi.home.interior.room.design`)
- [x] Display name "Abodi Home"
- [x] App icon 1024 (opaque, vuông)
- [x] Đã gỡ ATT prompt + `NSUserTrackingUsageDescription`
- [ ] `ITSAppUsesNonExemptEncryption = NO` vào Info.plist
- [ ] `TARGETED_DEVICE_FAMILY` chốt (`"1"` khuyến nghị)
- [ ] 6 ảnh màn hình trong `AppStore/screenshots/en/`
- [ ] App Privacy khai **User Content (Photos, Other)** — KHÔNG "Data Not Collected"
- [ ] Privacy Policy / Support URL do team chỉ định
- [ ] Tra lại trùng tên "Abodi" trên store
- [ ] Tài khoản Developer + chọn Team trong Xcode

## Nếu bị reject

Đọc phản hồi trong mục *App Review*, sửa, **tăng số build**, làm lại từ bước 7. Rủi ro hay gặp với app AI decor: **2.3.1** (mô tả nêu tính năng app chưa có — nhất là nếu AI còn mock); **5.1.1** (khai privacy sai — phải khai có thu User Content vì gửi ảnh lên server); **2.1** (reviewer không tạo được thiết kế — cần backend thật + Review Notes rõ). Khi cần trả lời Guideline 2.1 kèm video demo, xem [REVIEW_RESPONSE.md](REVIEW_RESPONSE.md).
