import SwiftUI
import SwiftData

@main
struct Reflets: App {
    
    var body: some Scene {
        WindowGroup {
            ViewContainer()
        }
        .modelContainer(for: VisionBoard.self)
    }
}
