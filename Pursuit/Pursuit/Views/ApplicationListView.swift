import SwiftData
import SwiftUI

/// The home screen: every tracked application, newest first.
struct ApplicationListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \JobApplication.dateApplied, order: .reverse)
    private var applications: [JobApplication]

    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(applications) { application in
                    ApplicationRowView(application: application)
                }
                .onDelete(perform: deleteApplications)
            }
            .overlay {
                if applications.isEmpty {
                    ContentUnavailableView(
                        "No applications yet",
                        systemImage: "briefcase",
                        description: Text("Tap + to log the first job you applied to.")
                    )
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
            .sheet(isPresented: $isShowingAddSheet) {
                AddApplicationView()
            }
        }
    }

    /// Called by swipe-to-delete. `offsets` holds the row positions to remove.
    private func deleteApplications(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(applications[index])
        }
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
