import Foundation
import SwiftData

/// Fake applications for Xcode previews, so screens can be designed without
/// typing data in by hand.
enum SampleData {
    static func makeApplications() -> [JobApplication] {
        [
            JobApplication(
                company: "Swiggy",
                role: "iOS Developer Intern",
                location: "Bengaluru",
                status: .interviewing,
                dateApplied: daysAgo(3),
                notes: "Round 2 is a take-home SwiftUI assignment."
            ),
            JobApplication(
                company: "Razorpay",
                role: "Software Engineer I",
                location: "Remote",
                status: .applied,
                dateApplied: daysAgo(6)
            ),
            JobApplication(
                company: "Zoho",
                role: "Mobile Engineer",
                location: "Chennai",
                status: .offer,
                dateApplied: daysAgo(21),
                notes: "Offer letter expected by Friday."
            ),
            JobApplication(
                company: "Flipkart",
                role: "SDE Intern",
                location: "Bengaluru",
                status: .rejected,
                dateApplied: daysAgo(30)
            ),
            JobApplication(
                company: "Atlassian",
                role: "Graduate Engineer",
                status: .wishlist,
                dateApplied: daysAgo(1),
                notes: "Applications open next month."
            ),
        ]
    }

    /// A database that lives only in memory, pre-filled with the sample data.
    static let previewContainer: ModelContainer = {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: JobApplication.self, configurations: configuration)
            for application in makeApplications() {
                container.mainContext.insert(application)
            }
            return container
        } catch {
            fatalError("Could not create the preview container: \(error)")
        }
    }()

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }
}
