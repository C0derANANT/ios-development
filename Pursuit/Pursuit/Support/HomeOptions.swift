import Foundation

/// How the home screen shows applications. Saved with `@AppStorage`, so the
/// app reopens in whichever layout you used last.
///
/// `String` raw values are what get saved, the same idea as `ApplicationStatus`.
enum HomeLayout: String {
    case list
    case board

    var toggled: HomeLayout {
        self == .list ? .board : .list
    }

    /// The toolbar button shows where tapping it will take you.
    var toggleTitle: String {
        self == .list ? "Show board" : "Show list"
    }

    var toggleSystemImage: String {
        self == .list ? "rectangle.split.1x2" : "list.bullet"
    }
}

/// The orders the home screen can sort applications in.
///
/// Named `ApplicationSort`, not `SortOrder`, because Foundation already has a
/// type called `SortOrder` and the two would clash.
enum ApplicationSort: String, CaseIterable, Identifiable {
    case dateApplied
    case recentlyUpdated
    case company

    var id: Self { self }

    var title: String {
        switch self {
        case .dateApplied: "Date applied"
        case .recentlyUpdated: "Recently updated"
        case .company: "Company name"
        }
    }

    var systemImage: String {
        switch self {
        case .dateApplied: "calendar"
        case .recentlyUpdated: "clock.arrow.circlepath"
        case .company: "textformat"
        }
    }

    /// Returns `applications` in this order. Newest first for dates, A to Z for names.
    func sorted(_ applications: [JobApplication]) -> [JobApplication] {
        switch self {
        case .dateApplied:
            applications.sorted { $0.dateApplied > $1.dateApplied }
        case .recentlyUpdated:
            applications.sorted { $0.lastUpdated > $1.lastUpdated }
        case .company:
            applications.sorted {
                $0.company.localizedCaseInsensitiveCompare($1.company) == .orderedAscending
            }
        }
    }
}
