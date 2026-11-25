# Monetization & Firebase — gỡ ở v1, khôi phục cho version sau

Bản **v1 lên App Store đã GỠ SẠCH** ads + Firebase + analytics + RemoteConfig (commit `b6c84a1`) vì Apple reject **Guideline 2.3.1(a)** (hidden features) và **5.6** (fraud pattern) — SDK bị link vào binary dù tắt, cộng cờ `isInReview` + RemoteConfig bật-từ-xa. **KHÔNG mất gì** — toàn bộ "khung" còn trong git.

## Khôi phục ở đâu

- **Git tag `pre-monetization-removal`** (commit `3f33171`) = bản cuối còn **đầy đủ** ads + Firebase + RemoteConfig + Adjust, build chạy được.
- Xem khung cũ: `git show pre-monetization-removal:HomeDecor/Core/Ads/Utils/AdUtil.swift` (đổi path tuỳ file).
- Lấy lại 1 file: `git checkout pre-monetization-removal -- HomeDecor/Core/Ads` (rồi sửa lại cho sạch).
- So sánh những gì đã gỡ: `git show b6c84a1` (commit gỡ).

## "Khung" gồm những gì (để biết cần khôi phục gì)

**SPM packages** (thêm lại qua Xcode ▸ Package Dependencies):
| Package | URL |
|---|---|
| firebase-ios-sdk | https://github.com/firebase/firebase-ios-sdk.git — products: FirebaseCore, FirebaseAnalytics, FirebaseCrashlytics, FirebaseRemoteConfig |
| ads-swift (wrapper nội bộ) | https://DucManh98@bitbucket.org/innofyapp/ads-swift.git — kéo theo AdMob/AppLovin/FB Audience Network/UMP |
| facebook-ios-sdk | https://github.com/facebook/facebook-ios-sdk — product: FacebookCore |
| adjust ios_sdk | https://github.com/adjust/ios_sdk.git — product: AdjustSdk |

**Code** (ở tag cũ, `HomeDecor/Core/`):
- `Core/Ads/` — `AdUtil`, `AdsManager`(trong ads-swift), `InterHomeUtil`, `RemoteConfigManager`, `AdjustManager`, `UMPManager`, `RevenueLogging`, `NativeAllAdManager`, `RewardAllUtil`, `AdConfig/*` (gồm `AppConfig` chứa creds + cờ `isInReview`).
- `Core/Firebase/` — `AnalyticsTracker` (log `screen_view`), `AnalyticsScreen` (enum màn). *v1 đã thay bằng `Common/Analytics/ScreenTracking.swift` — chỉ cần nối lại Firebase bên trong modifier là analytics sống lại, không phải sửa 9 call-site `.trackScreen`.*

**Call-site đã gỡ** (nối lại khi khôi phục):
- `SplashView.configAds()` — chuỗi init ads/consent (ORDER quan trọng).
- `AppDelegate.configureFirebase()`.
- `SwiftBaseApp` — `.environment(\.openURL){ AdUtil.suppressAdsUntilReturn() }`.
- `HomeViewModel`/`HomeDetailViewModel` — `InterHomeUtil.instance.show(...)`.
- `IntroView`/`LanguageView` — native ad (`NativeAdViewModel` + `NativeContentView`). Lottie (tap-hint) đi kèm ads-swift → v1 đã thay bằng `LottieTapView` SwiftUI thuần; muốn Lottie lại thì thêm package `airbnb/lottie-ios`.
- `Container+Services` — creds ArtMagic đọc từ `RemoteConfigManager.shared.appConfig` (giờ đọc từ `ArtMagicCredentials.swift` local).

**Info.plist** (thêm lại khi có ads): `GADApplicationIdentifier`, `SKAdNetworkItems` (~190 id), `FacebookAppID`/`FacebookClientToken`/`FacebookAutoLogAppEventsEnabled`, `NSUserTrackingUsageDescription` (ATT). Cũng cần `GoogleService-Info.plist` thật.

## ⚠️ Khi bật lại ads/Firebase (tránh reject lần nữa)

1. **Phải là tính năng NHÌN THẤY** trong app ở đúng version đó — đừng ship SDK "ngủ". Apple quét binary.
2. **BỎ HẲN cờ kiểu `isInReview`** và mọi cơ chế "bật tính năng từ xa SAU khi duyệt" — đó chính là thứ dính 5.6.
3. Khai **App Privacy** đúng (ads = tracking → bật ATT + `NSUserTrackingUsageDescription`, khai data collected).
4. Mô tả store nêu rõ có ads nếu có; không giấu.

## IAP (thêm ở version sau — chưa từng có)

Chưa có code IAP; `AppFeatures.iapEnabled=false`, `showPro=false` (nút Pro ✦ ẩn). Khi làm:
- Dùng **StoreKit 2** (`Product`, `Transaction`, `Product.purchase()`), không cần SDK ngoài.
- Khai sản phẩm trong App Store Connect (consumable/non-consumable/subscription).
- Mở nút Pro: đặt `AppFeatures.iapEnabled=true` → `showPro` tự bật lại (AppHeader + Settings đã gate sẵn theo `showPro`).
- Paywall là tính năng nhìn thấy ngay version đó; đừng ship ẩn.
