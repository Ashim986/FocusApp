#if os(macOS)
import FocusDesignSystem
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct DebugLogView: View {
    @ObservedObject var store: DebugLogStore
    var isEmbedded: Bool = false
    var onClose: (() -> Void)?
    @State var selectedLevel: DebugLogLevelFilter = .all
    @State var selectedCategory: DebugLogCategoryFilter = .all
    @State var searchText: String = ""
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            header
            summary
            filters
            Divider()
            content
        }
        .frame(minWidth: isEmbedded ? 0 : 640, minHeight: isEmbedded ? 0 : 480)
        .background(debugBackground)
    }
}

#endif
