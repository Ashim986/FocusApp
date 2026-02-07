// DSSurfaceCard.swift
// FocusApp — Surface card container
// Spec: FIGMA_SETUP_GUIDE.md §3.4

import SwiftUI

struct DSSurfaceCard<Content: View>: View {
    var cornerRadius: CGFloat = DSRadius.medium
    var padding: CGFloat = DSSpacing.space16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(DSColor.surface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DSColor.divider, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    DSSurfaceCard {
        Text("Hello")
    }
    .padding()
}
