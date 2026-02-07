// LegacyDSSurfaceCard.swift
// FocusApp — Surface card container
// Spec: FIGMA_SETUP_GUIDE.md §3.4

import SwiftUI

struct LegacyDSSurfaceCard<Content: View>: View {
    var cornerRadius: CGFloat = LegacyDSRadius.medium
    var padding: CGFloat = DSLayout.spacing(.space16)
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(LegacyDSColor.surface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LegacyDSColor.divider, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    LegacyDSSurfaceCard {
        Text("Hello")
    }
    .padding()
}
