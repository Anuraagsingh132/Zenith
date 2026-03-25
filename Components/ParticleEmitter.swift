import SwiftUI

/// Lightweight Canvas-based particle system.
/// Particles drift slowly and respond to breath phase:
/// drift inward on inhale, expand outward on exhale.
struct ParticleEmitter: View {
    var particleCount: Int = 40
    var breathPhase: BreathPhase = .idle
    
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: CGFloat
        var angle: CGFloat // radians
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    let drift: CGFloat = breathPhase == .inhale ? -0.3 : (breathPhase == .exhale ? 0.3 : 0.0)
                    
                    let baseX = particle.x * size.width
                    let baseY = particle.y * size.height
                    
                    // Orbital drift
                    let offsetX = cos(time * Double(particle.speed) + Double(particle.angle)) * 30 + Double(drift * 20)
                    let offsetY = sin(time * Double(particle.speed) * 0.7 + Double(particle.angle)) * 25
                    
                    let point = CGPoint(x: baseX + offsetX, y: baseY + offsetY)
                    let rect = CGRect(
                        x: point.x - particle.size / 2,
                        y: point.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )
                    
                    // Pulsing opacity
                    let pulseOpacity = particle.opacity * (0.6 + 0.4 * sin(time * Double(particle.speed) * 0.5))
                    
                    context.opacity = pulseOpacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(.white)
                    )
                }
            }
        }
        .onAppear {
            generateParticles()
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.15...0.4),
                speed: CGFloat.random(in: 0.3...1.2),
                angle: CGFloat.random(in: 0...(2 * .pi))
            )
        }
    }
}

/// Breath phase enum used across the app
enum BreathPhase: String, CaseIterable {
    case idle
    case inhale
    case hold
    case exhale
    
    var label: String {
        switch self {
        case .idle:    return "Ready"
        case .inhale:  return "Breathe In"
        case .hold:    return "Hold"
        case .exhale:  return "Breathe Out"
        }
    }
    
    var color: Color {
        switch self {
        case .idle:    return ZenithColors.textSecondary
        case .inhale:  return ZenithColors.inhaleColor
        case .hold:    return ZenithColors.holdColor
        case .exhale:  return ZenithColors.exhaleColor
        }
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        ParticleEmitter(breathPhase: .inhale)
    }
}
