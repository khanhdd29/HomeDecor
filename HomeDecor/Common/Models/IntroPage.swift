//
//  IntroPage.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

struct IntroPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let message: String
    let tint: Color

    /// The onboarding slides shown in order (Coral Glass).
    static let all: [IntroPage] = [
        IntroPage(
            systemImage: "wand.and.stars",
            title: "intro_title_1",       // AI Room Makeover
            message: "intro_message_1",
            tint: AppColor.coral
        ),
        IntroPage(
            systemImage: "text.bubble.fill",
            title: "intro_title_2",       // AI Design Advice
            message: "intro_message_2",
            tint: AppColor.coral
        ),
        IntroPage(
            systemImage: "square.grid.2x2.fill",
            title: "intro_title_3",       // Explore Interior Styles
            message: "intro_message_3",
            tint: AppColor.coral
        ),
        IntroPage(
            systemImage: "heart.fill",
            title: "intro_title_4",       // Discover Inspiration
            message: "intro_message_4",
            tint: AppColor.coral
        )
    ]
}
