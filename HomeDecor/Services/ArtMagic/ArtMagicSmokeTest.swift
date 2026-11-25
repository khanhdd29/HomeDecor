//
//  ArtMagicSmokeTest.swift
//  HomeDecor
//
//  One-off smoke test for the ArtMagic integration. DEBUG only.
//  Call `ArtMagicSmokeTest.run()` manually AFTER Remote Config has delivered
//  credentials (e.g. from a temporary button or lldb), then read the printed
//  payloads and trim the guessed key lists in Parsing/ to the real server
//  shape. See docs/ArtMagicKit/README.md §4 / REFERENCE.md §4.5.
//
//  Do NOT wire this into the launch path — it hits the network.
//

#if DEBUG
import Foundation
import Factory

enum ArtMagicSmokeTest {
    static func run(sampleTemplateCode: String? = nil) {
        let service = Container.shared.artMagic()
        Task {
            do {
                print("— ArtMagic smoke test —")
                print("categoryGroups:\n" + CatalogError.preview(try await service.categoryGroups(), limit: 600))
                print("templates:\n" + CatalogError.preview(try await service.templates(page: 0, size: 3), limit: 600))
                if let code = sampleTemplateCode {
                    print("decorate(\(code)) needs a photo URL — run from the Create flow instead.")
                }
            } catch {
                print("ArtMagic smoke test failed: \(error)")
            }
        }
    }
}
#endif
