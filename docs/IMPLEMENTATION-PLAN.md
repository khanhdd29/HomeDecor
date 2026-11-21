# Home Decor iOS — Kế hoạch triển khai theo Phase

> App AI redesign phòng: **chọn/chụp ảnh phòng → chọn style → AI generate ảnh mới → lưu "My look"**.
> Nền tảng: SwiftUI iOS 16+ (SwiftBase scaffold) + **ArtMagicKit** (SDK gen AI của Code12).
> Design: Figma **"Coral Glass"** (glassmorphism + accent coral), 393×852 (iPhone).
>
> **Bản v1 lên store: KHÔNG ads, KHÔNG IAP.** Toàn bộ phần ads & premium/paywall → **comment lại để dùng sau**, không gắn placement mới, không dựng màn paywall.

---

## Trạng thái hiện tại (đã khảo sát)

- **Có sẵn (SwiftBase):** luồng khởi động (Splash → Language → Intro → Home TabView), AppRouter (mỗi tab 1 stack), Core/Ads (AdMob đầy đủ), Core/Firebase (analytics), i18n 6 ngôn ngữ, DI bằng Factory.
- **Placeholder (cần thay bằng UI Figma):** `Views/*` hiện là demo (Home list số, Search/Favorites rỗng…). Tab đang là `home/search/favorites/settings`.
- **CHƯA có:** `ArtMagicService*` chưa copy vào project (mới nằm ở `docs/ArtMagicKit/Sources/`), chưa add `IosArtMagic.xcframework`, chưa có LookStore/ChatStore/CreateSession, chưa có design system Coral Glass.

### Tab bar thật (theo Figma) — khác code hiện tại
| Tab | Nội dung | Map code hiện tại |
|-----|----------|-------------------|
| **Create** | Màn Home: hero "Reimagine any room" + catalog style theo category + FAB tạo | `home` |
| **Inspiration** | Duyệt catalog: Category / Gallery style / Style Detail | `search` |
| **My look** | Ảnh đã generate & lưu (grid, select, delete, share) | `favorites` |
| **Setting** | Ngôn ngữ, privacy, share app | `settings` |

> **AI Chat** (trợ lý thiết kế) là 1 khu riêng — **entry point cần xác nhận** (nhiều khả năng từ nút menu ☰ ở Home hoặc 1 nút riêng, không phải 1 tab). Xem ❓ ở cuối.

---

## Nguyên tắc xuyên suốt (áp cho mọi phase)
- [ ] **Không gắn ad placement mới.** Giữ nguyên `Core/Ads` nhưng để tắt (RemoteConfig `showAllAds=false`, không có ad unit id → `isEnable=false`). Các call-site ads cũ trong Splash giữ nguyên (tự no-op khi tắt).
- [ ] **Không IAP/paywall.** Nút **Pro (✦)** ở header và template **premium** → ẩn/comment. v1 coi mọi template là free (hoặc chỉ hiển thị template free).
- [ ] Mọi chuỗi text → key trong `Localizable.strings` đủ **6 ngôn ngữ** (en, vi, de, es, fr, ja).
- [ ] Mỗi màn mới → thêm case `AnalyticsScreen` + `.trackScreen(...)`.
- [ ] Mỗi màn mới → thêm case `Destination` + map trong `Navigation.screen(for:)`; header tự vẽ bằng component (router ẩn navbar hệ thống).
- [ ] Credentials (`appId`/`secretKey`/`agentId`) **không commit** — lấy từ Remote Config `app_configs`.

---

## PHASE 0 — Rebrand + Design System "Coral Glass" (nền UI) — ✅ phần lớn (2026-11-20)
*Mục tiêu: dựng nền thương hiệu + hệ thiết kế để mọi màn sau dùng chung.*

> **Đã build SUCCEEDED + chạy thật trên simulator**: Home hiện 4 tab mới, tab active màu coral.
> Trong lúc làm phát hiện project bị **rename dở** (folder đổi SwiftBase→HomeDecor nhưng config chưa cập nhật) → đã sửa: scheme `ReferencedContainer`, `INFOPLIST_FILE`, đường dẫn GoogleService trong script Crashlytics, và **synchronized root group `path`** (SwiftBase→HomeDecor) — chính chỗ này làm app target trước đó không có source nào.

