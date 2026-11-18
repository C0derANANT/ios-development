import Foundation
import SwiftData

/// Fake applications for Xcode previews, so screens can be designed without
/// typing data in by hand.
enum SampleData {
    static func makeApplications() -> [JobApplication] {
        [
            make("Swiggy", "iOS Developer Intern", location: "Bengaluru",
                 notes: "Round 2 is a take-home SwiftUI assignment.",
                 stages: [(.wishlist, 12), (.applied, 9), (.interviewing, 3)]),
            make("Razorpay", "Software Engineer I", location: "Remote",
                 stages: [(.applied, 6)]),
            make("CRED", "Product Engineer Intern", location: "Bengaluru",
                 stages: [(.applied, 2)]),
            make("Zoho", "Mobile Engineer", location: "Chennai",
                 notes: "Offer letter expected by Friday.",
                 stages: [(.applied, 25), (.interviewing, 18), (.offer, 4)]),
            make("Flipkart", "SDE Intern", location: "Bengaluru",
                 stages: [(.applied, 30), (.interviewing, 22), (.rejected, 15)]),
            make("Microsoft", "Software Engineer Intern", location: "Hyderabad",
                 stages: [(.applied, 14), (.rejected, 10)]),
            make("Atlassian", "Graduate Engineer",
                 notes: "Applications open next month.",
                 stages: [(.wishlist, 1)]),
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

    /// One application from `previewContainer`, for previewing a single screen.
    static var previewApplication: JobApplication {
        let swiggy = FetchDescriptor<JobApplication>(predicate: #Predicate { $0.company == "Swiggy" })
        guard let application = try? previewContainer.mainContext.fetch(swiggy).first else {
            fatalError("The preview container has no Swiggy application.")
        }
        return application
    }

    /// Builds an application that went through `stages`, each given as
    /// (status, how many days ago it happened), oldest first.
    private static func make(
        _ company: String,
        _ role: String,
        location: String = "",
        notes: String = "",
        stages: [(ApplicationStatus, Int)]
    ) -> JobApplication {
        let (firstStatus, firstDay) = stages[0]
        let application = JobApplication(
            company: company,
            role: role,
            location: location,
            status: firstStatus,
            dateApplied: daysAgo(firstDay),
            notes: notes
        )
        for (status, day) in stages.dropFirst() {
            application.move(to: status, on: daysAgo(day))
        }
        return application
    }

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }
}
