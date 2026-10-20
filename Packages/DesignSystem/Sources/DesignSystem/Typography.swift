import SwiftUI

public struct TextStyle: Sendable {
    let font: Font
}

public extension TextStyle {
    static let title = TextStyle(font: .headline)
    static let body = TextStyle(font: .body)
    static let bodySmall = TextStyle(font: .subheadline)
    static let footnote = TextStyle(font: .footnote)
    static let caption = TextStyle(font: .caption)
    static let captionStrong = TextStyle(font: .caption.weight(.semibold))
    static let captionSmall = TextStyle(font: .caption2)
}

public extension View {
    func textStyle(_ style: TextStyle) -> some View {
        font(style.font)
    }
}