- [~] 0.1 Rebrand: **AccentColor xong**. Còn lại (tên hiển thị "Home Decor", bundle id `com.vtn.SwiftBase`, rename target/scheme `SwiftBase`→`HomeDecor`, `AppConstants.appId`/`policyLink`) → **làm riêng, cẩn thận** (đổi product name/bundle id).
- [x] 0.2 `AccentColor` = coral **#EF5B3A** (sample thật từ Figma) + màu nền peach + glass surface → `DesignSystem/AppColor.swift`.
- [x] 0.3 **Design tokens** `DesignSystem/AppTheme.swift` (radius/spacing/gradient/font) + `AppFeatures.swift` (cờ tắt ads & IAP v1).
- [x] 0.4 Component Coral Glass dùng chung:
  - [x] `GlassCard` (+ `.glassCard()`) — frosted + viền + shadow.
  - [x] Nền **blob gradient** `BlobBackground`.
  - [x] `PrimaryButton` (coral capsule) + `AppButton` (dark pill, icon tròn kính, coral circle).
  - [x] `AppHeader` (☰ menu · wordmark · ✦Pro ẩn qua `AppFeatures.showPro`).
  - [x] `BeforeAfterSlider` (so sánh kéo, nhãn Before/After).
  - [x] `CoralTabBar` + `CreateFAB` (component sẵn — **wire vào shell ở Phase 3**; hiện tab bar vẫn dùng native TabView + tint coral).
- [x] 0.5 Đổi `HomeTab` + `Destination` + navi + `AppManager` + `HomeTabView` + `AnalyticsScreen`: `create / inspiration / mylook / setting`; thêm key localization 6 ngôn ngữ.
- [ ] 0.6 Import assets từ Figma (icon, ảnh) → để **kéo theo từng phase** khi dựng màn thật.
- [ ] 0.7 Dọn placeholder → thay dần nội dung ở phase tương ứng.

**Done khi:** app build chạy, vào Home thấy đúng tab bar + theme coral, chưa cần dữ liệu thật. → **Đạt** (còn 0.1 rebrand định danh + 0.6 assets để sau).

---

## PHASE 1 — Tích hợp ArtMagicKit (nền AI gen) — ✅ tích hợp xong (2026-11-21)
*Theo `docs/ArtMagicKit/README.md` + `REFERENCE.md`. Làm TRƯỚC khi dựng màn Create.*

> **BUILD SUCCEEDED + app chạy không dyld-crash** → framework embed đúng. Chưa test gen thật (chờ credentials Code12).

