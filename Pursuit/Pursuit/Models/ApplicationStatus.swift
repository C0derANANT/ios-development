import SwiftUI

/// The stage a job application is currently in.
///
/// The raw `String` value is what gets saved to disk, so renaming a case later
/// would break existing data. Add new cases instead of renaming old ones.
nonisolated enum ApplicationStatus: String, Codable, CaseIterable, Identifiable {
    case wishlist
    case applied
    case interviewing
    case offer
    case rejected

    var id: Self { self }

    /// Human-readable name shown in the UI.
    var title: String {
        switch self {
        case .wishlist: "Wishlist"
        case .applied: "Applied"
        case .interviewing: "Interviewing"
        case .offer: "Offer"
        case .rejected: "Rejected"
        }
    }

    /// SF Symbol name used next to the title.
    var systemImage: String {
        switch self {
        case .wishlist: "bookmark"
        case .applied: "paperplane"
        case .interviewing: "person.2"
        case .offer: "party.popper"
        case .rejected: "xmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .wishlist: .gray
        case .applied: .blue
        case .interviewing: .orange
        case .offer: .green
        case .rejected: .red
        }
    }

    /// Sentence shown in the history timeline.
    var timelineTitle: String {
        switch self {
        case .wishlist: "Saved to wishlist"
        case .applied: "Applied"
        case .interviewing: "Started interviewing"
        case .offer: "Got an offer"
        case .rejected: "Marked as rejected"
        }
    }

    /// The main road an application travels. Rejected isn't on it, because
    /// a rejection can happen at any stage.
    static let pipeline: [ApplicationStatus] = [.wishlist, .applied, .interviewing, .offer]

    /// Position on the `pipeline` (0 = wishlist, 3 = offer), or nil for rejected.
    var pipelineIndex: Int? {
        Self.pipeline.firstIndex(of: self)
    }

    /// The stage that normally comes next, or nil at the end of the road.
    var next: ApplicationStatus? {
        switch self {
        case .wishlist: .applied
        case .applied: .interviewing
        case .interviewing: .offer
        case .offer, .rejected: nil
        }
    }
}
