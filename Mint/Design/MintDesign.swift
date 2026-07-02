import SwiftUI

enum MintColor {
    static let background = Color.white
    static let surfaceAlt = Color(red: 0.973, green: 0.973, blue: 0.973)
    static let surfaceHover = Color(red: 0.961, green: 0.961, blue: 0.961)
    static let border = Color(red: 0.910, green: 0.910, blue: 0.929)
    static let borderLight = Color(red: 0.941, green: 0.941, blue: 0.941)
    static let primaryText = Color(red: 0.067, green: 0.067, blue: 0.067)
    static let secondaryText = Color(red: 0.400, green: 0.400, blue: 0.400)
    static let tertiaryText = Color(red: 0.533, green: 0.533, blue: 0.533)
    static let mutedText = Color(red: 0.600, green: 0.600, blue: 0.600)
    static let placeholderText = Color(red: 0.667, green: 0.667, blue: 0.667)
    static let accent = Color(red: 0.067, green: 0.067, blue: 0.067)
    static let success = Color(red: 0.180, green: 0.490, blue: 0.196)
    static let successBackground = Color(red: 0.910, green: 0.961, blue: 0.914)
}

enum MintRadius {
    static let small: CGFloat = 3
    static let medium: CGFloat = 6
    static let standard: CGFloat = 8
    static let large: CGFloat = 12
    static let pill: CGFloat = 14
    static let extra: CGFloat = 20
}

enum MintSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let screen: CGFloat = 20
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let topBar: CGFloat = 52
}

extension Font {
    static func figtree(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .custom("Figtree", size: size).weight(weight)
    }

    static var mintTitle: Font { .figtree(size: 26, weight: .bold) }
    static var mintOnboardingTitle: Font { .figtree(size: 28, weight: .bold) }
    static var mintSection: Font { .figtree(size: 20, weight: .bold) }
    static var mintCardTitle: Font { .figtree(size: 18, weight: .bold) }
    static var mintBody: Font { .figtree(size: 15, weight: .medium) }
    static var mintBodyRegular: Font { .figtree(size: 15, weight: .regular) }
    static var mintSmall: Font { .figtree(size: 13, weight: .medium) }
    static var mintTiny: Font { .figtree(size: 11, weight: .medium) }
    static var mintStatus: Font { .figtree(size: 12, weight: .semibold) }
}

extension View {
    func mintScreen() -> some View {
        self
            .background(MintColor.background)
            .foregroundStyle(MintColor.primaryText)
    }
}