- [x] 1.1 Add `IosArtMagic.xcframework` (patch interface + copy ra `Frameworks/`) → **Link + Embed & Sign** cho cả 2 target (via gem `xcodeproj`), set `FRAMEWORK_SEARCH_PATHS`.
- [x] 1.2 Copy `Sources/` → `HomeDecor/Services/ArtMagic/` (service + `+Generate`/`+Catalog`/`+Chat` + `Parsing/*` + `PhotoTools`).
- [x] 1.3 Credentials qua Remote Config `app_configs`: thêm `appId`/`secretKey`/`agentId` vào `AppConfig`. **Cần Code12 cấp giá trị thật** (xem ❓).
- [x] 1.4 Factory `artMagic` singleton (`Container+Services.swift`) đọc credentials lười; `ArtMagicConfig.agentId` cho chat.
- [x] 1.5 Info.plist: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription` (wording Home Decor).
- [~] 1.6 **Smoke test**: đã có scaffold `ArtMagicSmokeTest.run()` (DEBUG, chạy tay). **Chạy thật + chỉnh key parser khi có credentials.**
- [x] 1.7 `LookStore` (Documents/Looks) — lưu/đọc/xoá ảnh kết quả.
- [x] 1.8 Models: `HomeContent`/`HomeSection`/`HomeTemplate` (đi kèm kit, đã sạch `Zone`). `CreateSession` → dựng ở **Phase 4** (state luồng tạo).
- [x] 1.9 Policy `premium` v1: **hiển thị tất cả template, không gate, không badge** (vì không paywall) — áp khi render ở Phase 3/5.

**Done khi:** gọi được `sections()` / `generate(photo:code:)` thật end-to-end. → **Tích hợp + build + chạy OK; gọi server thật chờ credentials Code12.**

---

## PHASE 2 — Onboarding reskin (Splash · Language · Intro)
- [ ] 2.1 **Splash** Coral Glass + progress bar % theo bước config thật (giữ thứ tự `configAds`, ads tắt).
- [ ] 2.2 **Language** (onboarding) + **Language 3** theo Figma (list cờ + chọn).
- [ ] 2.3 **Intro** 4 slide (Intro 1–4) nội dung + minh hoạ Coral Glass; nút next/skip/done → `finishOnboarding()`.
  - *Ghi chú:* Figma có thêm biến thể Intro 13–16 (A/B) — chốt 1 bộ khi làm.
- [ ] 2.4 Cập nhật `IntroPage.all` + localize.

**Done khi:** luồng Splash→Language→Intro→Home đúng theme, returning user vào thẳng Home.

---

## PHASE 3 — Tab **Create** (Home)
- [ ] 3.1 Header: ☰ menu · "Home Decor" wordmark · ✦Pro (ẩn/comment v1).
- [ ] 3.2 **Hero carousel**: Before/After "Reimagine any room" + "Try Now" (paging dots).
- [ ] 3.3 **Section catalog theo category** (vd "Modern Outside"): card ngang + "Show all" → See All.
- [ ] 3.4 Nạp dữ liệu từ `artMagic.sections()` (+ trạng thái loading/empty/error).
- [ ] 3.5 **FAB Create** (nút coral nổi) → mở luồng Create (Phase 4).
- [ ] 3.6 Tab bar custom Coral Glass hoạt động giữa 4 tab.

**Done khi:** Home hiển thị catalog thật, bấm card/FAB mở được bước tiếp.

---

## PHASE 4 — Luồng **Create / Generate** (lõi app) ⭐
*Màn: Style Detail → Upload Photo → Choose Style → Generating → Result. State dùng chung `CreateSession`.*

- [ ] 4.1 **Style Detail** (+ biến thể *Inside*): preview style, "More in <category>", nút "Try this style".
- [ ] 4.2 **Upload Photo** (+ *Selected* / *No Style*): chip style đã chọn + đổi style, "Tips for best results", Continue.
- [ ] 4.3 **Sheet — Add Photo**: Take photo / Photo library.
- [ ] 4.4 **Camera** → **Adjust Photo** (crop + "Use this photo"), dùng `PhotoTools.normalized/cropped`.
- [ ] 4.5 **Photo Library** picker (Recents).
- [ ] 4.6 **Choose Style** (+ *Outside*): toggle Inside/Outside, **Room type** (Living/Bedroom/Bathroom/Kitchen…), lưới **Style**, "Generate". + **Sheet — Change Style**.
- [ ] 4.7 **Generating** (+ *Done*): progress % **giả**, 3 bước (Analyzing room → Applying style → Rendering), "Stop".
- [ ] 4.8 **Result** (+ *Saved*): "Your Design" + Before/After slider, tên style, **Save to My look** / **View in My look**, share.
- [ ] 4.9 **Compare — Fullscreen** (slider toàn màn).
- [ ] 4.10 **ViewModel** (theo `OutcomeViewModel` mẫu): `generate()`, huỷ (`Task.checkCancellation`), retry/regenerate, lỗi mạng, `isTooDark`.
- [ ] 4.11 **Popups** Coral Glass:
  - [ ] Generation Failed · No Internet · Stop Generating · Photo Quality (ảnh tối) · Regenerate (bản mới) · Discard Design (rời không lưu)
  - [ ] Camera Access · Camera Access Off · Photo Access Off (xin quyền → Open Settings)
- [ ] 4.12 Lưu kết quả vào `LookStore`.

**Done khi:** chụp/chọn ảnh → chọn style → generate thật → xem Result → lưu vào My look, đủ các nhánh lỗi/huỷ.

---

## PHASE 5 — Tab **Inspiration** (duyệt catalog)
- [ ] 5.1 **Category** + **Category — See All** (lưới style theo danh mục).
- [ ] 5.2 **Inspiration — Inside** + **Inspiration — Loading** (phân nhóm Inside/Outside theo `categoryGroups`).
- [ ] 5.3 **Gallery** style (grid) + **Gallery Empty** / **Gallery — Loading**.
- [ ] 5.4 **Style — Image Preview** (xem lớn 1 style) → vào Create với style đó.
- [ ] 5.5 Dữ liệu từ `allTemplates(category:)` / `groupCode(containing:)`.

**Done khi:** duyệt được toàn catalog, chọn style nào cũng nhảy vào luồng Create.

---

## PHASE 6 — Tab **My look** (ảnh đã lưu)
- [ ] 6.1 Lưới ảnh từ `LookStore` + **Gallery — Downloaded** / **Loading** / empty.
- [ ] 6.2 **Gallery — Detail** (xem 1 ảnh) + **Sheet — Image Options** (tải/ chia sẻ/ xoá).
- [ ] 6.3 **Gallery — Select Mode** (chọn nhiều) + **Popup — Delete** / **Delete Selected** / **Gallery — Deleted**.
- [ ] 6.4 **Sheet — Share** (chia sẻ ảnh).

**Done khi:** xem/tải/chia sẻ/xoá (đơn & nhiều) ảnh đã generate.

---

## PHASE 7 — AI Chat (trợ lý thiết kế)
*Dùng `artMagic.chat(...)` + `ChatStore` (userId). Entry point: xác nhận ❓.*
- [ ] 7.1 **AI Chat — Welcome** (gợi ý mở đầu) + **Style Ideas**.
- [ ] 7.2 **Conversation** + **Typing** (render **Markdown**: đậm, list).
- [ ] 7.3 **Attach Photo** (Sheet) → **Photo Sent** / **Photo Advice**.
- [ ] 7.4 **Send Failed** (retry) + **Chat Options** (Sheet) + **Popup — Clear Chat** (`renewUserId`).
- [ ] 7.5 `ChatStore`: file `chat.json`, `userId`, New/Clear chat.

**Done khi:** chat qua lại được (text + ảnh), lưu/clear hội thoại.

---

## PHASE 8 — Tab **Setting**
- [ ] 8.1 **Setting** (Coral Glass): ngôn ngữ, privacy, share, (ẩn Pro v1).
- [ ] 8.2 **Setting — Languages** (đổi ngôn ngữ runtime) + **Languages — Applying**.
- [ ] 8.3 **Setting — Privacy Policy** + **Link Copied** + **Sheet — Share App**.
- [ ] 8.4 **State — No Internet** / **Server Error** (dùng chung toàn app).

**Done khi:** đổi ngôn ngữ áp ngay, mở privacy/share, có state lỗi chung.

---

## PHASE 9 — Hoàn thiện & chuẩn bị Store
- [ ] 9.1 Rà soát mọi màn: empty / loading / error đồng nhất.
- [ ] 9.2 **Xác nhận ads & IAP tắt hoàn toàn** cho v1 (không popup, không paywall, Pro ẩn).
- [ ] 9.3 Localization đủ 6 ngôn ngữ, không key thiếu.
- [ ] 9.4 App icon, launch screen, màu accent cuối.
- [ ] 9.5 Build Release, chạy simulator + device, **test generate end-to-end thật**, thử tắt mạng / huỷ giữa chừng.
- [ ] 9.6 Privacy manifest / App Store metadata / ảnh chụp màn hình.

---

## ❓ Cần bạn xác nhận / cung cấp trước khi code
1. **Credentials Code12 cho app Home Decor mới**: `appId`, `secretKey`, danh sách `code` template, `agentId` (chat). *Thiếu → không gen/chat được, nhưng vẫn dựng UI trước được.*
2. **Entry point AI Chat**: từ menu ☰ ở Home, hay nút riêng? (4 tab đã kín: Create/Inspiration/My look/Setting.)
3. **Bộ Intro**: dùng Intro 1–4 hay biến thể 13–16?
4. Hex màu coral chính xác (tôi sẽ lấy từ Figma variables ở Phase 0 nếu bạn không chốt).

## Thứ tự đề xuất thực thi
**Phase 0 → 1** (nền) ⟶ **2** (onboarding) ⟶ **3 → 4** (lõi Create) ⟶ **5 → 6** ⟶ **7** ⟶ **8** ⟶ **9**.
Phase 4 là phần lớn & quan trọng nhất; 5/6/7 tương đối độc lập, có thể làm song song sau khi 3+4 xong.
