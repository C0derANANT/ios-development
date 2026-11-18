import SwiftData
import SwiftUI

/// A form, shown as a sheet, for adding a new application or editing one.
struct ApplicationFormView: View {
    /// The application being edited, or nil when adding a new one.
    let application: JobApplication?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var company: String
    @State private var role: String
    @State private var location: String
    @State private var status: ApplicationStatus
    @State private var dateApplied: Date
    @State private var notes: String
    @State private var isShowingSaveError = false

    /// Fills the form from `application` when editing, or leaves it blank when adding.
    ///
    /// `_company` (with the underscore) is the `@State` wrapper itself. Setting
    /// it here gives the field its starting value before the screen appears.
    init(application: JobApplication? = nil) {
        self.application = application
        _company = State(initialValue: application?.company ?? "")
        _role = State(initialValue: application?.role ?? "")
        _location = State(initialValue: application?.location ?? "")
        _status = State(initialValue: application?.status ?? .applied)
        _dateApplied = State(initialValue: application?.dateApplied ?? .now)
        _notes = State(initialValue: application?.notes ?? "")
    }

    /// Company and role are required; everything else is optional.
    private var canSave: Bool {
        !company.trimmed.isEmpty && !role.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Job") {
                    TextField("Company", text: $company)
                        .textInputAutocapitalization(.words)
                    TextField("Role", text: $role)
                        .textInputAutocapitalization(.words)
                    TextField("Location (optional)", text: $location)
                        .textInputAutocapitalization(.words)
                }

                Section("Progress") {
                    Picker("Status", selection: $status) {
                        ForEach(ApplicationStatus.allCases) { status in
                            Label(status.title, systemImage: status.systemImage)
                                .tag(status)
                        }
                    }
                    DatePicker(
                        status == .wishlist ? "Date saved" : "Date applied",
                        selection: $dateApplied,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                }

                Section("Notes") {
                    TextField("Referral, recruiter, salary range…", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(application == nil ? "New Application" : "Edit Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                }
            }
            .alert("Couldn't save this application", isPresented: $isShowingSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Nothing was lost from the form. Please try again.")
            }
        }
    }

    private func save() {
        if let application {
            application.company = company.trimmed
            application.role = role.trimmed
            application.location = location.trimmed
            application.notes = notes.trimmed
            // Goes through move(to:) so a status change lands in the history.
            application.move(to: status)
            application.setDateApplied(dateApplied)
        } else {
            let application = JobApplication(
                company: company.trimmed,
                role: role.trimmed,
                location: location.trimmed,
                status: status,
                dateApplied: dateApplied,
                notes: notes.trimmed
            )
            modelContext.insert(application)
        }

        // SwiftData autosaves on its own schedule, so a crash or force-quit
        // right after tapping Save could lose the entry. Write to disk now.
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            isShowingSaveError = true
        }
    }
}

private extension String {
    /// The string without leading or trailing spaces and newlines.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview("Add") {
    ApplicationFormView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}

#Preview("Edit") {
    ApplicationFormView(application: SampleData.previewApplication)
        .modelContainer(SampleData.previewContainer)
}
