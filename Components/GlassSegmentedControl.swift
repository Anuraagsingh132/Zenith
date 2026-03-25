import SwiftUI

/// A glass-styled segmented control with a sliding frosted indicator.
/// Used for duration selection on the Home screen.
struct GlassSegmentedControl<T: Hashable & CustomStringConvertible>: View {
    let options: [T]
    @Binding var selection: T
    var height: CGFloat = 44
    
    @Namespace private var segmentAnimation
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                segmentButton(for: option)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: ZenithRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ZenithRadius.medium, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [ZenithColors.glassHighlight, ZenithColors.glassEdgeFade],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    private func segmentButton(for option: T) -> some View {
        let isSelected = selection == option
        
        return Button {
            withAnimation(ZenithMotion.quickSpring) {
                selection = option
            }
            HapticEngine.shared.selectionChanged()
        } label: {
            Text(option.description)
                .font(ZenithTypography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? ZenithColors.textPrimary : ZenithColors.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: ZenithRadius.small, style: .continuous)
                            .fill(.thinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: ZenithRadius.small, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                            .matchedGeometryEffect(id: "segment", in: segmentAnimation)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        LiquidBackground()
        GlassSegmentedControl(
            options: ["1 min", "3 min", "5 min", "10 min"],
            selection: .constant("5 min")
        )
        .padding()
    }
}
