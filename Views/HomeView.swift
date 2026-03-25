import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var viewModel = SessionViewModel()
    @State private var showPatternPicker = false
    
    var body: some View {
        ZStack {
            // Layer 0: Living background
            LiquidBackground(
                theme: viewModel.isActive ? .focus : .calm,
                speed: viewModel.isActive ? 0.6 : 1.0
            )
            
            // Layer 1: Ambient particles
            if !reduceMotion {
                ParticleEmitter(breathPhase: viewModel.breathPhase)
                    .opacity(0.5)
            }
            
            // Layer 2: Main content
            VStack(spacing: 0) {
                
                // Greeting header
                if !viewModel.isActive {
                    greetingHeader
                        .transition(.opacity.combined(with: .offset(y: -20)))
                }
                
                Spacer()
                
                // The Signature: Breathing Orb
                BreathingOrb(
                    breathPhase: viewModel.breathPhase,
                    sessionProgress: viewModel.sessionProgress,
                    isActive: viewModel.isActive,
                    timeDisplay: viewModel.timeDisplay
                )
                .onTapGesture {
                    withAnimation(ZenithMotion.standardSpring) {
                        if viewModel.isActive {
                            // Don't stop on tap during session — use the button
                        } else {
                            viewModel.startSession()
                        }
                    }
                }
                
                Spacer()
                
                // Bottom control area
                if viewModel.isActive {
                    activeSessionControls
                        .transition(.glassSlideUp)
                } else {
                    configurationPanel
                        .transition(.glassSlideUp)
                }
                
                Spacer().frame(height: ZenithSpacing.xxl)
            }
            .padding(.horizontal, ZenithSpacing.lg)
            .animation(ZenithMotion.standardSpring, value: viewModel.isActive)
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $viewModel.isComplete) {
            SessionCompleteView(
                duration: viewModel.completedDuration,
                selectedMood: $viewModel.selectedMood,
                onSave: {
                    viewModel.saveSession(to: modelContext)
                },
                onDismiss: {
                    viewModel.dismissCompletion()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
    }
    
    // MARK: - Greeting Header
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: ZenithSpacing.xs) {
            Spacer().frame(height: 60) // Safe area offset
            
            Text(viewModel.greeting)
                .font(ZenithTypography.largeTitle)
                .foregroundColor(ZenithColors.textPrimary)
            
            Text(viewModel.greetingSubtitle)
                .font(ZenithTypography.body)
                .foregroundColor(ZenithColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Configuration Panel (Pre-Session)
    
    private var configurationPanel: some View {
        VStack(spacing: ZenithSpacing.md) {
            // Duration picker
            GlassSegmentedControl(
                options: viewModel.durationOptions.map { DurationOption(seconds: $0) },
                selection: Binding(
                    get: { DurationOption(seconds: viewModel.selectedDuration) },
                    set: { viewModel.selectedDuration = $0.seconds }
                )
            )
            
            // Breath pattern selector
            Button {
                showPatternPicker.toggle()
                HapticEngine.shared.lightTap()
            } label: {
                HStack {
                    Image(systemName: "lungs.fill")
                        .foregroundColor(ZenithColors.amethyst)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.selectedPattern.name)
                            .font(ZenithTypography.subheadline)
                            .foregroundColor(ZenithColors.textPrimary)
                        Text(viewModel.selectedPattern.description)
                            .font(ZenithTypography.caption1)
                            .foregroundColor(ZenithColors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(ZenithColors.textTertiary)
                }
            }
            .glassCardStyle(cornerRadius: ZenithRadius.medium, elevation: .embedded)
            .buttonStyle(.plain)
            .sheet(isPresented: $showPatternPicker) {
                patternPickerSheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    // MARK: - Active Session Controls
    
    private var activeSessionControls: some View {
        VStack(spacing: ZenithSpacing.md) {
            // Breath phase indicator
            Text(viewModel.breathPhase.label)
                .font(ZenithTypography.title3)
                .foregroundColor(viewModel.breathPhase.color)
                .contentTransition(.interpolate)
                .animation(ZenithMotion.gentleSpring, value: viewModel.breathPhase)
            
            Button("End Session") {
                withAnimation(ZenithMotion.standardSpring) {
                    viewModel.stopSession()
                }
            }
            .buttonStyle(.fluid)
        }
    }
    
    // MARK: - Pattern Picker Sheet
    
    private var patternPickerSheet: some View {
        VStack(spacing: ZenithSpacing.lg) {
            Text("Breathing Pattern")
                .font(ZenithTypography.title2)
                .foregroundColor(ZenithColors.textPrimary)
                .padding(.top, ZenithSpacing.lg)
            
            ForEach(BreathPattern.allPatterns, id: \.id) { pattern in
                Button {
                    viewModel.selectedPattern = pattern
                    showPatternPicker = false
                    HapticEngine.shared.selectionChanged()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pattern.name)
                                .font(ZenithTypography.headline)
                                .foregroundColor(ZenithColors.textPrimary)
                            Text(pattern.description)
                                .font(ZenithTypography.caption1)
                                .foregroundColor(ZenithColors.textTertiary)
                        }
                        Spacer()
                        if pattern.id == viewModel.selectedPattern.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ZenithColors.amethyst)
                        }
                    }
                }
                .glassCardStyle(
                    cornerRadius: ZenithRadius.medium,
                    elevation: pattern.id == viewModel.selectedPattern.id ? .raised : .embedded
                )
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.horizontal, ZenithSpacing.lg)
    }
}

// MARK: - Duration Option Helper

struct DurationOption: Hashable, CustomStringConvertible {
    let seconds: Int
    var description: String {
        "\(seconds / 60) min"
    }
}

#Preview {
    HomeView()
        .modelContainer(for: SessionModel.self, inMemory: true)
}
