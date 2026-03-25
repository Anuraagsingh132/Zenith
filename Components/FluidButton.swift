import SwiftUI

/// Physics-based button style with haptic integration,
/// brightness shift on glass material, and primary/secondary variants.
struct FluidButtonStyle: ButtonStyle {
    enum Variant {
        case primary
        case secondary
    }
    
    var variant: Variant = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ZenithTypography.headline)
            .foregroundColor(ZenithColors.textPrimary)
            .padding(.vertical, ZenithSpacing.md)
            .padding(.horizontal, ZenithSpacing.xl)
            .frame(maxWidth: variant == .primary ? .infinity : nil)
            .background(backgroundForVariant)
            .clipShape(RoundedRectangle(cornerRadius: ZenithRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ZenithRadius.medium, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                ZenithColors.glassHighlight,
                                ZenithColors.glassEdgeFade
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .animation(ZenithMotion.quickSpring, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticEngine.shared.lightTap()
                }
            }
    }
    
    @ViewBuilder
    private var backgroundForVariant: some View {
        switch variant {
        case .primary:
            ZStack {
                LinearGradient(
                    colors: [ZenithColors.amethyst, ZenithColors.deepViolet],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                // Inner glass sheen
                LinearGradient(
                    colors: [Color.white.opacity(0.15), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        case .secondary:
            AnyView(Rectangle().fill(.ultraThinMaterial))
        }
    }
}

extension ButtonStyle where Self == FluidButtonStyle {
    static var fluid: FluidButtonStyle {
        FluidButtonStyle(variant: .primary)
    }
    
    static var fluidSecondary: FluidButtonStyle {
        FluidButtonStyle(variant: .secondary)
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        VStack(spacing: 20) {
            Button("Begin Session") {}
                .buttonStyle(.fluid)
            
            Button("Skip") {}
                .buttonStyle(.fluidSecondary)
        }
        .padding()
    }
}
