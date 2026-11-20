> **Ghi chú khi nằm trong gói `ArtMagicKit`:** doc này viết cho repo HomeDecor, nên nhắc `RemoteConfigManager`,
> `hardcodedAppId/SecretKey`, `HomeSection.zone`, `agentId: "400"`… — **những thứ đó không có trong gói**. Đối chiếu bảng
> "Khác gì so với source trong repo HomeDecor" ở `README.md`: credentials truyền qua `init`, `CatalogError`/parser tách vào
> `Sources/Parsing/`, `chat` nhận `agentId`. Đường dẫn `Services/…` ↔ `Sources/…`. Cài đặt: làm theo `README.md`.

# ArtMagic — Hàm gen & cách apply sang app khác

Doc này mô tả **các hàm gen (tạo ảnh/video/chat bằng AI) của HomeDecor** và các bước đem chúng sang
một app Code12 khác. Mọi thứ bên dưới lấy từ code thật trong repo; chỗ nào **chưa chạy thử** hoặc
**đang đoán** đều có ghi rõ ở mục 6.

Phạm vi: `Services/ArtMagicService*.swift` + những thứ nó cần để chạy được (credentials, parser,
xử lý ảnh, lưu kết quả). Kiến trúc chung của app (ads, router, onboarding) xem `README.md`.

---

## 1. Tóm tắt

- Toàn bộ "gen" đi qua **một service**: `ArtMagicService` (bọc `ArtMagicClient` của SDK
  `IosArtMagic.xcframework`). Lấy bằng `Container.shared.artMagic()` hoặc `@Injected(\.artMagic)`.
- SDK **không có model**: mọi hàm trả `Any` (thực tế `[String: Any]`). Việc "hiểu" JSON nằm ở
  3 parser nhỏ: `HomeContentParser`, `GenerationParser`, `ChatReplyParser`.
- 3 tầng:

| Tầng | Hàm | Việc |
|---|---|---|
| Bridge | `currentClient()`, `call(_:)` | Dựng client từ credentials, đổi callback SDK → `async throws` |
| Thô (1 hàm = 1 endpoint) | `decorate`, `result`, `staticVideo`, `analyze`, `categoryGroups`, `categories`, `templates`, `templateDetail` | Trả JSON nguyên bản |
| Cao (đã parse, dùng thẳng trong UI) | `generate`, `chat`, `sections`, `allTemplates`, `groupCode(containing:)` | Trả `UIImage` / `String` / model |

- **Muốn gen ảnh ở app khác, đường ngắn nhất** (mục 4.1): copy 3 file + `CatalogError` + `PhotoTools`,
  điền `appId`/`secretKey` vào Remote Config, rồi:

```swift
let file  = try PhotoTools.jpegFile(PhotoTools.normalized(userImage))
let image = try await Container.shared.artMagic().generate(photo: file, code: "<template_code>")
```

---

## 2. Bản đồ hàm

`✅` = HomeDecor đang dùng. `⚪` = có sẵn trong service nhưng **app chưa gọi, chưa kiểm chứng**.

### 2.1 Hàm thô — `ArtMagicService.swift`

