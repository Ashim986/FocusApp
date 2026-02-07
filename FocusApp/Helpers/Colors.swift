import SwiftUI
import FocusDesignSystem

extension Color {
    // Primary colors
    static let appPurple = Color(hex: "#6366f1")
    static let appIndigo = Color(hex: "#1e1b4b")
    static let appIndigoLight = Color(hex: "#312e81")

    // Status colors
    static let appGreen = Color(hex: "#10b981")
    static let appGreenLight = Color(hex: "#d1fae5")
    static let appCyan = Color(hex: "#22d3ee")
    static let appAmber = Color(hex: "#f59e0b")
    static let appAmberLight = Color(hex: "#fef3c7")
    static let appRed = Color(hex: "#ef4444")
    static let appRedLight = Color(hex: "#fee2e2")

    // Neutral colors
    static let appGray50 = Color(hex: "#f9fafb")
    static let appGray100 = Color(hex: "#f3f4f6")
    static let appGray200 = Color(hex: "#e5e7eb")
    static let appGray300 = Color(hex: "#d1d5db")
    static let appGray400 = Color(hex: "#9ca3af")
    static let appGray500 = Color(hex: "#6b7280")
    static let appGray600 = Color(hex: "#4b5563")
    static let appGray700 = Color(hex: "#374151")
    static let appGray800 = Color(hex: "#1f2937")
    static let appGray900 = Color(hex: "#111827")

    // Gradient
    static let purpleGradient = LinearGradient(
        colors: [Color(hex: "#6366f1"), Color(hex: "#8b5cf6")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let indigoGradient = LinearGradient(
        colors: [Color(hex: "#1e1b4b"), Color(hex: "#312e81")],
        startPoint: .top,
        endPoint: .bottom
    )

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

typealias DSImage = Image

struct DSText: View {
    private let text: Text

    init(_ content: String) {
        self.text = Text(content)
    }

    init(_ content: AttributedString) {
        self.text = Text(content)
    }

    var body: some View {
        text
    }
}

func DSButton<Label: View>(
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
) -> some View {
    Button(action: action, label: label)
}

func DSButton<Label: View>(
    config _: DSButtonConfig,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
) -> some View {
    Button(action: action, label: label)
}
