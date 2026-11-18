import SwiftData
import SwiftUI

/// Everything about one application: where it stands, what to do next, and its history.
struct ApplicationDetailView: View {
    /// No `@State` or `@Binding` needed: a `@Model` class is observable, so this
    /// screen redraws by itself whenever the application changes.
    let application: JobApplication

    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                progressCard
                historyCard
                if !application.notes.isEmpty {
                    notesCard
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(application.company)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                isEditing = true
            }
        }
        .sheet(isPresented: $isEditing) {
            ApplicationFormView(application: application)
        }
        // A strong buzz for an offer, a lighter tap for any other move.
        .sensoryFeedback(trigger: application.status) { _, newStatus in
            newStatus == .offer ? .success : .impact(weight: .medium)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 12) {
            CompanyAvatar(name: application.company, size: 76)
            VStack(spacing: 4) {
                Text(application.role)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(application.companyAndLocation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            StatusBadge(status: application.status)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            CompanyAvatar.color(for: application.company).opacity(0.12),
            in: .rect(cornerRadius: 24)
        )
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Progress")
                .font(.headline)

            StageStepper(application: application) { stage in
                move(to: stage)
            }

            actions
        }
        .cardStyle()
    }

    /// The buttons under the stepper change with the status.
    @ViewBuilder
    private var actions: some View {
        VStack(spacing: 10) {
            if application.status == .offer {
                OfferBanner()
            }

            if let next = application.status.next {
                Button {
                    move(to: next)
                } label: {
                    Label("Move to \(next.title)", systemImage: next.systemImage)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(next.color)
                .controlSize(.large)
            }

            switch application.status {
            case .rejected:
                Button {
                    // Reopen at the stage it was at when the rejection came.
                    move(to: ApplicationStatus.pipeline[application.stage])
                } label: {
                    Label("Reopen", systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            case .offer:
                EmptyView()
            default:
                Button(role: .destructive) {
                    move(to: .rejected)
                } label: {
                    Text("Mark as rejected")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("History")
                .font(.headline)
                .padding(.bottom, 14)

            let entries = application.timeline
            ForEach(entries.indices, id: \.self) { index in
                HistoryRow(
                    entry: entries[index],
                    isLatest: index == 0,
                    isOldest: index == entries.count - 1
                )
            }
        }
        .cardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(application.notes)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private func move(to status: ApplicationStatus) {
        withAnimation(.snappy) {
            application.move(to: status)
        }
        try? modelContext.save()
    }
}

/// One step in the history: a colored icon, what happened, and when.
private struct HistoryRow: View {
    let entry: StatusChange
    let isLatest: Bool
    let isOldest: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: entry.status.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isLatest ? Color.white : entry.status.color)
                .frame(width: 28, height: 28)
                .background(isLatest ? entry.status.color : entry.status.color.opacity(0.15), in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.status.timelineTitle)
                    .font(.subheadline.weight(isLatest ? .semibold : .regular))
                Text(entry.date, format: .dateTime.day().month(.abbreviated).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, isOldest ? 0 : 20)

            Spacer(minLength: 0)
        }
        // The line joining this icon to the one below. A background is always
        // exactly as tall as the row, so the line fits however long the text is.
        .background(alignment: .topLeading) {
            if !isOldest {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 2)
                    .padding(.top, 30)
                    .padding(.leading, 13)
            }
        }
    }
}

/// Shown when the application reaches an offer. The icon bounces when it appears.
private struct OfferBanner: View {
    @State private var bounce = 0

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "party.popper.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: bounce)
            VStack(alignment: .leading, spacing: 2) {
                Text("You got an offer")
                    .font(.headline)
                Text("All that effort paid off.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.green.opacity(0.12), in: .rect(cornerRadius: 14))
        .task {
            bounce += 1
        }
    }
}

#Preview {
    NavigationStack {
        ApplicationDetailView(application: SampleData.previewApplication)
    }
    .modelContainer(SampleData.previewContainer)
}