| Hàm | Gọi SDK | Dùng cho | |
|---|---|---|---|
| `categoryGroups()` | `getImageEditingCategoryGroups` | Nhóm danh mục (doc 14.4), vd Inside/Outside | ✅ |
| `categories(page:size:groupCode:)` | `getImageEditingCategories` | Danh mục = loại phòng (doc 13.1 / 14.5) | ✅ |
| `templates(page:size:category:)` | `getTemplateApps` | Template = style (doc 13.2 / 14.6). Field `premium` = template trả phí | ✅ |
| `templateDetail(code:)` | `getTemplateDetail` | Chi tiết 1 template | ⚪ |
| `decorate(image:code:options:attachments:prompt:)` | `processImageEditing` | **Gen ảnh từ ảnh** (doc 13.3). Cũng khởi chạy video premium `GENERATE_VIDEO` (doc 14.2) | ✅ |
| `result(requestId:)` | `getImageEditingResult` | Hỏi trạng thái/kết quả job của `decorate`/`staticVideo` (doc 14.3) | ✅ |
| `staticVideo(image:templateCode:options:prompt:)` | `generateStaticVideo` | Video từ ảnh + template `GENERATE_STATIC_VIDEO`, vd `static_frame_02` (doc 14.1) | ⚪ |
| `analyze(image:code:options:attachments:uuid:)` | `processGeneralAgent` | Agent phân tích ảnh: `ai_plant_identification`, `ai_garden_recommendation`… (doc mục 1, 7–12) | ⚪ |
| `call(_:)` | — | Cầu nối SDK → async. **Thêm hàm SDK mới = 1 wrapper dùng `call`** (mục 5.5) | ✅ |

`options` luôn là **chuỗi JSON**, mặc định `"{}"`. Ví dụ video: `{"aspectRatio":"PORTRAIT","duration":"5"}`.

### 2.2 Hàm cao

| Hàm | File | Trả về | |
|---|---|---|---|
| `generate(photo:code:)` | `+Generate` | `UIImage` kết quả | ✅ |
| `chat(_:language:userId:)` | `+Chat` | `String` (Markdown) | ✅ |
| `sections(groupCode:categorySize:templateSize:)` | `+Catalog` | `[HomeSection]` (mỗi danh mục + vài template đầu) | ✅ |
| `allTemplates(category:pageSize:)` | `+Catalog` | `[HomeTemplate]` — tất cả template 1 danh mục, phân trang | ✅ |
| `groupCode(containing:)` | `+Catalog` | `String` — mã nhóm có code/tên chứa keyword | ✅ |

### 2.3 SDK có nhưng `ArtMagicService` **chưa bọc**

Từ `ArtMagicClient` (swiftinterface): `removeObject`, `searchFood`, `getFoodDetail`, `createCharacter`,
`updateCharacter`, `deleteCharacter`, `getMyAgent`, `getAgents`, `getTags`, `getConversation`,
`getWeather`, `request(method:path:…)` (gọi path tuỳ ý), `upgradeProfile` (gợi ý gói trả phí theo hành vi).
Cần thì thêm wrapper theo mục 5.5.

---

## 3. Luồng chạy end-to-end

```
Splash   RemoteConfig.fetchAndActivate ──► RemoteConfigManager.appConfig (appId, secretKey)
                                              │  (thiếu 1 trong 2 → mọi hàm ném notConfigured)
Home     groupCode(containing: "inside") ─► sections(groupCode:) ─► [HomeSection]
                                              ▲ 1 call categories + N call templates chạy song song
Create   Camera/Library ─► PhotoTools.normalized (≤2048px, xoay đúng) ─► crop ─► isTooDark?
                         ─► PhotoTools.jpegFile (JPEG 0.9 vào thư mục tmp)
Outcome  generate(photo:code:)
           ├─ decorate(image:code:)                      ──► payload
           ├─ có URL ảnh?  ── có ─► download ─► UIImage ✔
           └─ chưa, có data.requestId? ─► ngủ 2s ─► result(requestId:) ─► lặp (tối đa 90 lần ≈ 3 phút)
Lưu      LookStore.add(jpeg)  →  Documents/Looks/<uuid>.jpg
```

Màn hình: Style Detail → Upload Photo → Choose Style → Outcome. State chung là `CreateSession`.
`OutcomeScreen` là 1 màn 3 pha (`generating → ready → result`), nên "Generate again" chỉ là
`OutcomeViewModel.start()`.

---

## 4. Apply sang app khác

### 4.0 Điều kiện cần có trước khi copy

