import SwiftUI

extension Color {
    /// Linux Command Library brand red (#e45151)
    static let brandRed = Color(red: 0xE4 / 255.0, green: 0x51 / 255.0, blue: 0x51 / 255.0)
}

extension Font {
    /// Share Tech Mono — bundled custom font for command/code rendering.
    /// PostScript name verified at runtime; falls back to monospaced system font.
    static func shareTechMono(size: CGFloat) -> Font {
        Font.custom("ShareTechMono-Regular", size: size)
    }
}
