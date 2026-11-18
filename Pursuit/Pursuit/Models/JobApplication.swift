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

    /// Every stage change, oldest first.
    ///
    /// The `= []` default matters: applications saved before this property
    /// existed have no history on disk, and the default lets SwiftData load
    /// them anyway instead of failing.
    var history: [StatusChange] = []

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
        self.history = [StatusChange(status: status, date: dateApplied)]
    }

    /// Moves the application to a new stage and records it in the history.
    ///
    /// Always change `status` through this method, never directly, so the
    /// timeline stays complete.
    func move(to newStatus: ApplicationStatus, on date: Date = .now) {
        guard newStatus != status else { return }

        // Older entries have no history yet. Record where they started first.
        if history.isEmpty {
            history = [StatusChange(status: status, date: dateApplied)]
        }
        // Leaving the wishlist for a real stage means you applied today.
        if status == .wishlist && newStatus != .rejected {
            dateApplied = date
        }
        status = newStatus
        history.append(StatusChange(status: newStatus, date: date))
    }

    /// Changes the date the user picked in the form. While the application
    /// has only its first entry, that entry moves with it.
    func setDateApplied(_ date: Date) {
        dateApplied = date
        if history.count == 1 {
            history[0].date = date
        }
    }

    // MARK: - Values worked out from the stored data

    /// Stage changes, newest first. Entries saved before history existed
    /// show their current status on the day they were added.
    var timeline: [StatusChange] {
        history.isEmpty ? [StatusChange(status: status, date: dateApplied)] : history.reversed()
    }

    /// Where the application stands on the pipeline: 0 = wishlist up to 3 = offer.
    ///
    /// A rejected application keeps the stage it was at when the rejection came,
    /// so "rejected after interviews" still shows 3 of 4. That's the newest
    /// history entry that is on the pipeline.
    var stage: Int {
        if let index = status.pipelineIndex {
            return index
        }
        return timeline.lazy.compactMap(\.status.pipelineIndex).first ?? 1
    }

    /// When anything last happened to this application.
    var lastUpdated: Date {
        timeline.first?.date ?? dateApplied
    }

    /// True once the application actually went out (it left the wishlist).
    var wasSent: Bool {
        stage >= 1
    }

    /// True once the company replied in any way: an interview, an offer or a rejection.
    var hasResponse: Bool {
        status == .rejected ? wasSent : stage >= 2
    }

    /// "Company · Location", or just the company when no location was entered.
    var companyAndLocation: String {
        location.isEmpty ? company : "\(company) · \(location)"
    }
}
