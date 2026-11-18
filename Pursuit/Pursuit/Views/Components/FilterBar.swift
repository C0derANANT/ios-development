import SwiftUI

/// A sideways-scrolling row of chips that filters the list by status.
///
/// `selection` is `nil` for "All". It's a `@Binding`: this view doesn't own the
/// value, it reads and writes the one that belongs to the home screen.
struct FilterBar: View {
    @Binding var selection: ApplicationStatus?
    let counts: [ApplicationStatus: Int]
    let total: Int

    /// Lets the colored highlight slide from one chip to the next instead of
    /// jumping. See `matchedGeometryEffect` below.
    @Namespace private var highlight

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                chip(title: "All", count: total, value: nil)
                ForEach(ApplicationStatus.allCases) { status in
                    chip(title: status.title, count: counts[status, default: 0], value: status)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func chip(title: String, count: Int, value: ApplicationStatus?) -> some View {
        let isSelected = selection == value

        return Button {
            withAnimation(.snappy) {
                selection = value
            }
        } label: {
            HStack(spacing: 6) {
                Text(title)
                Text(count, format: .number)
                    .opacity(isSelected ? 0.8 : 0.5)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill((value?.color ?? .accentColor).gradient)
                        .matchedGeometryEffect(id: "highlight", in: highlight)
                } else {
                    Capsule()
                        .fill(Color(.secondarySystemGroupedBackground))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selection: ApplicationStatus?

    FilterBar(selection: $selection, counts: [.applied: 3, .interviewing: 1], total: 4)
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
}
