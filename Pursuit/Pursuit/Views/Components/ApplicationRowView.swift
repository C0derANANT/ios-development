import SwiftUI

/// One row in the applications list.
struct ApplicationRowView: View {
    let application: JobApplication

    var body: some View {
        HStack(spacing: 12) {
            CompanyAvatar(name: application.company)

            VStack(alignment: .leading, spacing: 4) {
                Text(application.role)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusBadge(status: application.status)
                Text(application.dateApplied, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    /// "Company · Location", or just the company when no location was entered.
    private var subtitle: String {
        if application.location.isEmpty {
            application.company
        } else {
            "\(application.company) · \(application.location)"
        }
    }
}

#Preview {
    List(SampleData.makeApplications()) { application in
        ApplicationRowView(application: application)
    }
}
