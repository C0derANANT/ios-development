import SwiftData
import SwiftUI

/// The entry point of the app.
///
/// `@main` tells Swift "start the program here". The `modelContainer` modifier
/// creates the on-disk database for `JobApplication` and makes it available to
/// every view in the window.
@main
struct PursuitApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: JobApplication.self)
    }
}
