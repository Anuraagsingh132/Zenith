import SwiftUI

/// Circular progress ring with gradient stroke, animated trim, and glow.
struct AnimatedRing: View {
    var progress: Double  // 0.0 to 1.0
    var lineWidth: CGFloat = 6
    var size: CGFloat = 260
    var gradientColors: [Color] = [ZenithColors.nebulaTeal, ZenithColors.amethyst]
    
    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        colors: gradientColors + [gradientColors[0].opacity(0.3)],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)
            
            // Glow behind the progress endpoint
            Circle()
                .trim(from: max(0, CGFloat(progress) - 0.01), to: CGFloat(progress))
                .stroke(
                    gradientColors.last ?? ZenithColors.amethyst,
                    style: StrokeStyle(lineWidth: lineWidth * 3, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)
                .opacity(progress > 0.01 ? 0.6 : 0)
                .animation(.linear(duration: 0.5), value: progress)
        }
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        AnimatedRing(progress: 0.65)
    }
}
