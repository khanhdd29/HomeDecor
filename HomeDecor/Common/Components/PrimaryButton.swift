//
//  PrimaryButton.swift
//  SwiftBase
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        // Coral Glass primary CTA. `title` is a localization key (kept for
        // backwards-compatibility with existing call-sites).
        CoralPillButton(title: title.localized, action: action)
    }
}

#if DEBUG
#Preview {
    PrimaryButton("continue") {}
        .padding()
}
#endif