1. **`appId` + `secretKey` do Code12 cấp cho app mới.** Không dùng lại cặp của HomeDecor.
2. App mới được Code12 **cấp quyền template** (danh mục/template là theo từng app: `templates()` chỉ trả
   thứ app được cấp). Chưa cấp thì catalog rỗng, `generate` không có `code` để chạy.
3. Biết **loại tính năng**: ảnh→ảnh (mục 4.1), ảnh→video (5.2), phân tích ảnh (5.3), chat (5.4).

### 4.1 Gen ảnh — bộ file tối thiểu

| Cần copy | Từ | Ghi chú |
|---|---|---|
| `IosArtMagic.xcframework` | `Frameworks/` | Link **và** Embed & Sign ở mọi target chạy app |
| `patch_artmagic_interface.sh` | `scripts/` | Chạy 1 lần + chạy lại mỗi khi thay xcframework (mục 6, ý 8) |
| `ArtMagicService.swift` | `Services/` | Core |
| `ArtMagicService+Generate.swift` | `Services/` | `generate` + `GenerationParser` |
| `CatalogError` | `ArtMagicService+Catalog.swift` dòng 8–24 | **`+Generate` và `+Chat` đều phụ thuộc type này.** Copy cả file `+Catalog`, hoặc chỉ lấy `CatalogError` |
| `AppConfig` (2 field `appId`, `secretKey`) | `Core/Ads/AdConfig/AppConfig.swift` | Hoặc đọc credentials theo cách khác (mục 4.3) |
| `RemoteConfigManager.appConfig` | `Core/Ads/RemoteConfigManager.swift` | `ArtMagicService.currentClient()` đọc `RemoteConfigManager.shared.appConfig`. App mới không dùng bộ ads này thì sửa 1 dòng đó |
| `artMagic` factory | `Common/Factory/Container+Services.swift` | `Factory(self) { ArtMagicService() }.singleton` — cần package **Factory** |
| `PhotoTools` | `Services/PhotoTools.swift` | `normalized`, `jpegFile` là bắt buộc; `cropped`, `isTooDark`, quyền camera/ảnh là tuỳ chọn |

Thêm nếu muốn đủ luồng như HomeDecor:

| Tuỳ chọn | Từ |
|---|---|
| Catalog (Home/Search/Category) | `+Catalog`, `Common/Models/HomeContent.swift` |
| State luồng tạo | `Common/Models/CreateSession.swift` |
| Màn + VM tạo | `Views/Create/*` (xem `OutcomeViewModel` làm mẫu cho: tiến trình giả, huỷ, retry, lỗi mạng) |
| Lưu kết quả | `Services/LookStore.swift` |
| Popup lỗi/xác nhận | `Common/Components/PopupView.swift` |
| Chat | `+Chat`, `ChatStore`, `Views/Chat/*`, `Common/Models/ChatMessage.swift` |

### 4.2 Project setup

- **Deployment target iOS 16+**, Xcode 26.x. SDK build bằng Swift 6.4 nên **phải** chạy
  `scripts/patch_artmagic_interface.sh` (bỏ tiền tố `Module::` trong `.swiftinterface`), nếu không
  Xcode báo `expected dictionary value type`. Binary giữ nguyên.
- SPM: `Factory`; Firebase `RemoteConfig` nếu lấy credentials từ Remote Config.
- Quyền (HomeDecor đặt bằng `INFOPLIST_KEY_*` trong build settings, **không** nằm trong `Info.plist`):
  `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`
  (lưu ảnh kết quả vào thư viện). **Viết lại nội dung theo app mới** — bản gốc có chữ "Home Decor".
  Thiếu key thì crash ngay khi mở camera/thư viện.

### 4.3 Credentials

`currentClient()` lấy `appId`/`secretKey` rồi dựng `ArtMagicClient` lười (lần gọi đầu), dựng lại nếu giá trị đổi.

Ở app mới:

1. Thêm vào JSON của khoá Remote Config **`app_configs`** (ở cả project Firebase dev và prod):
   `{"appId": "...", "secretKey": "...", "appToken": "...", "eventToken": "..."}`.
