import SwiftUI

/// Multi-tier glass card component with elevation system,
/// specular highlight, and accessibility contrast support.
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var elevation: GlassElevation
    var isInteractive: Bool
    
    @State private var isPressed = false
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    init(
        cornerRadius: CGFloat = ZenithRadius.large,
        elevation: GlassElevation = .raised,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.elevation = elevation
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ZenithSpacing.md)
            .background(backgroundLayer)
            .clipShape(shape)
            .overlay(borderLayer)
            .shadow(
                color: .black.opacity(elevation.shadowOpacity),
                radius: elevation.shadowRadius,
                x: 0,
                y: elevation.shadowRadius / 3
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(ZenithMotion.quickSpring, value: isPressed)
            .if(isInteractive) { view in
                view.simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            }
    }
    
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    @ViewBuilder
    private var backgroundLayer: some View {
        if reduceTransparency {
            Color(white: 0.15)
        } else {
            ZStack {
                Rectangle().fill(elevation.material)
                // Subtle inner glow at the top
                LinearGradient(
                    colors: [Color.white.opacity(0.06), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        }
    }
    
    private var borderLayer: some View {
        shape
            .stroke(
                LinearGradient(
                    colors: [
                        ZenithColors.glassHighlight.opacity(elevation.borderOpacity),
                        ZenithColors.glassEdgeFade
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.75
            )
    }
}

// MARK: - View Extension

extension View {
    func glassCardStyle(
        cornerRadius: CGFloat = ZenithRadius.large,
        elevation: GlassElevation = .raised,
        isInteractive: Bool = false
    ) -> some View {
        GlassCard(cornerRadius: cornerRadius, elevation: elevation, isInteractive: isInteractive) {
            self
        }
    }
    
    /// Conditional modifier helper
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        VStack(spacing: 20) {
            Text("Embedded").glassCardStyle(elevation: .embedded)
            Text("Raised").glassCardStyle(elevation: .raised)
            Text("Floating").glassCardStyle(elevation: .floating)
        }
        .font(ZenithTypography.headline)
        .foregroundColor(ZenithColors.textPrimary)
    }
}
