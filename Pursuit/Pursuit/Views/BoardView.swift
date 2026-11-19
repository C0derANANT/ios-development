import SwiftData
import SwiftUI

/// The pipeline board: one lane per stage. Long-press a card and drag it into
/// another lane to move the application to that stage.
///
/// The board doesn't save or navigate by itself. It reports what happened
/// through `onOpen` and `onMove`, and the home screen does the work, so the
/// list and the board share one copy of that code.
struct BoardView: View {
    let applications: [JobApplication]
    /// Shared with the home screen so cards zoom into the detail screen.
    let zoom: Namespace.ID
    let onOpen: (JobApplication) -> Void
    let onMove: (JobApplication, ApplicationStatus) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(ApplicationStatus.allCases) { status in
                    BoardLane(
                        status: status,
                        applications: applications.filter { $0.status == status },
                        zoom: zoom,
                        onOpen: onOpen,
                        onDrop: { dragID in drop(dragID, on: status) }
                    )
                }

                Label("Long-press a card, then drag it to another stage", systemImage: "hand.draw")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    /// Finds the dragged application by its ID and moves it to `status`.
    /// Returns false if nothing matched, which tells iOS the drop failed.
    private func drop(_ dragID: String, on status: ApplicationStatus) -> Bool {
        guard !dragID.isEmpty,
              let application = applications.first(where: { $0.dragID == dragID })
        else { return false }

        onMove(application, status)
        return true
    }
}

/// One stage: a colored header and a sideways-scrolling row of cards.
private struct BoardLane: View {
    let status: ApplicationStatus
    let applications: [JobApplication]
    let zoom: Namespace.ID
    let onOpen: (JobApplication) -> Void
    let onDrop: (String) -> Bool

    /// True while a dragged card is hovering over this lane.
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.horizontal, 14)

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    if applications.isEmpty {
                        placeholder
                    }
                    ForEach(applications) { application in
                        Button {
                            onOpen(application)
                        } label: {
                            BoardCard(application: application)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .matchedTransitionSource(id: application.id, in: zoom)
                        // Long-press lifts the card. What travels with it is
                        // only the text ID, plus a picture of the card.
                        .draggable(application.dragID) {
                            BoardCard(application: application)
                        }
                    }
                }
                .padding(.horizontal, 14)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 10)
        .background(status.color.opacity(isTargeted ? 0.25 : 0.08), in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(status.color, lineWidth: isTargeted ? 2 : 0)
        }
        .scaleEffect(isTargeted ? 1.02 : 1)
        .animation(.snappy, value: isTargeted)
        // The whole lane accepts drops of text. `isTargeted` turns on while a
        // card hovers over it, which lights the lane up.
        .dropDestination(for: String.self) { items, _ in
            guard let dragID = items.first else { return false }
            return onDrop(dragID)
        } isTargeted: { hovering in
            isTargeted = hovering
        }
        .sensoryFeedback(.selection, trigger: isTargeted) { _, hovering in hovering }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: status.systemImage)
            Text(status.title)
                .font(.subheadline.weight(.semibold))
            Text(applications.count, format: .number)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(status.color.opacity(0.15), in: .capsule)
                .contentTransition(.numericText(value: Double(applications.count)))
            Spacer()
        }
        .foregroundStyle(status.color)
    }

    /// Shown in an empty lane, the same size as a card so lanes don't shrink.
    private var placeholder: some View {
        Text("Drop here")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(width: BoardCard.width, height: BoardCard.height)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
    }
}

private extension JobApplication {
    /// The application's database ID written out as text.
    ///
    /// Drag and drop can only carry data that could leave the app (text,
    /// images, files), never a live Swift object. So a card carries this
    /// text, and the lane it lands on looks the application back up by it.
    /// `.sortedKeys` makes the same ID always produce the same text.
    var dragID: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        guard let data = try? encoder.encode(persistentModelID) else { return "" }
        return String(decoding: data, as: UTF8.self)
    }
}

#Preview {
    @Previewable @Namespace var zoom

    BoardView(
        applications: SampleData.makeApplications(),
        zoom: zoom,
        onOpen: { _ in },
        onMove: { application, status in application.move(to: status) }
    )
    .background(Color(.systemGroupedBackground))
}