2. Trong `ArtMagicService.swift`, **để rỗng** 2 hằng `hardcodedAppId` / `hardcodedSecretKey`
   (khi khác rỗng, chúng thắng Remote Config).
3. **Không copy hằng key của HomeDecor sang app khác**, và không commit key thật của app mới vào repo công khai.
4. Client chỉ dựng được **sau khi Splash fetch xong**. Gọi gen trước đó → `ServiceError.notConfigured`.

### 4.4 Những chỗ đang gắn với HomeDecor — đổi/bỏ khi copy

| Chỗ | Trong HomeDecor | Làm gì ở app mới |
|---|---|---|
| `groupCode(containing: "inside"/"outside")`, `SearchViewModel.Zone` | 2 nhóm Inside/Outside | Xem `categoryGroups()` của app mới để biết nhóm thật; nếu không chia nhóm thì gọi `sections()` không `groupCode` |
| `HomeSection.zone: SearchViewModel.Zone?` + `inZone(_:)` (`HomeContent.swift`) | Dính type của màn Search | **Xoá 2 thứ này** nếu không copy `SearchViewModel`, nếu không sẽ lỗi compile |
| `CreateSession.zone`, `roomName` | Loại phòng hiện dưới kết quả | Đổi tên/bỏ theo domain (kiểu tóc, hình xăm…) |
| `chat`: `agentId: "400"` | Agent "AI Designer" | Dùng `agentId` Code12 cấp cho app mới |
| `ChatStore`: file `chat.json`, key `chat.userId` | — | Giữ được; đổi nếu xung đột |
| `LookStore`: thư mục `Documents/Looks` | "My look" | Giữ hoặc đổi tên theo app |
| Chuỗi UI (`generating`, `designingRoom`, popup…) | Tiếng Anh + 16 ngôn ngữ | Dịch lại cho domain mới |
| `OutcomeViewModel.step` (0/1/2) | "analyzing / applying style / rendering" | Đổi chữ cho đúng tính năng |

### 4.5 Smoke test trước khi tin parser (làm ngay ở app mới)

Parser đang chứa **danh sách key đoán** (mục 6, ý 2). Trước khi dựng UI, in payload thật:

```swift
#if DEBUG
Task {
    let s = Container.shared.artMagic()
    print(CatalogError.preview(try await s.categoryGroups(), limit: 600))
    print(CatalogError.preview(try await s.templates(page: 0, size: 3), limit: 600))
    // 1 lần gen thật với 1 code lấy từ templates():
    let payload = try await s.decorate(image: someJpegURL, code: "<code>")
    print(CatalogError.preview(payload, limit: 600))   // tìm: URL ảnh nằm ở key nào? có data.requestId không?
}
#endif
```

So với `GenerationParser.urlKeys` / `HomeContentParser` — nếu key thật khác, **sửa danh sách key** (hoặc thu gọn
về đúng key thật) thay vì thêm tiếp.

Với catalog rỗng, `sections()` bản DEBUG tự in thêm `groups:` và `templates:` không filter, để phân biệt
"app chưa có catalog" với "filter sai".

---

## 5. Công thức theo loại app

### 5.1 Ảnh → ảnh (HomeDecor; mọi app "chọn style rồi biến đổi ảnh")

Giữ nguyên `generate`. Chỉ khác `code` (lấy từ `templates()` / `HomeTemplate.id`) và UI. Mẫu dùng trong VM
(rút từ `OutcomeViewModel.run`):

```swift
let file  = try PhotoTools.jpegFile(photo)                     // photo đã normalized
let image = try await service.generate(photo: file, code: style.id)
try Task.checkCancellation()                                   // SDK call không huỷ được, xem mục 6 ý 5
```

