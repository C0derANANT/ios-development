import SwiftData
import SwiftUI

/// The home screen: every application as a list or a pipeline board, with
/// search, sorting, and the add button.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    /// Every application in the database. Sorting happens below, in memory,
    /// because "recently updated" isn't a stored column SwiftData can sort by.
    @Query private var applications: [JobApplication]

    /// `@AppStorage` is `@State` that survives quitting the app: the value is
    /// saved in UserDefaults, a small settings file the app keeps on the phone.
    @AppStorage("homeLayout") private var layout = HomeLayout.list
    @AppStorage("sortOrder") private var sort = ApplicationSort.dateApplied

    /// The status chip that's selected, or nil for "All". List layout only.
    @State private var filter: ApplicationStatus?
    @State private var searchText = ""
    /// The screens pushed on top of this one. Appending opens a detail screen.
    @State private var path: [JobApplication] = []
    @State private var isShowingAddSheet = false
    /// Goes up by one on every stage change. A haptic tap fires when it changes.
    @State private var moveCount = 0

    /// Connects each card to its detail screen for the zoom animation.
    @Namespace private var zoom

    /// Applications matching the search box, in the chosen order.
    private var searchResults: [JobApplication] {
        sort.sorted(applications.filter { $0.matches(searchText) })
    }

    /// Search results narrowed down by the selected chip.
    private var visibleApplications: [JobApplication] {
        guard let filter else { return searchResults }
        return searchResults.filter { $0.status == filter }
    }

    /// How many search results are in each status, for the chip numbers.
    private var counts: [ApplicationStatus: Int] {
        Dictionary(grouping: searchResults, by: \.status).mapValues(\.count)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if applications.isEmpty {
                    emptyState
                } else {
                    switch layout {
                    case .list:
                        listLayout
                    case .board:
                        if searchResults.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        } else {
                            BoardView(applications: searchResults, zoom: zoom, onOpen: open, onMove: move)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .animation(.snappy, value: sort)
            .navigationTitle("Pursuit")
            .searchable(text: $searchText, prompt: "Company, role or location")
            .toolbar { toolbarContent }
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

    // MARK: - List layout

    private var listLayout: some View {
        List {
            Group {
                StatsHeader(applications: applications)
                    .padding(.horizontal, 16)
                FilterBar(selection: $filter, counts: counts, total: searchResults.count)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            ForEach(visibleApplications) { application in
                card(for: application)
            }

            if visibleApplications.isEmpty {
                Group {
                    if !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else if let filter {
                        ContentUnavailableView(
                            "Nothing in \(filter.title)",
                            systemImage: filter.systemImage,
                            description: Text("When an application reaches \(filter.title), it shows up here.")
                        )
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// One card, plus everything you can do to it: tap, swipe, long-press.
    private func card(for application: JobApplication) -> some View {
        Button {
            open(application)
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

    // MARK: - Toolbar and empty state

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                // A Picker inside a Menu shows as a list of options with a
                // checkmark next to the current one.
                Picker("Sort by", selection: $sort) {
                    ForEach(ApplicationSort.allCases) { option in
                        Label(option.title, systemImage: option.systemImage)
                            .tag(option)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(layout.toggleTitle, systemImage: layout.toggleSystemImage) {
                withAnimation(.snappy) {
                    layout = layout.toggled
                }
            }
            Button("Add application", systemImage: "plus") {
                isShowingAddSheet = true
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

    // MARK: - Actions

    private func open(_ application: JobApplication) {
        path.append(application)
    }

    private func move(_ application: JobApplication, to status: ApplicationStatus) {
        guard application.status != status else { return }
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
    HomeView()
        .modelContainer(SampleData.previewContainer)
}

#Preview("Empty") {
    HomeView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
