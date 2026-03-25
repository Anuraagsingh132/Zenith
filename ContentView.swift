import SwiftUI

/// Root view with a custom glass tab bar.
struct ContentView: View {
    @State private var selectedTab: Tab = .focus
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    enum Tab: String, CaseIterable {
        case focus    = "Focus"
        case history  = "History"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .focus:    return "sparkles"
            case .history:  return "clock.arrow.circlepath"
            case .settings: return "gearshape"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case .focus:
                    HomeView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom glass tab bar
            glassTabBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Glass Tab Bar
    
    private var glassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, ZenithSpacing.md)
        .padding(.top, ZenithSpacing.sm)
        .padding(.bottom, ZenithSpacing.xxl) // Account for home indicator
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab bar")
    }
    
    private func tabButton(for tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button {
            withAnimation(ZenithMotion.tabSwitch) {
                selectedTab = tab
            }
            HapticEngine.shared.selectionChanged()
        } label: {
            VStack(spacing: ZenithSpacing.xxs) {
                ZStack {
                    // Active indicator pill behind icon
                    if isSelected {
                        Capsule()
                            .fill(ZenithColors.amethyst.opacity(0.2))
                            .frame(width: 56, height: 30)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? ZenithColors.amethyst : ZenithColors.textTertiary)
                        .symbolEffect(.bounce, value: selectedTab)
                }
                
                Text(tab.rawValue)
                    .font(ZenithTypography.caption2)
                    .foregroundColor(isSelected ? ZenithColors.amethyst : ZenithColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SessionModel.self, inMemory: true)
}
