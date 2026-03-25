import SwiftUI
import SwiftData
import Combine

/// Owns the entire session lifecycle: timer, breath engine, phase tracking,
/// duration selection, and completion state.
@Observable
final class SessionViewModel {
    
    // MARK: - Session Configuration
    
    var selectedDuration: Int = 300  // seconds
    var selectedPattern: BreathPattern = .boxBreathing
    
    let durationOptions: [Int] = [60, 180, 300, 600]
    
    var durationLabel: String {
        "\(selectedDuration / 60) min"
    }
    
    // MARK: - Session State
    
    var isActive = false
    var isComplete = false
    var timeRemaining: Int = 300
    var totalElapsed: Int = 0
    var breathPhase: BreathPhase = .idle
    var sessionProgress: Double = 0.0
    
    // MARK: - Completion State (for mood picker)
    
    var completedDuration: Int = 0
    var selectedMood: Int = 3
    
    // MARK: - Private
    
    private var timer: Timer?
    private var breathTimer: Timer?
    private var phaseStartTime: Date?
    private var currentPhaseDuration: TimeInterval = 0
    
    // MARK: - Computed
    
    var timeDisplay: String {
        let min = timeRemaining / 60
        let sec = timeRemaining % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Time to rest"
        }
    }
    
    var greetingSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Start your day with clarity"
        case 12..<17: return "A calm pause in your day"
        case 17..<21: return "Unwind and decompress"
        default:      return "Settle into stillness"
        }
    }
    
    // MARK: - Actions
    
    func startSession() {
        guard !isActive else { return }
        
        isActive = true
        isComplete = false
        timeRemaining = selectedDuration
        totalElapsed = 0
        sessionProgress = 0.0
        
        HapticEngine.shared.mediumTap()
        SoundscapeEngine.shared.startAmbience()
        
        // Main countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.totalElapsed += 1
                self.sessionProgress = Double(self.totalElapsed) / Double(self.selectedDuration)
                
                // Update soundscape volume based on breath
                let breathIntensity: Float = self.breathPhase == .inhale ? 0.8 : (self.breathPhase == .hold ? 0.6 : 0.3)
                SoundscapeEngine.shared.setBreathIntensity(breathIntensity)
            } else {
                self.completeSession()
            }
        }
        
        // Start breath cycling
        startBreathCycle()
    }
    
    func stopSession() {
        let elapsed = totalElapsed
        
        timer?.invalidate()
        timer = nil
        breathTimer?.invalidate()
        breathTimer = nil
        
        isActive = false
        breathPhase = .idle
        
        SoundscapeEngine.shared.stopAmbience()
        
        if elapsed > 10 {
            completedDuration = elapsed
            isComplete = true
            HapticEngine.shared.playCompletionCelebration()
        }
    }
    
    func completeSession() {
        completedDuration = totalElapsed
        
        timer?.invalidate()
        timer = nil
        breathTimer?.invalidate()
        breathTimer = nil
        
        isActive = false
        isComplete = true
        breathPhase = .idle
        
        SoundscapeEngine.shared.stopAmbience()
        HapticEngine.shared.playCompletionCelebration()
    }
    
    func saveSession(to modelContext: ModelContext) {
        let session = SessionModel(
            durationInSeconds: completedDuration,
            moodScore: selectedMood,
            breathPatternId: selectedPattern.id
        )
        modelContext.insert(session)
        
        isComplete = false
        selectedMood = 3
        totalElapsed = 0
        sessionProgress = 0.0
        timeRemaining = selectedDuration
    }
    
    func dismissCompletion() {
        isComplete = false
        selectedMood = 3
        totalElapsed = 0
        sessionProgress = 0.0
        timeRemaining = selectedDuration
    }
    
    // MARK: - Breath Engine
    
    private func startBreathCycle() {
        transitionToPhase(.inhale)
    }
    
    private func transitionToPhase(_ phase: BreathPhase) {
        guard isActive else { return }
        
        breathPhase = phase
        
        let duration: TimeInterval
        switch phase {
        case .inhale:
            duration = selectedPattern.inhaleDuration
            HapticEngine.shared.playInhaleHaptic(duration: duration)
        case .hold:
            duration = selectedPattern.holdDuration
            HapticEngine.shared.playHoldHaptic()
        case .exhale:
            duration = selectedPattern.exhaleDuration
            HapticEngine.shared.playExhaleHaptic(duration: duration)
        case .idle:
            return
        }
        
        guard duration > 0 else {
            // Skip zero-duration phases
            transitionToPhase(nextPhase(after: phase))
            return
        }
        
        breathTimer?.invalidate()
        breathTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            let next = self.nextPhase(after: phase)
            self.transitionToPhase(next)
        }
    }
    
    private func nextPhase(after phase: BreathPhase) -> BreathPhase {
        switch phase {
        case .idle:    return .inhale
        case .inhale:  return .hold
        case .hold:    return .exhale
        case .exhale:  return .inhale  // cycles back
        }
    }
}
