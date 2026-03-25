import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("defaultDuration") private var defaultDuration = 300
    
    @State private var showResetConfirmation = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                SubtleBackground(accentColor: ZenithColors.deepViolet)
                
                ScrollView {
                    VStack(spacing: ZenithSpacing.xl) {
                        sensorySection
                        sessionSection
                        aboutSection
                        dangerSection
                    }
                    .padding(.horizontal, ZenithSpacing.lg)
                    .padding(.top, ZenithSpacing.md)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - Sensory Section
    
    private var sensorySection: some View {
        settingsGroup(title: "Sensory Experience") {
            VStack(spacing: 0) {
                settingsToggle(
                    icon: "hand.tap.fill",
                    iconColor: ZenithColors.amethyst,
                    title: "Haptic Feedback",
                    subtitle: "Subtle vibrations during breathing",
                    isOn: $hapticEnabled
                )
                
                glassDivider
                
                settingsToggle(
                    icon: "speaker.wave.2.fill",
                    iconColor: ZenithColors.nebulaTeal,
                    title: "Ambient Sound",
                    subtitle: "Gentle tones during sessions",
                    isOn: $soundEnabled
                )
            }
        }
    }
    
    // MARK: - Session Section
    
    private var sessionSection: some View {
        settingsGroup(title: "Session Defaults") {
            VStack(spacing: 0) {
                HStack {
                    settingsIcon("timer", color: ZenithColors.warmGold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Default Duration")
                            .font(ZenithTypography.subheadline)
                            .foregroundColor(ZenithColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $defaultDuration) {
                        Text("1 min").tag(60)
                        Text("3 min").tag(180)
                        Text("5 min").tag(300)
                        Text("10 min").tag(600)
                    }
                    .pickerStyle(.menu)
                    .tint(ZenithColors.amethyst)
                }
                .padding(ZenithSpacing.md)
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        settingsGroup(title: "About") {
            VStack(spacing: 0) {
                NavigationLink {
                    privacyPolicyView
                } label: {
                    HStack {
                        settingsIcon("lock.shield.fill", color: ZenithColors.auroraGreen)
                        Text("Privacy Policy")
                            .font(ZenithTypography.subheadline)
                            .foregroundColor(ZenithColors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ZenithColors.textTertiary)
                    }
                    .padding(ZenithSpacing.md)
                }
                .buttonStyle(.plain)
                
                glassDivider
                
                HStack {
                    settingsIcon("info.circle.fill", color: ZenithColors.textTertiary)
                    Text("Version")
                        .font(ZenithTypography.subheadline)
                        .foregroundColor(ZenithColors.textPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(ZenithTypography.subheadline)
                        .foregroundColor(ZenithColors.textTertiary)
                }
                .padding(ZenithSpacing.md)
            }
        }
    }
    
    // MARK: - Danger Section
    
    private var dangerSection: some View {
        settingsGroup(title: "") {
            Button {
                showResetConfirmation = true
                HapticEngine.shared.lightTap()
            } label: {
                HStack {
                    settingsIcon("trash.fill", color: ZenithColors.destructive)
                    Text("Reset All Data")
                        .font(ZenithTypography.subheadline)
                        .foregroundColor(ZenithColors.destructive)
                    Spacer()
                }
                .padding(ZenithSpacing.md)
            }
            .buttonStyle(.plain)
        }
        .confirmationDialog("Reset All Data?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) {
                // Delete all sessions
                do {
                    try modelContext.delete(model: SessionModel.self)
                    HapticEngine.shared.success()
                } catch {
                    // Handle error silently
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your session history. This cannot be undone.")
        }
    }
    
    // MARK: - Helpers
    
    private func settingsGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: ZenithSpacing.sm) {
            if !title.isEmpty {
                Text(title)
                    .font(ZenithTypography.footnote)
                    .foregroundColor(ZenithColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.horizontal, ZenithSpacing.xs)
            }
            
            content()
                .glassCardStyle(cornerRadius: ZenithRadius.medium, elevation: .embedded)
        }
    }
    
    private func settingsToggle(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            settingsIcon(icon, color: iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ZenithTypography.subheadline)
                    .foregroundColor(ZenithColors.textPrimary)
                Text(subtitle)
                    .font(ZenithTypography.caption1)
                    .foregroundColor(ZenithColors.textTertiary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(ZenithColors.amethyst)
        }
        .padding(ZenithSpacing.md)
        .accessibilityElement(children: .combine)
    }
    
    private func settingsIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 14))
            .foregroundColor(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
    
    private var glassDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 0.5)
            .padding(.leading, 52)
    }
    
    private var privacyPolicyView: some View {
        ZStack {
            SubtleBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: ZenithSpacing.md) {
                    Text("Zenith takes your privacy seriously. All mindfulness session data is stored locally on your device using SwiftData and is never transmitted to external servers.")
                        .font(ZenithTypography.body)
                        .foregroundColor(ZenithColors.textSecondary)
                    
                    Text("No personal information is collected, stored, or shared with third parties.")
                        .font(ZenithTypography.body)
                        .foregroundColor(ZenithColors.textSecondary)
                }
                .padding(ZenithSpacing.xl)
                .glassCardStyle(elevation: .embedded)
                .padding(ZenithSpacing.lg)
            }
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: SessionModel.self, inMemory: true)
}