Có `prompt`/`attachments`/`options` riêng thì gọi `decorate(...)` trực tiếp rồi dùng lại vòng poll — tốt nhất
tách vòng poll thành hàm dùng chung (mục 5.2).

### 5.2 Ảnh → video  *(chưa chạy thử trên server — HomeDecor chưa dùng `staticVideo`)*

Cùng cơ chế `requestId` + `result(requestId:)` (doc 14.3 nói `result` dùng cho cả `decorate` và `staticVideo`).
Đề xuất tách poll dùng chung, rồi video chỉ trả **URL** (không tải về `UIImage`):

```swift
extension ArtMagicService {
    /// Chờ job xong, trả URL kết quả. Dùng cho cả ảnh lẫn video.
    func awaitResult(startedWith first: Any) async throws -> URL {
        var payload = first
        for _ in 0..<90 {
            if let url = GenerationParser.imageURL(in: payload) { return url }   // tên "imageURL" nhưng tìm URL http bất kỳ
            guard let id = GenerationParser.requestId(in: payload) else { break }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            payload = try await result(requestId: id)
        }
        throw CatalogError.unrecognized("result", in: payload)
    }

    func generateVideo(photo: URL, templateCode: String, options: String = #"{"aspectRatio":"PORTRAIT","duration":"5"}"#) async throws -> URL {
        try await awaitResult(startedWith: try await staticVideo(image: photo, templateCode: templateCode, options: options))
    }
}
```

Việc cần kiểm tra khi dùng thật: key chứa URL video có nằm trong `urlKeys` không; video lâu hơn ảnh nên 3 phút
có đủ không; phát video bằng `AVPlayer` từ URL từ xa hay tải về trước.

### 5.3 Phân tích ảnh (nhận diện cây, món ăn, tư vấn vườn…)

```swift
let payload = try await service.analyze(image: file, code: "ai_plant_identification", options: "{}")
```

Trả JSON thô **theo từng agent**, shape khác nhau → mỗi agent cần 1 parser riêng (viết như `ChatReplyParser`:
đọc `status.code`, lấy `data`, ném `CatalogError.unrecognized` nếu không khớp). Mã agent và `options` của từng agent
tra trong doc Code12 (mục 1, 7–12); repo này không có.

### 5.4 Chat

```swift
let text = try await service.chat("Gợi ý màu sơn phòng ngủ", language: "vi", userId: store.userId)
```

- `userId` quyết định **trí nhớ hội thoại phía server** (đã thử: cùng `userId` thì nhớ). Mỗi bản cài một
  `userId` (`ChatStore.userId`), "New chat"/"Clear chat" gọi `renewUserId()`.
- `language` = `AppLanguage.chatCode` (`pt`, `zh-CN`, `zh-TW`; còn lại dùng thẳng `rawValue`).
- Trả lời là **Markdown**, bubble phải vẽ được `**đậm**` và danh sách.
- `ChatReplyParser` ném message của server khi `status.code` khác `0`/`200`.
- Đổi `agentId` (hiện cứng `"400"` trong `ArtMagicService+Chat.swift`) sang agent của app mới; nếu app có nhiều
  agent thì đưa `agentId` thành tham số của `chat`.

### 5.5 Thêm một hàm SDK mới (vd `removeObject`)

Đúng mẫu hiện có: 1 wrapper, không logic khác.

```swift
func removeObject(image: URL, mask: URL? = nil) async throws -> Any {
    try await call { client, done in client.removeObject(fileURL: image, maskFileURL: mask, callback: done) }
}
```

Chữ ký thật của SDK xem trong `Frameworks/IosArtMagic.xcframework/**/arm64-apple-ios.swiftinterface`.
Nếu kết quả cũng là URL ảnh sau 1 job thì dùng lại `awaitResult` (5.2).

---

## 6. Giới hạn đã biết — đọc trước khi dùng

