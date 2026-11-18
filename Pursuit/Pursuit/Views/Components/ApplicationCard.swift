import SwiftUI

/// One application on the home screen, drawn as a card.
struct ApplicationCard: View {
    let application: JobApplication

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CompanyAvatar(name: application.company)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(application.role)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    StatusBadge(status: application.status)
                }

                Text(application.companyAndLocation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    StageProgressBar(application: application)
                    Spacer()
                    Text(application.lastUpdated.relativeDay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 6)
            }
        }
        .cardStyle(padding: 14, cornerRadius: 18)
        // Makes the whole card (including blank space) respond to taps.
        .contentShape(.rect(cornerRadius: 18))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(SampleData.makeApplications()) { application in
                ApplicationCard(application: application)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
