import AVFoundation
import Combine

/// Ambient soundscape engine for Zenith.
/// Generates a synth-pad-like ambient tone using AVAudioEngine
/// with breath-synced volume envelope.
@Observable
final class SoundscapeEngine {
    
    static let shared = SoundscapeEngine()
    
    private var audioEngine: AVAudioEngine?
    private var toneNode: AVAudioSourceNode?
    private var isPlaying = false
    
    var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "soundEnabled") }
    }
    
    /// Current volume envelope (0.0 to 1.0), driven by breath phase
    var volumeEnvelope: Float = 0.0
    
    /// Base frequency for the ambient pad
    private let baseFrequency: Double = 174.0 // Solfeggio frequency for relaxation
    private var phase: Double = 0.0
    private var harmonicPhase2: Double = 0.0
    private var harmonicPhase3: Double = 0.0
    
    private init() {}
    
    /// Start the ambient pad
    func startAmbience() {
        guard isEnabled, !isPlaying else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
        
        let engine = AVAudioEngine()
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        let sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buffer = ablPointer[0]
            let buf = buffer.mData!.assumingMemoryBound(to: Float.self)
            
            let freq1 = self.baseFrequency
            let freq2 = self.baseFrequency * 1.5  // Perfect fifth
            let freq3 = self.baseFrequency * 2.0  // Octave
            
            let increment1 = freq1 / sampleRate
            let increment2 = freq2 / sampleRate
            let increment3 = freq3 / sampleRate
            
            let envelope = self.volumeEnvelope * 0.08 // Keep it very subtle
            
            for frame in 0..<Int(frameCount) {
                let sine1 = sin(self.phase * .pi * 2.0)
                let sine2 = sin(self.harmonicPhase2 * .pi * 2.0) * 0.5
                let sine3 = sin(self.harmonicPhase3 * .pi * 2.0) * 0.25
                
                let mixed = Float(sine1 + sine2 + sine3) * envelope / 1.75
                buf[frame] = mixed
                
                self.phase += increment1
                self.harmonicPhase2 += increment2
                self.harmonicPhase3 += increment3
                
                if self.phase > 1.0 { self.phase -= 1.0 }
                if self.harmonicPhase2 > 1.0 { self.harmonicPhase2 -= 1.0 }
                if self.harmonicPhase3 > 1.0 { self.harmonicPhase3 -= 1.0 }
            }
            
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            isPlaying = true
            self.audioEngine = engine
            self.toneNode = sourceNode
        } catch {
            isPlaying = false
        }
    }
    
    /// Stop the ambient pad
    func stopAmbience() {
        audioEngine?.stop()
        isPlaying = false
        audioEngine = nil
        toneNode = nil
        volumeEnvelope = 0.0
    }
    
    /// Smoothly update the volume envelope for breath sync
    func setBreathIntensity(_ intensity: Float) {
        guard isEnabled else { return }
        volumeEnvelope = max(0, min(1, intensity))
    }
}
