import SwiftUI
import CoreHaptics

/// Centralized haptic feedback engine for Zenith.
/// Provides semantic haptic methods and advanced CoreHaptics patterns
/// for breath-synced continuous feedback.
@Observable
final class HapticEngine {
    
    static let shared = HapticEngine()
    
    private var coreEngine: CHHapticEngine?
    private var isEngineRunning = false
    
    /// Respect user preference
    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "hapticFeedbackEnabled") }
    }
    
    private init() {
        prepareEngine()
    }
    
    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            coreEngine = try CHHapticEngine()
            coreEngine?.resetHandler = { [weak self] in
                do {
                    try self?.coreEngine?.start()
                    self?.isEngineRunning = true
                } catch {
                    self?.isEngineRunning = false
                }
            }
            coreEngine?.stoppedHandler = { [weak self] _ in
                self?.isEngineRunning = false
            }
            try coreEngine?.start()
            isEngineRunning = true
        } catch {
            isEngineRunning = false
        }
    }
    
    // MARK: - Simple Feedback
    
    func lightTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func mediumTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func softTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Advanced: Breath Phase Haptics
    
    /// Plays a gentle crescendo haptic for the inhale phase
    func playInhaleHaptic(duration: TimeInterval) {
        guard isEnabled, isEngineRunning else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: duration
            )
            
            // Ramp intensity up over the duration
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0, value: 0.1),
                    .init(relativeTime: duration, value: 0.5)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try coreEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Fallback to simple feedback
            softTap()
        }
    }
    
    /// Plays a subtle steady pulse for the hold phase
    func playHoldHaptic() {
        guard isEnabled else { return }
        softTap()
    }
    
    /// Plays a gentle decrescendo haptic for the exhale phase
    func playExhaleHaptic(duration: TimeInterval) {
        guard isEnabled, isEngineRunning else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: duration
            )
            
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0, value: 0.4),
                    .init(relativeTime: duration, value: 0.0)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve])
            let player = try coreEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            softTap()
        }
    }
    
    /// Session completion celebration pattern
    func playCompletionCelebration() {
        guard isEnabled else { return }
        
        // Three ascending taps
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.impactOccurred(intensity: 0.7)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
    }
}
