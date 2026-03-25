import SwiftUI
import SwiftData

/// Computes stats, streaks, and grouped history data from sessions.
@Observable
final class HistoryViewModel {
    
    // MARK: - Stats
    
    func totalMinutes(from sessions: [SessionModel]) -> Int {
        sessions.reduce(0) { $0 + $1.durationInSeconds } / 60
    }
    
    func sessionCount(from sessions: [SessionModel]) -> Int {
        sessions.count
    }
    
    func currentStreak(from sessions: [SessionModel]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDays = Set(sessions.map { calendar.startOfDay(for: $0.startDate) })
            .sorted(by: >)
        
        guard let mostRecent = sortedDays.first else { return 0 }
        
        // Check if the most recent session is today or yesterday
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        guard mostRecent >= yesterday else { return 0 }
        
        var streak = 1
        var checkDate = mostRecent
        
        for day in sortedDays.dropFirst() {
            let expected = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            if day == expected {
                streak += 1
                checkDate = day
            } else {
                break
            }
        }
        
        return streak
    }
    
    func averageMood(from sessions: [SessionModel]) -> Double {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0) { $0 + $1.moodScore }
        return Double(total) / Double(sessions.count)
    }
    
    // MARK: - Weekly Chart Data
    
    struct DayData: Identifiable {
        let id = UUID()
        let dayLabel: String  // "Mon", "Tue", etc.
        let minutes: Int
    }
    
    func weeklyData(from sessions: [SessionModel]) -> [DayData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let daySessions = sessions.filter { $0.startDate >= dayStart && $0.startDate < dayEnd }
            let totalMinutes = daySessions.reduce(0) { $0 + $1.durationInSeconds } / 60
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let label = formatter.string(from: date)
            
            return DayData(dayLabel: label, minutes: totalMinutes)
        }
    }
    
    // MARK: - Grouped Sessions
    
    struct DayGroup: Identifiable {
        let id: Date
        let label: String
        let sessions: [SessionModel]
    }
    
    func groupedByDay(from sessions: [SessionModel]) -> [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startDate)
        }
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        return grouped.map { date, sessions in
            let label: String
            if date == today {
                label = "Today"
            } else if date == yesterday {
                label = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                label = formatter.string(from: date)
            }
            return DayGroup(id: date, label: label, sessions: sessions.sorted { $0.startDate > $1.startDate })
        }
        .sorted { $0.id > $1.id }
    }
}
