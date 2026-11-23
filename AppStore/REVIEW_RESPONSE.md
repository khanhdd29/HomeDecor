# Trả lời App Review — Guideline 2.1 Information Needed

## 0. Hiểu đúng tình huống (đừng lo)

Nếu Apple gửi **Guideline 2.1 – Information Needed**: đây **không phải** reject vì app lỗi/bị cấm. Reviewer cần thêm thông tin (và thường 1 video demo) để hiểu & test. Cách xử lý:

1. **Dán nội dung ở Mục 2 bên dưới vào ô "Notes"** của **App Review Information**.
2. **Đính kèm video demo** (quay luồng dùng) vào ô **Attachment** của App Review Information (hoặc reply kèm file trong **Resolution Center**).
3. **Resubmit** — thường **không cần build mới**, dùng lại build đã upload (xem Mục 4).

> Không phải sửa code. Chỉ bổ sung thông tin + video rồi gửi lại. (Trừ khi lỗi thật — ví dụ AI generate còn mock: lúc đó phải wire thật + build mới, xem [RELEASE_STEPS.md](RELEASE_STEPS.md) bước 0-A.)

---

## 1. Về video demo & "máy thật" — ĐỌC KỸ

Apple thường ghi: *"A screen recording captured on a physical device, running the latest operating system."* → **họ muốn máy thật.** Video quay trên Simulator có rủi ro bị hỏi lại (và máy thật sẽ cho ảnh camera/kết quả AI đẹp hơn). **Khuyến nghị: quay trên iPhone thật.**

### Cách quay trên iPhone thật mà KHÔNG cần máy riêng (mượn 10 phút)
1. **Mượn 1 iPhone bất kỳ** (bạn bè/người thân), iOS mới.
2. Cài app lên máy đó qua **TestFlight** (build đã upload):
   - App Store Connect → app → **TestFlight** → **Internal Testing** → thêm build → mời Apple ID người cho mượn (hoặc tạo **public link**).
   - Người mượn mở **TestFlight** → cài Abodi.
3. **Quay màn hình ngay trên iPhone** (không cần Mac/cáp):
   - Settings → Control Center → thêm **Screen Recording**.
   - Vuốt Control Center → bấm ⏺ (chờ 3s) → mở app, thao tác theo **Mục 3** → vuốt xuống dừng.
   - Video lưu vào **Photos** → AirDrop/gửi.
4. Upload video đó vào Attachment (hoặc Drive + dán link vào Notes).

> Cách khác (có Mac + cáp): **QuickTime Player → File → New Movie Recording → chọn camera là iPhone** → quay → Save.

Nếu file video vượt giới hạn đính kèm: upload Google Drive/Dropbox (link ai cũng xem được) rồi **dán link vào ô Notes**.

---

## 2. NỘI DUNG DÁN VÀO Ô "NOTES" (chép nguyên khối tiếng Anh)

```text
Thank you for reviewing Abodi. Below is the information requested.

OVERVIEW / PURPOSE (item 2)
Abodi is an AI interior-design app for everyday users. The user takes or picks a photo of a room, chooses a style, and the app returns an AI-generated redesign of that exact room (walls, furniture, lighting and mood). A built-in AI Designer (chat) also answers decorating questions and can give advice on a photo the user attaches. Target audience: general consumers who want to redecorate or get design ideas. The problem it solves: seeing a realistic restyle of your own room, privately, without an account.

HOW TO SET UP AND ACCESS THE MAIN FEATURES (item 3)
No login or credentials are required — the app has no account system and uses an anonymous on-device identifier only. On first launch, choose a language and pass the short onboarding.
1. Redesign a room: on the Create tab, tap the upload area, choose "Take photo" or "Photo library", and pick a room photo (Camera / Photo Library permission is requested here, only when used). Pick a style, then tap Generate. After a few seconds the redesigned room appears; drag the before/after slider to compare, then "Save to My look".
2. AI Designer: open the floating button, type a question (e.g. "ideas for a cozy small bedroom") and send. You can also attach a room photo to get tailored advice.
3. My look: shows saved designs; each can be downloaded to Photos or shared.
No sample files or demo accounts are needed.

EXTERNAL SERVICES, TOOLS, OR PLATFORMS (item 4)
- AI image/redesign and chat are produced by our AI service (image-generation API). The photo the user selects, and chat messages (with an optional attached photo), are sent to this service for processing; the generated result/reply is returned. This is the app's core function.
- There are NO other third-party services: no authentication service, no payment processor, no analytics, and no advertising SDKs. The app has no in-app purchases in this version.

DATA & PRIVACY
The app has no account and does not track users (no App Tracking Transparency, no NSUserTrackingUsageDescription). It does not collect analytics or advertising data. The only data that leaves the device is the photo and chat text the user chooses to process with the AI service, used solely to generate the requested design or reply, tied to an anonymous identifier (not to the user's identity). Saved designs, history, language and settings are stored only on the device, and the user can delete them at any time. App Privacy is therefore declared as collecting "User Content (Photos, Other)" for App Functionality, not linked to identity and not used for tracking.
User-generated content: a user's photos and generated designs are private to that user and are NOT shared with or shown to other users, so no content moderation/reporting/blocking system is required.

REGIONAL DIFFERENCES (item 5)
The app's features are identical in every region. The interface is localized in 16 languages and follows the device language automatically. There are no region-locked features or content.

REGULATED INDUSTRY / PROTECTED MATERIAL (item 6)
Abodi is a general consumer design app. It does not operate in a regulated industry and contains no protected third-party material. Redesigns are generated from the user's own photo; the app ships no third-party content of its own and requires no special credentials or authorization.

PERMISSIONS (requested only when the related feature is used)
- Camera: to take a photo of the room to redesign.
- Photo Library: to pick a room photo to redesign.
- Add to Photos: to save a generated design back to the photo library.

NSAllowsArbitraryLoads is NOT enabled. If anything else is needed, we are happy to provide it. Thank you.
```

