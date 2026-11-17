import SwiftUI

/// A rounded square with the company's first letter, used in place of a logo.
///
/// The background color is derived from the company name, so the same company
/// always gets the same color on every launch.
struct CompanyAvatar: View {
    let name: String

    private static let palette: [Color] = [.blue, .indigo, .purple, .pink, .orange, .teal, .green, .brown]

    var body: some View {
        Text(initial)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(color.gradient, in: .rect(cornerRadius: 10))
            .accessibilityHidden(true)
    }

    private var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }

    /// Picks a palette color by adding up the name's character codes.
    ///
    /// Swift's built-in `hashValue` changes every time the app launches, so it
    /// can't be used here. A plain sum is stable across launches.
    private var color: Color {
        let total = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palette[total % Self.palette.count]
    }
}

#Preview {
    HStack {
        CompanyAvatar(name: "Swiggy")
        CompanyAvatar(name: "Razorpay")
        CompanyAvatar(name: "Zoho")
        CompanyAvatar(name: "")
    }
}
