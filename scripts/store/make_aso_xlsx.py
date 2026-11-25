#!/usr/bin/env python3
"""Generate AppStore/Abodi_ASO_Metadata_iOS.xlsx.

A Notes sheet (limits + positioning) plus one "<lang> iOS" sheet per store
locale (Field | Value | Count | Status). EN is the locale that ships (store is
English-only); VI is kept ready in case a VN store page is ever added. The app
itself is localized in 16 languages regardless of the store page.

Keep the copy in sync with AppStore/metadata.md, then re-run:

    python3 scripts/store/make_aso_xlsx.py
"""
import pathlib
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

OUT = pathlib.Path(__file__).resolve().parents[2] / "AppStore" / "Abodi_ASO_Metadata_iOS.xlsx"

LIMITS = {
    "App name": 30,
    "Subtitle": 30,
    "Promotional text": 170,
    "Long description": 4000,
    "What's New (v1.0)": 4000,
    "Keywords": 100,
}

EN = {
    "App name": "Abodi: AI Room & Home Design",
    "Subtitle": "Interior decor & restyle ideas",
    "Primary Category": "Graphics & Design",
    "Secondary Category": "Lifestyle",
    "Promotional text": (
        "Snap a photo of any room and let AI restyle it in seconds — modern, cozy, "
        "minimal and more. Save your favorite looks, compare before and after, and "
        "ask the AI for advice."
    ),
    "Long description": (
        "Abodi turns a single photo of your room into a beautiful redesign in seconds. "
        "Point your camera at any space, pick a style you love, and watch AI reimagine "
        "it — walls, furniture, lighting and mood. It is fast, private and works without "
        "an account.\n\n"
        "REDESIGN ANY ROOM\n"
        "- Take a photo or pick one from your library\n"
        "- Choose from styles for every space: living room, bedroom, kitchen, bathroom, and outdoor\n"
        "- Try looks like modern, cozy, minimal, warm and more\n"
        "- Get a fresh AI concept in seconds\n\n"
        "SEE THE DIFFERENCE\n"
        "- Drag the before/after slider to compare your room with the new design\n"
        "- Keep the versions you like and try the same room in other styles\n\n"
        "YOUR OWN AI DESIGNER\n"
        "- Ask the built-in AI Designer anything about decorating — colors, layouts, small-space ideas\n"
        "- Send a photo of your room and get tailored suggestions back\n"
        "- Turn a suggestion into a full redesign with one tap\n\n"
        "SAVE YOUR LOOKS\n"
        "- Every design you like is saved to My look on your device\n"
        "- Download a design to Photos or share it with a friend\n"
        "- Clean up anytime — it is your gallery\n\n"
        "FIND INSPIRATION\n"
        "- Browse curated styles by room and category\n"
        "- Open any look to start redesigning your own space\n\n"
        "PRIVATE BY DESIGN\n"
        "No account, no ads and no trackers. Your photos are used only to create your "
        "designs, and your saved looks, history and settings stay on your iPhone. You can "
        "delete anything at any time.\n\n"
        "IN YOUR LANGUAGE\n"
        "Abodi speaks 16 languages and opens in your device language when it can — English, "
        "Spanish, French, German, Portuguese (Brazil & Portugal), Russian, Turkish, Arabic, "
        "Hindi, Bengali, Indonesian, Japanese, Korean, and Chinese (Simplified & Traditional). "
        "Switch any time in Settings.\n\n"
        "Download Abodi and see your home in a whole new style."
    ),
    "What's New (v1.0)": "First release of Abodi.",
    "Keywords": "bedroom,living,kitchen,makeover,renovate,furniture,remodel,house,bathroom,wall,paint,style,garden",
}

