import SwiftUI

/// The four pipeline stages as dots joined by a line. Tap any dot to jump there.
///
/// Each stage is a column of equal width: a dot with a half-line on each side,
/// and its name underneath. Side by side, the half-lines join into one line.
struct StageStepper: View {
    let application: JobApplication
    let onSelect: (ApplicationStatus) -> Void

    private let stages = ApplicationStatus.pipeline

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                column(for: index)
            }
        }
        .animation(.snappy, value: application.status)
    }

    private func column(for index: Int) -> some View {
        let columnStatus = stages[index]
        let currentIndex = application.stage
        let isRejected = application.status == .rejected
        // The big dot: the current stage, or where a rejected application stopped.
        let isCurrent = index == currentIndex
        let isPassed = index < currentIndex
        let tint = application.status.color

        let systemImage = if isCurrent && isRejected {
            ApplicationStatus.rejected.systemImage
        } else if isPassed {
            "checkmark"
        } else {
            columnStatus.systemImage
        }

        return VStack(spacing: 8) {
            HStack(spacing: 0) {
                line(color: index <= currentIndex ? tint : Color(.systemFill))
                    .opacity(index == 0 ? 0 : 1)
                Button {
                    onSelect(columnStatus)
                } label: {
                    dot(systemImage: systemImage, isCurrent: isCurrent, isPassed: isPassed, tint: tint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(columnStatus.title)
                .accessibilityAddTraits(isCurrent ? .isSelected : [])
                line(color: index + 1 <= currentIndex ? tint : Color(.systemFill))
                    .opacity(index == stages.count - 1 ? 0 : 1)
            }

            Text(columnStatus.title)
                .font(.caption.weight(isCurrent ? .semibold : .regular))
                .foregroundStyle(isCurrent ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func dot(systemImage: String, isCurrent: Bool, isPassed: Bool, tint: Color) -> some View {
        let fill: Color = isCurrent ? tint : isPassed ? tint.opacity(0.18) : Color(.systemFill)
        let iconColor: Color = isCurrent ? .white : isPassed ? tint : .secondary
        let size: CGFloat = isCurrent ? 40 : 30

        return Image(systemName: systemImage)
            .font(.system(size: isCurrent ? 16 : 12, weight: .semibold))
            .foregroundStyle(iconColor)
            .frame(width: size, height: size)
            .background(fill, in: .circle)
            // A fixed outer frame keeps every column the same height, so the
            // labels line up even though the current dot is bigger.
            .frame(width: 40, height: 40)
            .contentShape(.circle)
    }

    private func line(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(height: 3)
    }
}

#Preview {
    VStack(spacing: 32) {
        ForEach(SampleData.makeApplications()) { application in
            StageStepper(application: application) { _ in }
        }
    }
    .padding()
}
