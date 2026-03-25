import SwiftUI

/// Post-session celebration and mood capture screen.
/// Presented as a sheet with ultra-thin material background.
struct SessionCompleteView: View {
    let duration: Int
    @Binding var selectedMood: Int
    var onSave: () -> Void
    var onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var celebrationScale: CGFloat = 0.5
    
    private let moods = [
        (score: 1, emoji: "😔", label: "Rough"),
        (score: 2, emoji: "😐", label: "Okay"),
        (score: 3, emoji: "🙂", label: "Good"),
        (score: 4, emoji: "😊", label: "Great"),
        (score: 5, emoji: "🤩", label: "Amazing"),
    ]
    
    var body: some View {
        VStack(spacing: ZenithSpacing.xxl) {
            // Celebration icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ZenithColors.auroraGreen.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(ZenithColors.auroraGreen)
            }
            .scaleEffect(celebrationScale)
            .onAppear {
                withAnimation(ZenithMotion.bouncySpring) {
                    celebrationScale = 1.0
                }
            }
            
            // Stats
            VStack(spacing: ZenithSpacing.xs) {
                Text("Session Complete")
                    .font(ZenithTypography.title1)
                    .foregroundColor(ZenithColors.textPrimary)
                
                Text(formattedDuration)
                    .font(ZenithTypography.statValue)
                    .foregroundColor(ZenithColors.amethyst)
                
                Text("of mindful focus")
                    .font(ZenithTypography.body)
                    .foregroundColor(ZenithColors.textSecondary)
            }
            
            // Mood picker
            VStack(spacing: ZenithSpacing.sm) {
                Text("How do you feel?")
                    .font(ZenithTypography.headline)
                    .foregroundColor(ZenithColors.textSecondary)
                
                HStack(spacing: ZenithSpacing.sm) {
                    ForEach(moods, id: \.score) { mood in
                        Button {
                            withAnimation(ZenithMotion.quickSpring) {
                                selectedMood = mood.score
                            }
                            HapticEngine.shared.selectionChanged()
                        } label: {
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.system(size: selectedMood == mood.score ? 36 : 28))
                                
                                Text(mood.label)
                                    .font(ZenithTypography.caption2)
                                    .foregroundColor(
                                        selectedMood == mood.score ?
                                        ZenithColors.textPrimary : ZenithColors.textTertiary
                                    )
                            }
                            .padding(.vertical, ZenithSpacing.xs)
                            .padding(.horizontal, ZenithSpacing.sm)
                            .background {
                                if selectedMood == mood.score {
                                    RoundedRectangle(cornerRadius: ZenithRadius.small, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ZenithRadius.small, style: .continuous)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(mood.label), \(mood.emoji)")
                        .accessibilityAddTraits(selectedMood == mood.score ? .isSelected : [])
                    }
                }
            }
            .glassCardStyle(elevation: .embedded)
            
            // Save button
            Button("Save Session") {
                onSave()
            }
            .buttonStyle(.fluid)
            
            Button("Dismiss") {
                onDismiss()
            }
            .font(ZenithTypography.subheadline)
            .foregroundColor(ZenithColors.textTertiary)
        }
        .padding(ZenithSpacing.xl)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 30)
        .onAppear {
            withAnimation(ZenithMotion.gentleSpring.delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private var formattedDuration: String {
        let min = duration / 60
        let sec = duration % 60
        if min > 0 {
            return "\(min)m \(sec)s"
        }
        return "\(sec)s"
    }
}

#Preview {
    SessionCompleteView(
        duration: 300,
        selectedMood: .constant(4),
        onSave: {},
        onDismiss: {}
    )
    .background(LiquidBackground(theme: .complete))
}
