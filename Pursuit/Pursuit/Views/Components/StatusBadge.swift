import SwiftUI

/// A small colored pill showing an application's status.
struct StatusBadge: View {
    let status: ApplicationStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .imageScale(.small)
                // When the status changes, the old icon morphs into the new one.
                .contentTransition(.symbolEffect(.replace))
            Text(status.title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.15), in: .capsule)
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(ApplicationStatus.allCases) { status in
            StatusBadge(status: status)
        }
    }
}
