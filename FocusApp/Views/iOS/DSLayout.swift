import CoreGraphics

enum DSLayout {
    enum SpacingToken {
        case space2
        case space4
        case space8
        case space12
        case space16
        case space24
        case space32
        case space48
        case space64
    }

    static func spacing(_ token: SpacingToken) -> CGFloat {
        switch token {
        case .space2: LegacyDSSpacing.space2
        case .space4: LegacyDSSpacing.space4
        case .space8: LegacyDSSpacing.space8
        case .space12: LegacyDSSpacing.space12
        case .space16: LegacyDSSpacing.space16
        case .space24: LegacyDSSpacing.space24
        case .space32: LegacyDSSpacing.space32
        case .space48: LegacyDSSpacing.space48
        case .space64: LegacyDSSpacing.space64
        }
    }

    static func spacing(_ value: CGFloat) -> CGFloat {
        value
    }
}
