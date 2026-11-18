import Foundation

extension Date {
    /// "Today", "Yesterday", "3d ago", or "12 Nov" for anything older than a week.
    ///
    /// Counting calendar days (not 24-hour blocks) means something from 11 pm
    /// last night reads "Yesterday", which is how people think about it.
    var relativeDay: String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: self),
            to: calendar.startOfDay(for: .now)
        ).day ?? 0

        switch days {
        case ..<1: return "Today"
        case 1: return "Yesterday"
        case 2..<7: return "\(days)d ago"
        default: return formatted(.dateTime.day().month(.abbreviated))
        }
    }
}
