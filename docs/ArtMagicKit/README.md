# ArtMagicKit — gói gen AI (Code12 ArtMagic) cho iOS

Gói tự đủ để gắn các hàm gen vào một app iOS khác: **SDK + source Swift đã gỡ phụ thuộc + script patch + doc**.
Source tách ra từ app HomeDecor (nơi các hàm này đang được dùng), chỉ gỡ những chỗ dính HomeDecor.

Đọc theo thứ tự: **README này** (cài và dùng) → `REFERENCE.md` (giải thích từng hàm, công thức theo loại app, giới hạn đã biết).

## 0. Cần có trước khi bắt đầu (xin từ Code12 / người giao việc)

| Cần | Dùng cho | Nếu thiếu |
|---|---|---|
| `appId` + `secretKey` của **app mới** | `ArtMagicService(...)` | Mọi hàm ném `notConfigured`. Không dùng lại cặp key của app khác |
| Danh sách **template `code`** app được cấp | `generate(photo:code:)` | Không có `code` để gen. Lấy bằng `templates()` (mục 4) |
| `agentId` chat của app (nếu có chat) | `chat(...)` | Không chat được. Không đoán |
| Doc SDK của Code12 (mục 13.x, 14.x, 1, 7–12) | `options` của từng agent/video | Không biết `options` JSON hợp lệ. Gói này **không** có doc đó |

Key gửi **riêng**, không để trong gói và không commit lên repo công khai.

## 1. Trong gói có gì

```
ArtMagicKit/
├── IosArtMagic.xcframework        # SDK Code12 (đã patch interface cho Xcode 26.x)
├── scripts/patch_artmagic_interface.sh
├── Sources/
│   ├── ArtMagicService.swift          # client + hàm thô (decorate, result, staticVideo, analyze, catalog)
│   ├── ArtMagicService+Generate.swift # generate(photo:code:) -> UIImage  (gọi decorate, poll result, tải ảnh)
│   ├── ArtMagicService+Catalog.swift  # sections / allTemplates / groupCode(containing:)
│   ├── ArtMagicService+Chat.swift     # chat(_:language:userId:agentId:) -> String
│   ├── PhotoTools.swift               # chuẩn hoá ảnh, JPEG tạm, kiểm tra tối, quyền camera/ảnh
│   └── Parsing/                       # chỉ dùng Foundation, có test: CatalogError, GenerationParser,
│                                      #   HomeContent (model + HomeContentParser), ChatReplyParser
├── Checks/                        # run.sh + main.swift: self-check của 3 parser
├── README.md
└── REFERENCE.md
```

**Không có** trong gói (là UI/lưu trữ riêng của HomeDecor, tự dựng theo app mới): màn Create/Outcome, `Popup`,
`LookStore`, `ChatStore`, router. Mẫu cách dựng (tiến trình giả, huỷ, retry, lỗi mạng) nằm trong `REFERENCE.md` mục 5.1.

### Khác gì so với source trong repo HomeDecor

| File trong gói | Gốc trong HomeDecor | Thay đổi |
|---|---|---|
| `ArtMagicService.swift` | `Services/ArtMagicService.swift` | Credentials truyền qua `init` (đọc lại mỗi lần gọi). Bỏ 2 hằng key cứng và `RemoteConfigManager` |
| `ArtMagicService+Generate.swift` | `+Generate.swift` | `GenerationParser` tách sang `Parsing/` |
| `ArtMagicService+Catalog.swift` | `+Catalog.swift` | `CatalogError` tách sang `Parsing/` |
| `ArtMagicService+Chat.swift` | `+Chat.swift` | `agentId` là **tham số bắt buộc** (gốc cứng `"400"`); `ChatReplyParser` tách sang `Parsing/` |
| `Parsing/HomeContent.swift` | `Common/Models/HomeContent.swift` | Bỏ `HomeSection.zone` / `inZone` (dính màn Search của HomeDecor) |
| `PhotoTools.swift` | `Services/PhotoTools.swift` | Giữ nguyên |

`REFERENCE.md` viết cho repo HomeDecor nên nhắc `RemoteConfigManager`, `hardcoded*`, `zone`… — **không có trong gói**; theo bảng trên.

## 2. Cài vào app mới

