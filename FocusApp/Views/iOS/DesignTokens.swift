// DesignTokens.swift
// FocusApp iOS Design System Tokens
// Matches FIGMA_SETUP_GUIDE.md exactly

import SwiftUI

// MARK: - Color Tokens

enum DSColor {
    // Brand
    static let purple = Color(hex: 0x6366F1)
    static let indigo = Color(hex: 0x1E1B4B)
    static let indigoLight = Color(hex: 0x312E81)
    static let green = Color(hex: 0x10B981)
    static let greenLight = Color(hex: 0xD1FAE5)
    static let cyan = Color(hex: 0x22D3EE)
    static let amber = Color(hex: 0xF59E0B)
    static let amberLight = Color(hex: 0xFEF3C7)
    static let red = Color(hex: 0xEF4444)
    static let redLight = Color(hex: 0xFEE2E2)

    // Neutrals
    static let gray50 = Color(hex: 0xF9FAFB)
    static let gray100 = Color(hex: 0xF3F4F6)
    static let gray200 = Color(hex: 0xE5E7EB)
    static let gray300 = Color(hex: 0xD1D5DB)
    static let gray400 = Color(hex: 0x9CA3AF)
    static let gray500 = Color(hex: 0x6B7280)
    static let gray600 = Color(hex: 0x4B5563)
    static let gray700 = Color(hex: 0x374151)
    static let gray800 = Color(hex: 0x1F2937)
    static let gray900 = Color(hex: 0x111827)

    // Semantic (Light Mode)
    static let background = gray50
    static let surface = Color.white
    static let surfaceElevated = gray100
    static let textPrimary = gray900
    static let textSecondary = gray600
    static let divider = gray200
    static let accent = purple
    static let success = green
    static let warning = amber
    static let error = red

    // Gradients
    static let purpleGradient = LinearGradient(
        colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Difficulty badge colors
    static let easyBg = Color(hex: 0xD1FAE5)
    static let easyText = Color(hex: 0x059669)
    static let mediumBg = Color(hex: 0xFEF3C7)
    static let mediumText = Color(hex: 0xD97706)
    static let hardBg = Color(hex: 0xFEE2E2)
    static let hardText = Color(hex: 0xDC2626)

    // Streak badge
    static let streakBg = Color(hex: 0xFFF7ED)
    static let streakBorder = Color(hex: 0xFDBA74)
    static let streakText = Color(hex: 0xEA580C)
}

// MARK: - Typography

enum DSTypography {
    static let title = Font.system(size: 32, weight: .bold)          // Title
    static let headline = Font.system(size: 24, weight: .bold)       // Headline
    static let section = Font.system(size: 20, weight: .semibold)    // Section
    static let body = Font.system(size: 16, weight: .regular)        // Body
    static let bodyStrong = Font.system(size: 16, weight: .semibold) // Body Strong
    static let subbody = Font.system(size: 14, weight: .regular)     // Subbody
    static let subbodyStrong = Font.system(size: 14, weight: .semibold) // Subbody Strong
    static let caption = Font.system(size: 12, weight: .regular)     // Caption
    static let captionStrong = Font.system(size: 12, weight: .semibold) // Caption Strong
    static let micro = Font.system(size: 11, weight: .regular)       // Micro
    static let microStrong = Font.system(size: 11, weight: .semibold) // Micro Strong
    static let code = Font.system(size: 12, design: .monospaced)     // Code
    static let codeMicro = Font.system(size: 11, design: .monospaced) // Code Micro
    static let timerLarge = Font.system(size: 64, weight: .bold)     // Timer Large
}

// MARK: - Spacing

enum DSSpacing {
    static let space2: CGFloat = 2
    static let space4: CGFloat = 4
    static let space8: CGFloat = 8
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space24: CGFloat = 24
    static let space32: CGFloat = 32
    static let space48: CGFloat = 48
    static let space64: CGFloat = 64
}

// MARK: - Corner Radius

enum DSRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let full: CGFloat = 9999
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
