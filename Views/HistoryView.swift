import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SessionModel.startDate, order: .reverse) private var sessions: [SessionModel]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var viewModel = HistoryViewModel()
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                SubtleBackground(accentColor: ZenithColors.cosmicIndigo)
                
                ScrollView {
                    VStack(spacing: ZenithSpacing.xl) {
                        if sessions.isEmpty {
                            emptyState
                        } else {
                            statsRow
                            weeklyChart
                            sessionsList
                        }
                    }
                    .padding(.horizontal, ZenithSpacing.lg)
                    .padding(.top, ZenithSpacing.md)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("History")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                withAnimation(ZenithMotion.gentleSpring) {
                    appeared = true
                }
            }
        }
    }
    
    // MARK: - Stats Dashboard
    
    private var statsRow: some View {
        HStack(spacing: ZenithSpacing.sm) {
            statCard(
                value: "\(viewModel.currentStreak(from: sessions))",
                label: "Day Streak",
                icon: "flame.fill",
                color: ZenithColors.warmGold
            )
            
            statCard(
                value: "\(viewModel.totalMinutes(from: sessions))",
                label: "Minutes",
                icon: "clock.fill",
                color: ZenithColors.nebulaTeal
            )
            
            statCard(
                value: "\(viewModel.sessionCount(from: sessions))",
                label: "Sessions",
                icon: "sparkles",
                color: ZenithColors.amethyst
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: ZenithSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(ZenithTypography.title2)
                .foregroundColor(ZenithColors.textPrimary)
            
            Text(label)
                .font(ZenithTypography.caption1)
                .foregroundColor(ZenithColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .glassCardStyle(cornerRadius: ZenithRadius.medium, elevation: .embedded)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        let data = viewModel.weeklyData(from: sessions)
        let maxMinutes = max(data.map(\.minutes).max() ?? 1, 1)
        
        return VStack(alignment: .leading, spacing: ZenithSpacing.sm) {
            Text("This Week")
                .font(ZenithTypography.headline)
                .foregroundColor(ZenithColors.textSecondary)
                .padding(.horizontal, ZenithSpacing.xs)
            
            HStack(alignment: .bottom, spacing: ZenithSpacing.xs) {
                ForEach(data) { day in
                    VStack(spacing: ZenithSpacing.xxs) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [ZenithColors.amethyst, ZenithColors.nebulaTeal.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                height: max(4, CGFloat(day.minutes) / CGFloat(maxMinutes) * 80)
                            )
                            .frame(maxWidth: .infinity)
                        
                        Text(day.dayLabel)
                            .font(ZenithTypography.caption2)
                            .foregroundColor(ZenithColors.textTertiary)
                    }
                }
            }
            .frame(height: 110)
            .glassCardStyle(cornerRadius: ZenithRadius.medium, elevation: .embedded)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    // MARK: - Sessions List (Grouped)
    
    private var sessionsList: some View {
        let groups = viewModel.groupedByDay(from: sessions)
        
        return ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
            VStack(alignment: .leading, spacing: ZenithSpacing.sm) {
                Text(group.label)
                    .font(ZenithTypography.headline)
                    .foregroundColor(ZenithColors.textSecondary)
                    .padding(.horizontal, ZenithSpacing.xs)
                
                ForEach(Array(group.sessions.enumerated()), id: \.element.id) { sessionIndex, session in
                    sessionRow(session)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(
                            reduceMotion ? .none : ZenithMotion.cardAppear(index: index * 3 + sessionIndex),
                            value: appeared
                        )
                }
            }
        }
    }
    
    private func sessionRow(_ session: SessionModel) -> some View {
        HStack(spacing: ZenithSpacing.md) {
            // Mood emoji
            Text(session.moodEmoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.startDate.formatted(date: .omitted, time: .shortened))
                    .font(ZenithTypography.subheadline)
                    .foregroundColor(ZenithColors.textPrimary)
                
                Text(session.formattedDuration + " • " + session.sessionType.rawValue)
                    .font(ZenithTypography.caption1)
                    .foregroundColor(ZenithColors.textTertiary)
            }
            
            Spacer()
            
            Image(systemName: session.sessionType.icon)
                .font(.system(size: 14))
                .foregroundColor(ZenithColors.amethyst.opacity(0.6))
        }
        .glassCardStyle(cornerRadius: ZenithRadius.medium, elevation: .embedded)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: ZenithSpacing.xl) {
            Spacer().frame(height: 60)
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ZenithColors.amethyst.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(ZenithColors.amethyst.opacity(0.6))
            }
            
            VStack(spacing: ZenithSpacing.xs) {
                Text("Your journey begins here")
                    .font(ZenithTypography.title3)
                    .foregroundColor(ZenithColors.textPrimary)
                
                Text("Complete your first session to see\nyour mindfulness history.")
                    .font(ZenithTypography.body)
                    .foregroundColor(ZenithColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: SessionModel.self, inMemory: true)
}
