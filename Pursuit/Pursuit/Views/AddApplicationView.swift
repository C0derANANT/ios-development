import SwiftData
import SwiftUI

/// A form, shown as a sheet, for logging a new application.
struct AddApplicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var company = ""
    @State private var role = ""
    @State private var location = ""
    @State private var status = ApplicationStatus.applied
    @State private var dateApplied = Date.now
    @State private var notes = ""
    @State private var isShowingSaveError = false

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
            .navigationTitle("New Application")
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
        let application = JobApplication(
            company: company.trimmed,
            role: role.trimmed,
            location: location.trimmed,
            status: status,
            dateApplied: dateApplied,
            notes: notes.trimmed
        )
        modelContext.insert(application)

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

#Preview {
    AddApplicationView()
        .modelContainer(for: JobApplication.self, inMemory: true)
}