VI = {
    "App name": "Abodi: Thiết kế nhà bằng AI",
    "Subtitle": "Trang trí & đổi kiểu nội thất",
    "Primary Category": "Đồ hoạ & Thiết kế",
    "Secondary Category": "Phong cách sống",
    "Promotional text": (
        "Chụp ảnh bất kỳ căn phòng và để AI đổi phong cách trong vài giây — hiện đại, ấm "
        "cúng, tối giản và hơn thế. Lưu thiết kế yêu thích, so sánh trước/sau và hỏi AI "
        "để tư vấn."
    ),
    "Long description": (
        "Abodi biến một tấm ảnh phòng của bạn thành bản thiết kế đẹp chỉ trong vài giây. "
        "Hướng camera vào bất kỳ không gian nào, chọn phong cách bạn thích, rồi xem AI tái "
        "hiện lại — tường, nội thất, ánh sáng và không khí. Nhanh, riêng tư và dùng được mà "
        "không cần tài khoản.\n\n"
        "THIẾT KẾ LẠI MỌI PHÒNG\n"
        "- Chụp ảnh hoặc chọn ảnh từ thư viện\n"
        "- Chọn phong cách cho mọi không gian: phòng khách, phòng ngủ, bếp, phòng tắm, ngoài trời\n"
        "- Thử các kiểu như hiện đại, ấm cúng, tối giản, ấm áp và hơn nữa\n"
        "- Có bản thiết kế AI mới trong vài giây\n\n"
        "THẤY RÕ KHÁC BIỆT\n"
        "- Kéo thanh trước/sau để so sánh phòng gốc với thiết kế mới\n"
        "- Giữ các phiên bản bạn thích và thử cùng căn phòng với phong cách khác\n\n"
        "TRỢ LÝ THIẾT KẾ AI RIÊNG\n"
        "- Hỏi AI mọi thứ về trang trí — màu sắc, bố cục, ý tưởng cho không gian nhỏ\n"
        "- Gửi ảnh phòng và nhận gợi ý riêng cho bạn\n"
        "- Biến một gợi ý thành bản thiết kế hoàn chỉnh chỉ với một chạm\n\n"
        "LƯU THIẾT KẾ CỦA BẠN\n"
        "- Mỗi thiết kế bạn thích được lưu vào My look trên máy\n"
        "- Tải thiết kế về Ảnh hoặc chia sẻ cho bạn bè\n"
        "- Dọn dẹp bất cứ lúc nào — đây là bộ sưu tập của bạn\n\n"
        "TÌM CẢM HỨNG\n"
        "- Duyệt các phong cách tuyển chọn theo phòng và danh mục\n"
        "- Mở bất kỳ mẫu nào để bắt đầu thiết kế lại không gian của bạn\n\n"
        "RIÊNG TƯ NGAY TỪ ĐẦU\n"
        "Không tài khoản, không quảng cáo, không theo dõi. Ảnh của bạn chỉ dùng để tạo thiết "
        "kế; các mẫu đã lưu, lịch sử và cài đặt nằm trên iPhone của bạn. Bạn có thể xoá bất "
        "cứ lúc nào.\n\n"
        "THEO NGÔN NGỮ CỦA BẠN\n"
        "Abodi hỗ trợ 16 ngôn ngữ và mở theo ngôn ngữ máy khi có thể — Anh, Tây Ban Nha, "
        "Pháp, Đức, Bồ Đào Nha (Brazil & Bồ Đào Nha), Nga, Thổ Nhĩ Kỳ, Ả Rập, Hindi, Bengali, "
        "Indonesia, Nhật, Hàn và Trung (Giản thể & Phồn thể). Đổi bất cứ lúc nào trong Cài đặt.\n\n"
        "Tải Abodi và ngắm ngôi nhà của bạn trong một diện mạo hoàn toàn mới."
    ),
    "What's New (v1.0)": "Phiên bản đầu tiên của Abodi.",
    "Keywords": "phòng ngủ,phòng khách,bếp,cải tạo,nội thất,sửa nhà,nhà,phòng tắm,sơn,màu,phong cách,sân vườn",
}

