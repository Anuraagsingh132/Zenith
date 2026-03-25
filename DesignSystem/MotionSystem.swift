import SwiftUI

/// Centralized motion system for Zenith.
/// All animations are named, physics-based, and accessibility-aware.
enum ZenithMotion {
    
    // MARK: - Spring Animations
    
    /// Quick, snappy spring for button presses and toggles
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    
    /// Standard interactive spring for most transitions
    static let standardSpring = Animation.spring(response: 0.45, dampingFraction: 0.75, blendDuration: 0)
    
    /// Gentle, flowing spring for large element transitions
    static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    
    /// Bouncy spring for celebration/delight moments
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.55, blendDuration: 0)
    
    /// Very slow spring for ambient breathing orb
    static let breathSpring = Animation.spring(response: 1.2, dampingFraction: 0.9, blendDuration: 0.2)
    
    // MARK: - Named Transitions
    
    /// Tab content transition
    static let tabSwitch = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)
    
    /// Cards appearing in a list (staggered)
    static func cardAppear(index: Int) -> Animation {
        .spring(response: 0.5, dampingFraction: 0.78, blendDuration: 0)
        .delay(Double(index) * 0.06)
    }
    
    /// Glass panel sliding up (modal presentation)
    static let panelPresent = Animation.spring(response: 0.55, dampingFraction: 0.82, blendDuration: 0)
    
    /// Orb scale pulse during active breathing
    static func breathCycle(duration: TimeInterval) -> Animation {
        .easeInOut(duration: duration)
    }
    
    /// Particle drift
    static let particleDrift = Animation.linear(duration: 0).speed(0.02)
    
    // MARK: - Accessibility Aware Wrapper
    
    /// Returns the provided animation, or `.default` if reduce motion is requested.
    static func motionAware(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : animation
    }
}

// MARK: - View Transition Helpers

extension AnyTransition {
    
    /// Glass card slides up from bottom and fades in
    static var glassSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
            removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.98))
        )
    }
    
    /// Glass modal slides up with more travel
    static var glassModal: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity.combined(with: .scale(scale: 0.96))
        )
    }
    
    /// Fade + subtle scale for tab content
    static var tabContent: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.98))
    }
    
    /// Staggered card appearance
    static var cardReveal: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92)).combined(with: .offset(y: 20)),
            removal: .opacity.combined(with: .scale(scale: 0.96))
        )
    }
}
