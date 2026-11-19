import SwiftUI

/// A small card for the pipeline board. Fixed size, so every lane is the same height.
struct BoardCard: View {
    let application: JobApplication

    static let width: CGFloat = 150
    static let height: CGFloat = 50

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                CompanyAvatar(name: application.company, size: 28)
                Text(application.company)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            Text(application.role)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: Self.width, height: Self.height, alignment: .topLeading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        // The copy that follows your finger during a drag gets the same rounded corners.
        .contentShape(.dragPreview, .rect(cornerRadius: 14))
    }
}

#Preview {
    HStack {
        ForEach(SampleData.makeApplications().prefix(2)) { application in
            BoardCard(application: application)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