1. **SDK:** kéo `IosArtMagic.xcframework` vào project; ở target app đặt **Embed & Sign** (link + embed ở mọi target chạy app).
   Bản trong gói đã patch sẵn. Chỉ khi Code12 gửi **bản SDK mới**: thay thư mục `IosArtMagic.xcframework` cạnh script rồi chạy
   `scripts/patch_artmagic_interface.sh` (SDK build bằng Swift 6.4; Xcode 26.x báo `expected dictionary value type` nếu chưa patch).
2. **Source:** kéo cả thư mục `Sources/` (giữ `Parsing/`) vào target app. Deployment target **iOS 16+**.
3. **Quyền** (Info.plist), chỉ cần khi dùng `PhotoTools` cho camera / thư viện / lưu ảnh; **viết nội dung theo app của bạn**:
   `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`. Thiếu key là crash khi mở.
4. **Tạo service, đúng 1 instance cho cả app** (nó cache client):

```swift
// Key cố định:
let artMagic = ArtMagicService(appId: "…", secretKey: "…")

// Hoặc key đến muộn (Remote Config sau splash). Closure được đọc lại mỗi lần gọi; còn rỗng thì ném notConfigured:
let artMagic = ArtMagicService { (MyConfig.appId, MyConfig.secretKey) }
```

## 3. Dùng

```swift
// Gen ảnh: ảnh người dùng -> ảnh kết quả
let file  = try PhotoTools.jpegFile(PhotoTools.normalized(userImage))   // JPEG tạm, ≤ 2048px, xoay đúng
let image = try await artMagic.generate(photo: file, code: "<template_code>")   // UIImage

// Catalog: danh mục + template để người dùng chọn
let sections  = try await artMagic.sections()                           // [HomeSection]
let templates = try await artMagic.allTemplates(category: sections[0].category.id)
let group     = try await artMagic.groupCode(containing: "inside")      // nếu app chia nhóm

// Chat (Markdown). userId = 1 giá trị cho mỗi lần cài; đổi userId để bắt đầu hội thoại mới
let text = try await artMagic.chat("Xin chào", language: "vi", userId: savedUserId, agentId: "<agentId>")
```

`generate` mất vài giây đến ~3 phút (poll 2 s/lần, tối đa 90 lần). Chạy trong `Task`, hiện tiến trình giả, và gọi
`Task.checkCancellation()` sau khi xong — huỷ không dừng được request đã gửi (xem `REFERENCE.md` mục 6).

Video / phân tích ảnh / hàm SDK khác: `REFERENCE.md` mục 5.2, 5.3, 5.5.

## 4. Smoke test — LÀM TRƯỚC KHI DỰNG UI

Parser đọc JSON theo **danh sách key đoán** (`GenerationParser.urlKeys`, `HomeContentParser`…): server trả `{status, data, page}`,
nhưng tên key chi tiết chưa được xác nhận đủ. Chạy 1 lần trên app mới và đọc payload:

```swift
#if DEBUG
Task {
    print(CatalogError.preview(try await artMagic.categoryGroups(), limit: 600))
    print(CatalogError.preview(try await artMagic.templates(page: 0, size: 3), limit: 600))
    let sample = try PhotoTools.jpegFile(someUIImage)
    print(CatalogError.preview(try await artMagic.decorate(image: sample, code: "<template_code>"), limit: 600))
    // Tìm: URL ảnh kết quả nằm ở key nào? Có data.requestId không?
}
#endif
```

Nếu key thật khác danh sách, **sửa danh sách** trong `Parsing/` cho khớp (đừng thêm chồng). Catalog rỗng: bản DEBUG của
`sections()` tự in thêm `groups:` / `templates:` không filter để phân biệt "app chưa có catalog" với "filter sai".

## 5. Đã kiểm tra gì / chưa

Đã chạy (trên máy build gói):
- `Checks/run.sh`: **parser** đạt toàn bộ ca thử. Payload trong đó là **tự soạn** theo shape đã biết, không phải response thật của server.
- `swiftc -typecheck` toàn bộ `Sources/` với iOS Simulator SDK, target iOS 16, qua bản `xcframework` trong gói: **biên dịch sạch**.

**Chưa** làm: build thành app đầy đủ, chạy trên máy/simulator, gọi server thật với key của app mới. Bản gốc trong HomeDecor có gọi
gen ảnh, catalog và chat; `staticVideo` và `analyze` **chưa từng được gọi** ở đâu. Premium (`isPremium`) chỉ được đọc, chưa có paywall.
