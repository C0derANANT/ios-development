import Foundation

/// One entry in an application's history: "moved to Interviewing on 15 Nov".
///
/// This is a plain struct, not a `@Model`. SwiftData stores it inside its
/// `JobApplication` (encoded with `Codable`), so it needs no table of its own.
nonisolated struct StatusChange: Codable, Hashable, Identifiable {
    var id = UUID()
    var status: ApplicationStatus
    var date: Date
}