1. **Credentials đang cứng trong code.** `hardcodedAppId` / `hardcodedSecretKey` thắng Remote Config và
   nằm trong binary. Là tạm thời (có comment `ponytail:`). App mới: để rỗng, dùng Remote Config.
2. **Key trong parser là đoán.** `GenerationParser.urlKeys`, `skippedKeys` và các danh sách trong
   `HomeContentParser` (vd `animeCode`, `thumbnailEdited`) có comment `ponytail:` "trim them once real payloads
   have been seen". Chỉ chắc chắn: server trả `{status, data: [...], page: {has_next}}`; template có `code`,
   `categoryCode`, `imageUrl`, `premium`, `templateType`. App mới: chạy smoke test (4.5) rồi thu gọn.
3. **`premium` chỉ được parse, chưa được dùng.** `HomeTemplate.isPremium` không có chỗ nào đọc ngoài parser →
   **chưa có chặn template trả phí / paywall.** Muốn bán gói thì tự thêm (và có thể tham khảo `upgradeProfile`
   của SDK).
4. **`generate` không đọc trạng thái lỗi của job.** Nếu job fail phía server mà payload vẫn kèm `data.requestId`,
   vòng poll chạy hết 90 lần (~3 phút) rồi báo `No picture in: …`; nếu không có `requestId` thì báo ngay.
   Nếu `decorate` ném lỗi (mạng/timeout) thì `generate` ném lỗi luôn — **không** có đường lấy lại `requestId`
   để poll tiếp.
5. **Huỷ không dừng được request đang bay.** `call` dùng `withCheckedThrowingContinuation` nên `Task.cancel()`
   chỉ dừng được ở `Task.sleep`/tải ảnh; request đã gửi vẫn chạy trên server (có thể vẫn tốn quota). VM phải
   `Task.checkCancellation()` sau `generate` (`OutcomeViewModel` làm vậy).
6. **Thanh tiến trình là giả** (server không trả %): tiến dần tới 92%, mỗi 0,3s thêm 4% phần còn lại.
7. **File JPEG tạm không bị xoá** (`PhotoTools.jpegFile` ghi vào `temporaryDirectory`, để hệ điều hành dọn).
8. **SDK Swift 6.4 ↔ Xcode 26.x:** bắt buộc patch interface sau mỗi lần thay xcframework (hoặc bỏ patch khi
   Code12 build lại bằng Swift 6.2).
9. **Chưa có test** cho parser/service. 3 parser là hàm thuần nên dễ thêm test bằng payload thật dán vào.
10. `result(requestId:)` được doc ghi là dò kết quả của cả ảnh và video, nhưng **app chỉ dùng cho ảnh**;
    video (`staticVideo`) và `analyze` chưa từng được gọi trong repo này.

---

## 7. Checklist apply

- [ ] Có `appId` + `secretKey` + danh sách `code` template từ Code12 cho app mới
- [ ] Thêm `IosArtMagic.xcframework` (Link + Embed), chạy `patch_artmagic_interface.sh`
- [ ] Copy `ArtMagicService.swift`, `+Generate`, `CatalogError`, `PhotoTools`, factory `artMagic`
- [ ] `app_configs` trên Remote Config (dev + prod) có `appId`, `secretKey`; 2 hằng `hardcoded*` để rỗng
- [ ] Khai báo 3 usage description (camera, thư viện, lưu ảnh), viết lại nội dung theo app
- [ ] Splash: fetch Remote Config xong **trước** khi gọi bất kỳ hàm gen nào
- [ ] Smoke test (4.5): in payload `categoryGroups`, `templates`, `decorate`; chỉnh key parser theo thực tế
- [ ] Xoá/đổi phần dính HomeDecor: `Zone`, `roomName`, `agentId`, chuỗi UI (bảng 4.4)
- [ ] Quyết định chính sách `premium` (mục 6 ý 3) trước khi phát hành
- [ ] Chạy 1 lần gen thật end-to-end + thử tắt mạng + thử huỷ giữa chừng
