import SwiftUI

extension View {
    /// A rounded panel that stands out from the grey screen background.
    ///
    /// `secondarySystemGroupedBackground` is white in light mode and dark grey
    /// in dark mode, so cards stay visible in both.
    func cardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: cornerRadius))
    }
}

/// Shrinks a button slightly while your finger is on it, so cards feel pressable.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