---

## 3. SCRIPT QUAY MÀN HÌNH — luồng dùng điển hình (từng chạm)

> Mục tiêu Apple: "bắt đầu bằng mở app, thể hiện luồng dùng điển hình." App không có đăng nhập / mua hàng / nội dung chia sẻ giữa user → không cần quay mấy thứ đó.

### Chuẩn bị trước khi bấm quay
- [ ] Mở app **1 lần trước đó**, qua onboarding. (Để lúc quay không kẹt màn chọn ngôn ngữ, trừ khi muốn quay cả onboarding.)
- [ ] Có sẵn **1 ảnh phòng đẹp** trong thư viện (hoặc đứng ở phòng đủ sáng để chụp).
- [ ] Bật **Do Not Disturb**.
- [ ] Về **Home Screen**, thấy icon **Abodi Home**.
- [ ] Vuốt Control Center → bấm **⏺ Screen Recording** → đợi đếm ngược 3 giây.

> ⭐ Nên quay từ lần cài MỚI để thể hiện: chọn ngôn ngữ → onboarding → **popup hệ thống xin quyền Camera/Photos** → dùng app. Về trạng thái "cài mới": xoá app rồi cài lại qua TestFlight.

### Các bước (làm chậm, mỗi bước dừng vài giây)
1. **Chạm icon Abodi Home** → **Splash** → **Language**: chọn **English** → **Continue**.
2. Qua các màn **Intro** → **Get started**.
3. Vào tab **Create (Home)**. **Dừng ~2s** cho thấy hero + các section style.
4. **Chạm vùng upload / nút chụp ảnh** → chọn **"Photo library"** (hoặc "Take photo").
5. **Popup hệ thống xin quyền** ("Allow Abodi to access your photos / camera?") → **Allow**.
6. **Chọn 1 ảnh phòng** → quay lại màn chọn style. **Dừng ~1s**.
7. **Chọn 1 style** (ví dụ "Modern"/"Cozy") → **Dừng ~1s**.
8. **Chạm "Generate"** → màn generating (Analyzing → Applying → Rendering). **Dừng** chờ ra kết quả.
9. Màn **Your Design**: **kéo slider before/after** để so sánh. **Dừng ~3s**.
10. **Chạm "Save to My look"**.
11. Mở **AI Designer** (nút nổi) → **gõ "ideas for a cozy small bedroom"** → gửi → **Dừng** chờ trả lời. (Có thể đính kèm ảnh phòng để tư vấn.)
12. Mở tab **My look** → thấy thiết kế vừa lưu. **Dừng ~2s**. (Có thể chạm Download/Share.)
13. (Nên có — chứng minh privacy) Mở **Settings** → **Privacy Policy**; cho thấy không có đăng nhập.
14. Vuốt Control Center → **bấm ⏺ đỏ để dừng quay**. Video lưu vào **Photos**.

### Mẹo
- Thao tác **thong thả** — reviewer cần nhìn kịp.
- Tổng video ~**40–70 giây** là đẹp.
- ⚠️ Generate + chat phải **chạy thật** (không mock) khi quay cho reviewer — nếu không thì app chưa sẵn sàng submit.

---

## 4. CÁC BƯỚC RESUBMIT TRÊN APP STORE CONNECT

1. [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → chọn app → bản đang "Rejected".
2. Mục **App Review Information**:
   - Dán khối tiếng Anh (Mục 2) vào ô **Notes**.
   - Ô **Attachment**: chọn file video (nếu quá dung lượng → upload Drive/Dropbox, để link công khai, dán link cuối ô Notes).
   - **Sign-In required**: để **TẮT**.
   - Contact info: tên, số điện thoại, email.
3. (Khuyến nghị) Mở **Resolution Center** → **Reply** → dán tóm tắt + đính kèm/link video.
4. Bấm **Save**.
5. **Add for Review** → **Submit for Review** (nếu không đổi build thì dùng lại build cũ; nếu đã wire AI thật thì phải upload build mới trước).
6. Chờ duyệt lại (thường 1–2 ngày).

---

## 5. Checklist nhanh trước khi bấm Submit

- [ ] Đã dán Notes (Mục 2) vào App Review Information.
- [ ] Đã đính kèm video (hoặc link) demo luồng dùng — AI chạy thật.
- [ ] Sign-In required = OFF.
- [ ] Contact info đầy đủ.
- [ ] (Nếu được) đã reply kèm video trong Resolution Center.
- [ ] Bấm Submit for Review.
