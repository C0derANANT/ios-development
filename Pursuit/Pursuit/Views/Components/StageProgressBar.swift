import SwiftUI

/// Four short bars showing how far an application has moved along the pipeline.
///
/// A rejected application keeps its bars (in red), so you can still see that
/// it got to interviews before it ended.
struct StageProgressBar: View {
    let application: JobApplication

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ApplicationStatus.pipeline.indices, id: \.self) { index in
                Capsule()
                    .fill(index <= application.stage ? application.status.color : Color(.systemFill))
                    .frame(width: 22, height: 5)
            }
        }
        .animation(.snappy, value: application.status)
        .accessibilityElement()
        .accessibilityLabel("Stage \(application.stage + 1) of \(ApplicationStatus.pipeline.count)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(SampleData.makeApplications()) { application in
            StageProgressBar(application: application)
        }
    }
}
