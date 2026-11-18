import SwiftUI

/// Three headline numbers at the top of the home screen.
struct StatsHeader: View {
    let applications: [JobApplication]

    private var sentCount: Int {
        applications.filter(\.wasSent).count
    }

    private var interviewCount: Int {
        applications.filter { $0.stage >= 2 }.count
    }

    /// Share of sent applications that got any reply, from 0 to 1.
    private var replyRate: Double {
        guard sentCount > 0 else { return 0 }
        return Double(applications.filter(\.hasResponse).count) / Double(sentCount)
    }

    var body: some View {
        HStack(spacing: 10) {
            StatTile(value: Double(sentCount), text: "\(sentCount)", label: "Applied") {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.blue)
            }
            StatTile(value: Double(interviewCount), text: "\(interviewCount)", label: "Interviews") {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.orange)
            }
            StatTile(
                value: replyRate,
                text: sentCount == 0 ? "–" : replyRate.formatted(.percent.precision(.fractionLength(0))),
                label: "Reply rate"
            ) {
                ProgressRing(progress: replyRate)
            }
        }
    }
}

/// One number with a small icon above it and a label below.
///
/// `Icon` is a generic: each tile decides what to draw on top (an SF Symbol
/// or the progress ring) without needing a separate tile type for each.
private struct StatTile<Icon: View>: View {
    let value: Double
    let text: String
    let label: String
    @ViewBuilder let icon: Icon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            icon
                .font(.subheadline)
                .frame(height: 18)
            Text(text)
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)
                // Digits roll up or down when the number changes.
                .contentTransition(.numericText(value: value))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle(padding: 12, cornerRadius: 16)
        .animation(.snappy, value: value)
        .accessibilityElement(children: .combine)
    }
}

/// A small circle that fills clockwise as `progress` goes from 0 to 1.
private struct ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemFill), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                // Shapes start drawing at 3 o'clock; turn it to start at 12.
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 16, height: 16)
    }
}

#Preview {
    StatsHeader(applications: SampleData.makeApplications())
        .padding()
        .background(Color(.systemGroupedBackground))
}
