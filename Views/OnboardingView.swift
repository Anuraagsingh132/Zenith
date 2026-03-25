import SwiftUI

/// 3-page parallax glass onboarding experience.
struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("wind", "Breathe with Glass", "A living orb guides your breath.\nInhale, hold, exhale — in perfect rhythm."),
        ("sparkles", "Build Your Practice", "Track your sessions, view your streak,\nand watch your mindfulness grow."),
        ("waveform.path", "Feel Every Moment", "Synced haptics and ambient sound\ncreate a fully immersive experience."),
    ]
    
    var body: some View {
        ZStack {
            LiquidBackground(theme: .calm)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(ZenithMotion.standardSpring, value: currentPage)
                
                Spacer()
                
                // Page indicators + CTA
                VStack(spacing: ZenithSpacing.xl) {
                    // Custom page dots
                    HStack(spacing: ZenithSpacing.xs) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? ZenithColors.amethyst : Color.white.opacity(0.25))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(ZenithMotion.quickSpring, value: currentPage)
                        }
                    }
                    
                    // CTA button
                    Button(currentPage == pages.count - 1 ? "Begin Your Journey" : "Continue") {
                        if currentPage < pages.count - 1 {
                            withAnimation(ZenithMotion.standardSpring) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(ZenithMotion.gentleSpring) {
                                isOnboardingComplete = true
                            }
                            HapticEngine.shared.success()
                        }
                    }
                    .buttonStyle(.fluid)
                    .padding(.horizontal, ZenithSpacing.xxl)
                    
                    // Skip
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(ZenithMotion.gentleSpring) {
                                isOnboardingComplete = true
                            }
                        }
                        .font(ZenithTypography.subheadline)
                        .foregroundColor(ZenithColors.textTertiary)
                    }
                }
                .padding(.bottom, ZenithSpacing.xxxl)
            }
        }
        .ignoresSafeArea()
    }
    
    private func onboardingPage(index: Int) -> some View {
        let page = pages[index]
        
        return VStack(spacing: ZenithSpacing.xxl) {
            // Icon with glass halo
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ZenithColors.amethyst.opacity(0.25), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: page.icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(ZenithColors.textPrimary)
            }
            
            VStack(spacing: ZenithSpacing.sm) {
                Text(page.title)
                    .font(ZenithTypography.title1)
                    .foregroundColor(ZenithColors.textPrimary)
                
                Text(page.subtitle)
                    .font(ZenithTypography.body)
                    .foregroundColor(ZenithColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, ZenithSpacing.xxl)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
