import SwiftUI

/// The ambient liquid background for all Zenith screens.
/// Uses `TimelineView` + `Canvas` for frame-perfect animation
/// with theme-variant color palettes.
struct LiquidBackground: View {
    var theme: ZenithColors.BackgroundTheme = .calm
    var speed: Double = 1.0
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        if reduceMotion {
            // Static gradient fallback for reduce-motion
            staticBackground
        } else {
            animatedBackground
        }
    }
    
    private var staticBackground: some View {
        ZStack {
            ZenithColors.surfaceBase.ignoresSafeArea()
            LinearGradient(
                colors: [theme.colors[0], theme.colors[2]],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    private var animatedBackground: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate * speed * 0.08
                
                let colors = theme.colors
                
                // Draw 5 overlapping, slowly orbiting blurred circles
                let configs: [(index: Int, sizeFrac: CGFloat, blurR: CGFloat, orbitR: CGFloat, speedMul: Double, phase: Double)] = [
                    (0, 1.2, 140, 0.35, 1.0,  0.0),
                    (1, 1.0, 120, 0.30, 0.7,  1.5),
                    (2, 0.9, 130, 0.28, 0.9,  3.0),
                    (3, 1.1, 150, 0.32, 0.6,  4.5),
                    (0, 0.7, 100, 0.20, 1.2,  2.0),
                ]
                
                for config in configs {
                    let colorIdx = config.index % colors.count
                    let blobSize = size.width * config.sizeFrac
                    
                    let angle = time * config.speedMul + config.phase
                    let orbitX = cos(angle) * size.width * config.orbitR
                    let orbitY = sin(angle * 0.7) * size.height * config.orbitR
                    
                    let center = CGPoint(
                        x: size.width / 2 + orbitX,
                        y: size.height / 2 + orbitY
                    )
                    
                    let rect = CGRect(
                        x: center.x - blobSize / 2,
                        y: center.y - blobSize / 2,
                        width: blobSize,
                        height: blobSize
                    )
                    
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(colors[colorIdx])
                    )
                }
            }
            .blur(radius: 80)
        }
        .background(ZenithColors.surfaceBase)
        .ignoresSafeArea()
    }
}

// MARK: - Subtle secondary background for non-primary screens

struct SubtleBackground: View {
    var accentColor: Color = ZenithColors.cosmicIndigo
    
    var body: some View {
        ZStack {
            ZenithColors.surfaceBase.ignoresSafeArea()
            LinearGradient(
                colors: [accentColor.opacity(0.4), ZenithColors.surfaceBase],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LiquidBackground(theme: .focus)
}
