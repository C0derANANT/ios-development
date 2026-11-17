import Foundation
import SwiftData

/// One job or internship the user is tracking.
///
/// `@Model` turns this plain class into a SwiftData model: every stored
/// property becomes a column in the database, and changes are saved and
/// pushed to the UI automatically.
@Model
final class JobApplication {
    var company: String
    var role: String
    var location: String
    var status: ApplicationStatus
    var dateApplied: Date
    var notes: String
    var createdAt: Date

    init(
        company: String,
        role: String,
        location: String = "",
        status: ApplicationStatus = .applied,
        dateApplied: Date = .now,
        notes: String = ""
    ) {
        self.company = company
        self.role = role
        self.location = location
        self.status = status
        self.dateApplied = dateApplied
        self.notes = notes
        self.createdAt = .now
    }
}