NOTES = [
    ("Abodi ASO Metadata — v1.0", None),
    ("Apple App Store Connect limits", None),
    ("App name", "30 chars"),
    ("Subtitle", "30 chars"),
    ("Promotional text", "170 chars (changeable post-launch, not indexed for search)"),
    ("Long description", "4000 chars"),
    ("Keyword Field", "100 chars, comma-separated, no spaces after commas"),
    ("What's New", "4000 chars"),
    ("Positioning", "AI interior redesign from a room photo + an AI design chat. Diff vs other "
                    "AI decor apps = before/after slider, AI Designer chat with photo advice, styles "
                    "per room type, 16 languages, no account, no ads."),
    ("Tone", "Friendly, fast, privacy-aware. Lead with 'snap a photo -> AI restyle in seconds' and "
             "'no account, no ads'. Only describe shipped features (do NOT describe AI as live while "
             "it is still mock) to stay 2.3.1-safe."),
    ("Store locales", "EN ships (store English-only). VI kept ready in case a VN store page is added. "
                      "The app itself is localized in 16 languages regardless of the store page."),
    ("Keyword strategy", "App name + subtitle are auto-indexed by Apple. Keyword field holds words NOT in "
                         "name/subtitle (no abodi/ai/room/home/design/interior/decor/restyle/ideas), no "
                         "competitor names, no 'free'."),
    ("Categories", "Primary: Graphics & Design. Secondary: Lifestyle."),
    ("Bundle ID", "com.abodi.home.interior.room.design (dev: .dev). Display name 'Abodi Home'. "
                  "Check 'Abodi' is free on the App Store before submit."),
    ("App icon", "1024x1024 opaque, square — AppStore/AppIcon-1024.png (embedded in build)."),
    ("Devices", "iPhone-only (TARGETED_DEVICE_FAMILY = 1) -> no iPad screenshots needed."),
    ("Privacy", "App sends room photos + chat to an AI service -> App Privacy = User Content "
                "(Photos, Other) / App Functionality / not linked / no tracking. NOT 'Data Not "
                "Collected'. PrivacyInfo.xcprivacy ships; ATT removed."),
    ("Before submit (blocking)", "Wire real AI (Code12 creds) so generate + chat work (currently mock); "
                                 "real GoogleService-Info.plist; host Privacy Policy + Support URL."),
]

# ---- styling ----
HEAD_FILL = PatternFill("solid", fgColor="EF5B3A")   # Abodi coral
TITLE_FILL = PatternFill("solid", fgColor="FDE7E0")
WHITE = Font(color="FFFFFF", bold=True, size=11)
BOLD = Font(bold=True)
OVER_FILL = PatternFill("solid", fgColor="FFD4D4")
OK_FILL = PatternFill("solid", fgColor="D9F2E3")
TOP = Alignment(vertical="top", wrap_text=True)
THIN = Side(style="thin", color="E6DCD6")
BORDER = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)


def build_locale_sheet(wb, title, data):
    ws = wb.create_sheet(title)
    ws.column_dimensions["A"].width = 20
    ws.column_dimensions["B"].width = 95
    ws.column_dimensions["C"].width = 7
    ws.column_dimensions["D"].width = 8
    for c, h in enumerate(["Field", "Value", "Count", "Status"], 1):
        cell = ws.cell(row=1, column=c, value=h)
        cell.fill = HEAD_FILL; cell.font = WHITE; cell.border = BORDER
        cell.alignment = Alignment(vertical="center")
    order = ["App name", "Subtitle", "Primary Category", "Secondary Category",
             "Promotional text", "Long description", "What's New (v1.0)", "Keywords"]
    for r, field in enumerate(order, 2):
        val = data[field]
        ws.cell(row=r, column=1, value=field).font = BOLD
        ws.cell(row=r, column=2, value=val)
        if field in LIMITS:
            n = len(val); lim = LIMITS[field]
            ws.cell(row=r, column=3, value=n)
            st = ws.cell(row=r, column=4, value="OK" if n <= lim else "OVER")
            st.fill = OK_FILL if n <= lim else OVER_FILL
            st.alignment = Alignment(horizontal="center", vertical="top")
        for c in range(1, 5):
            cell = ws.cell(row=r, column=c)
            cell.border = BORDER; cell.alignment = TOP
    ws.freeze_panes = "A2"
    return ws


def build_notes_sheet(wb):
    ws = wb.create_sheet("Notes")
    ws.column_dimensions["A"].width = 24
    ws.column_dimensions["B"].width = 95
    for r, (a, b) in enumerate(NOTES, 1):
        ca = ws.cell(row=r, column=1, value=a)
        cb = ws.cell(row=r, column=2, value=b)
        ca.alignment = TOP; cb.alignment = TOP
        ca.font = BOLD
        if b is None:
            ca.fill = TITLE_FILL; cb.fill = TITLE_FILL
    return ws


def main():
    wb = openpyxl.Workbook()
    wb.remove(wb.active)
    build_notes_sheet(wb)
    build_locale_sheet(wb, "EN iOS", EN)
    build_locale_sheet(wb, "VI iOS", VI)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    wb.save(OUT)
    print(f"Wrote {OUT}")
    for name, data in (("EN", EN), ("VI", VI)):
        print(f"\n{name}:")
        for field, lim in LIMITS.items():
            n = len(data[field]); flag = "OK" if n <= lim else "OVER !!!"
            print(f"  {field:20} {n:>5}/{lim}  {flag}")


if __name__ == "__main__":
    main()
