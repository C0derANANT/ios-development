import SwiftUI

/// A rounded square with the company's first letter, used in place of a logo.
///
/// The background color is derived from the company name, so the same company
/// always gets the same color on every launch.
struct CompanyAvatar: View {
    let name: String
    var size: CGFloat = 44

    private static let palette: [Color] = [.blue, .indigo, .purple, .pink, .orange, .teal, .green, .brown]

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Self.color(for: name).gradient, in: .rect(cornerRadius: size * 0.28))
            .accessibilityHidden(true)
    }

    private var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }

    /// Picks a palette color by adding up the name's character codes.
    ///
    /// Swift's built-in `hashValue` changes every time the app launches, so it
    /// can't be used here. A plain sum is stable across launches.
    static func color(for name: String) -> Color {
        let total = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[total % palette.count]
    }
}

#Preview {
    HStack {
        CompanyAvatar(name: "Swiggy")
        CompanyAvatar(name: "Razorpay")
        CompanyAvatar(name: "Zoho", size: 76)
        CompanyAvatar(name: "")
    }
}
