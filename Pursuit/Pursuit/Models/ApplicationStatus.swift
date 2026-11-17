import SwiftUI

/// The stage a job application is currently in.
///
/// The raw `String` value is what gets saved to disk, so renaming a case later
/// would break existing data. Add new cases instead of renaming old ones.
enum ApplicationStatus: String, Codable, CaseIterable, Identifiable {
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
}
