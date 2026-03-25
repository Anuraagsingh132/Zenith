import Foundation
import SwiftData

/// Session types
enum SessionType: String, Codable, CaseIterable {
    case breathing = "Breathing"
    case focus     = "Focus"
    case bodyScan  = "Body Scan"
    
    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .focus:     return "sparkles"
        case .bodyScan:  return "figure.mind.and.body"
        }
    }
}

/// Represents a completed mindfulness session
@Model
final class SessionModel {
    var id: UUID
    var startDate: Date
    var durationInSeconds: Int
    var moodScore: Int  // 1 to 5
    var sessionTypeRaw: String
    var notes: String
    var breathPatternId: String

    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        durationInSeconds: Int,
        moodScore: Int = 3,
        sessionType: SessionType = .breathing,
        notes: String = "",
        breathPatternId: String = "box"
    ) {
        self.id = id
        self.startDate = startDate
        self.durationInSeconds = durationInSeconds
        self.moodScore = moodScore
        self.sessionTypeRaw = sessionType.rawValue
        self.notes = notes
        self.breathPatternId = breathPatternId
    }
    
    var sessionType: SessionType {
        get { SessionType(rawValue: sessionTypeRaw) ?? .breathing }
        set { sessionTypeRaw = newValue.rawValue }
    }
    
    var formattedDuration: String {
        let minutes = durationInSeconds / 60
        let seconds = durationInSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
    
    var moodEmoji: String {
        switch moodScore {
        case 1: return "😔"
        case 2: return "😐"
        case 3: return "🙂"
        case 4: return "😊"
        case 5: return "🤩"
        default: return "🙂"
        }
    }
    
    // MARK: - Sample Data
    
    static func sampleData() -> [SessionModel] {
        let calendar = Calendar.current
        return [
            SessionModel(startDate: calendar.date(byAdding: .hour, value: -2, to: Date())!, durationInSeconds: 300, moodScore: 4),
            SessionModel(startDate: calendar.date(byAdding: .day, value: -1, to: Date())!, durationInSeconds: 600, moodScore: 5),
            SessionModel(startDate: calendar.date(byAdding: .day, value: -2, to: Date())!, durationInSeconds: 180, moodScore: 3),
            SessionModel(startDate: calendar.date(byAdding: .day, value: -3, to: Date())!, durationInSeconds: 420, moodScore: 4),
            SessionModel(startDate: calendar.date(byAdding: .day, value: -5, to: Date())!, durationInSeconds: 300, moodScore: 5),
        ]
    }
}
