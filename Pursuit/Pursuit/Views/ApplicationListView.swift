import SwiftData
import SwiftUI

/// The home screen: headline stats, status filters, and every application as a card.
struct ApplicationListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \JobApplication.dateApplied, order: .reverse)
    private var applications: [JobApplication]

    /// The status chip that's selected, or nil for "All".
    @State private var filter: ApplicationStatus?
    /// The screens pushed on top of this one. Appending opens a detail screen.
    @State private var path: [JobApplication] = []
    @State private var isShowingAddSheet = false
    /// Goes up by one on every stage change. A haptic tap fires when it changes.
    @State private var moveCount = 0

    /// Connects each card to its detail screen for the zoom animation.
    @Namespace private var zoom

    private var visibleApplications: [JobApplication] {
        guard let filter else { return applications }
        return applications.filter { $0.status == filter }
    }

    /// How many applications are in each status, for the chip numbers.
    private var counts: [ApplicationStatus: Int] {
        Dictionary(grouping: applications, by: \.status).mapValues(\.count)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !applications.isEmpty {
                    Group {
                        StatsHeader(applications: applications)
                            .padding(.horizontal, 16)
                        FilterBar(selection: $filter, counts: counts, total: applications.count)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                ForEach(visibleApplications) { application in
                    card(for: application)
                }

                if let filter, visibleApplications.isEmpty, !applications.isEmpty {
                    ContentUnavailableView(
                        "Nothing in \(filter.title)",
                        systemImage: filter.systemImage,
                        description: Text("When an application reaches \(filter.title), it shows up here.")
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .overlay {
                if applications.isEmpty {
                    emptyState
                }
            }
            .navigationTitle("Pursuit")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add application", systemImage: "plus") {
                        isShowingAddSheet = true
                    }
                }
            }
            .navigationDestination(for: JobApplication.self) { application in
                ApplicationDetailView(application: application)
                    .navigationTransition(.zoom(sourceID: application.id, in: zoom))
            }
            .sheet(isPresented: $isShowingAddSheet) {
                ApplicationFormView()
            }
            .sensoryFeedback(.success, trigger: moveCount)
        }
    }

    /// One card, plus everything you can do to it: tap, swipe, long-press.
    private func card(for application: JobApplication) -> some View {
        Button {
            path.append(application)
        } label: {
            ApplicationCard(application: application)
        }
        .buttonStyle(PressableButtonStyle())
        // Clips the long-press preview to the card's rounded corners.
        .contentShape(.contextMenuPreview, .rect(cornerRadius: 18))
        .matchedTransitionSource(id: application.id, in: zoom)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        // Swipe right: move to the next stage. A long swipe does it in one go.
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if let next = application.status.next {
                Button(next.title, systemImage: next.systemImage) {
                    move(application, to: next)
                }
                .tint(next.color)
            }
        }
        // Swipe left: delete, or mark as rejected.
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete(application)
            }
            if application.status != .rejected {
                Button("Reject", systemImage: ApplicationStatus.rejected.systemImage) {
                    move(application, to: .rejected)
                }
                .tint(.gray)
            }
        }
        // Long-press: jump to any stage.
        .contextMenu {
            Menu {
                ForEach(ApplicationStatus.allCases) { status in
                    Button(status.title, systemImage: status.systemImage) {
                        move(application, to: status)
                    }
                    .disabled(status == application.status)
                }
            } label: {
                Label("Move to", systemImage: "arrow.right.circle")
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete(application)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Start your pursuit", systemImage: "briefcase")
        } description: {
            Text("Log every job you apply to, then watch each one move from applied to offer.")
        } actions: {
            Button("Add your first application") {
                isShowingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func move(_ application: JobApplication, to status: ApplicationStatus) {
        withAnimation(.snappy) {
            application.move(to: status)
        }
        try? modelContext.save()
        moveCount += 1
    }

    private func delete(_ application: JobApplication) {
        withAnimation {
            modelContext.delete(application)
        }
        // Write the deletion to disk now. If this fails, the deletion stays
        // pending and SwiftData's autosave retries it later.
        try? modelContext.save()
    }
}

#Preview("With data") {
    ApplicationListView()
        .modelContainer(SampleData.previewContainer)
}

#Preview("Empty") {
    ApplicationListView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
