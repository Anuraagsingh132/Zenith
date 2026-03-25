import Foundation

/// Defines a breathing pattern with phase durations.
/// Each cycle: inhale → hold → exhale → (optional pause)
struct BreathPattern: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let inhaleDuration: TimeInterval
    let holdDuration: TimeInterval
    let exhaleDuration: TimeInterval
    let pauseDuration: TimeInterval // pause between cycles
    
    var cycleDuration: TimeInterval {
        inhaleDuration + holdDuration + exhaleDuration + pauseDuration
    }
    
    // MARK: - Presets
    
    static let boxBreathing = BreathPattern(
        id: "box",
        name: "Box Breathing",
        description: "Equal parts. Calm and balanced.",
        inhaleDuration: 4, holdDuration: 4, exhaleDuration: 4, pauseDuration: 4
    )
    
    static let calm478 = BreathPattern(
        id: "calm",
        name: "4-7-8 Calm",
        description: "Extended exhale for deep relaxation.",
        inhaleDuration: 4, holdDuration: 7, exhaleDuration: 8, pauseDuration: 1
    )
    
    static let energize = BreathPattern(
        id: "energize",
        name: "Quick Energize",
        description: "Short, rhythmic breaths to wake up.",
        inhaleDuration: 2, holdDuration: 0, exhaleDuration: 2, pauseDuration: 0.5
    )
    
    static let allPatterns: [BreathPattern] = [.boxBreathing, .calm478, .energize]
}
