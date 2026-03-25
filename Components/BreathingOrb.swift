import SwiftUI

/// The signature Zenith component: a multi-layered breathing glass orb.
/// Inner radial gradient shifts by breath phase, outer ring tracks session progress,
/// scale oscillates with breath rhythm, and ambient particles respond to state.
struct BreathingOrb: View {
    var breathPhase: BreathPhase = .idle
    var sessionProgress: Double = 0.0  // 0.0 to 1.0
    var isActive: Bool = false
    var timeDisplay: String = ""
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Scale driven by breath phase
    private var orbScale: CGFloat {
        switch breathPhase {
        case .idle:    return 1.0
        case .inhale:  return 1.12
        case .hold:    return 1.12
        case .exhale:  return 0.95
        }
    }
    
    // Inner glow color driven by breath phase
    private var innerGlow: Color {
        switch breathPhase {
        case .idle:    return ZenithColors.deepViolet.opacity(0.3)
        case .inhale:  return ZenithColors.inhaleColor.opacity(0.4)
        case .hold:    return ZenithColors.holdColor.opacity(0.35)
        case .exhale:  return ZenithColors.exhaleColor.opacity(0.3)
        }
    }
    
    var body: some View {
        ZStack {
            // Layer 1: Progress ring (outermost)
            if isActive {
                AnimatedRing(
                    progress: sessionProgress,
                    lineWidth: 4,
                    size: 280,
                    gradientColors: [breathPhase.color, ZenithColors.amethyst]
                )
            }
            
            // Layer 2: Outer halo glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [innerGlow, .clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .opacity(isActive ? 0.8 : 0.4)
            
            // Layer 3: Glass orb body
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 220, height: 220)
            
            // Layer 4: Inner radial gradient (shifts with breath)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [innerGlow, .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 220)
            
            // Layer 5: Glass edge highlight
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 220, height: 220)
            
            // Layer 6: Specular highlight (light refraction dot)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .offset(x: -40, y: -50)
                .opacity(0.7)
            
            // Layer 7: Content (timer or label)
            VStack(spacing: ZenithSpacing.xs) {
                if isActive {
                    Text(timeDisplay)
                        .font(ZenithTypography.timerDisplay)
                        .foregroundColor(ZenithColors.textPrimary)
                        .contentTransition(.numericText())
                    
                    Text(breathPhase.label)
                        .font(ZenithTypography.breathLabel)
                        .foregroundColor(breathPhase.color)
                        .contentTransition(.interpolate)
                } else {
                    Image(systemName: "wind")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(ZenithColors.textSecondary)
                    
                    Text("Tap to Begin")
                        .font(ZenithTypography.breathLabel)
                        .foregroundColor(ZenithColors.textSecondary)
                }
            }
        }
        .scaleEffect(reduceMotion ? 1.0 : orbScale)
        .animation(
            reduceMotion ? .easeInOut(duration: 0.3) : ZenithMotion.breathSpring,
            value: breathPhase
        )
        .animation(ZenithMotion.gentleSpring, value: isActive)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isActive ? "Session in progress, \(timeDisplay), \(breathPhase.label)" : "Tap to begin a focus session")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ZStack {
        LiquidBackground(theme: .focus)
        BreathingOrb(
            breathPhase: .inhale,
            sessionProgress: 0.35,
            isActive: true,
            timeDisplay: "03:42"
        )
    }
}
