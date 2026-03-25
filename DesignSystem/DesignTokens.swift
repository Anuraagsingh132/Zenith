import SwiftUI

// MARK: - Color Tokens

/// Centralized design tokens for the Zenith design system.
/// Every color, spacing value, radius, and typography style lives here.
/// No magic numbers anywhere else in the codebase.
enum ZenithColors {
    
    // MARK: Brand Palette
    static let amethyst      = Color(red: 0.45, green: 0.25, blue: 0.85)
    static let deepViolet    = Color(red: 0.25, green: 0.10, blue: 0.55)
    static let cosmicIndigo  = Color(red: 0.15, green: 0.08, blue: 0.40)
    static let nebulaTeal    = Color(red: 0.10, green: 0.55, blue: 0.65)
    static let auroraGreen   = Color(red: 0.20, green: 0.75, blue: 0.60)
    static let warmGold      = Color(red: 0.95, green: 0.75, blue: 0.35)
    
    // MARK: Surface Colors
    static let surfaceBase   = Color(red: 0.04, green: 0.03, blue: 0.08)
    static let surfaceRaised = Color(white: 1.0, opacity: 0.06)
    static let surfaceGlow   = Color(white: 1.0, opacity: 0.03)
    
    // MARK: Text Colors
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary  = Color.white.opacity(0.45)
    
    // MARK: Glass Edge Colors
    static let glassHighlight = Color.white.opacity(0.35)
    static let glassEdgeFade  = Color.white.opacity(0.08)
    
    // MARK: Semantic
    static let success       = Color(red: 0.30, green: 0.85, blue: 0.55)
    static let warning       = warmGold
    static let destructive   = Color(red: 0.95, green: 0.35, blue: 0.40)
    
    // MARK: Breath Phase Colors
    static let inhaleColor   = nebulaTeal
    static let holdColor     = amethyst
    static let exhaleColor   = deepViolet
    
    // MARK: Background Theme Palettes
    struct BackgroundTheme {
        let colors: [Color]
        
        static let calm = BackgroundTheme(colors: [
            Color(red: 0.08, green: 0.12, blue: 0.32),
            Color(red: 0.22, green: 0.08, blue: 0.28),
            Color(red: 0.06, green: 0.22, blue: 0.28),
            Color(red: 0.14, green: 0.06, blue: 0.38)
        ])
        
        static let focus = BackgroundTheme(colors: [
            Color(red: 0.10, green: 0.06, blue: 0.35),
            Color(red: 0.35, green: 0.12, blue: 0.45),
            Color(red: 0.08, green: 0.18, blue: 0.42),
            Color(red: 0.20, green: 0.08, blue: 0.50)
        ])
        
        static let complete = BackgroundTheme(colors: [
            Color(red: 0.06, green: 0.25, blue: 0.30),
            Color(red: 0.12, green: 0.35, blue: 0.25),
            Color(red: 0.08, green: 0.20, blue: 0.35),
            Color(red: 0.15, green: 0.30, blue: 0.40)
        ])
    }
}

// MARK: - Typography Tokens

enum ZenithTypography {
    static let largeTitle    = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1        = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2        = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3        = Font.system(size: 20, weight: .medium, design: .rounded)
    static let headline      = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body          = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout       = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline   = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote      = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption1      = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2      = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // Specialized
    static let timerDisplay  = Font.system(size: 56, weight: .ultraLight, design: .rounded)
    static let statValue     = Font.system(size: 36, weight: .light, design: .rounded)
    static let breathLabel   = Font.system(size: 20, weight: .light, design: .rounded)
}

// MARK: - Spacing Tokens

enum ZenithSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat  = 8
    static let sm: CGFloat  = 12
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 20
    static let xl: CGFloat  = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

// MARK: - Radius Tokens

enum ZenithRadius {
    static let small: CGFloat   = 12
    static let medium: CGFloat  = 16
    static let large: CGFloat   = 24
    static let pill: CGFloat    = 100
}

// MARK: - Glass Elevation

enum GlassElevation {
    case embedded   // Subtle, within content
    case raised     // Standard card
    case floating   // Modal-level, strong blur
    
    var material: Material {
        switch self {
        case .embedded: return .ultraThinMaterial
        case .raised:   return .thinMaterial
        case .floating: return .regularMaterial
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .embedded: return 8
        case .raised:   return 16
        case .floating: return 30
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .embedded: return 0.10
        case .raised:   return 0.18
        case .floating: return 0.25
        }
    }
    
    var borderOpacity: Double {
        switch self {
        case .embedded: return 0.15
        case .raised:   return 0.30
        case .floating: return 0.40
        }
    }
}
