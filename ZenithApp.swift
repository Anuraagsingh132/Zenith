import SwiftUI
import SwiftData

@main
struct ZenithApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SessionModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
